local weighted = require("./weighted")

-- export type WeightedDict<K, V> = typeof(setmetatable(
-- 	{} :: {
-- 		dict: { [K]: V },
-- 		trim: boolean,
-- 	},
-- 	{} :: WeightedDictImpl
-- ))

-- type WeightedDictImpl = {
-- 	__index: WeightedDictImpl,
-- 	new: <K, V>(dict: { [K]: V }, trim: boolean?) -> WeightedDict<K, V>,
-- 	map: (<K, V>(self: WeightedDict<K, V>, getWeight: (key: K, value: V) -> number) -> () -> K) & (<K, V, M>(
-- 		self: WeightedDict<K, V>,
-- 		getWeight: (key: K, value: V) -> number,
-- 		map: (key: K, value: V) -> M
-- 	) -> () -> M),
-- }

export type WeightedDict<K, V> = {
	dict: { [K]: V },
	trim: boolean,

	__index: WeightedDict<K, V>,
	new: (dict: { [K]: V }, trim: boolean?) -> WeightedDict<K, V>,
	map: ((self: WeightedDict<K, V>, getWeight: (key: K, value: V) -> number) -> () -> K) & (<M>(
		self: WeightedDict<K, V>,
		getWeight: (key: K, value: V) -> number,
		map: (key: K, value: V) -> M
	) -> () -> M),
}

--[=[
	@class WeightedDict

	A dictionary with weighted keys. The `new` method creates a new instance of the dictionary. The `map` method returns a function that will return a random key from the dictionary, with the probability of each key being chosen weighted by the corresponding weight in the weights array. The `map` method can also take a second argument, a map function that will be used to map the key and value to the desired return value.

	```lua
	local weightedDict = rng.WeightedDict.new({
		a = {
			weight = 1,
		},
		b = {
			weight = 2,
		},
		c = {
			weight = 3,
		},
	})
	local choose = weightedDict:map(function(key, value)
		return value.weight
	end)
	local chosen = choose() -- "a", "b", or "c"
	```
]=]
local WeightedDict = {} :: WeightedDict<any, any>
WeightedDict.__index = WeightedDict

function WeightedDict.new(dict, trim)
	return setmetatable({
		dict = dict,
		trim = trim or false,
	}, WeightedDict) :: any
end

WeightedDict.map = function<K, V, M>(
	self: WeightedDict<K, V>,
	getWeight: (key: K, value: V) -> number,
	mapValue: ((key: K, value: V) -> M)?
): (() -> K) | (() -> M)
	local dict = self.dict
	local keys: { K } = {}
	local weights: { number } = {}

	for k, v in dict do
		local weight = getWeight(k, v)
		if weight > 0 then
			table.insert(keys, k)
			table.insert(weights, weight)
		end
	end

	local getKey = weighted(keys, weights, self.trim)
	if not mapValue then
		return getKey
	end

	return function(): M
		local key = getKey()
		local value = dict[key]
		return mapValue(key, value)
	end
end :: any

return WeightedDict
