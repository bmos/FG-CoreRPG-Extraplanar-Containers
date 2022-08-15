--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--

-- luacheck: globals onFilter

function onFilter(w)
	local nodeItem = w.getDatabaseNode();
	local _, sLocNode = DB.getValue(nodeItem, 'locationshortcut');
	if sLocNode then
		local nodeContainer = DB.findNode(sLocNode);
		if DB.getValue(nodeContainer, 'collapsedcontainer') == 'false' then
			return false;
		end
	end
	return true;
end