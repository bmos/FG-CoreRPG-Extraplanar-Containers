--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--

-- luacheck: globals onDoubleClick onLoseFocus ExtraplanarContainers.tAnnounce

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

	window.windowlist.updateContainers()
	return true
end

function onLoseFocus()
	super.onLoseFocus()
	window.windowlist.updateContainers()
end

-- everything below here is responsible for setting the weight to red if the container is overfull

local function tooltip(node)
	local sNodeName = DB.getName(node)
	if not sNodeName or not ExtraplanarContainers.tAnnounce[sNodeName] then return end
	return string.format(Interface.getString('item_tooltip_overfull'), ExtraplanarContainers.tAnnounce[sNodeName]['sDesc'])
		.. '\n'
		.. DB.getValue(node, '..' .. ExtraplanarContainers.tAnnounce[sNodeName]['sNodeName'], 'unknown')
		.. ' > '
		.. DB.getValue(node, '..' .. ExtraplanarContainers.tAnnounce[sNodeName]['sMaxNodeName'], 'unknown')
end

local function setWindowcontrolColors(node, sFrame)
	local sTooltip = tooltip(node)
	if not sTooltip then return end

	window.weight.setTooltipText(sTooltip)

	if sFrame then window.weight.setFrame(sFrame, 7, 5, 7, 5) end
end

local function onAnnounced(_, child) setWindowcontrolColors(child, 'fieldrequired') end

local function onUnannounced(source) setWindowcontrolColors(source, 'fielddark') end

function onInit()
	if super and super.onInit then super.onInit() end
	local nodeItem = window.getDatabaseNode()
	local sItemPath = DB.getPath(nodeItem)
	for sNodeName, _ in pairs(ExtraplanarContainers.tAnnounce) do
		local sEncumbranceAnnouncePath = sItemPath .. '.' .. sNodeName
		setWindowcontrolColors(DB.findNode(sEncumbranceAnnouncePath))
		DB.addHandler(sEncumbranceAnnouncePath, 'onUpdate', onUnannounced)
	end
	DB.addHandler(sItemPath, 'onChildAdded', onAnnounced)
	DB.addHandler(sItemPath .. '.*', 'onDelete', onUnannounced)
end

function onClose()
	if super and super.onClose then super.onClose() end
	local nodeItem = window.getDatabaseNode()
	local sItemPath = DB.getPath(nodeItem)
	for sNodeName, _ in pairs(ExtraplanarContainers.tAnnounce) do
		local sEncumbranceAnnouncePath = sItemPath .. '.' .. sNodeName
		DB.removeHandler(sEncumbranceAnnouncePath, 'onUpdate', onUnannounced)
	end
	DB.removeHandler(sItemPath, 'onChildAdded', onAnnounced)
	DB.removeHandler(sItemPath .. '.*', 'onDelete', onUnannounced)
end
