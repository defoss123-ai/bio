local LeaderstatsService = {}

function LeaderstatsService:Attach(player, profile)
	local folder = Instance.new("Folder")
	folder.Name = "leaderstats"
	folder.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = profile.Coins
	coins.Parent = folder

	local plants = Instance.new("IntValue")
	plants.Name = "Plants"
	plants.Value = #profile.Plants
	plants.Parent = folder

	return folder
end

function LeaderstatsService:Refresh(player, profile)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	leaderstats.Coins.Value = profile.Coins
	leaderstats.Plants.Value = #profile.Plants
end

return LeaderstatsService
