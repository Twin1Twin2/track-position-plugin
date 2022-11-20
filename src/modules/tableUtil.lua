
--- @class TableUtil
--- Provides a variety of utility Table operations
--- Taken from Nevermore Framework:
--- - https://github.com/Quenty/NevermoreEngine/blob/version2/Modules/Shared/Utility/Table.lua
--- - https://github.com/Quenty/NevermoreEngine
---
--- #### Edited by TheEpicTwin

local Table = {}

--- Concats `target` with `source`
--- @function append
--- @within TableUtil
--- @param target table -- Table to append to
--- @param source table -- Table read from
--- @return table parameter table
function Table.append(target: table, source: table)
	for _, value in pairs(source) do
		target[#target+1] = value
	end

	return target
end

--- Shallow merges two tables without modifying either
--- @function merge
--- @within TableUtil
--- @param orig table -- original table
--- @param new table -- new table
--- @return table
function Table.merge(orig: table, new: table)
	local tab = {}
	for key, val in pairs(orig) do
		tab[key] = val
	end
	for key, val in pairs(new) do
		tab[key] = val
	end
	return tab
end

--- Shallow merges two lists without modifying either
--- @function mergeLists
--- @within TableUtil
--- @param orig table -- original table
--- @param new table -- new table
--- @return table
function Table.mergeLists(orig: table, new: table)
	local tab = {}
	for _, val in pairs(orig) do
		table.insert(tab, val)
	end
	for _, val in pairs(new) do
		table.insert(tab, val)
	end
	return tab
end

--- Swaps keys with v values, overwriting additional values if duplicated
--- @function swapKeyValue
--- @within TableUtil
--- @param orig table -- original table
--- @return table
function Table.swapKeyValue(orig)
	local tab = {}
	for key, val in pairs(orig) do
		tab[val] = key
	end
	return tab
end

--- Converts a table to a list
--- @function toList
--- @within TableUtil
--- @param tab table -- Table to convert to a list
--- @return table
function Table.toList(tab)
	local list = {}
	for _, item in pairs(tab) do
		table.insert(list, item)
	end
	return list
end

--- Counts the number of items in `tab`.
--- Useful since `__len` on table in Lua 5.2 returns just the array length.
--- @function count
--- @within TableUtil
--- @param tab table -- Table to count
--- @return number -- count
function Table.count(tab)
	local count = 0
	for _, _ in pairs(tab) do
		count = count + 1
	end
	return count
end

--- Copies a table, but not deep.
--- @function copy
--- @within TableUtil
--- @param target table Table to copy
--- @return table -- New table
function Table.copy(target)
	local new = {}
	for key, value in pairs(target) do
		new[key] = value
	end
	return new
end

--- Deep copies a table including metatables
--- @function deepCopy
--- @within TableUtil
--- @param target table -- Table to deep copy
--- @return table -- New table
local function deepCopy(target, _context)
	_context = _context or  {}
	if _context[target] then
		return _context[target]
	end

	if type(target) == "table" then
		local new = {}
		_context[target] = new
		for index, value in pairs(target) do
			new[deepCopy(index, _context)] = deepCopy(value, _context)
		end
		return setmetatable(new, deepCopy(getmetatable(target), _context))
	else
		return target
	end
end
Table.deepCopy = deepCopy

--- Overwrites a table's value
--- @function deepOverwrite
--- @within TableUtil
--- @param target table -- Target table
--- @param source table -- Table to read from
--- @return table -- target
local function deepOverwrite(target, source)
	for index, value in pairs(source) do
		if type(target[index]) == "table" and type(value) == "table" then
			target[index] = deepOverwrite(target[index], value)
		else
			target[index] = value
		end
	end
	return target
end
Table.deepOverwrite = deepOverwrite

--- Gets an index by value, returning `nil` if no index is found.
--- @function getIndex
--- @within TableUtil
--- @param haystack table -- table to search in
--- @param needle any -- Value to search for
--- @return number | nil -- The index of the value, if found. Else nil.
function Table.getIndex(haystack, needle)
	for index, item in pairs(haystack) do
		if needle == item then
			return index
		end
	end
	return nil
end

--- Recursively prints the table. Does not handle recursive tables.
--- @function stringify
--- @within TableUtil
--- @param table table -- Table to stringify
--- @param indent number -- Indent level
--- @param output string -- Output string, used recursively
--- @return string The table in string form
local function stringify(table, indent, output)
	output = output or tostring(table)
	indent = indent or 0
	for key, value in pairs(table) do
		local formattedText = "\n" .. string.rep("  ", indent) .. tostring(key) .. ": "
		if type(value) == "table" then
			output = output .. formattedText
			output = stringify(value, indent + 1, output)
		else
			output = output .. formattedText .. tostring(value)
		end
	end
	return output
end
Table.stringify = stringify

--- Returns whether `value` is within `table`
--- @function contains
--- @within TableUtil
--- @param table table -- table to search in for value
--- @param value any -- value to search for
--- @return boolean `true` if within, `false` otherwise
function Table.contains(table, value)
	for _, item in pairs(table) do
		if item == value then
			return true
		end
	end

	return false
end

--- Overwrites an existing table
--- @function overwrite
--- @within TableUtil
--- @param target table -- Table to overwrite
--- @param source table -- Source table to read from
--- @return table -- target
function Table.overwrite(target, source)
	for index, item in pairs(source) do
		target[index] = item
	end

	return target
end

--- Sets a metatable on a table such that it errors when
--- indexing a nil value
--- @function readOnly
--- @within TableUtil
--- @param table table -- Table to error on indexing
--- @return table -- The same table
function Table.readOnly(table)
	return setmetatable(table, {
		__index = function(_, index)
			error(("Bad index %q"):format(tostring(index)), 2)
		end;
		__newindex = function(_, index, _)
			error(("Bad index %q"):format(tostring(index)), 2)
		end;
	})
end

--- Recursively sets the table as ReadOnly
--- @function deepReadOnly
--- @within TableUtil
--- @param table table -- Table to error on indexing
--- @return table -- The same table
function Table.deepReadOnly(table)
	for _, item in pairs(table) do
		if type(item) == "table" then
			Table.deepReadOnly(item)
		end
	end

	return Table.readOnly(table)
end

return Table