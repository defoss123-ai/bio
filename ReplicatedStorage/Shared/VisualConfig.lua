local VisualConfig = {
	Theme = {
		Primary = Color3.fromRGB(96, 214, 175),
		Secondary = Color3.fromRGB(120, 167, 255),
		Accent = Color3.fromRGB(176, 118, 255),
		Warm = Color3.fromRGB(255, 199, 130),
		Soil = Color3.fromRGB(88, 65, 47),
		Glass = Color3.fromRGB(189, 244, 255),
	},
	Lighting = {
		ClockTime = 15.6,
		Brightness = 2.35,
		ExposureCompensation = 0.1,
		FogStart = 120,
		FogEnd = 630,
		FogColor = Color3.fromRGB(148, 210, 188),
		Ambient = Color3.fromRGB(63, 84, 86),
		OutdoorAmbient = Color3.fromRGB(104, 132, 122),
	},
	Plot = {
		GridColumns = 5,
		GridSpacing = 8,
		PlotPadding = 7,
		PlanterSize = Vector3.new(6.6, 1.1, 6.6),
		PlatformThickness = 2,
		LargePlantExtraSpacing = 2,
	},
	StageScale = {
		Seed = 0.4,
		Sprout = 0.65,
		Young = 0.9,
		Mature = 1.15,
		Evolved = 1.35,
	},
	MutationVisuals = {
		PrismaticChance = 0.1,
		TitanChance = 0.08,
		LuminousChance = 0.18,
		ColorShiftRange = 22,
	},
	Effects = {
		SparkleLifetime = NumberRange.new(0.35, 0.7),
		SparkleSpeed = NumberRange.new(0.8, 2.8),
		SparkleRate = 0,
	},
}

return VisualConfig
