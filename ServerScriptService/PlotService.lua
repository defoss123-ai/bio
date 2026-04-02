local PlotService = {}

local plots = {}
local playerToPlot = {}

function PlotService:Init()
	local plotFolder = workspace:WaitForChild("Plots")
	for _, plot in ipairs(plotFolder:GetChildren()) do
		table.insert(plots, plot)
	end
end

function PlotService:AssignPlot(player)
	for _, plot in ipairs(plots) do
		if not plot:GetAttribute("OwnerUserId") then
			plot:SetAttribute("OwnerUserId", player.UserId)
			playerToPlot[player.UserId] = plot
			return plot
		end
	end
	return nil
end

function PlotService:GetPlot(player)
	return playerToPlot[player.UserId]
end

function PlotService:TeleportHome(player)
	local plot = self:GetPlot(player)
	if not plot then return end
	local home = plot:FindFirstChild("HomeSpawn")
	local char = player.Character
	if home and char and char.PrimaryPart then
		char:PivotTo(home.CFrame + Vector3.new(0, 4, 0))
	end
end

function PlotService:ReleasePlot(player)
	local plot = playerToPlot[player.UserId]
	if plot then
		plot:SetAttribute("OwnerUserId", nil)
		playerToPlot[player.UserId] = nil
	end
end

return PlotService
