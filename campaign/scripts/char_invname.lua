--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--

-- luacheck: globals onDoubleClick onLoseFocus

function onDoubleClick()
	local nodeItem = window.getDatabaseNode()
	local sName = DB.getValue(nodeItem, 'name', '')
	if ExtraplanarContainers.isAnyContainer(sName) then
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
end

function onLoseFocus()
	super.onLoseFocus()
	window.windowlist.updateContainers()
end
