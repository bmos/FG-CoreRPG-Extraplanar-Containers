--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--

-- luacheck: globals onDoubleClick onLoseFocus

function onDoubleClick()
	local nodeItem = window.getDatabaseNode()
	local sName = DB.getValue(nodeItem, 'name', '')
	if not ExtraplanarContainers.isAnyContainer(sName) then return false end

	local sNonIDName = DB.getValue(nodeItem, 'nonid_name', '')
	if not sName:match('%[%+%]%s+') then
		DB.setValue(nodeItem, 'name', 'string', '[+] ' .. sName)
		DB.setValue(nodeItem, 'nonid_name', 'string', '[+] ' .. sNonIDName)
	else
		DB.setValue(nodeItem, 'name', 'string', sName:gsub('%[%+%]%s+', ''))
		DB.setValue(nodeItem, 'nonid_name', 'string', sNonIDName:gsub('%[%+%]%s+', ''))
	end
	return true
end

function onLoseFocus()
	super.onLoseFocus()
	window.windowlist.updateContainers()
end

-- everything below here is responsible for setting the weight to red if the container is overfull

local tTooltips = { ['announcedW'] = 'weight', ['announcedV'] = 'volume' }

local function onAnnounced(_, child)
	local sNodeName = DB.getName(child)
	if sNodeName == 'announcedW' or sNodeName == 'announcedV' then
		window.weight.setColor(ColorManager.COLOR_HEALTH_CRIT_WOUNDS)
		window.weight.setTooltipText(string.format(Interface.getString('item_tooltip_overfull'), tTooltips[sNodeName]))
	end
end

local function onUnannounced(source)
	local sNodeName = DB.getName(source)
	if sNodeName == 'announcedW' or sNodeName == 'announcedV' then
		window.weight.setColor(ColorManager.COLOR_FULL)
		window.weight.setTooltipText('')
	end
end

function onInit()
	local nodeWeightAnnounced = DB.getChild(window.getDatabaseNode(), 'announcedW')
	if nodeWeightAnnounced then onAnnounced(nil, nodeWeightAnnounced) end
	if super and super.onInit then super.onInit() end
	DB.addHandler(DB.getPath(window.getDatabaseNode()), 'onChildAdded', onAnnounced)
	DB.addHandler(DB.getPath(window.getDatabaseNode()) .. '.*', 'onDelete', onUnannounced)
end

function onClose()
	if super and super.onClose then super.onClose() end
	DB.removeHandler(DB.getPath(window.getDatabaseNode()), 'onChildAdded', onAnnounced)
	DB.removeHandler(DB.getPath(window.getDatabaseNode()) .. '.*', 'onDelete', onUnannounced)
end