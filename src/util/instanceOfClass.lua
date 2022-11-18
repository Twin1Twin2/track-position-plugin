
-- local t = require(script.Parent.t)

-- loop through the metatable indexes to get the class
-- return function(class)
-- 	return function(value)
-- 		local tableSuccess, tableErrMsg = t.table(value)
-- 		if not tableSuccess then
-- 			return false, tableErrMsg or "" -- pass error message for value not being a table
-- 		end

-- 		local isClass
-- 		local function IsClass()
-- 			local mt = getmetatable(value)

-- 			if mt == nil then
-- 				return false
-- 			end

-- 			if not mt or mt.__index ~= class then
-- 			end
-- 		end

-- 		if isClass == false then
-- 			return false, "Not a " .. class.ClassName -- custom error message
-- 		end

-- 		return true -- all checks passed
-- 	end
-- end

--- Returns a function to check if value is an instance of the given class.
--- Uses a `newproxy`.
--- @function instanceOfClass
--- @within Util
--- @param class table
--- @return (value: any) -> (boolean, string?)
return function(class: table): (value: any) -> (boolean, string?)
	local className = class.ClassName

	local identifier = newproxy() -- kinda a hack for now
	class[identifier] = true

	return function(value: any)
		if type(value) ~= "table" then
			return false, ("not a table")
		end

		if value[identifier] == nil then
			return false, ("not an instance of class %s"):format(className)
		end

		return true
	end
end