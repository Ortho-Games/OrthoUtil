local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local isClient = RunService:IsClient()

return function(Util)
	function Util.partial(func: (...any) -> (), ...: any): (...any) -> ()
		local args = table.pack(...)
		return function(...)
			local newArgs = table.clone(args)
			local internalArgs = table.pack(...)
			table.move(internalArgs, 1, #internalArgs, #newArgs + 1, newArgs)
			func(table.unpack(newArgs))
		end
	end

	function Util.playServer(func, ...): thread?
		if not isClient then
			return task.spawn(func, ...)
		end
		return nil
	end

	function Util.playClient(func, ...): thread?
		if isClient then
			return task.spawn(func, ...)
		end
		return nil
	end

	function Util.playForPlayer(player, func, ...): thread?
		if isClient and Players.LocalPlayer == player then
			return task.spawn(func, ...)
		end
		return nil
	end

	function Util.debounce(func)
		local db = false
		return function(...)
			if db then
				return
			end
			db = true

			task.spawn(function(...)
				func(...)
				db = false
			end, ...)
		end
	end

	function Util.timeIt(name: string, func)
		local s = os.clock()
		func()
		print(name, "took", os.clock() - s, "to execute.")
	end

	function Util.timeItWarn(name: string, func)
		local s = os.clock()
		func()
		warn(name, "took", os.clock() - s, "to execute.")
	end

	function Util.memoize(fn)
		local cache = {}

		return function(...)
			local args = { ... }
			local key = table.concat(args, ",")

			if cache[key] == nil then
				cache[key] = fn(...)
			end

			return cache[key]
		end
	end

	return Util
end
