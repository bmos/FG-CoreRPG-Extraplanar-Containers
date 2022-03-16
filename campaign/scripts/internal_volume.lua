--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--

function onInit()
	getVolume()
end

--	luacheck: globals getVolume
function getVolume()
	setValue(window.internal_length.getValue() * window.internal_width.getValue() * window.internal_depth.getValue())
end
