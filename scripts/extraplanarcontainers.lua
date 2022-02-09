--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--

--	search terms for finding extraplanar containers
--	these containers will have their subtotals calculated
--	the weight of their contents will not be counted elsewhere
tExtraplanarContainers = {
	'quiver of ehlonna',
	'efficient quiver',
	'handy haversack',
	'portable hole',
	'extraplanar',
	'weightless',
	'of holding',
	'donkey',
	'horse',
	'mule'
	}
--	search terms for finding mundane containers
--	these containers will have their subtotals calculated
tContainers = {
	'container',
	'backpack',
	'satchel',
	'quiver',
	'chest',
	'purse',
	'pouch',
	'sack',
	'bag',
	'box'
	}

--	searches for provided sItemName in provided tTable.
--	the name doesn't have to be an exact match.
function isContainer(sItemName, tTable)
	if not sItemName or not tTable then return nil; end
	for _,v in pairs(tTable) do
		if string.find(sItemName, v) then
			return true
		end
	end
end

--	checks provided name against contents of two tables
--	returns true if either is a match
function isAnyContainer(sItemName)
	if sItemName and sItemName ~= '' then
		local sItemName = string.lower(sItemName)
		return isContainer(sItemName, tExtraplanarContainers) or isContainer(sItemName, tContainers)
	end
end

--	looks through provided charsheet for inventory items that are containers
--	if found, these are added to table_containers_extraplanar or table_containers_mundane as appropriate
local function build_containers(node_pc)
	local table_containers_mundane = {}
	local table_containers_extraplanar = {}
	for _,node_item in pairs(DB.getChildren(node_pc, 'inventorylist')) do
		local string_item_name = string.lower(DB.getValue(node_item, 'name', ''))
		local number_maxweight = DB.getValue(node_item, 'capacityweight', 0);

		local bisExtraplanar = isContainer(string_item_name, tExtraplanarContainers)
		local bisContainer = isContainer(string_item_name, tContainers)
		if bisExtraplanar then -- this creates an array keyed to the names of any detected extraplanar storage containers
			table_containers_extraplanar[string_item_name] = {
					['bTooBig'] = 0,
					['nMaxDepth'] = DB.getValue(node_item, 'internal_depth', 0),
					['nMaxLength'] = DB.getValue(node_item, 'internal_length', 0),
					['nMaxVolume'] = DB.getValue(node_item, 'internal_volume', 0),
					['nMaxWeight'] = number_maxweight,
					['nMaxWidth'] = DB.getValue(node_item, 'internal_width', 0),
					['nTotalVolume'] = 0,
					['nTotalWeight'] = 0,
					['nodeItem'] = node_item
				};
		elseif (bisContainer and not bisExtraplanar) then -- this creates an array keyed to the names of any detected mundane storage containers
			table_containers_mundane[string_item_name] = {
					['bTooBig'] = 0,
					['nMaxDepth'] = DB.getValue(node_item, 'internal_depth', 0),
					['nMaxLength'] = DB.getValue(node_item, 'internal_length', 0),
					['nMaxVolume'] = DB.getValue(node_item, 'internal_volume', 0),
					['nMaxWeight'] = number_maxweight,
					['nMaxWidth'] = DB.getValue(node_item, 'internal_width', 0),
					['nTotalVolume'] = 0,
					['nTotalWeight'] = 0,
					['nodeItem'] = node_item
				};
		end
	end

	return table_containers_mundane, table_containers_extraplanar
end

--	look at items in inventory and calculate their weight
--	items in extraplanar containers will only have weight added to container subtotal
--	items in mundane containers will have weight added to subtotal and encumbrance total
--	items in neither will have weight added to encumbrance total
local function measure_contents(node_pc, table_containers_mundane, table_containers_extraplanar)
	local number_total_weight = 0
	for _,node_item in pairs(DB.getChildren(node_pc, 'inventorylist')) do
		local state_item_carried = DB.getValue(node_item, 'carried', 0)
		if state_item_carried ~= 0 then
			local number_item_count = DB.getValue(node_item, 'count', 0);
			local number_item_weight = DB.getValue(node_item, 'weight', 0);
			local string_item_location = string.lower(DB.getValue(node_item, 'location', ''))
			
			local bIsInExtraplanar = isContainer(string_item_location, tExtraplanarContainers)
			local bIsInContainer = isContainer(string_item_location, tContainers)

			-- add up subtotals of container contents and put them in the table
			if state_item_carried ~= 2 and bIsInExtraplanar then
				if table_containers_extraplanar[string_item_location] then
					table_containers_extraplanar[string_item_location]['nTotalWeight'] = table_containers_extraplanar[string_item_location]['nTotalWeight'] + (number_item_count * number_item_weight)
					if OptionsManager.isOption('ITEM_VOLUME', 'on') then
						table_containers_extraplanar[string_item_location]['nTotalVolume'] = table_containers_extraplanar[string_item_location]['nTotalVolume'] + (number_item_count * DB.getValue(node_item, 'volume', 0))
						if table_containers_extraplanar[string_item_location]['nMaxLength'] < DB.getValue(node_item, 'length', 0) then table_containers_extraplanar[string_item_location]['bTooBig'] = 1 end
						if table_containers_extraplanar[string_item_location]['nMaxWidth'] < DB.getValue(node_item, 'width', 0) then table_containers_extraplanar[string_item_location]['bTooBig'] = 1 end
						if table_containers_extraplanar[string_item_location]['nMaxDepth'] < DB.getValue(node_item, 'depth', 0) then table_containers_extraplanar[string_item_location]['bTooBig'] = 1 end
					end
				end
			elseif state_item_carried ~= 2 and (bIsInContainer and not bIsInExtraplanar) then
				if table_containers_mundane[string_item_location] then
					table_containers_mundane[string_item_location]['nTotalWeight'] = table_containers_mundane[string_item_location]['nTotalWeight'] + (number_item_count * number_item_weight)
					if OptionsManager.isOption('ITEM_VOLUME', 'on') then
						table_containers_mundane[string_item_location]['nTotalVolume'] = table_containers_mundane[string_item_location]['nTotalVolume'] + (number_item_count * DB.getValue(node_item, 'volume', 0))
						if table_containers_mundane[string_item_location]['nMaxLength'] < DB.getValue(node_item, 'length', 0) then table_containers_mundane[string_item_location]['bTooBig'] = 1 end
						if table_containers_mundane[string_item_location]['nMaxWidth'] < DB.getValue(node_item, 'width', 0) then table_containers_mundane[string_item_location]['bTooBig'] = 1 end
						if table_containers_mundane[string_item_location]['nMaxDepth'] < DB.getValue(node_item, 'depth', 0) then table_containers_mundane[string_item_location]['bTooBig'] = 1 end
					end
					local string_item_location_location = string.lower(DB.getValue(table_containers_mundane[string_item_location]['nodeItem'], 'location', ''))
					if not table_containers_extraplanar[string_item_location_location] then
						number_total_weight = number_total_weight + (number_item_count * number_item_weight)
					else
						table_containers_extraplanar[string_item_location_location]['nTotalWeight'] = table_containers_extraplanar[string_item_location_location]['nTotalWeight'] + (number_item_count * number_item_weight)
					end
				end
			else
				number_total_weight = number_total_weight + (number_item_count * number_item_weight)
			end
		end
	end

	return number_total_weight
end

--	writes container subtotals to the relevant container
--	sends chat messages if containers are overfull
local function write_contents_to_containers(node_pc, table_containers, string_error)
	local rActor = ActorManager.resolveActor(node_pc)
	for _,table_container in pairs(table_containers) do
		DB.setValue(table_container['nodeItem'], 'extraplanarcontents', 'number', table_container['nTotalWeight'])
		DB.setValue(table_container['nodeItem'], 'contentsvolume', 'number', table_container['nTotalVolume'])
		local string_item_name = DB.getValue(table_container['nodeItem'], 'name', 'extraplanar container')

		-- check weight of contents and announce if excessive
		if table_container['nMaxWeight'] > 0 then
			if (table_container['nTotalWeight'] > table_container['nMaxWeight'])  then

				if not table_container['nodeItem'].getChild('announcedW') then
					DB.setValue(table_container['nodeItem'], 'announcedW', 'number', 1)
					ChatManager.Message(string.format(Interface.getString(string_error), string_item_name, 'weight'), true, rActor)
				end
			else
				if table_container['nodeItem'].getChild('announcedW') then table_container['nodeItem'].getChild('announcedW').delete() end
			end
		end

		-- check volume of contents and announce if excessive
		if OptionsManager.isOption('ITEM_VOLUME', 'on') and table_container['nMaxVolume'] > 0 then
			if table_container['bTooBig'] == 1 then
				if not table_container['nodeItem'].getChild('announcedV') then
					DB.setValue(table_container['nodeItem'], 'announcedV', 'number', 1)
					ChatManager.Message(string.format(Interface.getString(string_error), string_item_name, 'maximum dimension'), true, rActor)
				end
			elseif table_container['nTotalVolume'] > table_container['nMaxVolume'] then
				if not table_container['nodeItem'].getChild('announcedV') then
					DB.setValue(table_container['nodeItem'], 'announcedV', 'number', 1)
					ChatManager.Message(string.format(Interface.getString(string_error), string_item_name, 'volume'), true, rActor)
				end
			else
				if table_container['nodeItem'].getChild('announcedV') then table_container['nodeItem'].getChild('announcedV').delete() end
			end
		end
	end
end

local function coinWeight_2e(nodeChar)
	local nCoinWeight = 0;
	if not CoinsWeight and OptionsManager.getOption("OPTIONAL_ENCUMBRANCE_COIN") == "on" then
		nCoinWeight = nCoinWeight + DB.getValue(nodeChar, "coins.slot1.amount", 0);
		nCoinWeight = nCoinWeight + DB.getValue(nodeChar, "coins.slot2.amount", 0);
		nCoinWeight = nCoinWeight + DB.getValue(nodeChar, "coins.slot3.amount", 0);
		nCoinWeight = nCoinWeight + DB.getValue(nodeChar, "coins.slot4.amount", 0);
		nCoinWeight = nCoinWeight + DB.getValue(nodeChar, "coins.slot5.amount", 0);
		nCoinWeight = nCoinWeight + DB.getValue(nodeChar, "coins.slot6.amount", 0);

		nCoinWeight = nCoinWeight * DataCommonADND.nDefaultCoinWeight;
	end

	if OptionsManager.getOption("OPTIONAL_ENCUMBRANCE") == "on" then
		if DataCommonADND and DataCommonADND.coreVersion == "2e" then
			CharManager.updateMoveFromEncumbrance2e(nodeChar);
		else
			CharManager.updateMoveFromEncumbrance1e(nodeChar); 
		end
	else
		DB.setValue(nodeChar, "speed.basemodenc", "number", 0);
		DB.setValue(nodeChar, "speed.encumbrancerank", "string", "Normal");
	end

	return nCoinWeight
end

local function updateEncumbrance_new(node_char)
	-- assemble a list of containers and their capacities
	local table_containers_mundane, table_containers_extraplanar = build_containers(node_char)

	-- this will contain a running total of all items carried by the character
	local number_total = measure_contents(node_char, table_containers_mundane, table_containers_extraplanar) or 0

	-- writes container subtotals to database and handles chat messages
	write_contents_to_containers(node_char, table_containers_mundane, "item_overfull")
	write_contents_to_containers(node_char, table_containers_extraplanar, "item_self_destruct")

	-- ADND Coin Weight Compatibility
	if DataCommonADND then
		number_total = number_total + coinWeight_2e(node_char)
	end

	-- rounds total and writes to encumbrance field
	local number_rounded_total = number_total + 0.5 - (number_total + 0.5) % 1
	DB.setValue(node_char, 'encumbrance.load', 'number', number_rounded_total)
end

-- called when items have their locations changed
local function onLocationChanged(node)
	local node_char = node.getChild('....')
	CharManager.updateEncumbrance(node_char)
end

-- called when items have their dimensions changed
local function onDimensionsChanged(node)
	local node_char = node.getChild('....')
	CharManager.updateEncumbrance(node_char)
end

function onInit()
	OptionsManager.registerOption2('ITEM_VOLUME', false, 'option_header_game', 'opt_lab_item_volume', 'option_entry_cycler',
		{ labels = 'option_val_on',
		values = 'on',
		baselabel = 'option_val_off',
		baseval = 'off',
		default = 'off',
	})

	CharManager.updateEncumbrance = updateEncumbrance_new;

	if Session.IsHost then
		DB.addHandler(DB.getPath('charsheet.*.inventorylist.*.location'), 'onUpdate', onLocationChanged)
		DB.addHandler(DB.getPath('charsheet.*.inventorylist.*.length'), 'onUpdate', onDimensionsChanged)

		if OptionsManager.isOption('ITEM_VOLUME', 'on') then
			DB.addHandler(DB.getPath('charsheet.*.inventorylist.*.width'), 'onUpdate', onDimensionsChanged)
			DB.addHandler(DB.getPath('charsheet.*.inventorylist.*.depth'), 'onUpdate', onDimensionsChanged)
		end
	end
end
