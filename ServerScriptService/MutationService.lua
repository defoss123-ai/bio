local MutationConfig = require(game.ReplicatedStorage.Shared.MutationConfig)
local PlantConfig = require(game.ReplicatedStorage.Shared.PlantConfig)

local MutationService = {}

local function pairKey(a, b)
	if a < b then
		return a .. "_" .. b
	end
	return b .. "_" .. a
end

local function weightedRoll(weights)
	local roll = math.random()
	local total = 0
	for rarity, chance in pairs(weights) do
		total += chance
		if roll <= total then
			return rarity
		end
	end
	return "Common"
end

local function mutateWeights(weights, mutationBoost)
	local modified = {}
	for rarity, chance in pairs(weights) do
		modified[rarity] = chance
	end

	if mutationBoost > 1.0 then
		local bonus = math.min(0.08, (mutationBoost - 1.0) * 0.16)
		modified.Common = math.max(0.2, (modified.Common or 0) - bonus)
		modified.Uncommon = math.max(0.1, (modified.Uncommon or 0) - bonus * 0.3)
		modified.Rare = (modified.Rare or 0) + bonus * 0.6
		modified.Epic = (modified.Epic or 0) + bonus * 0.5
		modified.Legendary = (modified.Legendary or 0) + bonus * 0.2
	end

	local sum = 0
	for _, v in pairs(modified) do
		sum += v
	end
	for rarity, v in pairs(modified) do
		modified[rarity] = v / sum
	end

	return modified
end

function MutationService:GetOutcome(parentA, parentB)
	local hiddenKeyA = parentA.Species .. "+" .. parentB.Species
	local hiddenKeyB = parentB.Species .. "+" .. parentA.Species
	local hidden = MutationConfig.HiddenRecipes[hiddenKeyA] or MutationConfig.HiddenRecipes[hiddenKeyB]
	if hidden and math.random() <= hidden.chance then
		return hidden.rarity, hidden.species, true
	end

	local key = pairKey(parentA.Rarity, parentB.Rarity)
	local weights = MutationConfig.BaseChanceByRarityPair[key] or MutationConfig.Fallback

	local moodA = PlantConfig.Moods[parentA.Mood] and PlantConfig.Moods[parentA.Mood].mutation or 1
	local moodB = PlantConfig.Moods[parentB.Mood] and PlantConfig.Moods[parentB.Mood].mutation or 1
	weights = mutateWeights(weights, (moodA + moodB) / 2)

	local rarity = weightedRoll(weights)
	local bonus = math.random() <= MutationConfig.RandomMutationBonus
	return rarity, nil, bonus
end

return MutationService
