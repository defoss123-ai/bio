local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlantConfig = require(ReplicatedStorage.Shared.PlantConfig)
local VisualConfig = require(ReplicatedStorage.Shared.VisualConfig)

local VisualService = {}

local gardenFolder

local RARITY_GLOW = {
	Common = Color3.fromRGB(143, 225, 157),
	Uncommon = Color3.fromRGB(119, 238, 225),
	Rare = Color3.fromRGB(120, 180, 255),
	Epic = Color3.fromRGB(186, 131, 255),
	Legendary = Color3.fromRGB(255, 196, 115),
	Mythic = Color3.fromRGB(255, 118, 206),
}

local STEM_COLORS = {
	Fern = Color3.fromRGB(70, 157, 88),
	SproutBush = Color3.fromRGB(91, 175, 95),
	Bulb = Color3.fromRGB(87, 143, 75),
	Vine = Color3.fromRGB(65, 159, 97),
	FangBloom = Color3.fromRGB(115, 139, 83),
	Spiral = Color3.fromRGB(84, 160, 93),
	Orchid = Color3.fromRGB(84, 147, 112),
	Lily = Color3.fromRGB(74, 146, 108),
	Ivy = Color3.fromRGB(58, 137, 98),
	Dragonroot = Color3.fromRGB(93, 124, 91),
}

local function findSpecies(speciesName)
	for _, species in ipairs(PlantConfig.Species) do
		if species.Name == speciesName then
			return species
		end
	end
	return PlantConfig.Species[1]
end

local function createPart(parent, name, shape, size, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CastShadow = true
	part.Shape = shape or Enum.PartType.Block
	part.Size = size
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Parent = parent
	return part
end

local function createSparkles(parent, color)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "BioSparkles"
	emitter.Color = ColorSequence.new(color)
	emitter.Rate = VisualConfig.Effects.SparkleRate
	emitter.Lifetime = VisualConfig.Effects.SparkleLifetime
	emitter.Speed = VisualConfig.Effects.SparkleSpeed
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.22),
		NumberSequenceKeypoint.new(1, 0),
	})
	emitter.SpreadAngle = Vector2.new(15, 30)
	emitter.Parent = parent
	return emitter
end

local function makePlantModel(plant)
	local species = findSpecies(plant.Species)
	local profile = species.Visual or "Fern"
	local model = Instance.new("Model")
	model.Name = "Plant_" .. plant.PlantId

	local stageScale = VisualConfig.StageScale[plant.GrowthStage] or 1
	local finalScale = stageScale * (plant.SizeMultiplier or 1)
	local rarityColor = RARITY_GLOW[plant.Rarity] or VisualConfig.Theme.Primary
	local stemColor = STEM_COLORS[profile] or Color3.fromRGB(79, 158, 90)
	local colorShift = (((plant.MutationGenes or {}).Visual or {}).ColorShift or 0) / 255
	local leafColor = stemColor:Lerp(rarityColor, 0.28):Lerp(Color3.new(1, 1, 1), math.max(0, colorShift))

	local base = createPart(model, "Base", Enum.PartType.Cylinder, Vector3.new(1.15, 1.45, 1.15) * finalScale, stemColor, Enum.Material.Grass)
	base.Orientation = Vector3.new(0, 0, 90)

	if profile == "Fern" or profile == "SproutBush" then
		for i = 1, 6 do
			local leaf = createPart(model, "Leaf", Enum.PartType.Ball, Vector3.new(0.7, 0.24, 1.6) * finalScale, leafColor, Enum.Material.LeafyGrass)
			leaf.Orientation = Vector3.new(0, i * 60, i * 11)
			leaf.Position = base.Position + Vector3.new(0, 0.55 * finalScale, 0)
		end
	elseif profile == "Bulb" then
		local bulb = createPart(model, "Bulb", Enum.PartType.Ball, Vector3.new(1.35, 1.35, 1.35) * finalScale, rarityColor:Lerp(VisualConfig.Theme.Warm, 0.35), Enum.Material.Neon)
		bulb.Position = base.Position + Vector3.new(0, 1.15 * finalScale, 0)
	elseif profile == "Vine" or profile == "Ivy" then
		for i = 1, 4 do
			local vine = createPart(model, "Vine", Enum.PartType.Cylinder, Vector3.new(0.3, 1.8, 0.3) * finalScale, leafColor, Enum.Material.Grass)
			vine.Position = base.Position + Vector3.new((i - 2.5) * 0.34 * finalScale, i * 0.47 * finalScale, 0)
			vine.Orientation = Vector3.new(0, i * 23, 85)
		end
	elseif profile == "FangBloom" or profile == "Orchid" or profile == "Lily" then
		for i = 1, 5 do
			local petal = createPart(model, "Petal", Enum.PartType.Ball, Vector3.new(0.8, 0.24, 1.2) * finalScale, rarityColor, Enum.Material.SmoothPlastic)
			petal.Position = base.Position + Vector3.new(0, 1.28 * finalScale, 0)
			petal.Orientation = Vector3.new(i * 8, i * 72, i * 19)
		end
	elseif profile == "Spiral" then
		for i = 1, 6 do
			local node = createPart(model, "SpiralNode", Enum.PartType.Ball, Vector3.new(0.42, 0.42, 0.42) * finalScale, leafColor, Enum.Material.SmoothPlastic)
			local angle = math.rad(i * 56)
			node.Position = base.Position + Vector3.new(math.cos(angle) * 0.65 * finalScale, i * 0.4 * finalScale, math.sin(angle) * 0.65 * finalScale)
		end
	elseif profile == "Dragonroot" then
		for i = 1, 3 do
			local root = createPart(model, "Root", Enum.PartType.Cylinder, Vector3.new(0.45, 2.3, 0.45) * finalScale, stemColor:Lerp(Color3.new(0.35, 0.22, 0.18), 0.25), Enum.Material.Wood)
			root.Position = base.Position + Vector3.new((i - 2) * 0.65 * finalScale, 0.8 * finalScale, 0)
			root.Orientation = Vector3.new(i * 12, i * 40, 82)
		end
	end

	if (((plant.MutationGenes or {}).Visual or {}).Luminous) or plant.Rarity == "Legendary" or plant.Rarity == "Mythic" then
		local aura = createPart(model, "Aura", Enum.PartType.Ball, Vector3.new(2.6, 2.6, 2.6) * finalScale, rarityColor, Enum.Material.ForceField)
		aura.Transparency = 0.75
		aura.Position = base.Position + Vector3.new(0, 1.15 * finalScale, 0)
		createSparkles(aura, rarityColor)
	end

	model.PrimaryPart = base
	return model
end

local function ensurePostEffects()
	if not Lighting:FindFirstChild("BioAtmosphere") then
		local atmosphere = Instance.new("Atmosphere")
		atmosphere.Name = "BioAtmosphere"
		atmosphere.Density = 0.26
		atmosphere.Offset = 0.2
		atmosphere.Color = VisualConfig.Theme.Glass
		atmosphere.Decay = Color3.fromRGB(69, 103, 102)
		atmosphere.Parent = Lighting
	end

	if not Lighting:FindFirstChild("BioBloom") then
		local bloom = Instance.new("BloomEffect")
		bloom.Name = "BioBloom"
		bloom.Intensity = 0.35
		bloom.Size = 28
		bloom.Threshold = 0.95
		bloom.Parent = Lighting
	end

	if not Lighting:FindFirstChild("BioColor") then
		local color = Instance.new("ColorCorrectionEffect")
		color.Name = "BioColor"
		color.Brightness = 0.02
		color.Contrast = 0.08
		color.Saturation = 0.08
		color.TintColor = Color3.fromRGB(211, 255, 238)
		color.Parent = Lighting
	end

	if not Lighting:FindFirstChild("BioSunRays") then
		local rays = Instance.new("SunRaysEffect")
		rays.Name = "BioSunRays"
		rays.Intensity = 0.08
		rays.Spread = 0.58
		rays.Parent = Lighting
	end
end

local function decoratePlot(plot)
	if plot:FindFirstChild("BioDecorated") then
		return
	end

	local mark = Instance.new("BoolValue")
	mark.Name = "BioDecorated"
	mark.Parent = plot

	local basePart = plot:FindFirstChild("PlotBase") or plot:FindFirstChildWhichIsA("BasePart")
	if not basePart then
		return
	end

	local platform = Instance.new("Part")
	platform.Name = "BioPlatform"
	platform.Anchored = true
	platform.CanCollide = true
	platform.Material = Enum.Material.Slate
	platform.Color = Color3.fromRGB(62, 83, 88)
	platform.Size = Vector3.new(basePart.Size.X, VisualConfig.Plot.PlatformThickness, basePart.Size.Z)
	platform.CFrame = basePart.CFrame + Vector3.new(0, 0.15, 0)
	platform.Parent = plot

	for i = 1, 4 do
		local lamp = Instance.new("Part")
		lamp.Name = "BioLamp"
		lamp.Anchored = true
		lamp.CanCollide = false
		lamp.Material = Enum.Material.Neon
		lamp.Color = i % 2 == 0 and VisualConfig.Theme.Primary or VisualConfig.Theme.Secondary
		lamp.Size = Vector3.new(0.35, 3.4, 0.35)
		local dx = ((i <= 2) and -1 or 1) * ((basePart.Size.X / 2) - 1.2)
		local dz = ((i % 2 == 0) and -1 or 1) * ((basePart.Size.Z / 2) - 1.2)
		lamp.CFrame = basePart.CFrame * CFrame.new(dx, 2.1, dz)
		lamp.Parent = plot
	end

	local marker = Instance.new("Part")
	marker.Name = "PlantAnchor"
	marker.Transparency = 1
	marker.Anchored = true
	marker.CanCollide = false
	marker.Size = Vector3.new(1, 1, 1)
	marker.CFrame = basePart.CFrame + Vector3.new(0, 1.2, 0)
	marker.Parent = plot

	local ambient = Instance.new("ParticleEmitter")
	ambient.Name = "AmbientSpore"
	ambient.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	ambient.Rate = 1
	ambient.Speed = NumberRange.new(0.4, 1.2)
	ambient.Size = NumberSequence.new(0.1)
	ambient.Lifetime = NumberRange.new(2.4, 4)
	ambient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.55),
		NumberSequenceKeypoint.new(1, 1),
	})
	ambient.Color = ColorSequence.new(VisualConfig.Theme.Glass)
	ambient.Parent = marker
end

function VisualService:Init()
	Lighting.ClockTime = VisualConfig.Lighting.ClockTime
	Lighting.Brightness = VisualConfig.Lighting.Brightness
	Lighting.ExposureCompensation = VisualConfig.Lighting.ExposureCompensation
	Lighting.FogStart = VisualConfig.Lighting.FogStart
	Lighting.FogEnd = VisualConfig.Lighting.FogEnd
	Lighting.FogColor = VisualConfig.Lighting.FogColor
	Lighting.Ambient = VisualConfig.Lighting.Ambient
	Lighting.OutdoorAmbient = VisualConfig.Lighting.OutdoorAmbient

	ensurePostEffects()

	gardenFolder = workspace:FindFirstChild("BioGardenRuntime")
	if not gardenFolder then
		gardenFolder = Instance.new("Folder")
		gardenFolder.Name = "BioGardenRuntime"
		gardenFolder.Parent = workspace
	end

	local plots = workspace:FindFirstChild("Plots")
	if plots then
		for _, plot in ipairs(plots:GetChildren()) do
			decoratePlot(plot)
		end
	end
end

function VisualService:GetPlantCFrame(plot, slotIndex, sizeMultiplier)
	local basePart = plot:FindFirstChild("PlotBase") or plot:FindFirstChildWhichIsA("BasePart")
	if not basePart then
		return CFrame.new()
	end

	local cols = VisualConfig.Plot.GridColumns
	local row = math.floor((slotIndex - 1) / cols)
	local col = (slotIndex - 1) % cols
	local spacing = VisualConfig.Plot.GridSpacing + ((sizeMultiplier or 1) > 1.25 and VisualConfig.Plot.LargePlantExtraSpacing or 0)

	local xMin = -(math.floor(cols / 2) * spacing)
	local zMin = -(math.floor(cols / 2) * spacing)
	local x = xMin + (col * spacing)
	local z = zMin + (row * spacing)

	local pos = basePart.CFrame:PointToWorldSpace(Vector3.new(x, 1.2, z))
	return CFrame.new(pos)
end

function VisualService:RenderPlayerGarden(player, profile, plot)
	if not plot then
		return
	end

	decoratePlot(plot)

	local ownerFolder = gardenFolder:FindFirstChild(tostring(player.UserId))
	if not ownerFolder then
		ownerFolder = Instance.new("Folder")
		ownerFolder.Name = tostring(player.UserId)
		ownerFolder.Parent = gardenFolder
	end

	local tracked = {}
	for index, plant in ipairs(profile.Plants) do
		tracked[plant.PlantId] = true
		local model = ownerFolder:FindFirstChild("Plant_" .. plant.PlantId)
		if model then
			model:Destroy()
		end
		model = makePlantModel(plant)
		model.Parent = ownerFolder
		if model.PrimaryPart then
			model:PivotTo(self:GetPlantCFrame(plot, index, plant.SizeMultiplier))
		end
	end

	for _, child in ipairs(ownerFolder:GetChildren()) do
		local id = child.Name:gsub("Plant_", "")
		if not tracked[id] then
			child:Destroy()
		end
	end
end

function VisualService:EmitPlantEvent(plot, plantId, eventName)
	if not plot then
		return
	end
	local ownerId = plot:GetAttribute("OwnerUserId")
	if not ownerId then
		return
	end
	local ownerFolder = gardenFolder and gardenFolder:FindFirstChild(tostring(ownerId))
	if not ownerFolder then
		return
	end
	local model = ownerFolder:FindFirstChild("Plant_" .. plantId)
	if not model or not model.PrimaryPart then
		return
	end

	local emitter = model.PrimaryPart:FindFirstChild("EventBurst")
	if emitter then
		emitter:Destroy()
	end

	emitter = Instance.new("ParticleEmitter")
	emitter.Name = "EventBurst"
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Rate = 0
	emitter.Lifetime = NumberRange.new(0.4, 0.9)
	emitter.Speed = NumberRange.new(4, 8)
	emitter.SpreadAngle = Vector2.new(30, 40)
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 0),
	})
	if eventName == "MutationRare" then
		emitter.Color = ColorSequence.new(VisualConfig.Theme.Accent)
	elseif eventName == "Harvest" then
		emitter.Color = ColorSequence.new(VisualConfig.Theme.Warm)
	elseif eventName == "Steal" then
		emitter.Color = ColorSequence.new(Color3.fromRGB(255, 111, 111))
	else
		emitter.Color = ColorSequence.new(VisualConfig.Theme.Primary)
	end
	emitter.Parent = model.PrimaryPart
	emitter:Emit(eventName == "MutationRare" and 40 or 24)
	game:GetService("Debris"):AddItem(emitter, 1.5)
end

function VisualService:ClearPlayerGarden(userId)
	if not gardenFolder then
		return
	end
	local ownerFolder = gardenFolder:FindFirstChild(tostring(userId))
	if ownerFolder then
		ownerFolder:Destroy()
	end
end

return VisualService
