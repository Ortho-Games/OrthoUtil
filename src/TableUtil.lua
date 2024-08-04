local RNG = Random.new()

--- @class TableUtil

return function(OrthoUtil)
	--[=[
		Get a random value from an array.

		@within TableUtil
		@param tbl { T } -- Table to pick from.
		@param except T? -- A value from the tbl you don't want picked.
		@return T -- the picked value.
	]=]
	function OrthoUtil.pickRandom<T>(tbl: { T }, except: T?): T?
		if #tbl <= 0 then
			return nil
		end

		if #tbl < 2 then
			return tbl[1]
		end

		local pick
		repeat
			pick = tbl[RNG:NextInteger(1, #tbl)]
		until pick ~= except

		return pick
	end

	--[=[
		Returns a dictionary with each key as the value with the given array index as the value.

		{"a", "b", "c"} => {["a"] = 1, ["b"] = 2, ["c"] = 3}

		@within TableUtil
		@param arr {[number]: T} -- array to convert
		@return {[T]: number} -- mapped dictionary
	]=]
	function OrthoUtil.arrToOrderLUT<T>(arr: { [number]: T }): { [T]: number }
		local lut = {}

		for i, v in ipairs(arr) do
			lut[v] = i
		end

		return lut
	end

	--[=[
		Returns a dictionary with each key mapped to its exact value. Useful for making custom enums.

		{"a", "b", "c"} => {["a"] = "a", ["b"] = "b", ["c"] = "c"}

		@within TableUtil
		@param arr {T} -- array to convert
		@return {[T]: T} -- mapped dictionary
	]=]
	function OrthoUtil.arrayToDict<T>(arr: { T }): { [T]: T }
		local dict: { [T]: T } = {}

		for _, v: T in ipairs(arr) do
			dict[v] = v
		end

		return dict
	end

	--[=[
		Returns a dictionary with each key mapped to each value and each value the result of a function. 

		{"a", "b", "c"} => {["a"] = map("a"), ["b"] = map("b"), ["c"] = map("c")}

		@within TableUtil
		@param arr {T} -- array to convert
		@param map (number, T) -> T -- mapper function
		@return {[T]: T} -- mapped dictionary
	]=]
	function OrthoUtil.arrayToCustomDict<T>(arr: { T }, map: (number, T) -> any): { [T]: any }
		local dict: { [T]: T } = {}

		for i: number, v: T in ipairs(arr) do
			dict[v] = map(i, v)
		end

		return dict
	end

	--[=[
		Returns all the values out of a dictionary as an array.

		@within TableUtil
		@param dict {[any]: T} -- input dictionary
		@return { T } -- output array with all values.
	]=]
	function OrthoUtil.getValues<T>(dict: { [any]: T }): { T }
		local values = {}
		for _, v in dict do
			table.insert(values, v)
		end
		return values
	end

	--[=[
		Returns an array with only values that get a truthy result from the predicate function.

		@within TableUtil
		@param t { T } -- input array (must be an array)
		@param predicate (key: any, value: T) -> boolean
		@return { T } -- output array with only predicate truthy values.
	]=]
	function OrthoUtil.filter<T>(t: { T }, predicate: (key: any, value: T) -> boolean): { T }
		local newTable = {}

		for key, value in t do
			if predicate(key, value) then
				table.insert(newTable, value)
			end
		end

		return newTable
	end

	--[=[
		Returns an array/dictionary with each value converted into a value returned from a mapper function.

		@within TableUtil
		@param t { T } -- input array (must be an array)
		@param mapper (key: any, value: T) -> boolean -- function that returns a new value.
		@return { T } -- output array with only predicate truthy values.
	]=]
	function OrthoUtil.map<T, C>(t: { T }, mapper: (value: T) -> C): { C }
		local newTable = {}

		for key, value in t do
			newTable[key] = mapper(value)
		end

		return newTable
	end

	--[=[
		Combined the filter and map functions together to create a new table that only has filter_mapper values that are truthy. This works on dictionaries, but it can leave holes in an array.
		
		@within TableUtil
		@param t { T } -- input array (must be an array)
		@param filter_mapper (key: T, value: U) -> any? -- function that returns a new value.
		@return { [T]: any } -- output array with only predicate truthy values.
	]=]
	function OrthoUtil.filter_map_dict<T, U>(t: { [T]: U }, filter_mapper: (key: T, value: U) -> any?): { [T]: any }
		local newTable = {}

		for key, value in t do
			local mapped = filter_mapper(key, value)
			if mapped then
				newTable[key] = mapped
			end
		end

		return newTable
	end

	--[=[
		Combined the filter and map functions together to create a new table that only has filter_mapper values that are truthy. This works on dictionaries, but it can leave holes in an array.
		
		@within TableUtil
		@param t { [number]: U } -- input array (must be an array)
		@param filter_mapper (key: T, value: U) -> any? -- function that returns a new value.
		@return { [T]: any } -- output array with only predicate truthy values.
	]=]
	function OrthoUtil.filter_map<T, U>(t: { [number]: U }, filter_mapper: (number, U) -> any): { any }
		local newTable = {}
		for key, value in t do
			local mapped = filter_mapper(key, value)
			if mapped then
				table.insert(newTable, mapped)
			end
		end

		return newTable
	end

	--[=[
		On each member of an array/dictionary accumulate a value based on array/dictionary values.
		
		@within TableUtil
		@param t { [number]: U } -- input array (must be an array)
		@param reducer (accumulator: U, value: T, key: any) -> U -- function that takes in and returns the accumulator.
		@param initialValue U -- The value the accumulator starts at.
		@return { [T]: any } -- output array with only predicate truthy values.
	]=]
	function OrthoUtil.reduce<T, U>(t: { T }, reducer: (accumulator: U, value: T, key: any) -> U, initialValue: U): U
		local accumulator = initialValue

		for k, value in t do
			accumulator = reducer(accumulator, value, k)
		end

		return accumulator
	end

	--[=[
		Search for and return the first value that returns a truthy value from the predicate.

		@within TableUtil
		@param t {T} -- input array/dictionary
		@param predicate (value: T) -> boolean
		@return T?
	]=]
	function OrthoUtil.find<T>(t: { T }, predicate: (value: T) -> boolean): T?
		for _, value in t do
			if predicate(value) then
				return value
			end
		end

		return nil
	end

	--[=[
		Search for and return the first index that returns a truthy value from the predicate.

		@within TableUtil
		@param t { [U]:T } -- input array/dictionary
		@param predicate (value: T) -> boolean
		@return U?
	]=]
	function OrthoUtil.findIndex<T, U>(t: { [U]: T }, predicate: (value: T) -> boolean): U?
		for key, value in t do
			if predicate(value) then
				return key
			end
		end

		return nil
	end

	--[=[
		Filter map, however it only adds values to the return table that haven't been added before.

		@within TableUtil
		@param t { [T]: U } -- input array/dictionary
		@param filter_mapper (T, U) -> any -- function takes in key, value returns anything.
		@return { [T]: U }
	]=]
	function OrthoUtil.filter_map_no_duplicates<T, U>(t: { [T]: U }, filter_mapper: (T, U) -> any): { [T]: U }
		local newTable = {}
		local tempDict = {}
		for key, value in t do
			local mapped = filter_mapper(key, value)
			if not mapped then
				continue
			end
			if tempDict[mapped] then
				continue
			end
			tempDict[mapped] = true

			newTable[key] = mapped
		end

		return newTable
	end

	--[=[
		Given two arrays of possible values, and weights for each of those values, pick one entry at random.

		@within TableUtil
		@param values { T } -- input array/dictionary to pick from
		@param weights { number } -- input weights table whose indicies match to values.
		@return T -- a weighted randomly picked value.
	]=]
	function OrthoUtil.weightedRandom<T>(values: { T }, weights: { number }): T
		local total = 0

		for _, weight in weights do
			total += weight
		end

		local random = RNG:NextNumber() * total

		local cursor = 0
		for i = 1, #weights do
			cursor += weights[i]
			if cursor >= random then
				return values[i]
			end
		end

		return values[1]
	end

	return OrthoUtil
end
