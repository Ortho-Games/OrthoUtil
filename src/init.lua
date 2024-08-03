local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local isClient = RunService:IsClient()

local RNG = Random.new()

local FunctionUtil = require(script.FunctionUtil)
local TableUtil = require(script.TableUtil)

local Util = {}

Util = FunctionUtil(Util)
Util = TableUtil(Util)

function Util.slerp(angle1, angle2, t)
	local theta = angle2 - angle1
	angle1 += if theta > math.pi then 2 * math.pi elseif theta < -math.pi then -2 * math.pi else 0
	return angle1 + (angle2 - angle1) * t
end

function Util.weldBetween(a: BasePart, b: BasePart, inPlace: boolean?): Weld
	local weld = Instance.new("Weld")
	weld.Part0 = a
	weld.Part1 = b
	weld.C0 = if inPlace then CFrame.new() else a.CFrame:ToObjectSpace(b.CFrame)
	weld.Parent = a
	return weld
end

--- Maps number v, within range inMin inMax to range outMin outMax
function Util.scale(v: number, inMin: number, inMax: number, outMin: number, outMax: number): number
	return outMin + (v - inMin) * (outMax - outMin) / (inMax - inMin)
end

--- Like Util.scale, except clamps the output
function Util.scaleClamp(v: number, inMin: number, inMax: number, outMin: number, outMax: number): number
	return math.clamp(outMin + (v - inMin) * (outMax - outMin) / (inMax - inMin), outMin, outMax)
end

--- Gives you next value given (current value, how much you want to add to it, and the wrapped maximum, with a "1" offset for roblox)
--- (5, 2, 5) = 2
function Util.next(value: number, increment: number, wrap: number): number
	return (value + increment - 1) % wrap + 1
end

-- --- Gives you next value given (current value, how much you want to add to it, and the wrapped maximum, with a "1" offset for roblox)
-- --- (5, 2, 5) = 2
-- function Util.next(value: number, increment: number, min: number, max: number): number
-- 	return (value + increment - min) % max + min
-- end

--- Gives you prev value given (current value, how much you want to sub  and the wrapped maximum, with a "1" offset for roblox)
--- (1, 2, 5) = 4
function Util.prev(value: number, decrement: number, wrap: number): number
	return (value - decrement + wrap - 1) % wrap + 1
end

--- Returns a squared magnitude value for a vector meant for comparisons with squared values (saves performance by avoiding square root)
function Util.squareMag(vector: Vector3): number
	return vector:Dot(vector)
end

function Util.isBetweenVectors(origin, a, b, target)
	local StartOriginVector = a - origin
	local PositionOriginVector = target - origin
	local EndOriginVector = b - origin

	local Dot1 = StartOriginVector:Cross(PositionOriginVector).Y * StartOriginVector:Cross(EndOriginVector).Y
	local Dot2 = EndOriginVector:Cross(PositionOriginVector).Y * EndOriginVector:Cross(StartOriginVector).Y

	return Dot1 >= 0 and Dot2 >= 0
end

function Util.requireDescendants(parent)
	for _, descendant in parent:GetDescendants() do
		if descendant:IsA("ModuleScript") then
			local succ, err = pcall(require, descendant)
			if not succ then
				warn(descendant, err)
			end
		end
	end
end

function Util.requireDescendantsIgnoreClient(parent)
	for _, descendant in parent:GetDescendants() do
		if
			descendant:IsA("ModuleScript")
			and not descendant:FindFirstAncestor("Client")
			and descendant.Name ~= "Client"
		then
			local succ, err = pcall(require, descendant)
			if not succ then
				warn(descendant, err)
			end
		end
	end
end

function Util.getAnimationTrack(animator, animationId)
	for _, track in animator:GetPlayingAnimationTracks() do
		if track.Animation.AnimationId == animationId then
			return track
		end
	end
end

function Util.evalNumberSequence(ns: NumberSequence, t: number)
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
end

function Util.scaleNumberSequence(numberSequence: NumberSequence, scaleFactor: number): NumberSequence
	local newKeyPoints = {}

	for _, keyPoint in numberSequence.Keypoints do
		table.insert(
			newKeyPoints,
			NumberSequenceKeypoint.new(keyPoint.Time, keyPoint.Value * scaleFactor, keyPoint.Envelope * scaleFactor)
		)
	end

	return NumberSequence.new(newKeyPoints)
end

function Util.TweenModel(model: Model, tweenInfo: TweenInfo, goal): Tween
	local cf = Instance.new("CFrameValue")
	cf.Value = model:GetPivot()
	cf.Changed:Connect(function()
		model:PivotTo(cf.Value)
	end)

	goal.Value = goal.CFrame
	goal.CFrame = nil
	return TweenService:Create(cf, tweenInfo, goal)
end

function Util.weldAllToPrimaryPart(model: Model)
	if not model.PrimaryPart then
		return
	end

	for _, desc in model:GetDescendants() do
		if desc:IsA("BasePart") and desc ~= model.PrimaryPart then
			Util.weldBetween(desc, model.PrimaryPart)
		end
	end
end

function Util.makePartBetween(a: Vector3, b: Vector3): Part
	local vector = (a - b)

	local part = Instance.new("Part")
	part.Anchored = true
	part.Size = Vector3.new(1, 1, vector.Magnitude)
	part.CFrame = CFrame.new(b + vector / 2, a) * CFrame.new(-part.Size.X / 2, 0, 0)
	return part
end

function Util.regularPolygon(n: number, radius: number, height: number): Model
	local rotationAngle = math.rad(360 / n)
	local center = CFrame.new() * CFrame.Angles(0, rotationAngle / 2, 0)

	local model = Instance.new("Model")
	for _ = 1, n do
		local a = (center * CFrame.new(0, n, radius)).Position
		center *= CFrame.Angles(0, rotationAngle, 0)
		local b = (center * CFrame.new(0, n, radius)).Position
		local part = Util.makePartBetween(a, b)
		part.Size += Vector3.yAxis * height
		part.Parent = model
	end
	return model
end

function Util.playSound(sound: Sound, parent: Instance): Sound
	local newSound = sound:Clone()
	newSound.Parent = parent
	newSound.Stopped:Once(function(_)
		newSound:Destroy()
	end)
	newSound:Play()
	return newSound
end

function Util.fireAllExcept(remoteEvent: RemoteEvent, ignore: Player, ...)
	for _, player in Players:GetPlayers() do
		if player == ignore then
			continue
		end
		remoteEvent:FireClient(player, ...)
	end
end

local waitLimit = 1 / 240
function Util.waitFixed(duration: number, startTime: number)
	local waitTime = startTime + duration - os.clock()
	if waitTime > waitLimit then
		task.wait(waitTime)
	end
end

function Util.runAsyncAwait(t: {}, func: (...any?) -> ())
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

return Util
