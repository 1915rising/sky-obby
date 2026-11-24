--!strict
--[[
	Main.server.lua
	Server script (ServerScriptService)

	Game logic for Sky Obby:
	  * Builds the course (CourseBuilder) when the server starts.
	  * Gives every player leaderstats: Stage (highest checkpoint reached)
	    and Wins (times the course has been finished).
	  * Touching a checkpoint pad makes it the player's respawn point.
	  * Touching the win pad records a finish, announces it to everyone
	    through the WinEvent RemoteEvent, and sends the player back to
	    stage 1 for another run.
	  * Players who fall below the course are killed and respawn at
	    their checkpoint.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local serverFolder = script.Parent
assert(serverFolder, "Main.server.lua must be parented to the server folder")
local CourseBuilder = require(serverFolder:WaitForChild("CourseBuilder"))
local CourseConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CourseConfig"))

local WinEvent = ReplicatedStorage:WaitForChild("WinEvent") :: RemoteEvent

local course = CourseBuilder.build()

-- Per-player state, keyed by the Player instance.
local respawnPoints: { [Player]: CFrame } = {}
local winDebounce: { [Player]: boolean } = {}

local function getLeaderstats(player: Player): Folder?
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats and leaderstats:IsA("Folder") then
		return leaderstats
	end
	return nil
end

local function getStat(player: Player, statName: string): IntValue?
	local leaderstats = getLeaderstats(player)
	if not leaderstats then
		return nil
	end
	local stat = leaderstats:FindFirstChild(statName)
	if stat and stat:IsA("IntValue") then
		return stat
	end
	return nil
end

local function teleportToRespawn(player: Player)
	local character = player.Character
	if not character then
		return
	end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if rootPart and rootPart:IsA("BasePart") then
		rootPart.CFrame = respawnPoints[player] or course.checkpoints[1]
		rootPart.AssemblyLinearVelocity = Vector3.zero
	end
end

local function onCharacterAdded(player: Player, character: Model)
	-- Wait for the root part, then place the character at its checkpoint.
	character:WaitForChild("HumanoidRootPart")
	teleportToRespawn(player)
end

local function onPlayerAdded(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	local stage = Instance.new("IntValue")
	stage.Name = "Stage"
	stage.Value = 1
	stage.Parent = leaderstats

	local wins = Instance.new("IntValue")
	wins.Name = "Wins"
	wins.Value = 0
	wins.Parent = leaderstats

	leaderstats.Parent = player

	respawnPoints[player] = course.checkpoints[1]

	if player.Character then
		onCharacterAdded(player, player.Character)
	end
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
end

local function onPlayerRemoving(player: Player)
	respawnPoints[player] = nil
	winDebounce[player] = nil
end

local function onCheckpointTouched(stageNumber: number, hit: BasePart)
	local character = hit.Parent
	if not character or not character:IsA("Model") then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end

	-- This pad becomes the player's respawn point...
	respawnPoints[player] = course.checkpoints[stageNumber]

	-- ...and progress only ever moves forward.
	local stageStat = getStat(player, "Stage")
	if stageStat and stageNumber > stageStat.Value then
		stageStat.Value = stageNumber
	end
end

local function onWinPadTouched(hit: BasePart)
	local character = hit.Parent
	if not character or not character:IsA("Model") then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if not player or winDebounce[player] then
		return
	end
	winDebounce[player] = true

	local winsStat = getStat(player, "Wins")
	if winsStat then
		winsStat.Value += 1
	end

	-- Announce the finish to every client (the UI shows the banner).
	WinEvent:FireAllClients(player.Name)
	print(string.format("%s finished Sky Obby! (win #%d)", player.Name, if winsStat then winsStat.Value else 1))

	-- Reset the run: back to stage 1 for another go.
	local stageStat = getStat(player, "Stage")
	if stageStat then
		stageStat.Value = 1
	end
	respawnPoints[player] = course.checkpoints[1]
	teleportToRespawn(player)

	task.delay(2, function()
		winDebounce[player] = nil
	end)
end

-- Wire up the pads the builder created.
for stageNumber, pad in ipairs(course.checkpointPads) do
	pad.Touched:Connect(function(hit)
		onCheckpointTouched(stageNumber, hit)
	end)
end
course.winPad.Touched:Connect(onWinPadTouched)

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

-- Fall check: anyone who drops below the course is killed and will
-- respawn at their checkpoint via CharacterAdded.
task.spawn(function()
	while true do
		task.wait(0.5)
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player.Character
			if character then
				local rootPart = character:FindFirstChild("HumanoidRootPart")
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if
					rootPart
					and rootPart:IsA("BasePart")
					and humanoid
					and humanoid.Health > 0
					and rootPart.Position.Y < CourseConfig.FallY
				then
					humanoid.Health = 0
				end
			end
		end
	end
end)
