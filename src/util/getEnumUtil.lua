
local root = script.Parent.Parent

local modules = root.modules
local t = require(modules.t)
local Result = require(modules.Result)

local isValidEnumValue = t.union(
	t.EnumItem,
	t.integer,
	t.string
)

--- Get and check utilities for converting a value to an EnumItem
--- @interface EnumUtil
--- @within Util
--- .get (value: any) -> Result<EnumItem, string>
--- .check (value: any) -> boolean
export type EnumUtil = {
	get: (value: any) -> Result.Result,
	check: (value: any) -> boolean,
}

local function getEnumType(enum: Enum): EnumUtil
	assert(t.Enum(enum))

	local enumName = tostring(enum)

	local enumItems = {}
	local enumIntegers = {}
	local enumNames = {}

	for _, enumItem in ipairs(enum:GetEnumItems()) do
		enumItems[enumItem] = enumItem
		enumIntegers[enumItem.Value] = enumItem
		enumNames[enumItem.Name] = enumItem
	end

	local function get(value: any)
		local e = nil

		if typeof(value) == "EnumItem" then
			e = enumItems[value]
		elseif type(value) == "number" then
			if t.integer(value) == false then
				return Result.err(("cannot convert enum from non-integer value: %s"):format(tostring(value)))
			end

			e = enumIntegers[value]
		elseif type(value) == "string" then
			e = enumNames[value]
		else
			return Result.err(("invalid enum type %q! value: %s"):format(typeof(value), value))
		end

		if e == nil then
			return Result.err(("not a valid %q: %s"):format(enumName, tostring(value)))
		end

		return Result.ok(e)
	end

	local function check(value)
		local enumValueSuccess, enumValueMessage
			= isValidEnumValue(value)

		if enumValueSuccess == false then
			return false, enumValueMessage
		end

		local enumItemResult = get(value)
		if enumItemResult:isOK() then
			return true
		else
			return false, enumItemResult:unwrapErr()
		end
	end

	return {
		get = get,
		check = check,
	}
end


-- caching
local cachedEnumUtils = {}

--- Returns Get/Convert and Check functions for the given Enum
--- Check is used for t typechecking integration
--- EnumItems can also be Strings, Integer
--- See: https://developer.roblox.com/en-us/articles/Enumeration
--- @function getCFrameFromInstance
--- @within Util
--- @param enum Enum
--- @return EnumUtil
--- @error is not an Enum
return function(enum)
	assert(t.Enum(enum))

	local enumUtil = cachedEnumUtils[enum]

	if enumUtil then
		return enumUtil
	end

	enumUtil = getEnumType(enum)
	cachedEnumUtils[enum] = enumUtil

	return enumUtil
end