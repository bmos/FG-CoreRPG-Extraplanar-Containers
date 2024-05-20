--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--

-- luacheck: globals onFilter

-- function is run on each inventory item. return true = visible, return false = hidden.
function onFilter(w)
	local nodeWindow = w.getDatabaseNode()

	local _, sLocNode = DB.getValue(nodeWindow, 'locationshortcut')
	local nodeContainer = DB.findNode(sLocNode or '')
	if not nodeContainer then
		DB.deleteChild(nodeWindow, 'locationshortcut')
		return true
	end

	-- Make sure shortcuts go to the right item
	local sContainerName = DB.getValue(nodeContainer, 'name', ''):gsub('%[%+%]%s', '')
	local sItemLoc = DB.getValue(nodeWindow, 'location', '')
	if string.lower(sContainerName) ~= string.lower(sItemLoc) then
		DB.deleteChild(nodeWindow, 'locationshortcut')
		return true
	end

	local _, sContainerLocNode = DB.getValue(nodeContainer, 'locationshortcut')
	if DB.getValue(nodeContainer, 'name', ''):match('%[%+%]%s') then
		return false
	elseif sContainerLocNode then -- if container is inside another container (max one level deep).
		local nodeContainerContainer = DB.findNode(sContainerLocNode)
		if DB.getValue(nodeContainerContainer, 'name', ''):match('%[%+%]%s') then
			return false
		end
	end
	return true
end
