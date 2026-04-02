local EconomyConfig = require(game.ReplicatedStorage.Shared.EconomyConfig)

local RaidService = {}

function RaidService:CanSteal(attackerProfile, victimProfile, victimPlant)
	if not victimPlant then
		return false, "Plant missing"
	end
	if victimPlant.GrowthStage ~= "Mature" and victimPlant.GrowthStage ~= "Evolved" then
		return false, "Plant not mature"
	end
	if victimPlant.Name == "Glow Fern" and victimPlant.Level == 1 then
		return false, "Starter plant is protected"
	end
	if victimProfile.Protection.EndsAt > os.time() then
		return false, "Plot protected"
	end
	local day = os.date("!*t").yday
	if attackerProfile.Raid.LastResetDay ~= day then
		attackerProfile.Raid.DailyStealsUsed = 0
		attackerProfile.Raid.LastResetDay = day
	end
	local hasCharge = attackerProfile.Raid.Charges > 0
	if attackerProfile.Raid.DailyStealsUsed >= EconomyConfig.DailyFreeSteals and not hasCharge then
		return false, "Steal limit reached"
	end
	return true
end

function RaidService:ConsumeStealAttempt(attackerProfile)
	if attackerProfile.Raid.Charges > 0 then
		attackerProfile.Raid.Charges -= 1
	else
		attackerProfile.Raid.DailyStealsUsed += 1
	end
end

return RaidService
