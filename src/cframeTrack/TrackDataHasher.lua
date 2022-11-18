
--- Hashes a track data table based on the track length between data
--- HashInterval is the lengths
--- @class TrackDataHasher

local getHashIndex = function(position: number, hashInterval: number)
	return math.floor(position / hashInterval) + 1
end

--- @prop trackData {T}
--- @within TrackDataHasher

--- @prop length number
--- @within TrackDataHasher

--- @prop hashData {(number, number)} -- index, trackLength
--- @within TrackDataHasher

--- @prop hashInterval number
--- @within TrackDataHasher

--- @prop getLengthFunction (a: T, b: T) -> number
--- @within TrackDataHasher

local TrackDataHasher = {}
TrackDataHasher.__index = TrackDataHasher

--- Creates a new TrackDataHasher
--- @tag Constructor
--- @return TrackDataHasher
function TrackDataHasher.new()
	local self = setmetatable({}, TrackDataHasher)

	self.trackData = {}
	self.lengthData = {}
	self.length = 0

	self.hashData = {}
	self.hashInterval = 10

	self.getLengthFunction = function(_a, _b)
		return 0
	end

	return self
end

--- @tag Constructor
--- @param trackData {T}
--- @param getLengthFunction (a: T, b: T) -> number
--- @param hashInterval number
--- @return TrackDataHasher
function TrackDataHasher.create(trackData: {any}, getLengthFunction: (a: any, b: any) -> number, hashInterval: number?)
	local self = TrackDataHasher.new()

	self:_setData(trackData, getLengthFunction, hashInterval)

	return self
end

--- @tag Deconstructor
function TrackDataHasher:Destroy()
	self.trackData = nil
	self.lengthData = nil
	self.hashData = nil

	setmetatable(self, nil)
end

--- Sets the data
--- @param trackData {T}
--- @param getLengthFunction (a: T, b: T) -> number
--- @param hashInterval number
function TrackDataHasher:_setData(trackData: table, getLengthFunction: (a: any, b: any) -> number, hashInterval: number?)
	assert(type(trackData) == "table",
		"Arg [1] is not a table!")
	assert(type(getLengthFunction) == "function",
		"Arg [2] is not a function!")

	hashInterval = hashInterval or self.hashInterval
	assert(type(hashInterval) == "number",
		"Arg [3] is not a number!")

	local lengthData = {}
	local currentLength = 0

	do
		local previousData
		for _, currentData in ipairs(trackData) do
			if previousData then
				currentLength += getLengthFunction(previousData, currentData)
			end

			table.insert(lengthData, currentLength)
			previousData = currentData
		end
	end

	local hashData = {}

	-- manually hash point indexes
	-- use lowest (by going in order from least to greatest)
	for index, trackPosition in ipairs(lengthData) do
		local hashIndex = getHashIndex(trackPosition, hashInterval)
		local hashPointIndex = hashData[hashIndex]

		if hashPointIndex == nil then
			hashData[hashIndex] = index
		end
	end

	-- fill in any gaps
	local maxHashIndex = getHashIndex(currentLength, hashInterval)
	local lastHashPointIndex = 1
	for hashIndex = 1, maxHashIndex, 1 do
		local hashPointIndex = hashData[hashIndex]
		if hashPointIndex == nil then
			hashData[hashIndex] = lastHashPointIndex
		else
			lastHashPointIndex = hashPointIndex
		end
	end

	self.trackData = trackData
	self.lengthData = lengthData
	self.length = currentLength

	self.hashData = hashData
	self.hashInterval = hashInterval

	self.getLengthFunction = getLengthFunction
end

function TrackDataHasher:getDataIndexes(position: number)
	local trackLength = self.length

	local trackData = self.trackData
	local numData = #trackData
	assert(numData > 0,
		"trackData is empty!")

	local index1, index2

	if position >= trackLength then
		index1 = numData
	elseif position <= 0 then
		index2 = 1
	else
		local hashInterval = self.hashInterval
		local hashIndex = getHashIndex(position, hashInterval)
		local hashPointIndex = self.hashData[hashIndex]

		local lengthData = self.lengthData

		local currentLengthPosition = lengthData[hashPointIndex]
		if currentLengthPosition <= position then
			repeat
				hashPointIndex += 1
				currentLengthPosition = lengthData[hashPointIndex]
			until position <= currentLengthPosition
		end

		index1 = hashPointIndex - 1
		index2 = hashPointIndex
	end

	return index1, index2
end

--- Gets the Data
--- @param position number
--- @return T -- Data 1
--- @return T -- Data 2
--- @return number
--- @error "trackData is empty!" -- Shouldn't really happen
function TrackDataHasher:getData(position: number)
	local trackLength = self.length

	local trackData = self.trackData
	local numData = #trackData
	assert(numData > 0,
		"trackData is empty!")

	local index1, index2 = self:getDataIndexes(position)

	local data1, data2
	local difference

	if index2 == nil then -- position >= trackLength
		data1 = trackData[index1]
		difference = position - trackLength
	elseif index1 == nil then -- position < trackLength
		data2 = trackData[index2]
		difference = position
	else
		data1 = trackData[index1]
		data2 = trackData[index2]

		difference = position - self.lengthData[index1]
	end

	return data1, data2, difference
end

function TrackDataHasher:getLengthData(index: number)
	return self.lengthData[index]
end

function TrackDataHasher:getClosestIndex(position: number)
	local index1, index2 = self:getDataIndexes(position)

	if index2 == nil then -- position >= trackLength
		return index1
	elseif index1 == nil then -- position < trackLength
		return index2
	else
		local lengthData = self.lengthData
		local length1 = lengthData[index1]
		local length2 = lengthData[index2]

		local positionDifference = position - length1
		local difference = length2 - length1

		if positionDifference <= (difference * 0.5) then
			return index1
		else
			return index2
		end
	end
end

export type TrackDataHasher = typeof(TrackDataHasher.new())

return TrackDataHasher