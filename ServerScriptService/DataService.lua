local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local DataService = {}
local PROFILE_STORE = DataStoreService:GetDataStore("BioGardenProfiles_v1")
local RECEIPT_STORE = DataStoreService:GetDataStore("BioGardenReceipts_v1")

local defaultProfile = {
	Coins = 0,
	Plants = {},
	Inventory = {},
	PlotUpgrades = {},
	Protection = { Mode = "None", EndsAt = 0, LastFreeUsedAt = 0 },
	Stats = { PlantsCreated = 0, PlantsStolen = 0, CoinsEarned = 0, TotalDonated = 0 },
	Raid = { DailyStealsUsed = 0, LastResetDay = 0, Charges = 0 },
	Transactions = {},
}

local profiles = {}

local function deepCopy(template)
	local copy = {}
	for k, v in pairs(template) do
		if type(v) == "table" then
			copy[k] = deepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

local function retry(maxRetries, fn)
	local tries = 0
	while tries < maxRetries do
		tries += 1
		local ok, result = pcall(fn)
		if ok then
			return true, result
		end
		task.wait(1 + tries)
	end
	return false, nil
end

function DataService:GetProfile(player)
	return profiles[player.UserId]
end

function DataService:LoadProfile(player)
	local key = ("player_%d"):format(player.UserId)
	local ok, data = retry(5, function()
		return PROFILE_STORE:GetAsync(key)
	end)
	local profile = deepCopy(defaultProfile)
	if ok and type(data) == "table" then
		for k, v in pairs(data) do
			profile[k] = v
		end
	end
	profiles[player.UserId] = profile
	return profile
end

function DataService:SaveProfile(userId)
	local profile = profiles[userId]
	if not profile then
		return
	end
	local key = ("player_%d"):format(userId)
	retry(5, function()
		PROFILE_STORE:SetAsync(key, profile)
	end)
end

function DataService:RecordReceipt(purchaseId)
	local ok = retry(5, function()
		RECEIPT_STORE:SetAsync(tostring(purchaseId), true)
	end)
	return ok
end

function DataService:WasReceiptProcessed(purchaseId)
	local ok, value = retry(3, function()
		return RECEIPT_STORE:GetAsync(tostring(purchaseId))
	end)
	if not ok then
		return false
	end
	return value == true
end

Players.PlayerRemoving:Connect(function(player)
	DataService:SaveProfile(player.UserId)
	profiles[player.UserId] = nil
end)

task.spawn(function()
	while true do
		task.wait(60)
		for _, player in ipairs(Players:GetPlayers()) do
			DataService:SaveProfile(player.UserId)
		end
	end
end)

return DataService
