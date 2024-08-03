local RNG = Random.new()

return function(Util)
	function Util.pickRandom<T>(tbl: { T }, except: T | nil): T?
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

	--- Returns an array with each index as the value with the given array entry as the key.
	function Util.arrToOrderLUT(arr: { any }): { [any]: number }
		local lut = {}

		for i, v in ipairs(arr) do
			lut[v] = i
		end

		return lut
	end

	function Util.arrayToDict<T>(arr: { T }): { [T]: T }
		local dict: { [T]: T } = {}

		for _, v: T in ipairs(arr) do
			dict[v] = v
		end

		return dict
	end

	function Util.arrayToCustomDict<T, C>(arr: { T }, map: (number, T) -> T)
		local dict: { [T]: T } = {}

		for i: number, v: T in ipairs(arr) do
			dict[v] = map(i, v)
		end

		return dict
	end

	function Util.getValues(dict)
		local values = {}
		for _, v in dict do
			table.insert(values, v)
		end
		return values
	end

	function Util.filter<T, U>(t: { T }, predicate: (key: U, value: T) -> boolean): { T }
		local newTable = {}

		for key, value in t do
			if predicate(key, value) then
				table.insert(newTable, value)
			end
		end

		return newTable
	end

	function Util.map<T, U>(t: { T }, mapper: (value: T) -> U): { any }
		local newTable = {}

		for key, value in t do
			newTable[key] = mapper(value)
		end

		return newTable
	end

	function Util.filter_map_dict<T, U>(t: { [T]: U }, filter_mapper: (T, U) -> any): { [T]: U }
		local newTable = {}
		for key, value in t do
			local mapped = filter_mapper(key, value)
			if mapped then
				newTable[key] = mapped
			end
		end

		return newTable
	end

	function Util.filter_map<T, U>(t: { [T]: U }, filter_mapper: (T, U) -> any)
		local newTable = {}
		for key, value in t do
			local mapped = filter_mapper(key, value)
			if mapped then
				table.insert(newTable, mapped)
			end
		end

		return newTable
	end

	function Util.reduce<T, U>(t: { T }, reducer: (accumulator: U, value: T, key: any) -> U, initialValue: U)
		local accumulator = initialValue

		for k, value in t do
			accumulator = reducer(accumulator, value, k)
		end

		return accumulator
	end

	function Util.find<T>(t: { T }, predicate: (value: T) -> boolean)
		for _, value in t do
			if predicate(value) then
				return value
			end
		end

		return nil
	end

	function Util.findIndex<T>(t: { T }, predicate: (value: T) -> boolean)
		for key, value in t do
			if predicate(value) then
				return key
			end
		end

		return nil
	end

	function Util.filter_map_no_duplicates<T, U>(t: { [T]: U }, filter_mapper: (T, U) -> any): { [T]: U }
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

	function Util.weightedRandom(values, weights)
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

	return Util
end
