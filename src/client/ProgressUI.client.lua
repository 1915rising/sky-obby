--!strict
--[[
	ProgressUI.client.lua
	Local script (StarterPlayerScripts)

	Builds the in-game UI entirely in code:
	  * A stage counter at the top of the screen ("Stage 3 / 8") that
	    follows the player's Stage leaderstat.
	  * A banner that appears whenever someone finishes the course
	    (driven by the WinEvent RemoteEvent fired from the server).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local CourseConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CourseConfig"))
local WinEvent = ReplicatedStorage:WaitForChild("WinEvent") :: RemoteEvent

local totalStages = #CourseConfig.Stages

-- Stage counter ------------------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "ProgressGui"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10

local stageFrame = Instance.new("Frame")
stageFrame.Name = "StageFrame"
stageFrame.AnchorPoint = Vector2.new(0.5, 0)
stageFrame.Position = UDim2.new(0.5, 0, 0, 16)
stageFrame.Size = UDim2.new(0, 220, 0, 44)
stageFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 38)
stageFrame.BackgroundTransparency = 0.25
stageFrame.BorderSizePixel = 0
stageFrame.Parent = gui

local stageCorner = Instance.new("UICorner")
stageCorner.CornerRadius = UDim.new(0, 10)
stageCorner.Parent = stageFrame

local stageLabel = Instance.new("TextLabel")
stageLabel.Name = "StageLabel"
stageLabel.Size = UDim2.fromScale(1, 1)
stageLabel.BackgroundTransparency = 1
stageLabel.Font = Enum.Font.GothamBold
stageLabel.TextSize = 20
stageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
stageLabel.Text = string.format("Stage 1 / %d", totalStages)
stageLabel.Parent = stageFrame

-- Win banner ---------------------------------------------------------------

local banner = Instance.new("TextLabel")
banner.Name = "WinBanner"
banner.AnchorPoint = Vector2.new(0.5, 0)
banner.Position = UDim2.new(0.5, 0, 0, 76)
banner.Size = UDim2.new(0, 460, 0, 52)
banner.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
banner.BackgroundTransparency = 1
banner.BorderSizePixel = 0
banner.Font = Enum.Font.GothamBold
banner.TextSize = 24
banner.TextColor3 = Color3.fromRGB(40, 32, 0)
banner.TextTransparency = 1
banner.Text = ""
banner.Parent = gui

local bannerCorner = Instance.new("UICorner")
bannerCorner.CornerRadius = UDim.new(0, 10)
bannerCorner.Parent = banner

gui.Parent = playerGui

-- Live updates ---------------------------------------------------------------

local leaderstats = player:WaitForChild("leaderstats")
local stageStat = leaderstats:WaitForChild("Stage") :: IntValue

local function refreshStageLabel()
	stageLabel.Text = string.format("Stage %d / %d", stageStat.Value, totalStages)
end

refreshStageLabel()
stageStat.Changed:Connect(refreshStageLabel)

local bannerGeneration = 0
WinEvent.OnClientEvent:Connect(function(winnerName: string)
	bannerGeneration += 1
	local generation = bannerGeneration

	if winnerName == player.Name then
		banner.Text = "You win! Course complete!"
	else
		banner.Text = string.format("%s finished the course!", winnerName)
	end
	banner.BackgroundTransparency = 0.1
	banner.TextTransparency = 0

	task.delay(4, function()
		-- Only hide if no newer finish has replaced this banner.
		if generation == bannerGeneration then
			banner.BackgroundTransparency = 1
			banner.TextTransparency = 1
		end
	end)
end)
