--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--

-- luacheck: globals onClickRelease onLoseFocus

function onClickRelease()
	if Input.isControlPressed() then
		local nodeItem = window.getDatabaseNode()
		if DB.getValue(nodeItem, 'collapsedcontainer') == 'true' then
			DB.setValue(nodeItem, 'collapsedcontainer', 'string', 'false');
			DB.setValue(nodeItem, 'name', 'string', '[+] ' .. DB.getValue(nodeItem, 'name', ''));
			DB.setValue(nodeItem, 'nonid_name', 'string', '[+] ' .. DB.getValue(nodeItem, 'name', ''));
		else
			DB.setValue(nodeItem, 'collapsedcontainer', 'string', 'true');
			DB.setValue(nodeItem, 'name', 'string', DB.getValue(nodeItem, 'name', ''):gsub('%[%+%] ', ''));
			DB.setValue(nodeItem, 'nonid_name', 'string', DB.getValue(nodeItem, 'name', ''):gsub('%[%+%] ', ''));
		end
	end
end

function onLoseFocus()
	super.onLoseFocus();
	window.windowlist.updateContainers();
end