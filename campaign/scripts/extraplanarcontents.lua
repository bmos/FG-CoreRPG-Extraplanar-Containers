--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--

function onInit()
	local bVisible = ExtraplanarContainers.isAnyContainer(DB.getValue(window.getDatabaseNode(), 'name'))
	window.weight.setVisible(bVisible or window.weight.getValue() ~= 0)
	window.capacityweight.setVisible(bVisible or window.capacityweight.getValue() ~= 0)
	window.extraplanarcontents.setVisible(bVisible or window.extraplanarcontents.getValue() ~= 0)
	onValueChanged()
end

function onValueChanged()
	if window.capacityweight.getValue() ~= 0 then
		if getValue() < window.capacityweight.getValue() then
			setColor(ColorManager.COLOR_FULL)
		elseif getValue() == window.capacityweight.getValue() then
			setColor(ColorManager.COLOR_HEALTH_HVY_WOUNDS)
		elseif getValue() > window.capacityweight.getValue() then
			setColor(ColorManager.COLOR_HEALTH_CRIT_WOUNDS)
		end
	end
end
