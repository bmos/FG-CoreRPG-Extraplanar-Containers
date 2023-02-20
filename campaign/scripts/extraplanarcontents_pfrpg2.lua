--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--
-- luacheck: globals onValueChanged getValue setColor setReadOnly setVisible getName update

function update(bReadOnly, bForceHide)
	local bLocalShow
	if bForceHide then
		bLocalShow = false
	else
		--[[bmos fixing visibility of weight fields]]
		local nohide = ExtraplanarContainers.isAnyContainer(DB.getValue(window.getDatabaseNode(), 'name'))
		--[[end bmos fixing visibility of weight fields]]
		bLocalShow = true
		if bReadOnly and not nohide and getValue() == 0 then bLocalShow = false end
	end

	setReadOnly(bReadOnly)
	setVisible(bLocalShow)

	local sName = getName()
	if window[sName .. '_label'] then
		window[sName .. '_label'].setVisible(bLocalShow)
	elseif window[sName .. '_header'] then
		window[sName .. '_header'].setVisible(bLocalShow)
	end

	if self.onUpdate then self.onUpdate(bLocalShow) end

	return bLocalShow
end

function onInit()
	local bVisible = ExtraplanarContainers.isAnyContainer(DB.getValue(window.getDatabaseNode(), 'name'))
	window.container_bulk_label.setVisible(bVisible)
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
