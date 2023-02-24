--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--
-- luacheck: globals onValueChanged getValue setColor fieldname

function onValueChanged()
	local sFieldName = fieldname[1]
	if not sFieldName then return end

	local nCompare = window[sFieldName].getValue()
	if (nCompare == 0) or (getValue() < nCompare) then
		setColor(ColorManager.COLOR_FULL)
	elseif getValue() == nCompare then
		setColor(ColorManager.COLOR_HEALTH_HVY_WOUNDS)
	elseif getValue() > nCompare then
		setColor(ColorManager.COLOR_HEALTH_CRIT_WOUNDS)
	end
end
