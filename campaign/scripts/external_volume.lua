--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--

function onInit()
	getVolume()
end

--	luacheck: globals getVolume
function getVolume()
	setValue(window.length.getValue() * window.width.getValue() * window.depth.getValue())
	window.contentsvolume.onValueChanged()
end

function onValueChanged()
	window.contentsvolume.onValueChanged()
end
