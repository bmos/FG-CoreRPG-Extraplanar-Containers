--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--
-- luacheck: globals onValueChanged getValue setColor fieldname

function onValueChanged()
	local sFieldName = fieldname[1]
	if not sFieldName or  User.getRulesetName() == '5E' then
		return
	end

	local nCompare = window[sFieldName].getValue()
	if (nCompare == 0) or (getValue() < nCompare) then
		setColor(ColorManager.getUIColor("usage_full"))
	elseif getValue() == nCompare then
		setColor(ColorManager.getUIColor("health_wounds_heavy"))
	elseif getValue() > nCompare then
		setColor(ColorManager.getUIColor("health_wounds_critical"))
	end
end
