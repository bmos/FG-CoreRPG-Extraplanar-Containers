--
-- Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--
-- luacheck: globals update

local bIsContainer = false

local function updateWeight()
	local nodeRecord = getDatabaseNode()
	local bVisWt = not WindowManager.getReadOnlyState(nodeRecord) or bIsContainer

	local function updateWeightGeneral()
		bVisWt = bVisWt or (weight.getValue() ~= 0)
		weight_label.setVisible(bVisWt)
		weight.setVisible(bVisWt)
		weight_labeltop.setVisible(bVisWt)
	end

	local function updateWeightPFRPG2()
		-- luacheck: globals bulk
		bVisWt = bVisWt or (bulk.getValue() ~= '')
		bulk_label.setVisible(bVisWt)
		bulk.setVisible(bVisWt)
		container_bulk_label.setVisible(bVisWt and bIsContainer)
	end

	if bulk then
		updateWeightPFRPG2()
	else
		updateWeightGeneral()
	end

	local bVisCW = bIsContainer or capacityweight.getValue() ~= 0
	capacityweight.setVisible(bVisCW)
	capacityweight_label.setVisible(bVisCW)

	local bVisEC = bIsContainer or extraplanarcontents.getValue() ~= 0
	extraplanarcontents.setVisible(bVisEC)
	extraplanarcontents_label.setVisible(bVisEC)

	extraplanarcontents.onValueChanged()
end

local function updateCount()
	local bCountVisible = OptionsManager.isOption('EXTRAPLANAR_COUNT', 'on') and bIsContainer

	capacitycount.setVisible(bCountVisible)
	capacitycount_label.setVisible(bCountVisible)
end

local function updateVolume()
	local bVolumeVisible = OptionsManager.isOption('EXTRAPLANAR_VOLUME', 'on')
	if bVolumeVisible then -- calculate volume and color-code
		volume.getVolume()
		contentsvolume.onValueChanged()
	end

	external_dimensions_label.setVisible(bVolumeVisible)
	length.setVisible(bVolumeVisible)
	width.setVisible(bVolumeVisible)
	depth.setVisible(bVolumeVisible)
	volume.setVisible(bVolumeVisible)

	local bIntVolumeVisible = bVolumeVisible and bIsContainer

	contentsvolume.setVisible(bIntVolumeVisible)
	contentsvolume_label.setVisible(bIntVolumeVisible)

	internal_dimensions_label.setVisible(bIntVolumeVisible)
	internal_length.setVisible(bIntVolumeVisible)
	internal_width.setVisible(bIntVolumeVisible)
	internal_depth.setVisible(bIntVolumeVisible)
	internal_volume.setVisible(bIntVolumeVisible)
end

function update(bReadOnly, ...)
	if super and super.update then
		super.update(bReadOnly, ...)
	end

	bIsContainer = ExtraplanarContainers.isAnyContainer(DB.getValue(getDatabaseNode(), 'name'))

	updateCount()
	updateVolume()
	updateWeight()

	limits_label.setVisible(bIsContainer)

	capacityweight.setReadOnly(bReadOnly);
	capacitycount.setReadOnly(bReadOnly);
	internal_length.setReadOnly(bReadOnly);
	internal_width.setReadOnly(bReadOnly);
	internal_depth.setReadOnly(bReadOnly);
	internal_volume.setReadOnly(bReadOnly);
	length.setReadOnly(bReadOnly);
	width.setReadOnly(bReadOnly);
	depth.setReadOnly(bReadOnly);
	volume.setReadOnly(bReadOnly);
	capacityweight.setReadOnly(bReadOnly);
end

function onInit()
	if super and super.onInit then
		super.onInit()
	end
	update()
end
