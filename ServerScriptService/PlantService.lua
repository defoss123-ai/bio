local HttpService = game:GetService("HttpService")
local PlantConfig = require(game.ReplicatedStorage.Shared.PlantConfig)
local RarityConfig = require(game.ReplicatedStorage.Shared.RarityConfig)
local VisualConfig = require(game.ReplicatedStorage.Shared.VisualConfig)

local PlantService = {}

local function randomMood()
	local keys = {}
	for mood, _ in pairs(PlantConfig.Moods) do
		table.insert(keys, mood)
	end
	return keys[math.random(1, #keys)]
end

local function getGrowthProgress(plant)
	local moodMulti = PlantConfig.Moods[plant.Mood] and PlantConfig.Moods[plant.Mood].growth or 1
	local elapsed = os.time() - (plant.CreatedAt or os.time())
	local stageOrder = PlantConfig.GrowthStages
	local total = 0
	for _, stage in ipairs(stageOrder) do
		if stage == "Evolved" then
			break
		end
		local duration = math.floor((PlantConfig.StageDurations[stage] or 30) / moodMulti)
		total += duration
		if elapsed < total then
			return stage
		end
	end
	return "Evolved"
end

local function rollVisualMutation()
	return {
		Prismatic = math.random() <= VisualConfig.MutationVisuals.PrismaticChance,
		Titan = math.random() <= VisualConfig.MutationVisuals.TitanChance,
		Luminous = math.random() <= VisualConfig.MutationVisuals.LuminousChance,
		ColorShift = math.random(-VisualConfig.MutationVisuals.ColorShiftRange, VisualConfig.MutationVisuals.ColorShiftRange),
	}
end

function PlantService:CreatePlant(ownerUserId, speciesData)
	local visualMutation = rollVisualMutation()
	return {
		PlantId = HttpService:GenerateGUID(false),
		Species = speciesData.Name,
		Name = speciesData.Name,
		Rarity = speciesData.Rarity,
		Level = 1,
		GrowthStage = "Seed",
		Mood = randomMood(),
		Health = 100,
		MutationGenes = {
			Visual = visualMutation,
		},
		SellPrice = speciesData.SellPrice,
		ProductionRate = speciesData.ProductionRate,
		Stealable = false,
		ProtectedUntil = 0,
		OwnerUserId = ownerUserId,
		CreatedAt = os.time(),
		LastHarvestAt = os.time(),
		SizeMultiplier = visualMutation.Titan and math.random(120, 150) / 100 or math.random(92, 118) / 100,
	}
end

function PlantService:GetSpeciesByName(speciesName)
	for _, species in ipairs(PlantConfig.Species) do
		if species.Name == speciesName then
			return species
		end
	end
	return PlantConfig.Species[1]
end

function PlantService:TickPlant(plant)
	plant.GrowthStage = getGrowthProgress(plant)
	plant.Stealable = plant.GrowthStage == "Mature" or plant.GrowthStage == "Evolved"
	return plant.GrowthStage
end

function PlantService:GetStageScale(plant)
	local stageScale = VisualConfig.StageScale[plant.GrowthStage] or 1
	return stageScale * (plant.SizeMultiplier or 1)
end

function PlantService:Harvest(plant)
	if plant.GrowthStage ~= "Mature" and plant.GrowthStage ~= "Evolved" then
		return 0
	end
	local elapsed = math.max(1, os.time() - (plant.LastHarvestAt or os.time()))
	plant.LastHarvestAt = os.time()
	local mood = PlantConfig.Moods[plant.Mood]
	local rarityMultiplier = RarityConfig.Multipliers[plant.Rarity] or 1
	return math.floor((elapsed / 10) * plant.ProductionRate * mood.income * rarityMultiplier)
end

return PlantService
