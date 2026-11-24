--!strict
--[[
	CourseConfig.lua
	Shared module (ReplicatedStorage)

	Data definitions for every stage of the Sky Obby course.

	The course is built entirely from this table at runtime by the server
	(see CourseBuilder), so the whole game lives in code in this repo --
	there is no binary place file to keep in sync.

	Coordinate conventions:
	  * The course runs along the +Z axis. Stage 1 starts at Z = 0 and each
	    stage's origin sits at the cumulative length of the stages before it.
	  * A platform's `offset` is relative to its stage origin.
	    offset.y is the height of the platform's TOP surface above the
	    stage floor (the top of the checkpoint platform is y = 0).
	  * `length` is how much Z space the stage occupies, i.e. the distance
	    from this stage's checkpoint to the next stage's checkpoint.
]]

export type PlatformSpec = {
	size: Vector3,
	offset: Vector3,
	color: Color3?, -- falls back to the default platform colour when nil
}

export type StageSpec = {
	name: string,
	length: number,
	accent: Color3, -- colour of this stage's checkpoint pad
	platforms: { PlatformSpec },
	killBricks: { PlatformSpec },
}

local CourseConfig = {}

--- Height of the course floor above the void. The obby floats in the sky.
CourseConfig.CourseHeight = 100

--- If a character falls below this Y, it is killed and respawns.
CourseConfig.FallY = 55

--- Default platform colour (soft sky white).
CourseConfig.PlatformColor = Color3.fromRGB(235, 238, 245)

--- Kill brick colour (neon lava orange-red).
CourseConfig.KillColor = Color3.fromRGB(255, 85, 40)

CourseConfig.Stages = {
	{
		name = "First Steps",
		length = 54,
		accent = Color3.fromRGB(88, 200, 120),
		platforms = {
			{ size = Vector3.new(10, 1, 10), offset = Vector3.new(0, 0, 16) },
			{ size = Vector3.new(10, 1, 10), offset = Vector3.new(0, 0, 29) },
			{ size = Vector3.new(10, 1, 10), offset = Vector3.new(0, 0, 42) },
		},
		killBricks = {},
	},
	{
		name = "Gap Jumps",
		length = 62,
		accent = Color3.fromRGB(255, 170, 60),
		platforms = {
			{ size = Vector3.new(8, 1, 8), offset = Vector3.new(0, 0, 15) },
			{ size = Vector3.new(8, 1, 8), offset = Vector3.new(0, 0, 27) },
			{ size = Vector3.new(8, 1, 8), offset = Vector3.new(0, 0, 39) },
			{ size = Vector3.new(8, 1, 8), offset = Vector3.new(0, 0, 51) },
		},
		killBricks = {},
	},
	{
		name = "Lava Run",
		length = 64,
		accent = Color3.fromRGB(235, 80, 70),
		platforms = {
			{ size = Vector3.new(6, 1, 6), offset = Vector3.new(0, 0, 13) },
			{ size = Vector3.new(6, 1, 6), offset = Vector3.new(5, 0, 24) },
			{ size = Vector3.new(6, 1, 6), offset = Vector3.new(-5, 0, 35) },
			{ size = Vector3.new(6, 1, 6), offset = Vector3.new(0, 0, 46) },
			{ size = Vector3.new(8, 1, 8), offset = Vector3.new(0, 0, 54) },
		},
		killBricks = {
			-- One big lava pool under the whole stage: miss a jump and you land in it.
			{ size = Vector3.new(26, 1, 64), offset = Vector3.new(0, -4, 32) },
		},
	},
	{
		name = "Narrow Beams",
		length = 62,
		accent = Color3.fromRGB(150, 110, 230),
		platforms = {
			{ size = Vector3.new(2, 1, 20), offset = Vector3.new(0, 0, 16) },
			{ size = Vector3.new(6, 1, 6), offset = Vector3.new(0, 0, 29) },
			{ size = Vector3.new(18, 1, 2), offset = Vector3.new(8, 0, 32) },
			{ size = Vector3.new(6, 1, 6), offset = Vector3.new(16, 0, 32) },
			{ size = Vector3.new(2, 1, 18), offset = Vector3.new(16, 0, 41) },
			{ size = Vector3.new(8, 1, 8), offset = Vector3.new(8, 0, 50) },
		},
		killBricks = {},
	},
	{
		name = "Staircase",
		length = 58,
		accent = Color3.fromRGB(70, 190, 200),
		platforms = {
			{ size = Vector3.new(10, 1, 6), offset = Vector3.new(0, 1, 12) },
			{ size = Vector3.new(10, 1, 6), offset = Vector3.new(0, 2, 19) },
			{ size = Vector3.new(10, 1, 6), offset = Vector3.new(0, 3, 26) },
			{ size = Vector3.new(10, 1, 6), offset = Vector3.new(0, 4, 33) },
			{ size = Vector3.new(10, 1, 6), offset = Vector3.new(0, 5, 40) },
			{ size = Vector3.new(10, 1, 6), offset = Vector3.new(0, 6, 47) },
		},
		killBricks = {},
	},
	{
		name = "Zigzag",
		length = 68,
		accent = Color3.fromRGB(240, 120, 180),
		platforms = {
			{ size = Vector3.new(7, 1, 7), offset = Vector3.new(-5, 0, 14) },
			{ size = Vector3.new(7, 1, 7), offset = Vector3.new(5, 0, 26) },
			{ size = Vector3.new(7, 1, 7), offset = Vector3.new(-5, 0, 38) },
			{ size = Vector3.new(7, 1, 7), offset = Vector3.new(5, 0, 50) },
			{ size = Vector3.new(6, 1, 6), offset = Vector3.new(0, 0, 59) },
		},
		killBricks = {},
	},
	{
		name = "Lava Bridges",
		length = 70,
		accent = Color3.fromRGB(240, 200, 70),
		platforms = {
			{ size = Vector3.new(4, 1, 20), offset = Vector3.new(0, 0, 16) },
			{ size = Vector3.new(7, 1, 7), offset = Vector3.new(0, 0, 31) },
			{ size = Vector3.new(4, 1, 20), offset = Vector3.new(0, 0, 45) },
			{ size = Vector3.new(8, 1, 8), offset = Vector3.new(0, 0, 60) },
		},
		killBricks = {
			{ size = Vector3.new(28, 1, 70), offset = Vector3.new(0, -4, 35) },
		},
	},
	{
		name = "Final Climb",
		length = 60,
		accent = Color3.fromRGB(255, 215, 90),
		platforms = {
			{ size = Vector3.new(8, 1, 8), offset = Vector3.new(0, 1, 13) },
			{ size = Vector3.new(8, 1, 8), offset = Vector3.new(7, 2, 23) },
			{ size = Vector3.new(8, 1, 8), offset = Vector3.new(0, 3, 33) },
			{ size = Vector3.new(8, 1, 8), offset = Vector3.new(-7, 4, 43) },
			{ size = Vector3.new(12, 1, 12), offset = Vector3.new(0, 5, 53) },
		},
		killBricks = {},
	},
} :: { StageSpec }

return CourseConfig
