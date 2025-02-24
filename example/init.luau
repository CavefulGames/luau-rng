local rng = require("../")

print(rng.betweenFloats(-5, 5))
print(rng.chance(0.5))
print(rng.chancePercent(50))
print(rng.tonumber(5))
print(rng.weighted({ "a", "b", "c" }, { 1, 2, 3 })())
local dict = {
	a = {
		name = "Alpha",
		weight = 0.1,
	},
	b = {
		name = "Beta",
		weight = 0.2,
	},
	c = {
		name = "Charlie",
		weight = 0.3,
	}
} :: { [string]: { name: string, weight: number } }
print(rng.weightedKey(dict, function(_, v)
	return v.weight
end)())
print(rng.weightedKeyMapped(dict, function(_, v)
	return v.weight
end, function(_, v)
	return v.name
end)())
