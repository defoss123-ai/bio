local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local MonetizationService = {}

MonetizationService.Products = {
	Coins1000 = 3567502722,
	Coins5000 = 3567503034,
	Donate10 = 3568008173,
	Donate50 = 3568008392,
	Donate100 = 3568008795,
	Protection = 3567814697,
	StealAPlant = 3567811809,
}

function MonetizationService:Init(services)
	self.DataService = services.DataService
	self.ProtectionService = services.ProtectionService

	local productHandlers = {
		[self.Products.Coins1000] = function(profile)
			profile.Coins += 1000
		end,
		[self.Products.Coins5000] = function(profile)
			profile.Coins += 5000
		end,
		[self.Products.Donate10] = function(profile)
			profile.Stats.TotalDonated += 10
		end,
		[self.Products.Donate50] = function(profile)
			profile.Stats.TotalDonated += 50
		end,
		[self.Products.Donate100] = function(profile)
			profile.Stats.TotalDonated += 100
		end,
		[self.Products.Protection] = function(profile)
			self.ProtectionService:ActivatePremium(profile)
		end,
		[self.Products.StealAPlant] = function(profile)
			profile.Raid.Charges += 1
		end,
	}

	MarketplaceService.ProcessReceipt = function(receiptInfo)
		if self.DataService:WasReceiptProcessed(receiptInfo.PurchaseId) then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end

		local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if not player then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		local profile = self.DataService:GetProfile(player)
		if not profile then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local handler = productHandlers[receiptInfo.ProductId]
		if not handler then
			warn("Unknown product id:", receiptInfo.ProductId)
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end

		handler(profile)
		table.insert(profile.Transactions, {
			PurchaseId = receiptInfo.PurchaseId,
			ProductId = receiptInfo.ProductId,
			At = os.time(),
		})

		self.DataService:RecordReceipt(receiptInfo.PurchaseId)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end

return MonetizationService
