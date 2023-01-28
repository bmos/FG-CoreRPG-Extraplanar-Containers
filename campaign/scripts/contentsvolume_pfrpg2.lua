--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--
-- luacheck: globals onValueChanged getValue setColor

function onInit()
	local bVisible = OptionsManager.isOption('EXTRAPLANAR_VOLUME', 'on')

	window.external_dimensions_label.setVisible(bVisible)
	window.length.setVisible(bVisible)
	window.width.setVisible(bVisible)
	window.depth.setVisible(bVisible)
	window.volume.setVisible(bVisible)

	bVisible = bVisible and ExtraplanarContainers.isAnyContainer(DB.getValue(window.getDatabaseNode(), 'name'))

	window.contentsvolume.setVisible(bVisible)
	window.internal_dimensions_label.setVisible(bVisible)
	window.internal_length.setVisible(bVisible)
	window.internal_width.setVisible(bVisible)
	window.internal_depth.setVisible(bVisible)
	window.internal_volume.setVisible(bVisible)

	onValueChanged()
end

function onValueChanged()
	if window.internal_volume.getValue() ~= 0 then
		if getValue() < window.internal_volume.getValue() then
			setColor(ColorManager.COLOR_FULL)
		elseif getValue() == window.internal_volume.getValue() then
			setColor(ColorManager.COLOR_HEALTH_HVY_WOUNDS)
		elseif getValue() > window.internal_volume.getValue() then
			setColor(ColorManager.COLOR_HEALTH_CRIT_WOUNDS)
		end
	end
end