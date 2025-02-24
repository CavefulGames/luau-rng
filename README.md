# [luau-rng](https://pesde.dev/packages/caveful_games/rng)
Useful random-related utilities for Luau

## Example Usage
```lua
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
} :: {
	[string]: {
		name: string,
		weight: number
	}
}

local choose = rng.weightedKey(dict, function(_, v)
	return v.weight
end)
```

## Installation
via pesde
```sh
pesde add caveful_games/rng
```

This library is zero-dependency so this can be used as git submodule too
```sh
git submodule add https://github.com/CavefulGames/luau-rng.git submodules/rng
```

## TO-DOs
- [ ] Make docs from moonwave comments

## Credits
- [Chance.js](https://chancejs.com/) - Inspiration and Implementation of `rng.weighted`
