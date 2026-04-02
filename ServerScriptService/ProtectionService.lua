local EconomyConfig = require(game.ReplicatedStorage.Shared.EconomyConfig)

local ProtectionService = {}

local function now()
	return os.time()
end

function ProtectionService:GetMode(profile)
	if profile.Protection.EndsAt > now() then
		return profile.Protection.Mode
	end
	profile.Protection.Mode = "None"
	return "None"
end

function ProtectionService:IsProtected(profile)
	return self:GetMode(profile) ~= "None"
end

function ProtectionService:ActivateFree(profile)
	local t = now()
	if t - (profile.Protection.LastFreeUsedAt or 0) < EconomyConfig.FreeProtectionCooldownSeconds then
		return false, "Free protection cooldown active"
	end
	profile.Protection.Mode = "FreeProtection"
	profile.Protection.EndsAt = t + EconomyConfig.FreeProtectionDurationSeconds
	profile.Protection.LastFreeUsedAt = t
	return true
end

function ProtectionService:ActivatePremium(profile)
	profile.Protection.Mode = "PremiumProtection"
	profile.Protection.EndsAt = now() + EconomyConfig.PremiumProtectionDurationSeconds
	return true
end

return ProtectionService
