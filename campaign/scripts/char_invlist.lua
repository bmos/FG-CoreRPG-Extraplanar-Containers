--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--

-- luacheck: globals onFilter

-- function is run on each inventory item. return true = visible, return false = hidden.
function onFilter(w)
	local nodeItem = w.getDatabaseNode()
	local _, sLocNode = DB.getValue(nodeItem, 'locationshortcut')
	if sLocNode then
		local nodeContainer = DB.findNode(sLocNode)
		local _, sContainerLocNode = DB.getValue(nodeContainer, 'locationshortcut')
		if DB.getValue(nodeContainer, 'name', ''):match('%[%+%]%s+') then
			return false
		elseif sContainerLocNode then -- if container is inside another container (max one level deep).
			local nodeContainerContainer = DB.findNode(sContainerLocNode)
			if DB.getValue(nodeContainerContainer, 'name', ''):match('%[%+%]%s+') then return false end
		end
	end
	return true
end
