--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--
--	luacheck: globals getVolume setValue
function getVolume() setValue(window.internal_length.getValue() * window.internal_width.getValue() * window.internal_depth.getValue()) end

function onInit() getVolume() end
