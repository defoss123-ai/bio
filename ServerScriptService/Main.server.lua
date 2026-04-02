local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(script.Parent.DataService)
local PlotService = require(script.Parent.PlotService)
local PlantService = require(script.Parent.PlantService)
local MutationService = require(script.Parent.MutationService)
local ProtectionService = require(script.Parent.ProtectionService)
local RaidService = require(script.Parent.RaidService)
local MonetizationService = require(script.Parent.MonetizationService)
local LeaderstatsService = require(script.Parent.LeaderstatsService)
local VisualService = require(script.Parent.VisualService)

local PlantConfig = require(ReplicatedStorage.Shared.PlantConfig)
local EconomyConfig = require(ReplicatedStorage.Shared.EconomyConfig)

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local RequestPlant = remotes:WaitForChild("RequestPlant")
local HarvestPlant = remotes:WaitForChild("HarvestPlant")
local OpenMutation = remotes:WaitForChild("OpenMutation")
local ActivateFreeProtection = remotes:WaitForChild("ActivateFreeProtection")
local RequestStealPlant = remotes:WaitForChild("RequestStealPlant")
local TeleportToPlayerPlot = remotes:WaitForChild("TeleportToPlayerPlot")
local BuyProtection = remotes:WaitForChild("BuyProtection")

PlotService:Init()
VisualService:Init()
MonetizationService:Init({
	DataService = DataService,
	ProtectionService = ProtectionService,
})

local playerDebounces = {}

local function validateRateLimit(player, key, gap)
	playerDebounces[player.UserId] = playerDebounces[player.UserId] or {}
	local cache = playerDebounces[player.UserId]
	local t = os.clock()
	if cache[key] and t - cache[key] < gap then
		return false
	end
	cache[key] = t
	return true
end

local function syncPlayerGarden(player)
	local profile = DataService:GetProfile(player)
	local plot = PlotService:GetPlot(player)
	if not profile or not plot then
		return
	end
	for _, plant in ipairs(profile.Plants) do
		PlantService:TickPlant(plant)
	end
	VisualService:RenderPlayerGarden(player, profile, plot)
	LeaderstatsService:Refresh(player, profile)
end

Players.PlayerAdded:Connect(function(player)
	local profile = DataService:LoadProfile(player)
	if profile.Coins <= 0 then
		profile.Coins = EconomyConfig.StartingCoins
	end
	local plot = PlotService:AssignPlot(player)
	if not plot then
		warn("No free plot for", player.Name)
		return
	end
	LeaderstatsService:Attach(player, profile)

	if #profile.Plants == 0 then
		local starter = PlantService:CreatePlant(player.UserId, PlantConfig.Species[1])
		table.insert(profile.Plants, starter)
	end

	syncPlayerGarden(player)
	PlotService:TeleportHome(player)
end)

Players.PlayerRemoving:Connect(function(player)
	VisualService:ClearPlayerGarden(player.UserId)
	PlotService:ReleasePlot(player)
	playerDebounces[player.UserId] = nil
end)

RequestPlant.OnServerEvent:Connect(function(player, speciesName)
	if not validateRateLimit(player, "RequestPlant", 0.25) then return end
	local profile = DataService:GetProfile(player)
	if not profile then return end
	if #profile.Plants >= EconomyConfig.MaxActivePlants then return end
	if profile.Coins < EconomyConfig.PlantCost then return end

	local species = PlantService:GetSpeciesByName(speciesName)
	profile.Coins -= EconomyConfig.PlantCost
	table.insert(profile.Plants, PlantService:CreatePlant(player.UserId, species))
	syncPlayerGarden(player)
end)

HarvestPlant.OnServerEvent:Connect(function(player, plantId)
	if not validateRateLimit(player, "HarvestPlant", 0.2) then return end
	local profile = DataService:GetProfile(player)
	if not profile then return end
	for _, plant in ipairs(profile.Plants) do
		if plant.PlantId == plantId then
			PlantService:TickPlant(plant)
			local gain = PlantService:Harvest(plant)
			profile.Coins += gain
			profile.Stats.CoinsEarned += gain
			local plot = PlotService:GetPlot(player)
			VisualService:EmitPlantEvent(plot, plant.PlantId, "Harvest")
			LeaderstatsService:Refresh(player, profile)
			return
		end
	end
end)

OpenMutation.OnServerInvoke = function(player, parentAId, parentBId)
	local profile = DataService:GetProfile(player)
	if not profile then return false, "No profile" end
	if profile.Coins < EconomyConfig.MutationCost then
		return false, "Not enough coins"
	end

	local parentA, parentB
	for _, plant in ipairs(profile.Plants) do
		if plant.PlantId == parentAId then parentA = plant end
		if plant.PlantId == parentBId then parentB = plant end
	end
	if not parentA or not parentB then
		return false, "Parents not found"
	end
	if parentA.GrowthStage == "Seed" or parentB.GrowthStage == "Seed" then
		return false, "Parents too young"
	end

	profile.Coins -= EconomyConfig.MutationCost
	local rarity, forcedSpecies, bonus = MutationService:GetOutcome(parentA, parentB)
	local speciesData = PlantConfig.Species[math.random(1, #PlantConfig.Species)]
	local child = PlantService:CreatePlant(player.UserId, speciesData)
	child.Rarity = rarity
	if forcedSpecies then
		child.Species = forcedSpecies
		child.Name = forcedSpecies
	end
	if bonus then
		child.Level = 2
		child.SizeMultiplier = (child.SizeMultiplier or 1) + 0.12
	end
	table.insert(profile.Plants, child)
	profile.Stats.PlantsCreated += 1
	syncPlayerGarden(player)
	local mutationEvent = ((rarity == "Legendary" or rarity == "Mythic") and "MutationRare") or "Mutation"
	VisualService:EmitPlantEvent(PlotService:GetPlot(player), child.PlantId, mutationEvent)
	return true, child
end

ActivateFreeProtection.OnServerEvent:Connect(function(player)
	if not validateRateLimit(player, "ActivateFreeProtection", 0.5) then return end
	local profile = DataService:GetProfile(player)
	if not profile then return end
	local ok, err = ProtectionService:ActivateFree(profile)
	if not ok then
		warn("Free protection failed:", err)
		return
	end
	local plot = PlotService:GetPlot(player)
	if plot then
		for _, plant in ipairs(profile.Plants) do
			VisualService:EmitPlantEvent(plot, plant.PlantId, "Protection")
		end
	end
end)

BuyProtection.OnServerEvent:Connect(function(player)
	game:GetService("MarketplaceService"):PromptProductPurchase(player, MonetizationService.Products.Protection)
end)

TeleportToPlayerPlot.OnServerEvent:Connect(function(player, targetUserId)
	if not validateRateLimit(player, "TeleportToPlayerPlot", 1.0) then return end
	local target = Players:GetPlayerByUserId(targetUserId)
	if not target then return end
	local plot = PlotService:GetPlot(target)
	if not plot then return end
	local visitorSpawn = target == player and plot:FindFirstChild("HomeSpawn") or plot:FindFirstChild("VisitorSpawn")
	if visitorSpawn and player.Character and player.Character.PrimaryPart then
		player.Character:PivotTo(visitorSpawn.CFrame + Vector3.new(0, 4, 0))
	end
end)

RequestStealPlant.OnServerEvent:Connect(function(player, victimUserId, plantId)
	if not validateRateLimit(player, "RequestStealPlant", 0.5) then return end
	local attackerProfile = DataService:GetProfile(player)
	local victim = Players:GetPlayerByUserId(victimUserId)
	if not attackerProfile or not victim then return end
	local victimProfile = DataService:GetProfile(victim)
	if not victimProfile then return end

	local victimPlant, victimIndex
	for i, plant in ipairs(victimProfile.Plants) do
		if plant.PlantId == plantId then
			victimPlant = plant
			victimIndex = i
			break
		end
	end

	local canSteal, reason = RaidService:CanSteal(attackerProfile, victimProfile, victimPlant)
	if not canSteal then
		warn("Steal denied", reason)
		return
	end

	RaidService:ConsumeStealAttempt(attackerProfile)
	attackerProfile.Stats.PlantsStolen += 1

	local stolenCopy = table.clone(victimPlant)
	stolenCopy.PlantId = game:GetService("HttpService"):GenerateGUID(false)
	stolenCopy.OwnerUserId = player.UserId
	table.insert(attackerProfile.Inventory, stolenCopy)

	if EconomyConfig.SoftSteal then
		victimPlant.Health = math.max(20, victimPlant.Health - 35)
		victimPlant.ProductionRate = math.max(1, math.floor(victimPlant.ProductionRate * 0.75))
	else
		table.remove(victimProfile.Plants, victimIndex)
	end

	local victimPlot = PlotService:GetPlot(victim)
	VisualService:EmitPlantEvent(victimPlot, plantId, "Steal")
	syncPlayerGarden(victim)
	LeaderstatsService:Refresh(player, attackerProfile)
end)

task.spawn(function()
	while true do
		task.wait(EconomyConfig.GrowthTickIntervalSeconds)
		for _, player in ipairs(Players:GetPlayers()) do
			syncPlayerGarden(player)
		end
	end
end)
