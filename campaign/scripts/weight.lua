--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--
-- luacheck: globals update getValue setReadOnly setVisible getName
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

	local sLabel = getName() .. '_label'
	if window[sLabel] then window[sLabel].setVisible(bLocalShow) end

	if self.onUpdate then self.onUpdate(bLocalShow) end

	return bLocalShow
end
