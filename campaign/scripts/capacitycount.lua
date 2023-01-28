--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--
-- luacheck: globals onValueChanged

function onInit()
	local bVisible = OptionsManager.isOption('EXTRAPLANAR_COUNT', 'on')
	bVisible = bVisible and ExtraplanarContainers.isAnyContainer(DB.getValue(window.getDatabaseNode(), 'name'))

	window.capacitycount.setVisible(bVisible)
	window.capacitycount_label.setVisible(bVisible)
end

function onValueChanged() window.extraplanarcontents.onValueChanged() end
