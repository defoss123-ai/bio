local PlantConfig = {
	Species = {
		{ Name = "Glow Fern", Rarity = "Common", ProductionRate = 3, SellPrice = 18, Visual = "Fern" },
		{ Name = "Moss Hopper", Rarity = "Common", ProductionRate = 4, SellPrice = 22, Visual = "SproutBush" },
		{ Name = "Sun Bulb", Rarity = "Common", ProductionRate = 5, SellPrice = 25, Visual = "Bulb" },
		{ Name = "Crystal Vine", Rarity = "Uncommon", ProductionRate = 7, SellPrice = 40, Visual = "Vine" },
		{ Name = "Bloom Fang", Rarity = "Uncommon", ProductionRate = 8, SellPrice = 45, Visual = "FangBloom" },
		{ Name = "Spiral Cactus", Rarity = "Uncommon", ProductionRate = 9, SellPrice = 50, Visual = "Spiral" },
		{ Name = "Nebula Orchid", Rarity = "Rare", ProductionRate = 12, SellPrice = 80, Visual = "Orchid" },
		{ Name = "Volt Lily", Rarity = "Rare", ProductionRate = 13, SellPrice = 90, Visual = "Lily" },
		{ Name = "Void Ivy", Rarity = "Rare", ProductionRate = 14, SellPrice = 100, Visual = "Ivy" },
		{ Name = "Myco Dragonroot", Rarity = "Epic", ProductionRate = 18, SellPrice = 140, Visual = "Dragonroot" },
		{ Name = "Starflare Orchid", Rarity = "Epic", ProductionRate = 20, SellPrice = 160, Visual = "Orchid" },
		{ Name = "Abyss Bloom", Rarity = "Legendary", ProductionRate = 24, SellPrice = 220, Visual = "FangBloom" },
	},
	Moods = {
		Calm = { growth = 1.05, mutation = 1.0, income = 1.0 },
		Moody = { growth = 0.95, mutation = 1.1, income = 1.0 },
		Aggressive = { growth = 1.0, mutation = 1.05, income = 1.1 },
		Lazy = { growth = 0.85, mutation = 0.95, income = 0.9 },
		Energetic = { growth = 1.15, mutation = 1.0, income = 1.15 },
		Chaotic = { growth = 1.0, mutation = 1.3, income = 0.95 },
	},
	GrowthStages = { "Seed", "Sprout", "Young", "Mature", "Evolved" },
	-- Slower curve to better match BioSim-like "watch it grow" pacing.
	StageDurations = {
		Seed = 45,
		Sprout = 85,
		Young = 140,
		Mature = 220,
	},
}

return PlantConfig
