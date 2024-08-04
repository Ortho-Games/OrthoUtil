--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local FunctionUtil: (any) -> any = require(script.FunctionUtil)
local TableUtil: (any) -> any = require(script.TableUtil)
local MathUtil: (any) -> any = require(script.Math)

--[=[
	@class OrthoUtil

	The main tool library.
]=]
local OrthoUtil = {}
OrthoUtil = FunctionUtil(OrthoUtil)
OrthoUtil = TableUtil(OrthoUtil)
OrthoUtil = MathUtil(OrthoUtil)

--[=[
	This function creates a weld between two parts.
	Places weld inside of Part0.
	
	@within OrthoUtil
	@param a BasePart -- The first part, Part0
	@param b BasePart -- The second part, Part1
	@param b boolean? -- If you want the weld to have no offset.
	@return Weld -- Return the weld.
]=]
function OrthoUtil.weldBetween(a: BasePart, b: BasePart, inPlace: boolean?): Weld
	local weld = Instance.new("Weld")
	weld.Part0 = a
	weld.Part1 = b
	weld.C0 = if inPlace then CFrame.new() else a.CFrame:ToObjectSpace(b.CFrame)
	weld.Parent = a
	return weld
end

--[=[
	Simple require every module descendant function.

	@within OrthoUtil
	@param parent Instance -- The instance to search for descendants in.
]=]
function OrthoUtil.requireDescendants(parent)
	for _, descendant in parent:GetDescendants() do
		if descendant:IsA("ModuleScript") then
			local succ, err = pcall(require, descendant)
			if not succ then
				warn(descendant, err)
			end
		end
	end
end

--[=[
	Given an animator and an animationId it searches through playing tracks to find the one with the animationId.

	@param animator Animator -- target Animator instance
	@param animationId string -- the animationId for the Animation you want to find.
	@return AnimationTrack? -- returns the animation track if it finds one. 
]=]
function OrthoUtil.getAnimationTrack(animator: Animator, animationId: string): AnimationTrack?
	for _, track in animator:GetPlayingAnimationTracks() do
		if track.Animation.AnimationId == animationId then
			return track
		end
	end
	return nil
end

--[=[
	Given a number sequence and a t value it finds what number would be returned at that point in the number sequence. Will not account for number sequence Envelopes.

	@within OrthoUtil
	@param ns NumberSequence -- Input number sequence
	@param t number -- Scale value
	@return number -- returns number sequence value.
]=]
function OrthoUtil.evalNumberSequence(ns: NumberSequence, t: number): number?
	if t <= 0 then
		return ns.Keypoints[1].Value
	end
	if t >= 1 then
		return ns.Keypoints[#ns.Keypoints].Value
	end
	for i = 1, #ns.Keypoints - 1 do
		local this = ns.Keypoints[i]
		local next = ns.Keypoints[i + 1]
		if t >= this.Time and t < next.Time then
			local alpha = (t - this.Time) / (next.Time - this.Time)
			return (next.Value - this.Value) * alpha + this.Value
		end
	end
	return nil
end

--[=[
	Given a number sequence and a scaleFactor number it returns a new number sequence with all keypoints values scaled by the scale factor.

	@within OrthoUtil
	@param numberSequence NumberSequence -- Input number sequence
	@param scaleFactor number -- A multiplier for all number sequence values.
	@return NumberSequence -- returns NumberSequence with scaled keypoints.
]=]
function OrthoUtil.scaleNumberSequence(numberSequence: NumberSequence, scaleFactor: number): NumberSequence
	local newKeyPoints = {}

	for _, keyPoint in numberSequence.Keypoints do
		table.insert(
			newKeyPoints,
			NumberSequenceKeypoint.new(keyPoint.Time, keyPoint.Value * scaleFactor, keyPoint.Envelope * scaleFactor)
		)
	end

	return NumberSequence.new(newKeyPoints)
end

--[=[
	Given a model and tween information it returns a new tween that will pivot the model as the tween changes. The goal must have a CFrame value.

	@within OrthoUtil
	@param model Model -- the input model
	@param tweenInfo TweenInfo -- the tween information for the tween.
	@param goal {CFrame: CFrame} -- a table with a CFrame value.
	@return Tween  
]=]
function OrthoUtil.TweenModel(model: Model, tweenInfo: TweenInfo, goal: { [any]: any }): Tween
	assert(goal.CFrame, "Goal must have a CFrame value.")

	local cf = Instance.new("CFrameValue")
	cf.Value = model:GetPivot()
	cf.Changed:Connect(function()
		model:PivotTo(cf.Value)
	end)

	goal.Value = goal.CFrame
	goal.CFrame = nil
	return TweenService:Create(cf, tweenInfo, goal)
end

--[=[
	Find all children of a model and weld all parts to the PrimaryPart.

	@within OrthoUtil
	@param model Model -- model that has a PrimaryPart
]=]
function OrthoUtil.weldAllToPrimaryPart(model: Model)
	assert(model.PrimaryPart, `Model {model:GetFullName()} must have a PrimaryPart.`)

	for _, desc in model:GetDescendants() do
		if desc:IsA("BasePart") and desc ~= model.PrimaryPart then
			OrthoUtil.weldBetween(desc, model.PrimaryPart)
		end
	end
end

--[=[
	Create a new part that is placed and scaled between two positions a and b.
	
	@within OrthoUtil
	@param a Vector3 -- The first position
	@param b Vector3 -- The second position
	@return Part -- the returned part
]=]
function OrthoUtil.makePartBetween(a: Vector3, b: Vector3): Part
	local vector = (a - b)

	local part = Instance.new("Part")
	part.Anchored = true
	part.Size = Vector3.new(1, 1, vector.Magnitude)
	part.CFrame = CFrame.new(b + vector / 2, a) * CFrame.new(-part.Size.X / 2, 0, 0)
	return part
end

--[=[
	Create a 2D regular polygon of parts given the radius and number of sides.
	
	@within OrthoUtil
	@param n number -- the number of sides of the polygon.
	@param radius number -- the radius of the polygon.
	@param height number -- how tall you want the parts to be that make up the polygon.
	@return Model -- the model that contains all the parts of the polygon.
]=]
function OrthoUtil.regularPolygon(n: number, radius: number, height: number): Model
	local rotationAngle = math.rad(360 / n)
	local center = CFrame.new() * CFrame.Angles(0, rotationAngle / 2, 0)

	local model = Instance.new("Model")
	for _ = 1, n do
		local a = (center * CFrame.new(0, n, radius)).Position
		center *= CFrame.Angles(0, rotationAngle, 0)
		local b = (center * CFrame.new(0, n, radius)).Position
		local part = OrthoUtil.makePartBetween(a, b)
		part.Size += Vector3.yAxis * height
		part.Parent = model
	end
	return model
end

--[=[
	Create a sound clone, parent it, and remove it when its finished. If it loops this will never destroy the sound.

	@within OrthoUtil
	@param sound Sound -- the sound you want to clone/play.
	@param parent Instance -- the place you want the sound to play from.
	@return Sound -- the sound clone that was created.
]=]
function OrthoUtil.playSound(sound: Sound, parent: Instance): Sound
	local newSound = sound:Clone()
	newSound.Parent = parent
	newSound.Stopped:Once(function(_)
		newSound:Destroy()
	end)
	newSound:Play()
	return newSound
end

--[=[
	Fire all clients with a remove event except for a single player.

	@within OrthoUtil
	@param remoteEvent RemoteEvent -- the remote event for fire.
	@param ignore Player -- the player to not fire
	@param ... any -- various arguments to be passed down.
]=]
function OrthoUtil.fireAllExcept(remoteEvent: RemoteEvent, ignore: Player, ...: any)
	for _, player in Players:GetPlayers() do
		if player == ignore then
			continue
		end
		remoteEvent:FireClient(player, ...)
	end
end

local waitLimit = 1 / 240
--[=[
	Fire all clients with a remove event except for a single player.

	@within OrthoUtil
	@ignore
]=]
function OrthoUtil.waitFixed(duration: number, startTime: number)
	local waitTime = startTime + duration - os.clock()
	if waitTime > waitLimit then
		task.wait(waitTime)
	end
end

--[=[
	Equivalent of a Promise.allSettled. This will run the function on every entry in an array in a new thread and wait until all threads have settled before moving on.

	@within OrthoUtil
	@param t {} -- input table
	@param func (...any?) -> () -- function to run on every table entry
	@yields
]=]
function OrthoUtil.runAsyncAwait(t: {}, func: (...any?) -> ())
	local threads = {}

	for _, v in t do
		table.insert(
			threads,
			task.spawn(function()
				func(v)
			end)
		)
	end

	repeat
		local finished = true
		for _, thread in threads do
			if coroutine.status(thread) ~= "dead" then
				finished = false
			end
		end
		task.wait()
	until finished
end

return OrthoUtil
