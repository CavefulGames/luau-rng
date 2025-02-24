--[=[
	@class rng

	# [luau-rng](https://pesde.dev/packages/caveful_games/rng)
	Useful random-related utilities for Luau
]=]
local rng = {}

export type Range = { Min: number, Max: number }

--[=[
	@within rng

	Converts a number or NumberRange to a number. If a number is passed, it is returned as is. If a NumberRange is passed, a random number within the range is returned.

	```lua
	local num = rng.tonumber(5) -- 5
	local num2 = rng.tonumber({ Min = 5, Max = 10 }) -- random number between 5 and 10
	local num3 = rng.tonumber(NumberRange.new(5, 10)) -- random number between 5 and 10
	```
]=]
function rng.tonumber(
	range: number | typeof(if _G.LUA_ENV == "roblox"
		then ({} :: any) :: NumberRange | Range
		else {} :: Range)
): number
	if type(range) == "number" then
		return range
	else
		local min = range.Min
		return min + math.random() * (range.Max - min)
	end
end

--[=[
	@within rng

	Returns a random number between the two given numbers.

	```lua
	local num = rng.betweenFloats(5, 10) -- random number between 5 and 10
	```
]=]
function rng.betweenFloats(min: number, max: number): number
	return min + math.random() * (max - min)
end

--[=[
	@within rng

	Returns a function that will return a random element from the given array, with the probability of each element being chosen weighted by the corresponding weight in the weights array.

	Original code inspired by [chance.js's `weighted`](https://github.com/chancejs/chancejs/blob/f915240410f7c5ee2f22b7960081ac39c81ec411/chance.js#L720)

	```lua
	local arr = { "a", "b", "c" }
	local weights = { 1, 2, 3 }
	local choose = rng.weighted(arr, weights)
	local chosen = choose() -- "a", "b", or "c"
	```
]=]
function rng.weighted<V>(arr: { V }, weights: { number }, trim: boolean?): () -> V
	if #arr ~= #weights then
		error("Length of array and weights must match")
	end

	local sum = 0
	for _, weight in weights do
		if type(weight) ~= "number" then
			error("All weights must be numbers")
		end

		if weight > 0 then
			sum += weight
		end
	end

	if sum == 0 then
		error("No valid entries in array weights")
	end

	local selected = math.random() * sum

	return function()
		local total = 0
		local lastGoodIdx = -1
		local chosenIdx: number

		for i, weight in weights do
			total = total + weight
			if weight > 0 then
				if selected <= total then
					chosenIdx = i
					break
				end
				lastGoodIdx = i
			end

			if i == #weights then
				chosenIdx = lastGoodIdx
			end
		end

		local chosen = arr[chosenIdx]

		if trim then
			table.remove(arr, chosenIdx)
			table.remove(weights, chosenIdx)
		end

		return chosen
	end
end

--[=[
	@within rng

	Returns a function that will return a random key from the given table, with the probability of each key being chosen weighted by the corresponding weight in the weights array.

	```lua
	local dict = {
		a = {
			weight = 1,
		},
		b = {
			weight = 2,
		},
		c = {
			weight = 3,
		},
	}
	local choose = rng.weightedKey(dict, function(key, value)
		return v.weight
	end)
	local chosen = choose() -- "a", "b", or "c"
	```
]=]
function rng.weightedKey<K, V>(dict: { [K]: V }, weightGettingFunction: (key: K, value: V) -> number, trim: boolean?): () -> K
	local keys = {}
	local weights = {}

	for k, v in dict do
		local weight = weightGettingFunction(k, v)
		if weight > 0 then
			table.insert(keys, k)
			table.insert(weights, weight)
		end
	end

	return rng.weighted(keys, weights, trim)
end

--[=[
	@within rng

	Returns a function that will return a random value from the given table, with the probability of each key being chosen weighted by the corresponding weight in the weights array. The map function is used to map the key and value to the desired return value.

	```lua
	local dict = {
		a = {
			name = "Alpha",
			weight = 1,
		},
		b = {
			name = "Beta",
			weight = 2,
		},
		c = {
			name = "Charlie",
			weight = 3,
		},
	}
	local choose = rng.weightedKeyMapped(dict, function(key, value)
		return v.weight
	end, function(_key, value)
		return v.name
	end)
	local chosen = choose() -- "Alpha", "Beta", or "Charlie"
	```
]=]
function rng.weightedKeyMapped<K, V, M>(
	dict: { [K]: V },
	weightGettingFunction: (key: K, value: V) -> number,
	map: (key: K, value: V) -> M,
	trim: boolean?
): () -> M
	local getKey = rng.weightedKey(dict, weightGettingFunction, trim)
	return function()
		local key = getKey()
		local value = dict[key]
		return map(key, value)
	end
end

--[=[
	@within rng

	Returns a boolean indicating whether a random number between 0 and 1 is less than the given chance.

	```lua
	local success = rng.chance(0.5) -- 50% chance of success
	```
]=]
function rng.chance(chance: number): boolean
	return math.random() < chance
end

--[=[
	@within rng

	Returns a boolean indicating whether a random number between 0 and 100 is less than the given percent.

	```lua
	local success = rng.chancePercent(50) -- 50% chance of success
	```
]=]
function rng.chancePercent(percent: number): boolean
	return math.random() * 100 < percent
end

return rng
