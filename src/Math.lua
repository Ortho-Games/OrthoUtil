--- @class MathUtil

return function(OrthoUtil)
	--[=[
		This function is like lerp but for angles.

		@within MathUtil
		@param angle1 number -- The first angle in radians
		@param angle2 number -- The target angle in radians
		@param t number -- a number between 0 and 1 indicating the blend between angle1 and angle2
		@return number -- the interpolated angle
	]=]
	function OrthoUtil.slerp(angle1: number, angle2: number, t: number): number
		local theta = angle2 - angle1
		angle1 += if theta > math.pi then 2 * math.pi elseif theta < -math.pi then -2 * math.pi else 0
		return angle1 + (angle2 - angle1) * t
	end

	--[=[
		Maps number v, within range inMin inMax to range outMin outMax

		@within MathUtil
		@param v number -- input number.
		@param inMin number -- the lower range that we want to assume v falls into.
		@param inMax number -- the upper range that we want to assume v falls into.
		@param outMin number -- the lower range that we want to map v to.
		@param outMax number -- the upper range that we want to map v to.
		@return number -- Returns the scaled number.
	]=]
	function OrthoUtil.scale(v: number, inMin: number, inMax: number, outMin: number, outMax: number): number
		return outMin + (v - inMin) * (outMax - outMin) / (inMax - inMin)
	end

	--[=[
		This works the same as scale, but it slams the value at the end to the out range.

		@within MathUtil
		@param v number -- input number.
		@param inMin number -- the lower range that we want to assume v falls into.
		@param inMax number -- the upper range that we want to assume v falls into.
		@param outMin number -- the lower range that we want to map v to.
		@param outMax number -- the upper range that we want to map v to.
		@return number -- Returns the scaled number.
	]=]
	function OrthoUtil.scaleClamp(v: number, inMin: number, inMax: number, outMin: number, outMax: number): number
		return math.clamp(outMin + (v - inMin) * (outMax - outMin) / (inMax - inMin), outMin, outMax)
	end

	--[=[
		Increment a value such that it wraps around a set range. Useful for cycling array indicies.

		@within MathUtil
		@param value number -- the current value we want to increment.
		@param increment number -- the number you want to add to value. 
		@param wrap number -- the higher number there can be that you want to wrap around if you go past.
		@return number -- returns value + increment wrapped around [0, wrap].
	]=]
	function OrthoUtil.next(value: number, increment: number, wrap: number): number
		return (value + increment - 1) % wrap + 1
	end

	--[=[
		Decrement a value such that it wraps around a set range. Useful for cycling array indicies.

		@within MathUtil
		@param value number -- the current value we want to increment.
		@param decrement number -- the number you want to subtract from value. 
		@param wrap number -- the higher number there can be that you want to wrap around if you go past.
		@return number -- returns value - increment wrapped around [0, wrap].
	]=]
	function OrthoUtil.prev(value: number, decrement: number, wrap: number): number
		return (value - decrement + wrap - 1) % wrap + 1
	end

	--[=[
		Get the squared magnitude version of a vector to save on computation. Useful for magnitude comparisons.

		@within MathUtil
		@param vector Vector3 -- Input vector you want to get the distance of.
		@return number -- The magnitude value without square root.
	]=]
	function OrthoUtil.squareMag(vector: Vector3): number
		return vector:Dot(vector)
	end

	--[=[
		Determines if target is within the triangle origin - a - b.

		@unreleased
		@within MathUtil
		@param origin Vector3 -- The start point of a triangle.
		@param a Vector3 -- the far left angle of the triangle from the origin.
		@param b Vector3 -- the far right angle of the triangle from the origin.
		@param target Vector3 -- the target's position.
		@return boolean -- 
	]=]
	function OrthoUtil.isBetweenVectors(origin: Vector3, a: Vector3, b: Vector3, target: Vector3): boolean
		local StartOriginVector = a - origin
		local PositionOriginVector = target - origin
		local EndOriginVector = b - origin

		local Dot1 = StartOriginVector:Cross(PositionOriginVector).Y * StartOriginVector:Cross(EndOriginVector).Y
		local Dot2 = EndOriginVector:Cross(PositionOriginVector).Y * EndOriginVector:Cross(StartOriginVector).Y

		return Dot1 >= 0 and Dot2 >= 0
	end

	return OrthoUtil
end
