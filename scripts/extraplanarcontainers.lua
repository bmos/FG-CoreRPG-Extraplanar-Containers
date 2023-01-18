--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--
--	search terms for finding extraplanar containers
--	these containers will have their subtotals calculated
--	the weight of their contents will not be counted elsewhere
--	luacheck: globals tExtraplanarContainers
tExtraplanarContainers = {
	'knapsack of halflingkind',
	'quiver of ehlonna',
	'efficient quiver',
	'handy haversack',
	'portable hole',
	'extraplanar',
	'weightless',
	'of holding',
	'donkey',
	'horse',
	'mule',
}
--	search terms for finding mundane containers
--	these containers will have their subtotals calculated
--	luacheck: globals tContainers
tContainers = { 'container', 'backpack', 'satchel', 'quiver', 'chest', 'purse', 'pouch', 'sack', 'bag', 'box' }

--- This function figures out how many decimal places to round to.
--	If the total weight is greater than or equal to 100, it recommends 0 (whole numbers).
--	If it's greater than or equal to 10, it recommends 1.
--	If it's greater than or equal to 1, it recommends 2.
--	Otherwise, it recommends 3.
--	This maximizes difficulty at low levels when it has the most impact.
--	The intent is to keep the number visible on the inventory list without clipping.
local function determineRounding(number)
	if number >= 100 then
		return 0
	elseif number >= 10 then
		return 1
	elseif number >= 1 then
		return 2
	else
		return 3
	end
end

-- luacheck: globals round
---	This function rounds to the specified number of decimals
function round(number)
	local n = 10 ^ (determineRounding(number) or 0)
	number = number * n
	if number >= 0 then
		number = math.floor(number + 0.5)
	else
		number = math.ceil(number - 0.5)
	end
	return number / n
end

--	searches for provided sItemName in provided tTable.
--	the name doesn't have to be an exact match.
local function isContainer(sItemName, tTable)
	if not sItemName or not tTable then return nil end
	for _, v in pairs(tTable) do
		if string.find(sItemName, v) then return true end
	end
end

--	checks provided name against contents of two tables
--	returns true if either is a match
--	luacheck: globals isAnyContainer
function isAnyContainer(sItemName)
	if sItemName and sItemName ~= '' then
		local sItemNameLower = string.lower(sItemName)
		return isContainer(sItemNameLower, tExtraplanarContainers) or isContainer(sItemNameLower, tContainers)
	end
end

--	looks through provided charsheet for inventory items that are containers
--	if found, these are added to table_containers_extraplanar or table_containers_mundane as appropriate
local function build_containers(node_inventory)
	local table_containers_mundane = {}
	local table_containers_extraplanar = {}
	for _, node_item in pairs(DB.getChildren(node_inventory)) do
		local string_item_name = string.lower(DB.getValue(node_item, 'name', '')):gsub('%[%+%]%s+', '')
		local number_maxweight = DB.getValue(node_item, 'capacityweight', 0)

		local bool_extraplanar = isContainer(string_item_name, tExtraplanarContainers)
		local bool_container = isContainer(string_item_name, tContainers)
		if bool_extraplanar then -- this creates an array keyed to the names of any detected extraplanar storage containers
			table_containers_extraplanar[string_item_name] = {
				['bTooBig'] = 0,
				['nMaxDepth'] = DB.getValue(node_item, 'internal_depth', 0),
				['nMaxLength'] = DB.getValue(node_item, 'internal_length', 0),
				['nMaxVolume'] = DB.getValue(node_item, 'internal_volume', 0),
				['nMaxWeight'] = number_maxweight,
				['nMaxWidth'] = DB.getValue(node_item, 'internal_width', 0),
				['nTotalVolume'] = 0,
				['nTotalWeight'] = 0,
				['nodeItem'] = node_item,
			}
		elseif bool_container and not bool_extraplanar then -- this creates an array keyed to the names of any detected mundane storage containers
			table_containers_mundane[string_item_name] = {
				['bTooBig'] = 0,
				['nMaxDepth'] = DB.getValue(node_item, 'internal_depth', 0),
				['nMaxLength'] = DB.getValue(node_item, 'internal_length', 0),
				['nMaxVolume'] = DB.getValue(node_item, 'internal_volume', 0),
				['nMaxWeight'] = number_maxweight,
				['nMaxWidth'] = DB.getValue(node_item, 'internal_width', 0),
				['nTotalVolume'] = 0,
				['nTotalWeight'] = 0,
				['nodeItem'] = node_item,
			}
		end
	end

	return table_containers_mundane, table_containers_extraplanar
end

--	writes container subtotals to the relevant container
--	sends chat messages if containers are overfull
local function write_contents_to_containers(node_inventory, table_containers, string_error)
	local rActor = ActorManager.resolveActor(DB.getParent(node_inventory))
	for _, table_container in pairs(table_containers) do
		DB.setValue(table_container['nodeItem'], 'extraplanarcontents', 'number', round(table_container['nTotalWeight']))
		DB.setValue(table_container['nodeItem'], 'contentsvolume', 'number', round(table_container['nTotalVolume']))
		local string_item_name = DB.getValue(table_container['nodeItem'], 'name', 'extraplanar container')
		local messagedata = { text = '', sender = rActor.sName, font = 'emotefont' }

		-- check weight of contents and announce if excessive
		if table_container['nMaxWeight'] > 0 then
			if table_container['nTotalWeight'] > table_container['nMaxWeight'] then
				if not DB.getChild(table_container['nodeItem'], 'announcedW') then
					DB.setValue(table_container['nodeItem'], 'announcedW', 'number', 1)
					messagedata.text = string.format(Interface.getString(string_error), string_item_name, 'weight')
					Comm.deliverChatMessage(messagedata)
				end
			else
				if DB.getChild(table_container['nodeItem'], 'announcedW') then DB.deleteChild(table_container['nodeItem'], 'announcedW') end
			end
		end

		-- check volume of contents and announce if excessive
		if OptionsManager.isOption('ITEM_VOLUME', 'on') and table_container['nMaxVolume'] > 0 then
			if table_container['bTooBig'] == 1 then
				if not table_container['nodeItem'].getChild('announcedV') then
					DB.setValue(table_container['nodeItem'], 'announcedV', 'number', 1)
					messagedata.text = string.format(Interface.getString(string_error), string_item_name, 'maximum dimension')
					Comm.deliverChatMessage(messagedata)
				end
			elseif table_container['nTotalVolume'] > table_container['nMaxVolume'] then
				if not table_container['nodeItem'].getChild('announcedV') then
					DB.setValue(table_container['nodeItem'], 'announcedV', 'number', 1)
					messagedata.text = string.format(Interface.getString(string_error), string_item_name, 'volume')
					Comm.deliverChatMessage(messagedata)
				end
			else
				if DB.getChild(table_container['nodeItem'], 'announcedV') then DB.deleteChild(table_container['nodeItem'], 'announcedV') end
			end
		end
	end
end

--	look at items in inventory and calculate their weight
--	items in extraplanar containers will only have weight added to container subtotal
--	items in mundane containers will have weight added to subtotal and encumbrance total
--	items in neither will have weight added to encumbrance total
local function measure_contents(node_inventory, table_containers_mundane, table_containers_extraplanar)
	local number_total_weight = 0
	for _, node_item in pairs(DB.getChildren(node_inventory)) do
		local string_item_location = string.lower(DB.getValue(node_item, 'location', '')):gsub('%[%+%]%s+', '')

		local bIsInExtraplanar = isContainer(string_item_location, tExtraplanarContainers)
		local bIsInContainer = isContainer(string_item_location, tContainers)

		-- add shortcut to location node
		if table_containers_extraplanar[string_item_location] or table_containers_mundane[string_item_location] then
			if bIsInExtraplanar and table_containers_extraplanar[string_item_location]['nodeItem'] then
				local sLocNode = table_containers_extraplanar[string_item_location]['nodeItem'].getPath()
				DB.setValue(node_item, 'locationshortcut', 'windowreference', 'item', sLocNode)
			elseif bIsInContainer and table_containers_mundane[string_item_location]['nodeItem'] then
				local sLocNode = table_containers_mundane[string_item_location]['nodeItem'].getPath()
				DB.setValue(node_item, 'locationshortcut', 'windowreference', 'item', sLocNode)
			elseif node_item.getChild('locationshortcut') then
				DB.deleteChild(node_item, 'locationshortcut') -- not sure if this ever runs
			end
		end

		local state_item_carried = DB.getValue(node_item, 'carried', 0)
		if state_item_carried ~= 0 then
			local number_item_weight = DB.getValue(node_item, 'weight', 0)
			local number_item_count = DB.getValue(node_item, 'count', 0)
				-- add up subtotals of container contents and put them in the table
			if state_item_carried ~= 2 and bIsInExtraplanar then
				if table_containers_extraplanar[string_item_location] then
					table_containers_extraplanar[string_item_location]['nTotalWeight'] = (
						table_containers_extraplanar[string_item_location]['nTotalWeight'] + (number_item_count * number_item_weight)
					)
					if OptionsManager.isOption('ITEM_VOLUME', 'on') then
						table_containers_extraplanar[string_item_location]['nTotalVolume'] = (
							table_containers_extraplanar[string_item_location]['nTotalVolume']
							+ (number_item_count * DB.getValue(node_item, 'volume', 0))
						)
						if table_containers_extraplanar[string_item_location]['nMaxLength'] < DB.getValue(node_item, 'length', 0) then
							table_containers_extraplanar[string_item_location]['bTooBig'] = 1
						end
						if table_containers_extraplanar[string_item_location]['nMaxWidth'] < DB.getValue(node_item, 'width', 0) then
							table_containers_extraplanar[string_item_location]['bTooBig'] = 1
						end
						if table_containers_extraplanar[string_item_location]['nMaxDepth'] < DB.getValue(node_item, 'depth', 0) then
							table_containers_extraplanar[string_item_location]['bTooBig'] = 1
						end
					end
				end
			elseif state_item_carried ~= 2 and (bIsInContainer and not bIsInExtraplanar) then
				if table_containers_mundane[string_item_location] then
					table_containers_mundane[string_item_location]['nTotalWeight'] = (
						table_containers_mundane[string_item_location]['nTotalWeight'] + (number_item_count * number_item_weight)
					)
					if OptionsManager.isOption('ITEM_VOLUME', 'on') then
						table_containers_mundane[string_item_location]['nTotalVolume'] = (
							table_containers_mundane[string_item_location]['nTotalVolume']
							+ (number_item_count * DB.getValue(node_item, 'volume', 0))
						)
						if table_containers_mundane[string_item_location]['nMaxLength'] < DB.getValue(node_item, 'length', 0) then
							table_containers_mundane[string_item_location]['bTooBig'] = 1
						end
						if table_containers_mundane[string_item_location]['nMaxWidth'] < DB.getValue(node_item, 'width', 0) then
							table_containers_mundane[string_item_location]['bTooBig'] = 1
						end
						if table_containers_mundane[string_item_location]['nMaxDepth'] < DB.getValue(node_item, 'depth', 0) then
							table_containers_mundane[string_item_location]['bTooBig'] = 1
						end
					end
					local string_item_location_location =
						string.lower(DB.getValue(table_containers_mundane[string_item_location]['nodeItem'], 'location', ''))
					if not table_containers_extraplanar[string_item_location_location] then
						number_total_weight = number_total_weight + (number_item_count * number_item_weight)
					else
						table_containers_extraplanar[string_item_location_location]['nTotalWeight'] = (
							table_containers_extraplanar[string_item_location_location]['nTotalWeight']
							+ (number_item_count * number_item_weight)
						)
					end
				end
			else
				number_total_weight = number_total_weight + (number_item_count * number_item_weight)
			end
		end
	end

	return number_total_weight
end

local function updateContainers(node_inventory)
	-- assemble a list of containers and their capacities
	local table_containers_mundane, table_containers_extraplanar = build_containers(node_inventory)

	-- this will contain a running total of all items carried by the character
	local number_total = measure_contents(node_inventory, table_containers_mundane, table_containers_extraplanar)

	-- writes container subtotals to database and handles chat messages
	write_contents_to_containers(node_inventory, table_containers_mundane, 'item_overfull')
	write_contents_to_containers(node_inventory, table_containers_extraplanar, 'item_self_destruct')

	return number_total or 0
end

--
--	TRIGGERING
--

-- called when items are deleted
local function onItemDeleted(node) updateContainers(DB.getParent(node)) end

-- called when items have their details changed
local function onItemUpdate(node) updateContainers(DB.getChild(node, '...')) end

--
--	FUNCTION REPLACEMENT
--

local function calcDefaultInventoryEncumbrance_new(node_char)
	local totalweight = 0
	for _, string_itemlist in pairs(ItemManager.getInventoryPaths('charsheet')) do
		local node_inventory = node_char.getChild(string_itemlist)
		if node_inventory then totalweight = totalweight + updateContainers(node_inventory) end
	end
	return totalweight
end

-- round intelligently rather than just down.
local function setDefaultEncumbranceValue_new(nodeChar, nEncumbrance)
	local sField = CharEncumbranceManager.getEncumbranceField()
	DB.setValue(nodeChar, sField, 'number', round(nEncumbrance))
end

-- Enable onFilter function in for char_invlist.lua
local onInventorySortUpdate_old
local function onInventorySortUpdate_new(cList, ...)
	onInventorySortUpdate_old(cList, ...)
	cList.applyFilter()
end

function onInit()
	OptionsManager.registerOption2(
		'ITEM_VOLUME',
		false,
		'option_header_game',
		'opt_lab_item_volume',
		'option_entry_cycler',
		{ labels = 'option_val_on', values = 'on', baselabel = 'option_val_off', baseval = 'off', default = 'off' }
	)

	CharEncumbranceManager.calcDefaultInventoryEncumbrance = calcDefaultInventoryEncumbrance_new
	CharEncumbranceManager.setDefaultEncumbranceValue = setDefaultEncumbranceValue_new

	onInventorySortUpdate_old = ItemManager.onInventorySortUpdate
	ItemManager.onInventorySortUpdate = onInventorySortUpdate_new

	if Session.IsHost then
		for _, sItemListNodeName in pairs(ItemManager.getInventoryPaths('charsheet')) do
			local sItemList = 'charsheet.*.' .. sItemListNodeName
			DB.addHandler(DB.getPath(sItemList .. '.*.capacityweight'), 'onUpdate', onItemUpdate)
			DB.addHandler(DB.getPath(sItemList .. '.*.location'), 'onUpdate', onItemUpdate)
			DB.addHandler(DB.getPath(sItemList .. '.*.name'), 'onUpdate', onItemUpdate)
			DB.addHandler(DB.getPath(sItemList .. '.*'), 'onChildDeleted', onItemDeleted)

			-- external size fields
			DB.addHandler(DB.getPath(sItemList .. '.*.length'), 'onUpdate', onItemUpdate)
			DB.addHandler(DB.getPath(sItemList .. '.*.width'), 'onUpdate', onItemUpdate)
			DB.addHandler(DB.getPath(sItemList .. '.*.depth'), 'onUpdate', onItemUpdate)

			-- internal size fields
			DB.addHandler(DB.getPath(sItemList .. '.*.internal_length'), 'onUpdate', onItemUpdate)
			DB.addHandler(DB.getPath(sItemList .. '.*.internal_width'), 'onUpdate', onItemUpdate)
			DB.addHandler(DB.getPath(sItemList .. '.*.internal_depth'), 'onUpdate', onItemUpdate)
		end
	end
end
