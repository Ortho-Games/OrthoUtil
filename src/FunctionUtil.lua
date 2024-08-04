--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local isClient = RunService:IsClient()

--- @class FunctionUtil

return function(OrthoUtil)
	--[=[
		Create a new function that passes in the given parameters to the given function first.

		@within FunctionUtil
		@param func (...any) -> any -- input function
		@param ... any -- arguments you want to be passedin first to func
		@return (...any) -> any
	]=]
	function OrthoUtil.partial(func: (...any) -> (), ...: any): (...any) -> ()
		local args = table.pack(...)
		return function(...)
			local newArgs = table.clone(args)
			local internalArgs = table.pack(...)
			table.move(internalArgs, 1, #internalArgs, #newArgs + 1, newArgs)
			return func(table.unpack(newArgs))
		end
	end

	--[=[
		Create a new function that will only play on the server on a new thread.

		@within FunctionUtil
		@param func ((...any) -> any) | thread -- input function
		@param ... any -- params passed into func
		@return thread? -- returned thread or nothing if on client.
	]=]
	function OrthoUtil.playServer(func: ((...any) -> any) | thread, ...: any): thread?
		if not isClient then
			return task.spawn(func, ...)
		end
		return nil
	end

	--[=[
		Create a new function that will only play on the client on a new thread.
		
		@within FunctionUtil
		@param func ((...any) -> any) | thread -- input function
		@param ... any -- params passed into func
		@return thread? -- returned thread or nothing if on server.
	]=]
	function OrthoUtil.playClient(func: ((...any) -> any) | thread, ...: any): thread?
		if isClient then
			return task.spawn(func, ...)
		end
		return nil
	end

	--[=[
		Create a new function that will only play on the client on a new thread.

		@within FunctionUtil
		@param player Player -- player you want this function to play for
		@param func ((...any) -> any) | thread -- input function
		@param ... any -- params passed into func
		@return thread? -- returned thread or nothing if on server.
	]=]
	function OrthoUtil.playForPlayer(player, func: ((...any) -> any) | thread, ...: any): thread?
		if isClient and Players.LocalPlayer == player then
			return task.spawn(func, ...)
		end
		return nil
	end

	--[=[
		Returns a function that cannot run while the previous call is still running.

		@within FunctionUtil
		@param func (...any) -> any -- input function
		@return (...any) -> ()
	]=]
	function OrthoUtil.debounce(func: (...any) -> any): (...any) -> ()
		local db: boolean = false
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

	--[=[
		Executes a function and prints how long it took to execute.

		@within FunctionUtil
		@param name string -- the text you want to display on output.
		@param func () -> ()
	]=]
	function OrthoUtil.timeIt(name: string, func: () -> ())
		local s = os.clock()
		func()
		print(name, "took", os.clock() - s, "to execute.")
	end

	--[=[
		Executes a function and warnm how long it took to execute.

		@within FunctionUtil
		@param name string -- the text you want to display on output.
		@param func () -> ()
	]=]
	function OrthoUtil.timeItWarn(name: string, func)
		local s = os.clock()
		func()
		warn(name, "took", os.clock() - s, "to execute.")
	end

	--[=[
		Executes a function and prints how long it took to execute.

		@within FunctionUtil
		@param fn (...any) -> T) -- the text you want to display on output.
		@return (...any) -> T
	]=]
	function OrthoUtil.memoize<T>(fn: (...any) -> T): (...any) -> T
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

	return OrthoUtil
end
