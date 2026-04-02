local MutationConfig = {
	BaseChanceByRarityPair = {
		["Common_Common"] = { Common = 0.62, Uncommon = 0.31, Rare = 0.07 },
		["Common_Uncommon"] = { Common = 0.45, Uncommon = 0.42, Rare = 0.12, Epic = 0.01 },
		["Uncommon_Uncommon"] = { Uncommon = 0.56, Rare = 0.34, Epic = 0.10 },
		["Rare_Rare"] = { Rare = 0.58, Epic = 0.34, Legendary = 0.08 },
		["Epic_Legendary"] = { Epic = 0.62, Legendary = 0.34, Mythic = 0.04 },
	},
	Fallback = { Common = 0.45, Uncommon = 0.33, Rare = 0.17, Epic = 0.05 },
	HiddenRecipes = {
		["Nebula Orchid+Volt Lily"] = { species = "Starflare Orchid", rarity = "Epic", chance = 0.11 },
		["Void Ivy+Myco Dragonroot"] = { species = "Abyss Bloom", rarity = "Legendary", chance = 0.07 },
	},
	RandomMutationBonus = 0.05,
}

return MutationConfig
