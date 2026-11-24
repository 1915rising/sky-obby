--!strict
--[[
	CourseBuilder.lua
	Server module (ServerScriptService)

	Builds the entire obby course into Workspace at runtime from the stage
	definitions in CourseConfig: one checkpoint platform + pad per stage,
	the stage's platforms, its kill bricks, and a win platform at the end.

	Kill bricks are wired up here because they are a pure course hazard.
	Checkpoints and the win pad are returned unwired -- game logic
	(spawning, leaderstats, win announcements) lives in Main.server.lua.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local CourseConfig = require(Shared:WaitForChild("CourseConfig"))

type PlatformSpec = CourseConfig.PlatformSpec

export type BuildResult = {
	-- Spawn CFrame for each stage, indexed by stage number (1-based).
	checkpoints: { [number]: CFrame },
	-- The checkpoint pad parts, indexed by stage number.
	checkpointPads: { [number]: BasePart },
	winPad: BasePart,
	totalStages: number,
}

local CourseBuilder = {}

local CHECKPOINT_PLATFORM_SIZE = Vector3.new(12, 1, 12)
local CHECKPOINT_PAD_SIZE = Vector3.new(6, 0.5, 6)
local WIN_PLATFORM_SIZE = Vector3.new(16, 1, 16)
local WIN_PAD_SIZE = Vector3.new(8, 0.5, 8)

local function newPart(
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3,
	material: Enum.Material,
	parent: Instance
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function onKillBrickTouched(hit: BasePart)
	local character = hit.Parent
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		humanoid.Health = 0
	end
end

local function buildPlatform(spec: PlatformSpec, origin: Vector3, parent: Instance): Part
	-- offset.y is the height of the platform's top surface, so the part's
	-- centre sits half its thickness below that.
	local position = origin + spec.offset - Vector3.new(0, spec.size.Y / 2, 0)
	local color = spec.color or CourseConfig.PlatformColor
	return newPart("Platform", spec.size, position, color, Enum.Material.SmoothPlastic, parent)
end

local function buildKillBrick(spec: PlatformSpec, origin: Vector3, parent: Instance): Part
	local position = origin + spec.offset - Vector3.new(0, spec.size.Y / 2, 0)
	local brick = newPart("KillBrick", spec.size, position, CourseConfig.KillColor, Enum.Material.Neon, parent)
	brick.Touched:Connect(onKillBrickTouched)
	return brick
end

local function buildCheckpoint(stageNumber: number, stage: CourseConfig.StageSpec, origin: Vector3, parent: Instance): (Part, Part)
	local platform = newPart(
		"CheckpointPlatform" .. stageNumber,
		CHECKPOINT_PLATFORM_SIZE,
		origin - Vector3.new(0, CHECKPOINT_PLATFORM_SIZE.Y / 2, 0),
		CourseConfig.PlatformColor,
		Enum.Material.SmoothPlastic,
		parent
	)

	local pad = newPart(
		"Checkpoint" .. stageNumber,
		CHECKPOINT_PAD_SIZE,
		origin + Vector3.new(0, CHECKPOINT_PAD_SIZE.Y / 2, 0),
		stage.accent,
		Enum.Material.Neon,
		parent
	)
	pad.CanCollide = false
	pad:SetAttribute("StageNumber", stageNumber)

	return platform, pad
end

--- Builds the whole course and returns the pieces Main needs to wire up.
function CourseBuilder.build(): BuildResult
	local course = Instance.new("Folder")
	course.Name = "Course"

	local checkpoints: { [number]: CFrame } = {}
	local checkpointPads: { [number]: BasePart } = {}

	local zCursor = 0
	for stageNumber, stage in ipairs(CourseConfig.Stages) do
		local origin = Vector3.new(0, CourseConfig.CourseHeight, zCursor)

		local _, pad = buildCheckpoint(stageNumber, stage, origin, course)
		checkpointPads[stageNumber] = pad

		-- Spawn a few studs above the pad, facing down the course (+Z).
		local spawnPosition = origin + Vector3.new(0, 4, 0)
		checkpoints[stageNumber] = CFrame.new(spawnPosition) * CFrame.Angles(0, math.pi, 0)

		for _, spec in ipairs(stage.platforms) do
			buildPlatform(spec, origin, course)
		end
		for _, spec in ipairs(stage.killBricks) do
			buildKillBrick(spec, origin, course)
		end

		zCursor += stage.length
	end

	-- Win platform just past the final stage.
	local winOrigin = Vector3.new(0, CourseConfig.CourseHeight, zCursor + 12)
	newPart(
		"WinPlatform",
		WIN_PLATFORM_SIZE,
		winOrigin - Vector3.new(0, WIN_PLATFORM_SIZE.Y / 2, 0),
		CourseConfig.PlatformColor,
		Enum.Material.SmoothPlastic,
		course
	)
	local winPad = newPart(
		"WinPad",
		WIN_PAD_SIZE,
		winOrigin + Vector3.new(0, WIN_PAD_SIZE.Y / 2, 0),
		Color3.fromRGB(255, 215, 0),
		Enum.Material.Neon,
		course
	)
	winPad.CanCollide = false
	winPad:SetAttribute("IsWinPad", true)

	course.Parent = Workspace

	return {
		checkpoints = checkpoints,
		checkpointPads = checkpointPads,
		winPad = winPad,
		totalStages = #CourseConfig.Stages,
	}
end

return CourseBuilder
