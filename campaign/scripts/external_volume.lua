--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--
--	luacheck: globals getVolume
function getVolume()
	setValue(window.length.getValue() * window.width.getValue() * window.depth.getValue())
	window.contentsvolume.onValueChanged()
end

function onInit() getVolume() end

function onValueChanged() window.contentsvolume.onValueChanged() end
