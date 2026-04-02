local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("MainHUD")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local RequestPlant = remotes:WaitForChild("RequestPlant")
local ActivateFreeProtection = remotes:WaitForChild("ActivateFreeProtection")
local BuyProtection = remotes:WaitForChild("BuyProtection")
local TeleportToPlayerPlot = remotes:WaitForChild("TeleportToPlayerPlot")

local palette = {
	bg = Color3.fromRGB(14, 34, 38),
	panel = Color3.fromRGB(21, 50, 58),
	text = Color3.fromRGB(222, 250, 233),
	primary = Color3.fromRGB(99, 224, 180),
	secondary = Color3.fromRGB(117, 171, 255),
	warning = Color3.fromRGB(255, 185, 121),
}

local function ensureCorner(instance, radius)
	local corner = instance:FindFirstChildOfClass("UICorner")
	if not corner then
		corner = Instance.new("UICorner")
		corner.Parent = instance
	end
	corner.CornerRadius = UDim.new(0, radius)
end

local function styleButton(button, color)
	button.BackgroundColor3 = color
	button.TextColor3 = palette.text
	button.Font = Enum.Font.GothamSemibold
	button.TextScaled = true
	ensureCorner(button, 11)

	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.16), { BackgroundColor3 = color:Lerp(Color3.new(1, 1, 1), 0.1) }):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.16), { BackgroundColor3 = color }):Play()
	end)

	button.MouseButton1Down:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.05), { Size = button.Size - UDim2.new(0, 2, 0, 2) }):Play()
	end)
	button.MouseButton1Up:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.08), { Size = button.Size + UDim2.new(0, 2, 0, 2) }):Play()
	end)
end

local function styleHUD()
	local root = gui:FindFirstChild("MainButtons")
	if not root then
		return
	end

	root.BackgroundColor3 = palette.panel
	root.BackgroundTransparency = 0.08
	ensureCorner(root, 14)

	local stroke = root:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	stroke.Color = palette.primary
	stroke.Transparency = 0.42
	stroke.Thickness = 1.5
	stroke.Parent = root

	if root:FindFirstChild("PlantButton") then
		styleButton(root.PlantButton, palette.primary)
	end
	if root:FindFirstChild("FreeShieldButton") then
		styleButton(root.FreeShieldButton, palette.secondary)
	end
	if root:FindFirstChild("PremiumShieldButton") then
		styleButton(root.PremiumShieldButton, palette.warning)
	end
	if root:FindFirstChild("HomeButton") then
		styleButton(root.HomeButton, Color3.fromRGB(82, 193, 223))
	end
end

local function bindCoins()
	local coinsLabel = gui:FindFirstChild("CoinsLabel")
	if not coinsLabel then
		return
	end

	coinsLabel.BackgroundColor3 = palette.bg
	coinsLabel.TextColor3 = palette.text
	coinsLabel.Font = Enum.Font.GothamBold
	coinsLabel.TextScaled = true
	ensureCorner(coinsLabel, 10)

	local ls = player:WaitForChild("leaderstats", 15)
	if not ls then
		return
	end
	local coins = ls:WaitForChild("Coins", 15)
	if not coins then
		return
	end

	local function refresh()
		coinsLabel.Text = ("🪙 Coins: %d"):format(coins.Value)
	end
	coins:GetPropertyChangedSignal("Value"):Connect(refresh)
	refresh()
end

styleHUD()
bindCoins()

local main = gui:FindFirstChild("MainButtons")
if not main then
	return
end

-- Polished interaction wiring.
if main:FindFirstChild("PlantButton") then
	main.PlantButton.MouseButton1Click:Connect(function()
		RequestPlant:FireServer("Glow Fern")
	end)
end

if main:FindFirstChild("FreeShieldButton") then
	main.FreeShieldButton.MouseButton1Click:Connect(function()
		ActivateFreeProtection:FireServer()
	end)
end

if main:FindFirstChild("PremiumShieldButton") then
	main.PremiumShieldButton.MouseButton1Click:Connect(function()
		BuyProtection:FireServer()
	end)
end

if main:FindFirstChild("HomeButton") then
	main.HomeButton.MouseButton1Click:Connect(function()
		TeleportToPlayerPlot:FireServer(player.UserId)
	end)
end
