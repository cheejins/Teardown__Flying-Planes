-- UMF Package umf_complete_c v0.9.1 generated with:
-- build.lua -n "umf_complete_c v0.9.1" dist/umf_complete_c.lua src
--
local __RUNLATER = {} local UMF_RUNLATER = function(code) __RUNLATER[#__RUNLATER + 1] = code end
local __UMFLOADED = {["src/core/hook.lua"]=true,["src/util/detouring.lua"]=true,["src/core/hooks_base.lua"]=true,["src/core/hooks_extra.lua"]=true,["src/util/registry.lua"]=true,["src/util/debug.lua"]=true,["src/core/console_backend.lua"]=true,["src/core/_index.lua"]=true,["src/util/config.lua"]=true,["src/util/meta.lua"]=true,["src/util/constraint.lua"]=true,["src/util/resources.lua"]=true,["src/util/timer.lua"]=true,["src/util/visual.lua"]=true,["src/util/xml.lua"]=true,["src/vector/quat.lua"]=true,["src/vector/transform.lua"]=true,["src/vector/vector.lua"]=true,["src/entities/entity.lua"]=true,["src/entities/body.lua"]=true,["src/entities/joint.lua"]=true,["src/entities/light.lua"]=true,["src/entities/location.lua"]=true,["src/entities/player.lua"]=true,["src/entities/screen.lua"]=true,["src/entities/shape.lua"]=true,["src/entities/trigger.lua"]=true,["src/entities/vehicle.lua"]=true,["src/animation/animation.lua"]=true,["src/animation/armature.lua"]=true,["src/tool/tool.lua"]=true,["src/tdui/base.lua"]=true,["src/tdui/image.lua"]=true,["src/tdui/layout.lua"]=true,["src/tdui/panel.lua"]=true,["src/tdui/window.lua"]=true,["src/_index.lua"]=true,} local UMF_SOFTREQUIRE = function(name) return __UMFLOADED[name] end
--src/core/hook.lua
(function() ----------------
-- Hook library
-- @script core.hook

if hook then
	return
end

local hook_table = {}
local hook_compiled = {}

local function recompile( event )
	local hooks = {}
	for k, v in pairs( hook_table[event] ) do
		hooks[#hooks + 1] = v
	end
	hook_compiled[event] = hooks
end

hook = { table = hook_table }

--- Hooks a function to the specified event.
---
---@param event string
---@param identifier any
---@param func function
---@overload fun(event: string, func: function)
function hook.add( event, identifier, func )
	assert( type( event ) == "string", "Event must be a string" )
	if func then
		assert( identifier ~= nil, "Identifier must not be nil" )
		assert( type( func ) == "function", "Callback must be a function" )
	else
		assert( type( identifier ) == "function", "Callback must be a function" )
	end
	hook_table[event] = hook_table[event] or {}
	hook_table[event][identifier] = func or identifier
	recompile( event )
	return identifier
end

--- Removes a hook to an event by its identifier.
---
---@param event string
---@param identifier any
function hook.remove( event, identifier )
	assert( type( event ) == "string", "Event must be a string" )
	assert( identifier ~= nil, "Identifier must not be nil" )
	if hook_table[event] then
		hook_table[event][identifier] = nil
		if next( hook_table[event] ) == nil then
			hook_table[event] = nil
			hook_compiled[event] = nil
		else
			recompile( event )
		end
	end
end

--- Executes all hooks associated to an event.
---
---@param event string
---@return any
function hook.run( event, ... )
	local hooks = hook_compiled[event]
	if not hooks then
		return
	end
	for i = 1, #hooks do
		local a, b, c, d, e = hooks[i]( ... )
		if a ~= nil then
			return a, b, c, d, e
		end
	end
end

--- Executes all hooks associated to an event with `pcall`.
---
---@param event string
---@return any
function hook.saferun( event, ... )
	local hooks = hook_compiled[event]
	if not hooks then
		return
	end
	for i = 1, #hooks do
		local s, a, b, c, d, e = softassert( pcall( hooks[i], ... ) )
		if s and a ~= nil then
			return a, b, c, d, e
		end
	end
end

--- Tests if an event has hooks attached.
---
---@param event string
---@return boolean
function hook.used( event )
	return hook_table[event]
end


 end)();
--src/util/detouring.lua
(function() ----------------
-- Detour Utilities
-- @script util.detouring
local original = {}
local function call_original( name, ... )
	local fn = original[name]
	if fn then
		return fn( ... )
	end
end

local detoured = {}
--- Detours a global function even it gets reassigned afterwards.
---
---@param name string
---@param generator fun(original: function): function
function DETOUR( name, generator )
	original[name] = original[name] or rawget( _G, name )
	detoured[name] = generator( function( ... )
		return call_original( name, ... )
	end )
	rawset( _G, name, nil )
end

setmetatable( _G, {
	__index = detoured,
	__newindex = function( self, k, v )
		if detoured[k] then
			original[k] = v
		else
			rawset( self, k, v )
		end
	end,
} )

 end)();
--src/core/hooks_base.lua
(function() ----------------
-- Default hooks
-- @script core.hooks_base
UMF_RUNLATER "UpdateQuickloadPatch()"

local hook = hook

local function checkoriginal( b, ... )
	if not b then
		printerror( ... )
		return
	end
	return ...
end

local function simple_detour( name )
	local event = "base." .. name
	DETOUR( name, function( original )
		return function( ... )
			hook.saferun( event, ... )
			return checkoriginal( pcall( original, ... ) )
		end

	end )
end

local detours = {
	"init", -- "base.init" (runs before init())
	"tick", -- "base.tick" (runs before tick())
	"update", -- "base.update" (runs before update())
}
for i = 1, #detours do
	simple_detour( detours[i] )
end

--- Tests if a UI element should be drawn.
---
---@param kind string
---@return boolean
function shoulddraw( kind )
	return hook.saferun( "api.shoulddraw", kind ) ~= false
end

DETOUR( "draw", function( original )
	return function( dt )
		if shoulddraw( "all" ) then
			hook.saferun( "base.predraw", dt )
			if shoulddraw( "original" ) then
				checkoriginal( pcall( original, dt ) )
			end
			hook.saferun( "base.draw", dt )
		end
	end

end )

DETOUR( "Command", function( original )
	return function( cmd, ... )
		hook.saferun( "base.precmd", cmd, { ... } )
		local a, b, c, d, e, f = original( cmd, ... )
		hook.saferun( "base.postcmd", cmd, { ... }, { a, b, c, d, e, f } )
	end

end )

------ QUICKSAVE WORKAROUND -----
-- Quicksaving stores a copy of the global table without functions, so libraries get corrupted on quickload
-- This code prevents this by overriding them back

local saved = {}

local function hasfunction( t, bck )
	if bck[t] then
		return
	end
	bck[t] = true
	for k, v in pairs( t ) do
		if type( v ) == "function" then
			return true
		end
		if type( v ) == "table" and hasfunction( v, bck ) then
			return true
		end
	end
end

--- Updates the list of libraries known by the Quickload Patch.
function UpdateQuickloadPatch()
	for k, v in pairs( _G ) do
		if k ~= "_G" and type( v ) == "table" and hasfunction( v, {} ) then
			saved[k] = v
		end
	end
end

local quickloadfix = function()
	for k, v in pairs( saved ) do
		_G[k] = v
	end
end

DETOUR( "handleCommand", function( original )
	return function( command, ... )
		if command == "quickload" then
			quickloadfix()
		end
		hook.saferun( "base.command." .. command, ... )
		return original( command, ... )
	end
end )

--------------------------------

hook.add( "base.tick", "api.firsttick", function()
	hook.remove( "base.tick", "api.firsttick" )
	hook.saferun( "api.firsttick" )
	if type( firsttick ) == "function" then
		firsttick()
	end
end )

 end)();
--src/core/hooks_extra.lua
(function() ----------------
-- @submodule core.hooks_base

--- Checks if the player is in a vehicle.
---
---@return boolean
function IsPlayerInVehicle()
	return GetBool( "game.player.usevehicle" )
end

local tool = GetString( "game.player.tool" )
local invehicle = IsPlayerInVehicle()

local keyboardkeys = { "esc", "up", "down", "left", "right", "space", "interact", "return" }
for i = 97, 97 + 25 do
	keyboardkeys[#keyboardkeys + 1] = string.char( i )
end
local function checkkeys( func, mousehook, keyhook )
	if hook.used( keyhook ) and func( "any" ) then
		for i = 1, #keyboardkeys do
			if func( keyboardkeys[i] ) then
				hook.saferun( keyhook, keyboardkeys[i] )
			end
		end
	end
	if hook.used( mousehook ) then
		if func( "lmb" ) then
			hook.saferun( mousehook, "lmb" )
		end
		if func( "rmb" ) then
			hook.saferun( mousehook, "rmb" )
		end
	end
end

local mousekeys = { "lmb", "rmb", "mmb" }
local heldkeys = {}

hook.add( "base.tick", "api.default_hooks", function()
	if InputLastPressedKey then
		for i = 1, #mousekeys do
			local k = mousekeys[i]
			if InputPressed( k ) then
				hook.saferun( "api.mouse.pressed", k )
			elseif InputReleased( k ) then
				hook.saferun( "api.mouse.released", k )
			end
		end
		local lastkey = InputLastPressedKey()
		if lastkey ~= "" then
			heldkeys[lastkey] = true
			hook.saferun( "api.key.pressed", lastkey )
		end
		for key in pairs( heldkeys ) do
			if not InputDown( key ) then
				heldkeys[key] = nil
				hook.saferun( "api.key.released", key )
				break
			end
		end
		local wheel = InputValue( "mousewheel" )
		if wheel ~= 0 then
			hook.saferun( "api.mouse.wheel", wheel )
		end
		local mousedx = InputValue( "mousedx" )
		local mousedy = InputValue( "mousedy" )
		if mousedx ~= 0 or mousedy ~= 0 then
			hook.saferun( "api.mouse.move", mousedx, mousedy )
		end
	elseif InputPressed then
		checkkeys( InputPressed, "api.mouse.pressed", "api.key.pressed" )
		checkkeys( InputReleased, "api.mouse.released", "api.key.released" )
		local wheel = InputValue( "mousewheel" )
		if wheel ~= 0 then
			hook.saferun( "api.mouse.wheel", wheel )
		end
		local mousedx = InputValue( "mousedx" )
		local mousedy = InputValue( "mousedy" )
		if mousedx ~= 0 or mousedy ~= 0 then
			hook.saferun( "api.mouse.move", mousedx, mousedy )
		end
	end

	local n_invehicle = IsPlayerInVehicle()
	if invehicle ~= n_invehicle then
		hook.saferun( n_invehicle and "api.player.enter_vehicle" or "api.player.exit_vehicle",
		              n_invehicle and GetPlayerVehicle() )
		invehicle = n_invehicle
	end

	local n_tool = GetString( "game.player.tool" )
	if tool ~= n_tool then
		hook.saferun( "api.player.switch_tool", n_tool, tool )
		tool = n_tool
	end
end )

 end)();
--src/util/registry.lua
(function() ----------------
-- Registry Utilities
-- @script util.registry
local coreloaded = UMF_SOFTREQUIRE "src/core/_index.lua"

util = util or {}

do
	local serialize_any, serialize_table

	serialize_table = function( val, bck )
		if bck[val] then
			return "nil"
		end
		bck[val] = true
		local entries = {}
		for k, v in pairs( val ) do
			entries[#entries + 1] = string.format( "[%s] = %s", serialize_any( k, bck ), serialize_any( v, bck ) )
		end
		return string.format( "{%s}", table.concat( entries, "," ) )
	end

	serialize_any = function( val, bck )
		local vtype = type( val )
		if vtype == "table" then
			return serialize_table( val, bck )
		elseif vtype == "string" then
			return string.format( "%q", val )
		elseif vtype == "function" or vtype == "userdata" then
			return string.format( "nil --[[%s]]", tostring( val ) )
		else
			return tostring( val )
		end
	end

	--- Serializes something to a lua-like string.
	---
	---@vararg any
	---@return string
	function util.serialize( ... )
		local result = {}
		for i = 1, select( "#", ... ) do
			result[i] = serialize_any( select( i, ... ), {} )
		end
		return table.concat( result, "," )
	end
end

--- Unserializes something from a lua-like string.
---
---@param dt string
---@return ...
function util.unserialize( dt )
	local fn = loadstring( "return " .. dt )
	if fn then
		setfenv( fn, {} )
		return fn()
	end
end

do
	local function serialize_any( val, bck )
		local vtype = type( val )
		if vtype == "table" then
			if bck[val] then
				return "{}"
			end
			bck[val] = true
			local len = 0
			for k, v in pairs( val ) do
				len = len + 1
			end
			local rt = {}
			if len == #val then
				for i = 1, #val do
					rt[i] = serialize_any( val[i], bck )
				end
				return string.format( "[%s]", table.concat( rt, "," ) )
			else
				for k, v in pairs( val ) do
					if type( k ) == "string" or type( k ) == "number" then
						rt[#rt + 1] = string.format( "%s: %s", serialize_any( k, bck ), serialize_any( v, bck ) )
					end
				end
				return string.format( "{%s}", table.concat( rt, "," ) )
			end
		elseif vtype == "string" then
			return string.format( "%q", val )
		elseif vtype == "function" or vtype == "userdata" or vtype == "nil" then
			return "null"
		else
			return tostring( val )
		end
	end

	--- Serializes something to a JSON string.
	---
	---@param val any
	---@return string
	function util.serializeJSON( val )
		return serialize_any( val, {} )
	end
end

--- Creates a buffer shared via the registry.
---
---@param name string
---@param max? number
---@return table
function util.shared_buffer( name, max )
	max = max or 64
	return {
		_pos_name = name .. ".position",
		_list_name = name .. ".list.",
		push = function( self, text )
			local cpos = GetInt( self._pos_name )
			SetString( self._list_name .. (cpos % max), text )
			SetInt( self._pos_name, cpos + 1 )
		end,
		len = function( self )
			return math.min( GetInt( self._pos_name ), max )
		end,
		pos = function( self )
			return GetInt( self._pos_name )
		end,
		get = function( self, index )
			local pos = GetInt( self._pos_name )
			local len = math.min( pos, max )
			if index >= len then
				return
			end
			return GetString( self._list_name .. (pos + index - len) % max )
		end,
		iterator = function( self )
			local pos = GetInt( self._pos_name )
			local len = math.min( pos, max )
			return function( _, i )
				i = (i or 0) + 1
				if i >= len then
					return
				end
				return i, GetString( self._list_name .. (pos + i - len) % max )
			end
		end,
		get_g = function( self, index )
			return GetString( self._list_name .. (index % max) )
		end,
		clear = function( self )
			SetInt( self._pos_name, 0 )
			ClearKey( self._list_name:sub( 1, -2 ) )
		end,
	}
end

if coreloaded then
	--- Creates a channel shared via the registry.
	---
	---@param name string Name of the channel.
	---@param max? number Maximum amount of unread messages in the channel.
	---@param local_realm? string Name to use to identify the local recipient.
	---@return table
	function util.shared_channel( name, max, local_realm )
		max = max or 64
		local channel = {
			_buffer = util.shared_buffer( name, max ),
			_offset = 0,
			_hooks = {},
			_ready_count = 0,
			_ready = {},
			broadcast = function( self, ... )
				return self:send( "", ... )
			end,
			send = function( self, realm, ... )
				self._buffer:push( string.format( ",%s,;%s",
				                                  (type( realm ) == "table" and table.concat( realm, "," ) or tostring( realm )),
				                                  util.serialize( ... ) ) )
			end,
			listen = function( self, callback )
				if self._ready[callback] ~= nil then
					return
				end
				self._hooks[#self._hooks + 1] = callback
				self:ready( callback )
				return callback
			end,
			unlisten = function( self, callback )
				self:unready( callback )
				self._ready[callback] = nil
				for i = 1, #self._hooks do
					if self._hooks[i] == callback then
						table.remove( self._hooks, i )
						return true
					end
				end
			end,
			ready = function( self, callback )
				if not self._ready[callback] then
					self._ready_count = self._ready_count + 1
					self._ready[callback] = true
				end
			end,
			unready = function( self, callback )
				if self._ready[callback] then
					self._ready_count = self._ready_count - 1
					self._ready[callback] = false
				end
			end,
		}
		local_realm = "," .. (local_realm or "unknown") .. ","
		local function receive( ... )
			for i = 1, #channel._hooks do
				local f = channel._hooks[i]
				if channel._ready[f] then
					f( channel, ... )
				end
			end
		end
		hook.add( "base.tick", name, function( dt )
			if channel._ready_count > 0 then
				local last_pos = channel._buffer:pos()
				if last_pos > channel._offset then
					for i = math.max( channel._offset, last_pos - max ), last_pos - 1 do
						local message = channel._buffer:get_g( i )
						local start = message:find( ";", 1, true )
						local realms = message:sub( 1, start - 1 )
						if realms == ",," or realms:find( local_realm, 1, true ) then
							receive( util.unserialize( message:sub( start + 1 ) ) )
							if channel._ready_count <= 0 then
								channel._offset = i + 1
								return
							end
						end
					end
					channel._offset = last_pos
				end
			end
		end )
		return channel
	end

	--- Creates an async reader on a channel for coroutines.
	---
	---@param channel table Name of the channel.
	---@return table
	function util.async_channel( channel )
		local listener = {
			_channel = channel,
			_waiter = nil,
			read = function( self )
				self._waiter = coroutine.running()
				if not self._waiter then
					error( "async_channel:read() can only be used in a coroutine" )
				end
				self._channel:ready( self._handler )
				return coroutine.yield()
			end,
			close = function( self )
				if self._handler then
					self._channel:unlisten( self._handler )
				end
			end,
		}
		listener._handler = listener._channel:listen( function( _, ... )
			if listener._waiter then
				local co = listener._waiter
				listener._waiter = nil
				listener._channel:unready( listener._handler )
				return coroutine.resume( co, ... )
			end
		end )
		listener._channel:unready( listener._handler )
		return listener
	end
end

do

	local gets, sets = {}, {}

	--- Registers a type unserializer.
	---
	---@param type string
	---@param callback fun(data: string): any
	function util.register_unserializer( type, callback )
		gets[type] = function( key )
			return callback( GetString( key ) )
		end
	end

	if coreloaded then
		hook.add( "api.newmeta", "api.createunserializer", function( name, meta )
			gets[name] = function( key )
				return setmetatable( {}, meta ):__unserialize( GetString( key ) )
			end
			sets[name] = function( key, value )
				return SetString( key, meta.__serialize( value ) )
			end
		end )
	end

	--- Creates a table shared via the registry.
	---
	---@param name string
	---@param base? table
	---@return table
	function util.shared_table( name, base )
		return setmetatable( base or {}, {
			__index = function( self, k )
				local key = tostring( k )
				local vtype = GetString( string.format( "%s.%s.type", name, key ) )
				if vtype == "" then
					return
				end
				return gets[vtype]( string.format( "%s.%s.val", name, key ) )
			end,
			__newindex = function( self, k, v )
				local vtype = type( v )
				local handler = sets[vtype]
				if not handler then
					return
				end
				local key = tostring( k )
				if vtype == "table" then
					local meta = getmetatable( v )
					if meta and meta.__serialize and meta.__type then
						vtype = meta.__type
						v = meta.__serialize( v )
						handler = sets.string
					end
				end
				SetString( string.format( "%s.%s.type", name, key ), vtype )
				handler( string.format( "%s.%s.val", name, key ), v )
			end,
		} )
	end

	--- Creates a table shared via the registry with a structure.
	---
	---@param name string
	---@param base table
	---@return table
	---@overload fun(name: string): fun(base: table): table
	function util.structured_table( name, base )
		local function generate( base )
			local root = {}
			local keys = {}
			for k, v in pairs( base ) do
				local key = name .. "." .. tostring( k )
				if type( v ) == "table" then
					if #v == 0 then
						root[k] = util.structured_table( key, v )
					else
						keys[k] = { type = v[1], key = key, default = v[2] }
					end
				elseif type( v ) == "string" then
					keys[k] = { type = v, key = key }
				else
					root[k] = v
				end
			end
			return setmetatable( root, {
				__index = function( self, k )
					local entry = keys[k]
					if entry and gets[entry.type] then
						if HasKey( entry.key ) then
							return gets[entry.type]( entry.key )
						else
							return entry.default
						end
					end
				end,
				__newindex = function( self, k, v )
					local entry = keys[k]
					if entry and sets[entry.type] then
						return sets[entry.type]( entry.key, v )
					end
				end,
			} )
		end
		if type( base ) == "table" then
			return generate( base )
		end
		return generate
	end

	gets.number = GetFloat
	gets.integer = GetInt
	gets.boolean = GetBool
	gets.string = GetString
	gets.table = util.shared_table

	sets.number = SetFloat
	sets.integer = SetInt
	sets.boolean = SetBool
	sets.string = SetString
	sets.table = function( key, val )
		local tab = util.shared_table( key )
		for k, v in pairs( val ) do
			tab[k] = v
		end
	end

end

 end)();
--src/util/debug.lua
(function() ----------------
-- Debug Utilities
-- @script util.debug
util = util or {}

--- Gets the current line of code.
---
---@param level number stack depth
---@return string
function util.current_line( level )
	level = (level or 0) + 3
	local _, line = pcall( error, "-", level )
	if line == "-" then
		_, line = pcall( error, "-", level + 1 )
		if line == "-" then
			return
		end
		line = "[C]:?"
	else
		line = line:sub( 1, -4 )
	end
	return line
end

--- Gets the current stacktrack.
---
---@param start number starting stack depth
---@return string
function util.stacktrace( start )
	start = (start or 0) + 3
	local stack, last = {}, nil
	for i = start, 32 do
		local _, line = pcall( error, "-", i )
		if line == "-" then
			if last == "-" then
				break
			end
		else
			if last == "-" then
				stack[#stack + 1] = "[C]:?"
			end
			stack[#stack + 1] = line:sub( 1, -4 )
		end
		last = line
	end
	return stack
end

 end)();
--src/core/console_backend.lua
(function() ----------------
-- Console related functions
-- @script core.console_backend

local console_buffer = util.shared_buffer( "game.console", 128 )

-- Console backend --

local function maketext( ... )
	local text = ""
	local len = select( "#", ... )
	for i = 1, len do
		local s = tostring( select( i, ... ) )
		if i < len then
			s = s .. string.rep( " ", 8 - #s % 8 )
		end
		text = text .. s
	end
	return text
end

_OLDPRINT = _OLDPRINT or print
--- Prints its arguments in the specified color to the console.
--- Also prints to the screen if global `PRINTTOSCREEN` is set to true.
---
---@param r number
---@param g number
---@param b number
function printcolor( r, g, b, ... )
	local text = maketext( ... )
	console_buffer:push( string.format( "%f;%f;%f;%s", r, g, b, text ) )
	-- TODO: Use color
	if PRINTTOSCREEN then
		DebugPrint( text )
	end
	return _OLDPRINT( ... )
end

--- Prints its arguments to the console.
--- Also prints to the screen if global `PRINTTOSCREEN` is set to true.
function print( ... )
	printcolor( 1, 1, 1, ... )
end

--- Prints its arguments to the console.
--- Also prints to the screen if global `PRINTTOSCREEN` is set to true.
function printinfo( ... )
	printcolor( 0, .6, 1, ... )
end

--- Prints a warning and the current stacktrace to the console.
--- Also prints to the screen if global `PRINTTOSCREEN` is set to true.
---
---@param msg any
function warning( msg )
	printcolor( 1, .7, 0, "[WARNING] " .. tostring( msg ) .. "\n  " .. table.concat( util.stacktrace( 1 ), "\n  " ) )
end

printwarning = warning

--- Prints its arguments to the console.
--- Also prints to the screen if global `PRINTTOSCREEN` is set to true.
function printerror( ... )
	printcolor( 1, .2, 0, ... )
end

--- Clears the UMF console buffer.
function clearconsole()
	console_buffer:clear()
end

--- To be used with `pcall`, checks success value and prints the error if necessary.
---
---@param b boolean
---@return any
function softassert( b, ... )
	if not b then
		printerror( ... )
	end
	return b, ...
end

function assert( b, msg, ... )
	if not b then
		local m = msg or "Assertion failed"
		warning( m )
		return error( m, ... )
	end
	return b, msg, ...
end


 end)();
--src/core/_index.lua
(function() 
GLOBAL_CHANNEL = util.shared_channel( "game.umf_global_channel", 128 )

 end)();
--src/util/config.lua
(function() ----------------
-- Config Library
-- @script util.config
local registryloaded = UMF_SOFTREQUIRE "src/util/registry.lua"

if registryloaded then
	--- Creates a structured table for the mod config
	---
	---@param def table
	function OptionsKeys( def )
		return util.structured_table( "savegame.mod", def )
	end
end

OptionsMenu = setmetatable( {}, {
	__call = function( self, def )
		def.title_size = def.title_size or 50
		local f = OptionsMenu.Group( def )
		draw = function()
			UiTranslate( UiCenter(), 60 )
			UiPush()
			local fw, fh = f()
			UiPop()
			UiTranslate( 0, fh + 20 )
			UiFont( "regular.ttf", 30 )
			UiAlign( "center top" )
			UiButtonImageBox( "ui/common/box-outline-6.png", 6, 6 )
			if UiTextButton( "Close" ) then
				Menu()
			end
		end
		return f
	end,
} )

----------------
-- Organizers --
----------------

--- Groups multiple options together
---
---@param def table
function OptionsMenu.Group( def )
	local elements = {}
	if def.title then
		elements[#elements + 1] = OptionsMenu.Text( def.title, {
			size = def.title_size or 40,
			pad_bottom = def.title_pad or 15,
			align = def.title_align or "center top",
		} )
	end
	for i = 1, #def do
		elements[#elements + 1] = def[i]
	end
	local condition = def.condition
	return function()
		if condition and not condition() then
			return 0, 0
		end
		local mw, mh = 0, 0
		for i = 1, #elements do
			UiPush()
			local w, h = elements[i]()
			UiPop()
			UiTranslate( 0, h )
			mh = mh + h
			mw = math.max( mw, w )
		end
		return mw, mh
	end
end

--- Text section
---
---@param text string
---@param options? table
function OptionsMenu.Text( text, options )
	options = options or {}
	local size = options.size or 30
	local align = options.align or "left top"
	local offset = options.offset or (align:find( "left" ) and -400) or 0
	local font = options.font or "regular.ttf"
	local padt = options.pad_top or 0
	local padb = options.pad_bottom or 5
	local condition = options.condition
	return function()
		if condition and not condition() then
			return 0, 0
		end
		UiTranslate( offset, padt )
		UiFont( font, size )
		UiAlign( align )
		UiWordWrap( 800 )
		local tw, th = UiText( text )
		return tw, th + padt + padb
	end
end

--- Spacer
---
---@param space number Vertical space
---@param spacew? number Horizontal space
---@param condition? function Condition function to enable this spacer
function OptionsMenu.Spacer( space, spacew, condition )
	return function()
		if condition and not condition() then
			return 0, 0
		end
		return spacew or 0, space
	end
end

----------------
---- Values ----
----------------

local function getvalue( id, def, func )
	local key = "savegame.mod." .. id
	if HasKey( key ) then
		return (func or GetString)( key )
	else
		return def
	end
end

local function setvalue( id, val, func )
	local key = "savegame.mod." .. id
	if val ~= nil then
		(func or SetString)( key, val )
	else
		ClearKey( key )
	end
end

--- Keybind value
---
---@param def table
function OptionsMenu.Keybind( def )
	local text = def.name or def.id
	local size = def.size or 30
	local padt = def.pad_top or 0
	local padb = def.pad_bottom or 5
	local value = string.upper( getvalue( def.id, def.default ) or "" )
	if value == "" then
		value = "<none>"
	end
	local pressed = false
	local condition = def.condition
	return function()
		if condition and not condition() then
			return 0, 0
		end
		UiTranslate( -4, padt )
		UiFont( "regular.ttf", size )
		local fheight = UiFontHeight()
		UiAlign( "right top" )
		local lw, lh = UiText( text )
		UiTranslate( 8, 0 )
		UiAlign( "left top" )
		UiColor( 1, 1, 0 )
		local tempv = value
		if pressed then
			tempv = "<press a key>"
			local k = InputLastPressedKey()
			if k == "esc" then
				pressed = false
			elseif k ~= "" then
				value = string.upper( k )
				tempv = value
				setvalue( def.id, k )
				pressed = false
			end
		end
		local rw, rh = UiGetTextSize( tempv )
		if UiTextButton( tempv ) then
			pressed = not pressed
		end
		UiTranslate( rw, 0 )
		if value ~= "<none>" then
			UiColor( 1, 0, 0 )
			if UiTextButton( "x" ) then
				value = "<none>"
				setvalue( def.id, "" )
			end
			UiTranslate( size * 0.8, 0 )
		end
		if getvalue( def.id ) then
			UiColor( 0.5, 0.8, 1 )
			if UiTextButton( "Reset" ) then
				value = def.default and string.upper( def.default ) or "<none>"
				setvalue( def.id )
			end
		end
		return lw + 8 + rw, fheight + padt + padb
	end
end

--- Slider value
---
---@param def table
function OptionsMenu.Slider( def )
	local text = def.name or def.id
	local size = def.size or 30
	local padt = def.pad_top or 0
	local padb = def.pad_bottom or 5
	local min = def.min or 0
	local max = def.max or 100
	local range = max - min
	local value = getvalue( def.id, def.default, GetFloat )
	local format = string.format( "%%.%df", math.max( 0, math.floor( math.log10( 1000 / range ) ) ) )
	local step = def.step
	local condition = def.condition
	return function()
		if condition and not condition() then
			return 0, 0
		end
		UiTranslate( -4, padt )
		UiFont( "regular.ttf", size )
		local fheight = UiFontHeight()
		UiAlign( "right top" )
		local lw, lh = UiText( text )
		UiTranslate( 16, lh / 2 )
		UiAlign( "left middle" )
		UiColor( 1, 1, 0.5 )
		UiRect( 200, 2 )
		UiTranslate( -8, 0 )
		local prev = value
		value = UiSlider( "ui/common/dot.png", "x", (value - min) * 200 / range, 0, 200 ) * range / 200 + min
		if value ~= prev then
			setvalue( def.id, value, SetFloat )
			if step then
				value = math.floor( value / step + 0.5 ) * step
			end
		end
		UiTranslate( 216, 0 )
		UiText( string.format( format, value ) )
		return lw + 224, fheight + padt + padb
	end
end

--- Toggle value
---
---@param def table
function OptionsMenu.Toggle( def )
	local text = def.name or def.id
	local size = def.size or 30
	local padt = def.pad_top or 0
	local padb = def.pad_bottom or 5
	local value = getvalue( def.id, def.default, GetBool )
	local condition = def.condition
	return function()
		if condition and not condition() then
			return 0, 0
		end
		UiTranslate( -4, padt )
		UiFont( "regular.ttf", size )
		local fheight = UiFontHeight()
		UiAlign( "right top" )
		local lw, lh = UiText( text )
		UiTranslate( 8, 0 )
		UiAlign( "left top" )
		UiColor( 1, 1, 0 )
		if UiTextButton( value and "Enabled" or "Disabled" ) then
			value = not value
			setvalue( def.id, value, SetBool )
		end
		return lw + 100, fheight + padt + padb
	end
end

 end)();
--src/util/meta.lua
(function() ----------------
-- Metatable Utilities
-- @script util.meta
local coreloaded = UMF_SOFTREQUIRE "src/core/_index.lua"

local registered_meta = {}
local reverse_meta = {}

--- Defines a new metatable type.
---
---@param name string
---@param parent? string
---@return table
function global_metatable( name, parent, usecomputed )
	local meta = registered_meta[name]
	if meta then
		if not parent then
			return meta
		end
	else
		meta = {}
		meta.__index = meta
		meta.__type = name
		registered_meta[name] = meta
		reverse_meta[meta] = name
		if coreloaded then
			hook.saferun( "api.newmeta", name, meta )
		end
	end
	local newindex = rawset
	if usecomputed then
		local computed = {}
		meta._C = computed
		meta.__index = function( self, k )
			local c = computed[k]
			if c then
				return c( self )
			end
			return meta[k]
		end
		meta.__newindex = function( self, k, v )
			local c = computed[k]
			if c then
				return c( self, v )
			end
			return newindex( self, k, v )
		end
	end
	if parent then
		local parent_meta = global_metatable( parent )
		if parent_meta.__newindex then
			newindex = parent_meta.__newindex
			if not meta.__newindex then
				meta.__newindex = newindex
			end
		end
		setmetatable( meta, { __index = parent_meta.__index } )
	end
	return meta
end

--- Gets an existing metatable.
---
---@param name string
---@return table?
function find_global_metatable( name )
	if not name then
		return
	end
	if type( name ) == "table" then
		return reverse_meta[name]
	end
	return registered_meta[name]
end

local function findmeta( src, found )
	if found[src] then
		return
	end
	found[src] = true
	local res
	for k, v in pairs( src ) do
		if type( v ) == "table" then
			local dt
			local m = getmetatable( v )
			if m then
				local name = reverse_meta[m]
				if name then
					dt = {}
					dt[1] = name
				end
			end
			local sub = findmeta( v, found )
			if sub then
				dt = dt or {}
				dt[2] = sub
			end
			if dt then
				res = res or {}
				res[k] = dt
			end
		end
	end
	return res
end

if coreloaded then
	-- I hate this but without a pre-quicksave handler I see no other choice.
	local previous = -2
	hook.add( "base.tick", "api.metatables.save", function( ... )
		if GetTime() - previous > 2 then
			previous = GetTime()
			_G.GLOBAL_META_SAVE = findmeta( _G, {} )
		end
	end )

	local function restoremeta( dst, src )
		for k, v in pairs( src ) do
			local dv = dst[k]
			if type( dv ) == "table" then
				if v[1] then
					setmetatable( dv, global_metatable( v[1] ) )
				end
				if v[2] then
					restoremeta( dv, v[2] )
				end
			end
		end
	end

	hook.add( "base.command.quickload", "api.metatables.restore", function( ... )
		if GLOBAL_META_SAVE then
			restoremeta( _G, GLOBAL_META_SAVE )
		end
	end )
end
 end)();
--src/util/constraint.lua
(function() ----------------
-- Constraint Utilities
-- @script util.constraint

if not GetEntityHandle then
	GetEntityHandle = function( handle )
		return handle
	end
end

constraint = {}
_UMFConstraints = {}
local solvers = {}

function constraint.RunUpdate( dt )
	local offset = 0
	for i = 1, #_UMFConstraints do
		local v = _UMFConstraints[i + offset]
		if v.joint and IsJointBroken( v.joint ) then
			table.remove( _UMFConstraints, i + offset )
			offset = offset - 1
		else
			local result = { c = v }
			for j = 1, #v.solvers do
				local s = v.solvers[j]
				solvers[s.type]( s, result )
			end
			if result.angvel then
				local l = VecLength( result.angvel )
				ConstrainAngularVelocity( v.parent, v.child, VecScale( result.angvel, 1 / l ), l * 10, 0, v.max_aimp )
			end
		end
	end
end

local coreloaded = UMF_SOFTREQUIRE "src/core/_index.lua"
if coreloaded then
	hook.add( "base.update", "umf.constraint", constraint.RunUpdate )
end

local function find_index( t, v )
	for i = 1, #t do
		if t[i] == v then
			return i
		end
	end
end

function constraint.Relative( val, body )
	if type( val ) == "table" and val.handle or type( val ) == "number" then
		body = val
		val = nil
	end
	if type( val ) == "table" and val.body then
		body = val.body
		val = val.val
	end
	return { body = GetEntityHandle( body or 0 ), val = val }
end

local function resolve_point( relative_val )
	return TransformToParentPoint( GetBodyTransform( relative_val.body ), relative_val.val )
end

local function resolve_axis( relative_val )
	return TransformToParentVec( GetBodyTransform( relative_val.body ), relative_val.val )
end

local function resolve_orientation( relative_val )
	return TransformToParentTransform( GetBodyTransform( relative_val.body ),
	                                   Transform( Vec(), relative_val.val or Quat() ) )
end

local function resolve_transform( relative_val )
	return TransformToParentTransform( GetBodyTransform( relative_val.body ), relative_val.val )
end

local constraint_meta = global_metatable( "constraint" )

function constraint.New( parent, child, joint )
	return setmetatable( {
		parent = GetEntityHandle( parent ),
		child = GetEntityHandle( child ),
		joint = GetEntityHandle( joint ),
		solvers = {},
		tmp = {},
		active = false,
	}, constraint_meta )
end

function constraint_meta:Rebuild()
	if not self.active then
		return
	end
	local index = self.lastbuild and find_index( _UMFConstraints, self.lastbuild ) or (#_UMFConstraints + 1)
	local c = {
		parent = self.parent,
		child = self.child,
		joint = self.joint,
		solvers = {},
		max_aimp = self.max_aimp or math.huge,
		max_vimp = self.max_vimp or math.huge,
	}
	for i = 1, #self.solvers do
		c.solvers[i] = self.solvers[i]:Build() or { type = "none" }
	end
	self.lastbuild = c
	_UMFConstraints[index] = c
end

function constraint_meta:Activate()
	self.active = true
	self:Rebuild()
	return self
end

local colors = { { 1, 0, 0 }, { 0, 1, 0 }, { 0, 0, 1 }, { 0, 1, 1 }, { 1, 0, 1 }, { 1, 1, 0 }, { 1, 1, 1 } }
function constraint_meta:DrawDebug( c )
	c = c or GetBodyTransform( self.child ).pos
	for i = 1, #self.solvers do
		local col = colors[(i - 1) % #colors + 1]
		self.solvers[i]:DrawDebug( c, col[1], col[2], col[3] )
	end
end

function constraint_meta:LimitAngularVelocity( maxangvel )
	if self.tmp.asolver then
		self.tmp.asolver.max_avel = maxangvel
	else
		self.tmp.max_avel = maxangvel
	end
	return self
end

function constraint_meta:LimitAngularImpulse( maxangimpulse )
	self.max_aimp = maxangimpulse
	return self
end

function constraint_meta:LimitVelocity( maxvel )
	if self.tmp.vsolver then
		self.tmp.vsolver.max_vel = maxvel
	else
		self.tmp.max_vel = maxvel
	end
	return self
end

function constraint_meta:LimitImpulse( maximpulse )
	self.max_vimp = maximpulse
	return self
end

--------------------------------
--         Solver Base        --
--------------------------------

local solver_meta = global_metatable( "constraint_solver" )

function solver_meta:Build()
end
function solver_meta:DrawDebug()
end

function solvers:none()
end

--------------------------------
--    Rotation Axis Solvers   --
--------------------------------

function constraint_meta:ConstrainRotationAxis( axis, body )
	self.tmp.vsolver = nil
	self.tmp.asolver = nil
	self.tmp.axis = constraint.Relative( axis, body )
	return self
end

local solver_ra_sphere_meta = global_metatable( "constraint_ra_sphere_solver", "constraint_solver" )

function constraint_meta:OnSphere( quat, body )
	local s = setmetatable( {}, solver_ra_sphere_meta )
	s.axis = self.tmp.axis
	s.quat = constraint.Relative( quat, body )
	s.max_avel = self.tmp.max_avel
	self.tmp.vsolver = nil
	self.tmp.asolver = s
	self.solvers[#self.solvers + 1] = s
	return self
end

function constraint_meta:AboveLatitude( min )
	self.tmp.asolver.min_lat = min
	return self
end

function constraint_meta:BelowLatitude( max )
	self.tmp.asolver.max_lat = max
	return self
end

function constraint_meta:WithinLatitudes( min, max )
	return self:AboveLatitude( min ):BelowLatitude( max )
end

function constraint_meta:WithinLongitudes( min, max )
	self.tmp.asolver.min_lng = min
	self.tmp.asolver.max_lng = max
	return self
end

function solver_ra_sphere_meta:DrawDebug( c, r, g, b )
	local tr = resolve_orientation( self.quat )
	tr.pos = c
	local axis = VecNormalize( resolve_axis( self.axis ) )

	local start_lng = self.min_lng or 0
	local len_lng = self.max_lng and (start_lng - self.max_lng) % 360
	if self.min_lat then
		visual.drawpolygon( TransformToParentTransform( tr, Transform( Vec( 0, math.sin( math.rad( self.min_lat ) ), 0 ) ) ),
		                    math.cos( math.rad( self.min_lat ) ), -start_lng, 40, { arc = len_lng, r = r, g = g, b = b } )
	end
	if self.max_lat then
		visual.drawpolygon( TransformToParentTransform( tr, Transform( Vec( 0, math.sin( math.rad( self.max_lat ) ), 0 ) ) ),
		                    math.cos( math.rad( self.max_lat ) ), -start_lng, 40, { arc = len_lng, r = r, g = g, b = b } )
	end
	if self.min_lng then
		local start_lat = self.min_lat or 360
		local len_lat = start_lat - (self.max_lat or 0)
		visual.drawpolygon( TransformToParentTransform( tr, Transform( Vec(), QuatEuler( 0, 180 - self.min_lng, 90 ) ) ), 1,
		                    180 - start_lat, 20, { arc = len_lat, r = r, g = g, b = b } )
		visual.drawpolygon( TransformToParentTransform( tr, Transform( Vec(), QuatEuler( 0, 180 - self.max_lng, 90 ) ) ), 1,
		                    180 - start_lat, 20, { arc = len_lat, r = r, g = g, b = b } )
	end

	DrawLine( tr.pos, VecAdd( tr.pos, axis ), r, g, b )
end

function solver_ra_sphere_meta:Build()
	local quat = constraint.Relative( self.quat )
	local lng
	if self.min_lng then
		local mid = (self.max_lng + self.min_lng) / 2
		if self.max_lng < self.min_lng then
			mid = mid + 180
		end
		lng = math.acos( math.cos( math.rad( self.min_lng - mid ) ) )
		quat.val = QuatRotateQuat( QuatAxisAngle( QuatRotateVec( quat.val or Quat(), Vec( 0, 1, 0 ) ), -mid ),
		                           quat.val or Quat() )
	end
	local axis = constraint.Relative( self.axis )
	axis.val = VecNormalize( axis.val )
	return {
		type = "ra_sphere",
		axis = axis,
		quat = quat,
		lng = lng,
		min_lat = self.min_lat and math.rad( self.min_lat ) or nil,
		max_lat = self.max_lat and math.rad( self.max_lat ) or nil,
		max_avel = self.max_avel,
	}
end

function solvers:ra_sphere( result )
	local axis = resolve_axis( self.axis )
	local tr = resolve_orientation( self.quat )
	local local_axis = TransformToLocalVec( tr, axis )
	local resv
	local lat = math.asin( local_axis[2] )
	if self.min_lat and lat < self.min_lat then
		local c = VecNormalize( VecCross( Vec( 0, -1, 0 ), local_axis ) )
		resv = VecScale( c, lat - self.min_lat )
	elseif self.max_lat and lat > self.max_lat then
		local c = VecNormalize( VecCross( Vec( 0, -1, 0 ), local_axis ) )
		resv = VecScale( c, lat - self.max_lat )
	end
	if self.lng then
		local l = math.sqrt( local_axis[1] ^ 2 + local_axis[3] ^ 2 )
		if l > 0.05 then
			local n = math.acos( local_axis[3] / l ) - self.lng
			if n < 0 then
				local c = VecNormalize( VecCross( VecCross( Vec( 0, 1, 0 ), local_axis ), local_axis ) )
				resv = VecAdd( resv, VecScale( c, local_axis[1] > 0 and -n or n ) )
				-- local c = VecNormalize( VecCross( Vec( 0, 0, -1 ), local_axis ) )
				-- resv = VecAdd( resv, VecScale( c, -n ) )
			end
		end
	end
	if resv then
		if self.max_avel then
			local len = VecLength( resv )
			if len > self.max_avel then
				resv = VecScale( resv, self.max_avel / len )
			end
		end
		result.angvel = VecAdd( result.angvel, TransformToParentVec( tr, resv ) )
	end
end

--------------------------------
--     Orientation Solvers    --
--------------------------------

function constraint_meta:ConstrainOrientation( quat, body )
	self.tmp.vsolver = nil
	self.tmp.asolver = nil
	self.tmp.quat = constraint.Relative( quat, body )
	return self
end

local solver_quat_quat_meta = global_metatable( "constraint_quat_quat_solver", "constraint_solver" )

function constraint_meta:ToOrientation( quat, body )
	local s = setmetatable( {}, solver_quat_quat_meta )
	s.quat1 = self.tmp.quat
	s.quat2 = constraint.Relative( quat, body )
	s.max_avel = self.tmp.max_avel
	self.tmp.vsolver = nil
	self.tmp.asolver = s
	self.solvers[#self.solvers + 1] = s
	return self
end

local cdirections = { Vec( 1, 0, 0 ), Vec( 0, 1, 0 ), Vec( 0, 0, 1 ) }
function solver_quat_quat_meta:DrawDebug( c, r, g, b )
	local tr1 = resolve_orientation( self.quat1 )
	tr1.pos = c
	local tr2 = resolve_orientation( self.quat2 )
	tr2.pos = c
	for i = 1, #cdirections do
		local dir = cdirections[i]
		local p1 = TransformToParentPoint( tr1, dir )
		local p2 = TransformToParentPoint( tr2, dir )
		DrawLine( tr1.pos, p1, r, g, b )
		DrawLine( tr1.pos, p2, r, g, b )
		DrawLine( p1, p2, r, g, b )
	end
end

function solver_quat_quat_meta:Build()
	return { type = "quat_quat", quat1 = self.quat1, quat2 = self.quat2, max_avel = self.max_avel or math.huge }
end

function solvers:quat_quat( result )
	ConstrainOrientation( result.c.child, result.c.parent, resolve_orientation( self.quat1 ).rot,
	                      resolve_orientation( self.quat2 ).rot, self.max_avel, result.c.max_aimp )
end

--------------------------------
--      Position Solvers      --
--------------------------------

function constraint_meta:ConstrainPoint( point, body )
	self.tmp.vsolver = nil
	self.tmp.asolver = nil
	self.tmp.point = constraint.Relative( point, body )
	return self
end

local solver_point_point_meta = global_metatable( "constraint_point_point_solver", "constraint_solver" )

function constraint_meta:ToPoint( point, body )
	local s = setmetatable( {}, solver_point_point_meta )
	s.point1 = self.tmp.point
	s.point2 = constraint.Relative( point, body )
	s.max_vel = self.tmp.max_vel
	self.tmp.vsolver = s
	self.tmp.asolver = nil
	self.solvers[#self.solvers + 1] = s
	return self
end

function solver_point_point_meta:DrawDebug( c, r, g, b )
	local point1 = resolve_point( self.point1 )
	local point2 = resolve_point( self.point2 )
	DebugCross( point1, r, g, b )
	DebugCross( point2, r, g, b )
	DrawLine( point1, point2, r, g, b )
end

function solver_point_point_meta:Build()
	return { type = "point_point", point1 = self.point1, point2 = self.point2, max_vel = self.max_vel or math.huge }
end

function solvers:point_point( result )
	ConstrainPosition( result.c.child, result.c.parent, resolve_point( self.point1 ), resolve_point( self.point2 ),
	                   self.max_vel, result.c.max_vimp )
end

local solver_point_space_meta = global_metatable( "constraint_point_space_solver", "constraint_solver" )

function constraint_meta:ToSpace( transform, body )
	local s = setmetatable( {}, solver_point_space_meta )
	s.point = self.tmp.point
	s.transform = constraint.Relative( transform, body )
	s.max_vel = self.tmp.max_vel
	s.constraints = {}
	self.tmp.vsolver = s
	self.tmp.asolver = nil
	self.solvers[#self.solvers + 1] = s
	return self
end

function constraint_meta:WithinBox( center, min, max )
	local rcenter = constraint.Relative( self.tmp.vsolver.transform )
	rcenter.val = TransformToParentTransform( rcenter.val, center )
	table.insert( self.tmp.vsolver.constraints, { type = "box", center = rcenter, min = min, max = max } )
	return self
end

function constraint_meta:WithinSphere( center, radius )
	local rcenter = constraint.Relative( self.tmp.vsolver.transform )
	rcenter.val = TransformToParentPoint( rcenter.val, center )
	table.insert( self.tmp.vsolver.constraints, { type = "sphere", center = rcenter, radius = radius } )
	return self
end

function constraint_meta:AbovePlane( transform )
	local rcenter = constraint.Relative( self.tmp.vsolver.transform )
	rcenter.val = TransformToParentTransform( rcenter.val, transform )
	table.insert( self.tmp.vsolver.constraints, { type = "plane", center = rcenter } )
	return self
end

function solver_point_space_meta:DrawDebug( c, r, g, b )
	local point = resolve_point( self.point )
	for i = 1, #self.constraints do
		local c = self.constraints[i]
		if c.type == "plane" then
			local tr = resolve_transform( c.center )
			local lp = TransformToLocalPoint( tr, point )
			lp[2] = 0
			tr.pos = TransformToParentPoint( tr, lp )
			visual.drawpolygon( tr, 1.414, 45, 4, { r = r, g = g, b = b } )
		elseif c.type == "box" then
			local tr = resolve_transform( c.center )
			visual.drawbox( tr, c.min, c.max, { r = r, g = g, b = b } )
		elseif c.type == "sphere" then
			local tr = Transform( resolve_point( c.center ), Quat() )
			visual.drawwiresphere( tr, c.radius, 32, { r = r, g = g, b = b } )
		end
	end
end

function solver_point_space_meta:Build()
	local consts = {}
	for i = 1, #self.constraints do
		local c = self.constraints[i]
		if c.type == "box" then
			local rcenter = constraint.Relative( c.center )
			rcenter.val.pos = TransformToParentPoint( rcenter.val, VecScale( VecAdd( c.min, c.max ), 0.5 ) )
			consts[i] = { type = "box", center = rcenter, size = VecScale( VecSub( c.max, c.min ), 0.5 ) }
		else
			consts[i] = c
		end
	end
	return { type = "point_space", point = self.point, constraints = consts, max_vel = self.max_vel or math.huge }
end

function solvers:point_space( result )
	local point = resolve_point( self.point )
	local resv
	for i = 1, #self.constraints do
		local c = self.constraints[i]
		if c.type == "plane" then
			local tr = resolve_transform( c.center )
			local lp = TransformToLocalPoint( tr, point )
			if lp[2] < 0 then
				resv = VecAdd( resv, TransformToParentVec( tr, Vec( 0, lp[2], 0 ) ) )
			end
		elseif c.type == "box" then
			local tr = resolve_transform( c.center )
			local lp = TransformToLocalPoint( tr, point )
			local sx, sy, sz = c.size[1], c.size[2], c.size[3]
			local nlp = Vec( lp[1] < -sx and lp[1] + sx or lp[1] > sx and lp[1] - sx or 0,
			                 lp[2] < -sy and lp[2] + sy or lp[2] > sy and lp[2] - sy or 0,
			                 lp[3] < -sz and lp[3] + sz or lp[3] > sz and lp[3] - sz or 0 )
			if nlp[1] ~= 0 or nlp[2] ~= 0 or nlp[3] ~= 0 then
				resv = VecAdd( resv, TransformToParentVec( tr, nlp ) )
			end
		elseif c.type == "sphere" then
			local center = resolve_point( c.center )
			local diff = VecSub( point, center )
			local len = VecLength( diff )
			if len > c.radius then
				resv = VecAdd( resv, VecScale( diff, (len - c.radius) / len ) )
			end
		end
	end
	if resv then
		local len = VecLength( resv )
		resv = VecScale( resv, 1 / len )
		if self.max_vel and len > self.max_vel then
			len = self.max_vel
		end
		ConstrainVelocity( result.c.parent, result.c.child, point, resv, len * 10, 0, result.c.max_vimp )
	end
end

 end)();
--src/util/resources.lua
(function() ----------------
-- Resources Utilities
-- @script util.resources

util = util or {}

local mod
do
	local stack = util.stacktrace()
	local function findmods( file )
		local matches = {}
		while file and #file > 0 do
			matches[#matches + 1] = file
			file = file:match( "^(.-)/[^/]*$" )
		end

		local found
		for _, key in ipairs( ListKeys( "mods.available" ) ) do
			local path = GetString( "mods.available." .. key .. ".path" )
			for _, subpath in ipairs( matches ) do
				if path:sub( -#subpath ) == subpath then
					if found then
						return
					end
					found = key
					break
				end
			end
		end
		return found
	end
	for i = 1, #stack do
		if stack[i] ~= "[C]:?" then
			local t = stack[i]:match( "%[string \"%.%.%.(.*)\"%]:%d+" ) or stack[i]:match( "%.%.%.(.*):%d+" )
			if t then
				local found = findmods( t )
				if found then
					mod = found
					MOD = found
					break
				end
			end
		end
	end
end

--- Resolves a given mod path to an absolute path.
---
---@param path string
---@return string path Absolute path
function util.resolve_path( path )
	-- TODO: support relative paths (relative to the current file)
	-- TODO: return multiple matches if applicable
	local replaced, n = path:gsub( "^MOD/", GetString( "mods.available." .. mod .. ".path" ) .. "/" )
	if n == 0 then
		replaced, n = path:gsub( "^LEVEL/", GetString( "game.levelpath" ):sub( 1, -5 ) .. "/" )
	end
	if n == 0 then
		replaced, n = path:gsub( "^MODS/([^/]+)", function( mod )
			return GetString( "mods.available." .. mod .. ".path" )
		end )
	end
	if n == 0 then
		return path
	end
	return replaced
end

--- Load a lua file from its mod path.
---
---@param path string
---@return function
---@return string error_message
function util.load_lua_resource( path )
	return loadfile( util.resolve_path( path ) )
end

 end)();
--src/util/timer.lua
(function() ----------------
-- Timer Utilities
--
--              WARNING
--   Timers are reset on quickload!
-- Keep this in mind if you use them.
--
-- @script util.timer

timer = {}
timer._backlog = {}

local backlog = timer._backlog

local function sortedinsert( tab, val )
	for i = #tab, 1, -1 do
		if val.time < tab[i].time then
			tab[i + 1] = val
			return
		end
		tab[i + 1] = tab[i]
	end
	tab[1] = val
end

local diff = GetTime() -- In certain realms, GetTime() is not 0 right away

--- Creates a simple timer to execute code in a specified amount of time.
---
---@param time number
---@param callback function
function timer.simple( time, callback )
	sortedinsert( backlog, { time = GetTime() + time - diff, callback = callback } )
end

--- Creates a time to execute a function in the future
---
---@param id any
---@param interval number
---@param iterations number
---@param callback function
function timer.create( id, interval, iterations, callback )
	sortedinsert( backlog, {
		id = id,
		time = GetTime() + interval - diff,
		interval = interval,
		callback = callback,
		runsleft = iterations - 1,
	} )
end

--- Waits a specified amount of time in a coroutine.
---
---@param time number
function timer.wait( time )
	local co = coroutine.running()
	if not co then
		error( "timer.wait() can only be used in a coroutine" )
	end
	timer.simple( time, function()
		coroutine.resume( co )
	end )
	return coroutine.yield()
end

local function find( id )
	for i = 1, #backlog do
		if backlog[i].id == id then
			return i, backlog[i]
		end
	end
end

--- Gets the amount of time left of a named timer.
---
---@param id any
---@return number
function timer.time_left( id )
	local index, entry = find( id )
	if entry then
		return entry.time - GetTime()
	end
end

--- Gets the number of iterations left on a named timer.
---
---@param id any
---@return number
function timer.iterations_left( id )
	local index, entry = find( id )
	if entry then
		return entry.runsleft + 1
	end
end

--- Removes a named timer.
---
---@param id any
function timer.remove( id )
	local index, entry = find( id )
	if index then
		table.remove( backlog, index )
	end
end

hook.add( "base.tick", "framework.timer", function( dt )
	diff = 0
	local now = GetTime()
	while #backlog > 0 do
		local first = backlog[#backlog]
		if first.time > now then
			break
		end
		backlog[#backlog] = nil
		first.callback()
		if first.runsleft and first.runsleft > 0 then
			first.runsleft = first.runsleft - 1
			first.time = first.time + first.interval
			sortedinsert( backlog, first )
		end
	end
end )

 end)();
--src/util/visual.lua
(function() ----------------
-- Visual Utilities
-- @script util.visual
visual = {}
degreeToRadian = math.pi / 180
COLOR_WHITE = { r = 255 / 255, g = 255 / 255, b = 255 / 255, a = 255 / 255 }
COLOR_BLACK = { r = 0, g = 0, b = 0, a = 255 / 255 }
COLOR_RED = { r = 255 / 255, g = 0, b = 0, a = 255 / 255 }
COLOR_ORANGE = { r = 255 / 255, g = 128 / 255, b = 0, a = 255 / 255 }
COLOR_YELLOW = { r = 255 / 255, g = 255 / 255, b = 0, a = 255 / 255 }
COLOR_GREEN = { r = 0, g = 255 / 255, b = 0, a = 255 / 255 }
COLOR_CYAN = { r = 0, g = 255 / 255, b = 128 / 255, a = 255 / 255 }
COLOR_AQUA = { r = 0, g = 255 / 255, b = 255 / 255, a = 255 / 255 }
COLOR_BLUE = { r = 0, g = 0, b = 255 / 255, a = 255 / 255 }
COLOR_VIOLET = { r = 128 / 255, g = 0, b = 255 / 255, a = 255 / 255 }
COLOR_PINK = { r = 255 / 255, g = 0, b = 255 / 255, a = 255 / 255 }

if DrawSprite then
	function visual.huergb( p, q, t )
		if t < 0 then
			t = t + 1
		end
		if t > 1 then
			t = t - 1
		end
		if t < 1 / 6 then
			return p + (q - p) * 6 * t
		end
		if t < 1 / 2 then
			return q
		end
		if t < 2 / 3 then
			return p + (q - p) * (2 / 3 - t) * 6
		end
		return p
	end

	--- Converts hue, saturation, and light to RGB.
	---
	---@param h number
	---@param s number
	---@param l number
	---@return number[]
	function visual.hslrgb( h, s, l )
		local r, g, b

		if s == 0 then
			r = l
			g = l
			b = l
		else
			local huergb = visual.huergb

			local q = l < .5 and l * (1 + s) or l + s - l * s
			local p = 2 * l - q

			r = huergb( p, q, h + 1 / 3 )
			g = huergb( p, q, h )
			b = huergb( p, q, h - 1 / 3 )

		end
		return Vec( r, g, b )
	end

	--- Draws a sprite facing the camera.
	---
	---@param sprite number
	---@param source Vector
	---@param radius number
	---@param info table
	function visual.drawsprite( sprite, source, radius, info )
		local r, g, b, a
		local writeZ, additive = true, false
		local target = GetCameraTransform().pos
		local DrawFunction = DrawSprite

		radius = radius or 1

		if info then
			r = info.r and info.r or 1
			g = info.g and info.g or 1
			b = info.b and info.b or 1
			a = info.a and info.a or 1
			target = info.target or target
			if info.writeZ ~= nil then
				writeZ = info.writeZ
			end
			if info.additive ~= nil then
				additive = info.additive
			end
			DrawFunction = info.DrawFunction ~= nil and info.DrawFunction or DrawFunction
		end

		DrawFunction( sprite, Transform( source, QuatLookAt( source, target ) ), radius, radius, r, g, b, a, writeZ, additive )
	end

	--- Draws sprites facing the camera.
	---
	---@param sprites number[]
	---@param sources Vector[]
	---@param radius number
	---@param info table
	function visual.drawsprites( sprites, sources, radius, info )
		sprites = type( sprites ) ~= "table" and { sprites } or sprites

		for i = 1, #sprites do
			for j = 1, #sources do
				visual.drawsprite( sprites[i], sources[j], radius, info )
			end
		end
	end

	--- Draws a line using a sprite.
	---
	---@param sprite number
	---@param source Vector
	---@param destination Vector
	---@param info table
	function visual.drawline( sprite, source, destination, info )
		local r, g, b, a
		local writeZ, additive = true, false
		local target = GetCameraTransform().pos
		local DrawFunction = DrawLine
		local width = 0.03

		if info then
			r = info.r and info.r or 1
			g = info.g and info.g or 1
			b = info.b and info.b or 1
			a = info.a and info.a or 1
			width = info.width or width
			target = info.target or target
			if info.writeZ ~= nil then
				writeZ = info.writeZ
			end
			if info.additive ~= nil then
				additive = info.additive
			end
			DrawFunction = info.DrawFunction ~= nil and info.DrawFunction or (info.writeZ == false and DebugLine or DrawLine)
		end

		if sprite then
			local middle = VecScale( VecAdd( source, destination ), .5 )
			local len = VecLength( VecSub( source, destination ) )
			local transform = Transform( middle, QuatRotateQuat( QuatLookAt( source, destination ), QuatEuler( -90, 0, 0 ) ) )
			local target_local = TransformToLocalPoint( transform, target )
			target_local[2] = 0
			local transform_fixed = TransformToParentTransform( transform, Transform( nil, QuatLookAt( target_local, nil ) ) )

			DrawSprite( sprite, transform_fixed, width, len, r, g, b, a, writeZ, additive )
		else
			DrawFunction( source, destination, r, g, b, a );
		end
	end

	--- Draws lines using a sprite.
	---
	---@param sprites number[] | number
	---@param sources Vector[]
	---@param connect boolean
	---@param info table
	function visual.drawlines( sprites, sources, connect, info )
		sprites = type( sprites ) ~= "table" and { sprites } or sprites

		for i = 1, #sprites do
			local sourceCount = #sources

			for j = 1, sourceCount - 1 do
				visual.drawline( sprites[i], sources[j], sources[j + 1], info )
			end

			if connect then
				visual.drawline( sprites[i], sources[1], sources[sourceCount], info )
			end
		end
	end

	--- Draws a debug axis.
	---
	---@param transform Transformation
	---@param quat? Quaternion
	---@param radius number
	---@param writeZ boolean
	function visual.drawaxis( transform, quat, radius, writeZ )
		local DrawFunction = writeZ and DrawLine or DebugLine

		if not transform.pos then
			transform = Transform( transform, quat or QUAT_ZERO )
		end
		radius = radius or 1

		DrawFunction( transform.pos, TransformToParentPoint( transform, Vec( radius, 0, 0 ) ), 1, 0, 0 )
		DrawFunction( transform.pos, TransformToParentPoint( transform, Vec( 0, radius, 0 ) ), 0, 1, 0 )
		DrawFunction( transform.pos, TransformToParentPoint( transform, Vec( 0, 0, radius ) ), 0, 0, 1 )
	end

	--- Draws a polygon.
	---
	---@param transform Transformation
	---@param radius number
	---@param rotation number
	---@param sides number
	---@param info table
	function visual.drawpolygon( transform, radius, rotation, sides, info )
		sides = sides or 4
		radius = radius or 1

		local offset, interval = math.rad( rotation or 0 ), 2 * math.pi / sides
		local arc = false
		local r, g, b, a = 1, 1, 1, 1
		local DrawFunction = DrawLine

		if info then
			r = info.r or r
			g = info.g or g
			b = info.b or b
			a = info.a or a
			if info.arc then
				arc = true
				interval = interval * info.arc / 360
			end
			DrawFunction = info.DrawFunction or (info.writeZ == false and DebugLine or DrawLine)
		end

		local points = {}
		for i = 0, sides - 1 do
			points[i + 1] = TransformToParentPoint( transform, Vec( math.sin( offset + i * interval ) * radius, 0,
			                                                        math.cos( offset + i * interval ) * radius ) )
			if i > 0 then
				DrawFunction( points[i], points[i + 1], r, g, b, a )
			end
		end
		if arc then
			points[#points + 1] = TransformToParentPoint( transform, Vec( math.sin( offset + sides * interval ) * radius, 0,
			                                                              math.cos( offset + sides * interval ) * radius ) )
			DrawFunction( points[#points - 1], points[#points], r, g, b, a )
		else
			DrawFunction( points[#points], points[1], r, g, b, a )
		end

		return points
	end

	--- Draws a 3D box.
	---
	---@param transform Transformation
	---@param min Vector
	---@param max Vector
	---@param info table
	function visual.drawbox( transform, min, max, info )
		local r, g, b, a
		local DrawFunction = DrawLine
		local points = {
			TransformToParentPoint( transform, Vec( min[1], min[2], min[3] ) ),
			TransformToParentPoint( transform, Vec( max[1], min[2], min[3] ) ),
			TransformToParentPoint( transform, Vec( min[1], max[2], min[3] ) ),
			TransformToParentPoint( transform, Vec( max[1], max[2], min[3] ) ),
			TransformToParentPoint( transform, Vec( min[1], min[2], max[3] ) ),
			TransformToParentPoint( transform, Vec( max[1], min[2], max[3] ) ),
			TransformToParentPoint( transform, Vec( min[1], max[2], max[3] ) ),
			TransformToParentPoint( transform, Vec( max[1], max[2], max[3] ) ),
		}

		if info then
			r = info.r and info.r or 1
			g = info.g and info.g or 1
			b = info.b and info.b or 1
			a = info.a and info.a or 1
			DrawFunction = info.DrawFunction ~= nil and info.DrawFunction or (info.writeZ == false and DebugLine or DrawLine)
		end

		DrawFunction( points[1], points[2], r, g, b, a )
		DrawFunction( points[1], points[3], r, g, b, a )
		DrawFunction( points[1], points[5], r, g, b, a )
		DrawFunction( points[4], points[3], r, g, b, a )
		DrawFunction( points[4], points[2], r, g, b, a )
		DrawFunction( points[4], points[8], r, g, b, a )
		DrawFunction( points[6], points[5], r, g, b, a )
		DrawFunction( points[6], points[8], r, g, b, a )
		DrawFunction( points[6], points[2], r, g, b, a )
		DrawFunction( points[7], points[8], r, g, b, a )
		DrawFunction( points[7], points[5], r, g, b, a )
		DrawFunction( points[7], points[3], r, g, b, a )

		return points
	end

	--- Draws a prism.
	---
	---@param transform Transformation
	---@param radius number
	---@param depth number
	---@param rotation number
	---@param sides number
	---@param info table
	function visual.drawprism( transform, radius, depth, rotation, sides, info )
		local points = {}
		local iteration = 1
		local pow, sqrt, sin, cos = math.pow, math.sqrt, math.sin, math.cos
		local r, g, b, a
		local DrawFunction = DrawLine

		radius = sqrt( 2 * pow( radius, 2 ) ) or sqrt( 2 )
		depth = depth or 1
		rotation = rotation or 0
		sides = sides or 4

		if info then
			r = info.r and info.r or 1
			g = info.g and info.g or 1
			b = info.b and info.b or 1
			a = info.a and info.a or 1
			DrawFunction = info.DrawFunction ~= nil and info.DrawFunction or (info.writeZ == false and DebugLine or DrawLine)
		end

		for v = 0, 360, 360 / sides do
			points[iteration] = TransformToParentPoint( transform, Vec( sin( (v + rotation) * degreeToRadian ) * radius, depth,
			                                                            cos( (v + rotation) * degreeToRadian ) * radius ) )
			points[iteration + 1] = TransformToParentPoint( transform, Vec( sin( (v + rotation) * degreeToRadian ) * radius,
			                                                                -depth,
			                                                                cos( (v + rotation) * degreeToRadian ) * radius ) )
			if iteration > 2 then
				DrawFunction( points[iteration], points[iteration + 1], r, g, b, a )
				DrawFunction( points[iteration - 2], points[iteration], r, g, b, a )
				DrawFunction( points[iteration - 1], points[iteration + 1], r, g, b, a )
			end
			iteration = iteration + 2
		end

		return points
	end

	--- Draws a sphere.
	---
	---@param transform Transformation
	---@param radius number
	---@param rotation number
	---@param samples number
	---@param info table
	function visual.drawsphere( transform, radius, rotation, samples, info )
		local points = {}
		local sqrt, sin, cos = math.sqrt, math.sin, math.cos
		local r, g, b, a
		local DrawFunction = DrawLine

		radius = radius or 1
		rotation = rotation or 0
		samples = samples or 100

		if info then
			r = info.r and info.r or 1
			g = info.g and info.g or 1
			b = info.b and info.b or 1
			a = info.a and info.a or 1
			DrawFunction = info.DrawFunction ~= nil and info.DrawFunction or (info.writeZ == false and DebugLine or DrawLine)
		end

		-- Converted from python to lua, see original code https://stackoverflow.com/a/26127012/5459461
		local points = {}
		for i = 0, samples do
			local y = 1 - (i / (samples - 1)) * 2
			local rad = sqrt( 1 - y * y )
			local theta = 2.399963229728653 * i

			local x = cos( theta ) * rad
			local z = sin( theta ) * rad
			local point = TransformToParentPoint( Transform( transform.pos,
			                                                 QuatRotateQuat( transform.rot, QuatEuler( 0, rotation, 0 ) ) ),
			                                      Vec( x * radius, y * radius, z * radius ) )

			DrawFunction( point, VecAdd( point, Vec( 0, .01, 0 ) ), r, g, b, a )
			points[i + 1] = point
		end

		return points
	end

	--- Draws a wireframe sphere.
	---
	---@param transform Transformation
	---@param radius number
	---@param points number
	---@param info table
	function visual.drawwiresphere( transform, radius, points, info )
		radius = radius or 1
		points = points or 32
		if not info or not info.nolines then
			local tr_r = TransformToParentTransform( transform, Transform( Vec(), QuatEuler( 90, 0, 0 ) ) )
			local tr_f = TransformToParentTransform( transform, Transform( Vec(), QuatEuler( 0, 0, 90 ) ) )
			visual.drawpolygon( transform, radius, 0, points, info )
			visual.drawpolygon( tr_r, radius, 0, points, info )
			visual.drawpolygon( tr_f, radius, 0, points, info )
		end

		local cam = info and info.target or GetCameraTransform().pos
		local diff = VecSub( transform.pos, cam )
		local len = VecLength( diff )
		if len < radius then
			return
		end
		local a = math.pi / 2 - math.asin( radius / len )
		local vtr = Transform( VecAdd( transform.pos, VecScale( diff, -math.cos( a ) / len ) ),
		                       QuatRotateQuat( QuatLookAt( transform.pos, cam ), QuatEuler( 90, 0, 0 ) ) )
		visual.drawpolygon( vtr, radius * math.sin( a ), 0, points, info )
	end
end

 end)();
--src/util/xml.lua
(function() ----------------
-- XML Utilities
-- @script util.xml

---@class XMLNode
---@field __call fun(children: XMLNode[]): XMLNode
---@field attributes table<string, string> | nil
---@field children XMLNode[] | nil
---@field type string
local xml_meta
xml_meta = global_metatable( "xmlnode" )

--- Defines an XML node.
---
---@param type string
---@return fun(attributes: table<string, string>): XMLNode
XMLTag = function( type )
	return function( attributes )
		return setmetatable( { type = type, attributes = attributes }, xml_meta )
	end
end

--- Parses XML from a string.
---
---@param xml string
---@return XMLNode
ParseXML = function( xml )
	local pos = 1
	local function skipw()
		local next = xml:find( "[^ \t\n]", pos )
		if not next then
			return false
		end
		pos = next
		return true
	end
	local function expect( pattern, noskip )
		if not noskip then
			if not skipw() then
				return false
			end
		end
		local s, e = xml:find( pattern, pos )
		if not s then
			return false
		end
		local pre = pos
		pos = e + 1
		return xml:match( pattern, pre )
	end

	local readtag, readattribute, readstring

	local rt = { n = "\n", t = "\t", r = "\r", ["0"] = "\0", ["\\"] = "\\", ["\""] = "\"" }
	readstring = function()
		if not expect( "^\"" ) then
			return false
		end
		local start = pos
		while true do
			local s = assert( xml:find( "[\\\"]", pos ), "Invalid string" )
			if xml:sub( s, s ) == "\\" then
				pos = s + 2
			else
				pos = s + 1
				break
			end
		end
		return xml:sub( start, pos - 2 ):gsub( "\\(.)", rt )
	end

	readattribute = function()
		local name = expect( "^([%d%w_]+)" )
		if not name then
			return false
		end
		if expect( "^=" ) then
			return name, assert( readstring() )
		else
			return name, "1"
		end
	end

	readtag = function()
		local save = pos
		if not expect( "^<" ) then
			return false
		end

		local type = expect( "^([%d%w_]+)" )
		if not type then
			pos = save
			return false
		end
		skipw()

		local attributes = {}
		repeat
			local attr, val = readattribute()
			if attr then
				attributes[attr] = val
			end
		until not attr

		local children = {}
		if not expect( "^/>" ) then
			assert( expect( "^>" ) )
			repeat
				local child = readtag()
				if child then
					children[#children + 1] = child
				end
			until not child
			assert( expect( "^</" ) and expect( "^" .. type ) and expect( "^>" ) )
		end

		return XMLTag( type )( attributes )( children )
	end

	return readtag()
end

---@type XMLNode

---@return XMLNode self
function xml_meta:__call( children )
	self.children = children
	return self
end

--- Renders this node into an XML string.
---
---@return string
function xml_meta:Render()
	local attr = ""
	if self.attributes then
		for name, val in pairs( self.attributes ) do
			attr = string.format( "%s %s=%q", attr, name, val )
		end
	end
	local children = {}
	if self.children then
		for i = 1, #self.children do
			children[i] = self.children[i]:Render()
		end
	end
	return string.format( "<%s%s>%s</%s>", self.type, attr, table.concat( children, "" ), self.type )
end

 end)();
--src/vector/quat.lua
(function() ----------------
-- Quaternion class and related functions
-- @script vector.quat

local vector_meta = global_metatable( "vector" )
---@class Quaternion
local quat_meta
quat_meta = global_metatable( "quaternion" )

--- Tests if the parameter is a quaternion.
---
---@param q any
---@return boolean
function IsQuaternion( q )
	return type( q ) == "table" and type( q[1] ) == "number" and type( q[2] ) == "number" and type( q[3] ) == "number" and
		       type( q[4] ) == "number"
end

--- Makes the parameter quat into a quaternion.
---
---@param q number[]
---@return Quaternion q
function MakeQuaternion( q )
	return setmetatable( q, quat_meta )
end

--- Creates a new quaternion.
---
---@param i? number
---@param j? number
---@param k? number
---@param r? number
---@return Quaternion
---@overload fun(q: Quaternion): Quaternion
function Quaternion( i, j, k, r )
	if IsQuaternion( i ) then
		i, j, k, r = i[1], i[2], i[3], i[4]
	end
	return MakeQuaternion { i or 0, j or 0, k or 0, r or 1 }
end

---@type Quaternion

---@param data string
---@return Quaternion self
function quat_meta:__unserialize( data )
	local i, j, k, r = data:match( "([-0-9.]*);([-0-9.]*);([-0-9.]*);([-0-9.]*)" )
	self[1] = tonumber( i )
	self[2] = tonumber( j )
	self[3] = tonumber( k )
	self[4] = tonumber( r )
	return self
end

---@return string data
function quat_meta:__serialize()
	return table.concat( self, ";" )
end

QUAT_ZERO = Quaternion()

--- Clones the quaternion.
---
---@return Quaternion clone
function quat_meta:Clone()
	return MakeQuaternion { self[1], self[2], self[3], self[4] }
end

local QuatStr = QuatStr
---@return string
function quat_meta:__tostring()
	return QuatStr( self )
end

---@return Quaternion
function quat_meta:__unm()
	return MakeQuaternion { -self[1], -self[2], -self[3], -self[4] }
end

--- Conjugates the quaternion.
---
---@return Quaternion
function quat_meta:Conjugate()
	return MakeQuaternion { -self[1], -self[2], -self[3], self[4] }
end

--- Inverts the quaternion.
---
---@return Quaternion
function quat_meta:Invert()
	local l = quat_meta.LengthSquare( self )
	return MakeQuaternion { -self[1] / l, -self[2] / l, -self[3] / l, self[4] / l }
end

--- Adds to the quaternion.
---
---@param o Quaternion | number
---@return Quaternion self
function quat_meta:Add( o )
	if IsQuaternion( o ) then
		self[1] = self[1] + o[1]
		self[2] = self[2] + o[2]
		self[3] = self[3] + o[3]
		self[4] = self[4] + o[4]
	else
		self[1] = self[1] + o
		self[2] = self[2] + o
		self[3] = self[3] + o
		self[4] = self[4] + o
	end
	return self
end

---@param a Quaternion | number
---@param b Quaternion | number
---@return Quaternion
function quat_meta.__add( a, b )
	if not IsQuaternion( a ) then
		a, b = b, a
	end
	return quat_meta.Add( quat_meta.Clone( a ), b )
end

--- Subtracts from the quaternion.
---
---@param o Quaternion | number
---@return Quaternion self
function quat_meta:Sub( o )
	if IsQuaternion( o ) then
		self[1] = self[1] - o[1]
		self[2] = self[2] - o[2]
		self[3] = self[3] - o[3]
		self[4] = self[4] - o[4]
	else
		self[1] = self[1] - o
		self[2] = self[2] - o
		self[3] = self[3] - o
		self[4] = self[4] - o
	end
	return self
end

---@param a Quaternion | number
---@param b Quaternion | number
---@return Quaternion
function quat_meta.__sub( a, b )
	if not IsQuaternion( a ) then
		a, b = b, a
	end
	return quat_meta.Sub( quat_meta.Clone( a ), b )
end

--- Multiplies (~rotate) the quaternion.
---
---@param o Quaternion
---@return Quaternion self
function quat_meta:Mul( o )
	local i1, j1, k1, r1 = self[1], self[2], self[3], self[4]
	local i2, j2, k2, r2 = o[1], o[2], o[3], o[4]
	self[1] = j1 * k2 - k1 * j2 + r1 * i2 + i1 * r2
	self[2] = k1 * i2 - i1 * k2 + r1 * j2 + j1 * r2
	self[3] = i1 * j2 - j1 * i2 + r1 * k2 + k1 * r2
	self[4] = r1 * r2 - i1 * i2 - j1 * j2 - k1 * k2
	return self
end

---@param a Quaternion | number
---@param b Quaternion | number
---@return Quaternion
---@overload fun(a: Quaternion, b: Vector): Vector
---@overload fun(a: Quaternion, b: Transformation): Transformation
function quat_meta.__mul( a, b )
	if not IsQuaternion( a ) then
		a, b = b, a
	end
	if type( b ) == "number" then
		return Quaternion( a[1] * b, a[2] * b, a[3] * b, a[4] * b )
	end
	if IsVector( b ) then
		return vector_meta.__mul( b, a )
	end
	if IsTransformation( b ) then
		---@diagnostic disable-next-line: undefined-field
		return Transformation( vector_meta.Mul( vector_meta.Clone( b.pos ), a ), QuatRotateQuat( b.rot, a ) )
	end
	return MakeQuaternion( QuatRotateQuat( a, b ) )
end

--- Divides the quaternion components.
---
---@param o number
---@return Quaternion self
function quat_meta:Div( o )
	if IsQuaternion( o ) then
		quat_meta.Mul( self, { -o[1], -o[2], -o[3], o[4] } )
	else
		self[1] = self[1] / o
		self[2] = self[2] / o
		self[3] = self[3] / o
		self[4] = self[4] / o
	end
	return self
end

---@param a Quaternion | number
---@param b Quaternion | number
---@return Quaternion
function quat_meta.__div( a, b )
	return quat_meta.Div( quat_meta.Clone( a ), b )
end

---@param a Quaternion
---@param b Quaternion
---@return boolean
function quat_meta.__eq( a, b )
	return a[1] == b[1] and a[2] == b[2] and a[3] == b[3] and a[4] == b[4]
end

--- Gets the squared length of the quaternion.
---
---@return number
function quat_meta:LengthSquare()
	return self[1] ^ 2 + self[2] ^ 2 + self[3] ^ 2 + self[4] ^ 2
end

--- Gets the length of the quaternion
---
---@return number
function quat_meta:Length()
	return math.sqrt( quat_meta.LengthSquare( self ) )
end

local QuatSlerp = QuatSlerp
--- S-lerps from the quaternion to another one.
---
---@param o Quaternion
---@param n number
---@return Quaternion
function quat_meta:Slerp( o, n )
	return MakeQuaternion( QuatSlerp( self, o, n ) )
end

--- Gets the left-direction of the quaternion.
---
---@return Vector
function quat_meta:Left()
	local x, y, z, s = self[1], self[2], self[3], self[4]

	return Vector( 1 - (y ^ 2 + z ^ 2) * 2, (z * s + x * y) * 2, (x * z - y * s) * 2 )
end

--- Gets the up-direction of the quaternion.
---
---@return Vector
function quat_meta:Up()
	local x, y, z, s = self[1], self[2], self[3], self[4]

	return Vector( (y * x - z * s) * 2, 1 - (z ^ 2 + x ^ 2) * 2, (x * s + y * z) * 2 )
end

--- Gets the forward-direction of the quaternion.
---
---@return Vector
function quat_meta:Forward()
	local x, y, z, s = self[1], self[2], self[3], self[4]

	return Vector( (y * s + z * x) * 2, (z * y - x * s) * 2, 1 - (x ^ 2 + y ^ 2) * 2 )
end

--- Gets the euler angle representation of the quaternion.
--- Note: This uses the same order as QuatEuler().
---
---@return number
---@return number
---@return number
function quat_meta:ToEuler()
	if GetQuatEuler then
		return GetQuatEuler( self )
	end
	local x, y, z, w = self[1], self[2], self[3], self[4]
	-- Credit to https://www.euclideanspace.com/maths/geometry/rotations/conversions/quaternionToEuler/index.htm

	local bank, heading, attitude

	local s = 2 * x * y + 2 * z * w
	if s >= 1 then
		heading = 2 * math.atan2( x, w )
		bank = 0
		attitude = math.pi / 2
	elseif s <= -1 then
		heading = -2 * math.atan2( x, w )
		bank = 0
		attitude = math.pi / -2
	else
		bank = math.atan2( 2 * x * w - 2 * y * z, 1 - 2 * x ^ 2 - 2 * z ^ 2 )
		heading = math.atan2( 2 * y * w - 2 * x * z, 1 - 2 * y ^ 2 - 2 * z ^ 2 )
		attitude = math.asin( s )
	end

	return math.deg( bank ), math.deg( heading ), math.deg( attitude )
end

--- Approachs another quaternion by the specified angle.
---
---@param dest Quaternion
---@param rate number
---@return Quaternion
function quat_meta:Approach( dest, rate )
	local dot = self[1] * dest[1] + self[2] * dest[2] + self[3] * dest[3] + self[4] * dest[4]
	if dot >= 1 then
		return self
	end
	local corr_rate = rate / math.acos( 2 * dot ^ 2 - 1 )
	if corr_rate >= 1 then
		return MakeQuaternion( dest )
	end
	return MakeQuaternion( QuatSlerp( self, dest, corr_rate ) )
end

 end)();
--src/vector/transform.lua
(function() ----------------
-- Transform class and related functions
-- @script vector.transform

local vector_meta = global_metatable( "vector" )
local quat_meta = global_metatable( "quaternion" )
---@class Transformation
---@field pos Vector
---@field rot Quaternion
local transform_meta
transform_meta = global_metatable( "transformation" )

--- Tests if the parameter is a transformation.
---
---@param t any
---@return boolean
function IsTransformation( t )
	return type( t ) == "table" and t.pos and t.rot
end

--- Makes the parameter transform into a transformation.
---
---@param t { pos: number[] | Vector, rot: number[] | Quaternion }
---@return Transformation t
function MakeTransformation( t )
	setmetatable( t.pos, vector_meta )
	setmetatable( t.rot, quat_meta )
	return setmetatable( t, transform_meta )
end

--- Creates a new transformation.
---
---@param pos number[] | Vector
---@param rot number[] | Quaternion
---@return Transformation
function Transformation( pos, rot )
	return MakeTransformation { pos = pos, rot = rot }
end

---@type Transformation

---@param data string
---@return Transformation self
function transform_meta:__unserialize( data )
	local x, y, z, i, j, k, r =
		data:match( "([-0-9.]*);([-0-9.]*);([-0-9.]*);([-0-9.]*);([-0-9.]*);([-0-9.]*);([-0-9.]*)" )
	self.pos = Vector( tonumber( x ), tonumber( y ), tonumber( z ) )
	self.rot = Quaternion( tonumber( i ), tonumber( j ), tonumber( k ), tonumber( r ) )
	return self
end

---@return string data
function transform_meta:__serialize()
	return table.concat( self.pos, ";" ) .. ";" .. table.concat( self.rot, ";" )
end

--- Clones the transformation.
---
---@return Vector clone
function transform_meta:Clone()
	return MakeTransformation { pos = vector_meta.Clone( self.pos ), rot = quat_meta.Clone( self.rot ) }
end

local TransformStr = TransformStr
---@return string
function transform_meta:__tostring()
	return TransformStr( self )
end

local TransformToLocalPoint = TransformToLocalPoint
local TransformToLocalTransform = TransformToLocalTransform
local TransformToLocalVec = TransformToLocalVec
local TransformToParentPoint = TransformToParentPoint
local TransformToParentTransform = TransformToParentTransform
local TransformToParentVec = TransformToParentVec

---@param a Transformation
---@param b Transformation | Vector | Quaternion
---@return Transformation
function transform_meta.__add( a, b )
	if not IsTransformation( b ) then
		if IsVector( b ) then
			b = Transformation( b, QUAT_ZERO )
		elseif IsQuaternion( b ) then
			b = Transformation( VEC_ZERO, b )
		end
	end
	return MakeTransformation( TransformToParentTransform( a, b ) )
end

--- Gets the local representation of a world-space transform, point or rotation
---
---@param o Transformation
---@return Transformation
---@overload fun(o: Vector): Vector
---@overload fun(o: Quaternion): Quaternion
function transform_meta:ToLocal( o )
	if IsTransformation( o ) then
		return MakeTransformation( TransformToLocalTransform( self, o ) )
	elseif IsQuaternion( o ) then
		return MakeQuaternion( TransformToLocalTransform( self, Transform( {}, o ) ).rot )
	else
		return MakeVector( TransformToLocalPoint( self, o ) )
	end
end

--- Gets the local representation of a world-space direction
---
---@param o Vector
---@return Vector
function transform_meta:ToLocalDir( o )
	return MakeVector( TransformToLocalVec( self, o ) )
end

--- Gets the global representation of a local-space transform, point or rotation
---
---@param o Transformation
---@return Transformation
---@overload fun(o: Vector): Vector
---@overload fun(o: Quaternion): Quaternion
function transform_meta:ToGlobal( o )
	if IsTransformation( o ) then
		return MakeTransformation( TransformToParentTransform( self, o ) )
	elseif IsQuaternion( o ) then
		return MakeQuaternion( TransformToParentTransform( self, Transform( {}, o ) ).rot )
	else
		return MakeVector( TransformToParentPoint( self, o ) )
	end
end

--- Gets the global representation of a local-space direction
---
---@param o Vector
---@return Vector
function transform_meta:ToGlobalDir( o )
	return MakeVector( TransformToParentVec( self, o ) )
end

--- Raycasts from the transformation
---
---@param dist number
---@param mul? number
---@param radius? number
---@param rejectTransparent? boolean
---@return { hit: boolean, dist: number, normal: Vector, shape: Shape | number, hitpos: Vector }
function transform_meta:Raycast( dist, mul, radius, rejectTransparent )
	local dir = TransformToParentVec( self, VEC_FORWARD )
	if mul then
		vector_meta.Mul( dir, mul )
	end
	local hit, dist2, normal, shape = QueryRaycast( self.pos, dir, dist, radius, rejectTransparent )
	return {
		hit = hit,
		dist = dist2,
		normal = hit and MakeVector( normal ),
		shape = hit and Shape and Shape( shape ) or shape,
		hitpos = vector_meta.__add( self.pos, vector_meta.Mul( dir, hit and dist2 or dist ) ),
	}
end

 end)();
--src/vector/vector.lua
(function() ----------------
-- Vector class and related functions
-- @script vector.vector

local quat_meta = global_metatable( "quaternion" )

---@class Vector
local vector_meta
vector_meta = global_metatable( "vector" )

--- Tests if the parameter is a vector.
---
---@param v any
---@return boolean
function IsVector( v )
	return type( v ) == "table" and type( v[1] ) == "number" and type( v[2] ) == "number" and type( v[3] ) == "number" and
		       not v[4]
end

--- Makes the parameter vec into a vector.
---
---@param v number[]
---@return Vector v
function MakeVector( v )
	return setmetatable( v, vector_meta )
end

--- Creates a new vector.
---
---@param x? number
---@param y? number
---@param z? number
---@return Vector
---@overload fun(v: Vector): Vector
function Vector( x, y, z )
	if IsVector( x ) then
		x, y, z = x[1], x[2], x[3]
	end
	return MakeVector { x or 0, y or 0, z or 0 }
end

---@type Vector

---@param data string
---@return Vector self
function vector_meta:__unserialize( data )
	local x, y, z = data:match( "([-0-9.]*);([-0-9.]*);([-0-9.]*)" )
	self[1] = tonumber( x )
	self[2] = tonumber( y )
	self[3] = tonumber( z )
	return self
end

---@return string data
function vector_meta:__serialize()
	return table.concat( self, ";" )
end

VEC_ZERO = Vector()
VEC_FORWARD = Vector( 0, 0, 1 )
VEC_UP = Vector( 0, 1, 0 )
VEC_LEFT = Vector( 1, 0, 0 )

--- Clones the vector.
---
---@return Vector clone
function vector_meta:Clone()
	return MakeVector { self[1], self[2], self[3] }
end

local VecStr = VecStr
---@return string
function vector_meta:__tostring()
	return VecStr( self )
end

---@return Vector
function vector_meta:__unm()
	return MakeVector { -self[1], -self[2], -self[3] }
end

--- Adds to the vector.
---
---@param o Vector | number
---@return Vector self
function vector_meta:Add( o )
	if IsVector( o ) then
		self[1] = self[1] + o[1]
		self[2] = self[2] + o[2]
		self[3] = self[3] + o[3]
	else
		self[1] = self[1] + o
		self[2] = self[2] + o
		self[3] = self[3] + o
	end
	return self
end

---@param a Vector | Transformation | number
---@param b Vector | Transformation | number
---@return Vector
function vector_meta.__add( a, b )
	if not IsVector( a ) then
		a, b = b, a
	end
	if IsTransformation( b ) then
		return Transformation( vector_meta.Add( vector_meta.Clone( a ), b.pos ), quat_meta.Clone( b.rot ) )
	end
	return vector_meta.Add( vector_meta.Clone( a ), b )
end

--- Subtracts from the vector.
---
---@param o Vector | number
---@return Vector self
function vector_meta:Sub( o )
	if IsVector( o ) then
		self[1] = self[1] - o[1]
		self[2] = self[2] - o[2]
		self[3] = self[3] - o[3]
	else
		self[1] = self[1] - o
		self[2] = self[2] - o
		self[3] = self[3] - o
	end
	return self
end

---@param a Vector | number
---@param b Vector | number
---@return Vector
function vector_meta.__sub( a, b )
	if not IsVector( a ) then
		a, b = b, a
	end
	return vector_meta.Sub( vector_meta.Clone( a ), b )
end

--- Multiplies the vector.
---
---@param o Vector | Quaternion | number
---@return Vector self
function vector_meta:Mul( o )
	if IsVector( o ) then
		self[1] = self[1] * o[1]
		self[2] = self[2] * o[2]
		self[3] = self[3] * o[3]
	elseif IsQuaternion( o ) then
		-- v2 = v + 2 * r X (s * v + r X v) / quat_meta.LengthSquare(self)
		-- local s, r = o[4], Vector(o[1], o[2], o[3])
		-- self:Add(2 * s * r:Cross(self) + 2 * r:Cross(r:Cross(self)))

		local x1, y1, z1 = self[1], self[2], self[3]
		local x2, y2, z2, s = o[1], o[2], o[3], o[4]

		local x3 = y2 * z1 - z2 * y1
		local y3 = z2 * x1 - x2 * z1
		local z3 = x2 * y1 - y2 * x1

		self[1] = x1 + (x3 * s + y2 * z3 - z2 * y3) * 2
		self[2] = y1 + (y3 * s + z2 * x3 - x2 * z3) * 2
		self[3] = z1 + (z3 * s + x2 * y3 - y2 * x3) * 2
	else
		self[1] = self[1] * o
		self[2] = self[2] * o
		self[3] = self[3] * o
	end
	return self
end

---@param a Vector | Quaternion | number
---@param b Vector | Quaternion | number
---@return Vector
function vector_meta.__mul( a, b )
	if not IsVector( a ) then
		a, b = b, a
	end
	return vector_meta.Mul( vector_meta.Clone( a ), b )
end

--- Divides the vector components.
---
---@param o number
---@return Vector self
function vector_meta:Div( o )
	self[1] = self[1] / o
	self[2] = self[2] / o
	self[3] = self[3] / o
	return self
end

---@param a Vector | number
---@param b Vector | number
---@return Vector
function vector_meta.__div( a, b )
	return vector_meta.Div( vector_meta.Clone( a ), b )
end

--- Applies the modulo operator on the vector components.
---
---@param o number
---@return Vector self
function vector_meta:Mod( o )
	self[1] = self[1] % o
	self[2] = self[2] % o
	self[3] = self[3] % o
	return self
end

---@param a Vector | number
---@param b Vector | number
---@return Vector
function vector_meta.__mod( a, b )
	return vector_meta.Mod( vector_meta.Clone( a ), b )
end

--- Applies the exponent operator on the vector components.
---
---@param o number
---@return Vector self
function vector_meta:Pow( o )
	self[1] = self[1] ^ o
	self[2] = self[2] ^ o
	self[3] = self[3] ^ o
	return self
end

---@param a Vector
---@param b number
---@return Vector
function vector_meta.__pow( a, b )
	return vector_meta.Pow( vector_meta.Clone( a ), b )
end

---@param a Vector
---@param b Vector
---@return boolean
function vector_meta.__eq( a, b )
	return a[1] == b[1] and a[2] == b[2] and a[3] == b[3]
end

---@param a Vector
---@param b Vector
---@return boolean
function vector_meta.__lt( a, b )
	return a[1] < b[1] or (a[1] == b[1] and (a[2] < b[2] or (a[2] == b[2] and (a[3] < b[3]))))
end

---@param a Vector
---@param b Vector
---@return boolean
function vector_meta.__le( a, b )
	return a[1] < b[1] or (a[1] == b[1] and (a[2] < b[2] or (a[2] == b[2] and (a[3] <= b[3]))))
end

local VecDot = VecDot
--- Computes the dot product with another vector.
---
---@param b Vector
---@return number
function vector_meta:Dot( b )
	return VecDot( self, b )
end

local VecCross = VecCross
--- Computes the cross product with another vector.
---
---@param b Vector
---@return Vector
function vector_meta:Cross( b )
	return MakeVector( VecCross( self, b ) )
end

local VecLength = VecLength
--- Gets the length of the vector.
---
---@return number
function vector_meta:Length()
	return VecLength( self )
end

--- Gets the volume of the vector (product of all its components).
---
---@return number
function vector_meta:Volume()
	return math.abs( self[1] * self[2] * self[3] )
end

local VecLerp = VecLerp
--- Lerps from the vector to another one.
---
---@param o Vector
---@param n number
---@return Vector
function vector_meta:Lerp( o, n )
	return MakeVector( VecLerp( self, o, n ) )
end

local VecNormalize = VecNormalize
--- Gets the normalized form of the vector.
---
---@return Vector
function vector_meta:Normalized()
	return MakeVector( VecNormalize( self ) )
end

--- Normalize the vector.
---
---@return Vector self
function vector_meta:Normalize()
	return vector_meta.Div( self, vector_meta.Length( self ) )
end

--- Gets the squared distance to another vector.
---
---@return number
function vector_meta:DistSquare( o )
	return (self[1] - o[1]) ^ 2 + (self[2] - o[2]) ^ 2 + (self[3] - o[3]) ^ 2
end

--- Gets the distance to another vector.
---
---@return number
function vector_meta:Distance( o )
	return math.sqrt( vector_meta.DistSquare( self, o ) )
end

--- Gets the rotation to another vector.
---
---@param o Vector
---@return Quaternion
function vector_meta:LookAt( o )
	return MakeQuaternion( QuatLookAt( self, o ) )
end

--- Approachs another vector by the specified distance.
---
---@param dest Vector
---@param rate number
---@return Vector
function vector_meta:Approach( dest, rate )
	local dist = vector_meta.Distance( self, dest )
	if dist < rate then
		return dest
	end
	return vector_meta.Lerp( self, dest, rate / dist )
end

--- Get the minimum value for each vector component.
---
---@vararg Vector
---@return Vector
---@overload fun(o: number, ...): Vector
function vector_meta:Min( ... )
	local n = vector_meta.Clone( self )
	for i = 1, select( "#", ... ) do
		local o = select( i, ... )
		if type( o ) == "number" then
			n[1] = math.min( n[1], o )
			n[2] = math.min( n[2], o )
			n[3] = math.min( n[3], o )
		else
			n[1] = math.min( n[1], o[1] )
			n[2] = math.min( n[2], o[2] )
			n[3] = math.min( n[3], o[3] )
		end
	end
	return n
end

--- Get the maximum value for each vector component.
---
---@vararg Vector
---@return Vector
---@overload fun(o: number, ...): Vector
function vector_meta:Max( ... )
	local n = vector_meta.Clone( self )
	for i = 1, select( "#", ... ) do
		local o = select( i, ... )
		if type( o ) == "number" then
			n[1] = math.max( n[1], o )
			n[2] = math.max( n[2], o )
			n[3] = math.max( n[3], o )
		else
			n[1] = math.max( n[1], o[1] )
			n[2] = math.max( n[2], o[2] )
			n[3] = math.max( n[3], o[3] )
		end
	end
	return n
end

--- Clamp the vector components.
---
---@param min Vector | number
---@param max Vector | number
---@return Vector
function vector_meta:Clamp( min, max )
	if type( min ) == "number" then
		return Vector( math.max( math.min( self[1], max ), min ), math.max( math.min( self[2], max ), min ),
		               math.max( math.min( self[3], max ), min ) )
	else
		return Vector( math.max( math.min( self[1], max[1] ), min[1] ), math.max( math.min( self[2], max[2] ), min[2] ),
		               math.max( math.min( self[3], max[3] ), min[3] ) )
	end
end

 end)();
--src/entities/entity.lua
(function() ----------------
-- Entity class and related functions
-- @script entities.entity

---@class Entity
---@field handle number
---@field type string
local entity_meta
entity_meta = global_metatable( "entity" )

--- Gets the handle of an entity.
---
---@param e Entity | number
---@return number
function GetEntityHandle( e )
	if IsEntity( e ) then
		return e.handle
	end
	return e
end

--- Gets the validity of a table by calling :IsValid() if it supports it.
---
---@param e any
---@return boolean
function IsValid( e )
	if type( e ) == "table" and e.IsValid then
		return e:IsValid()
	end
	return false
end

--- Tests if the parameter is an entity.
---
---@param e any
---@return boolean
function IsEntity( e )
	return type( e ) == "table" and type( e.handle ) == "number"
end

--- Wraps the given handle with the entity class.
---
---@param handle number
---@return Entity
function Entity( handle )
	if handle > 0 then
		return setmetatable( { handle = handle, type = "unknown" }, entity_meta )
	end
end

---@type Entity

---@param data string
---@return Entity self
function entity_meta:__unserialize( data )
	self.handle = tonumber( data )
	return self
end

---@return string data
function entity_meta:__serialize()
	return tostring( self.handle )
end

---@return string
function entity_meta:__tostring()
	return string.format( "Entity[%d]", self.handle )
end

--- Gets the type of the entity.
---
---@return string type
function entity_meta:GetType()
	return self.type or "unknown"
end

local IsHandleValid = IsHandleValid
--- Gets the validity of the entity.
---
---@return boolean
function entity_meta:IsValid()
	return IsHandleValid( self.handle )
end

local SetTag = SetTag
--- Sets a tag value on the entity.
---
---@param tag string
---@param value string
function entity_meta:SetTag( tag, value )
	assert( self:IsValid() )
	return SetTag( self.handle, tag, value )
end

local SetDescription = SetDescription
--- Sets the description of the entity.
---
---@param description string
function entity_meta:SetDescription( description )
	assert( self:IsValid() )
	return SetDescription( self.handle, description )
end

local RemoveTag = RemoveTag
--- Removes a tag from the entity.
---
---@param tag string
function entity_meta:RemoveTag( tag )
	assert( self:IsValid() )
	return RemoveTag( self.handle, tag )
end

local HasTag = HasTag
--- Gets if the entity has a tag.
---
---@param tag string
---@return boolean
function entity_meta:HasTag( tag )
	assert( self:IsValid() )
	return HasTag( self.handle, tag )
end

local GetTagValue = GetTagValue
--- Gets the value of a tag.
---
---@param tag string
---@return string
function entity_meta:GetTagValue( tag )
	assert( self:IsValid() )
	return GetTagValue( self.handle, tag )
end

local GetDescription = GetDescription
--- Gets the description of the entity.
---
---@return string
function entity_meta:GetDescription()
	assert( self:IsValid() )
	return GetDescription( self.handle )
end

local Delete = Delete
--- Deletes the entity.
function entity_meta:Delete()
	return Delete( self.handle )
end

 end)();
--src/entities/body.lua
(function() ----------------
-- Body class and related functions
-- @script entities.body

---@class Body: Entity
local body_meta
body_meta = global_metatable( "body", "entity" )

--- Tests if the parameter is a body entity.
---
---@param e any
---@return boolean
function IsBody( e )
	return IsEntity( e ) and e.type == "body"
end

--- Wraps the given handle with the body class.
---
---@param handle number
---@return Body?
function Body( handle )
	if handle > 0 then
		return setmetatable( { handle = handle, type = "body" }, body_meta )
	end
end

--- Finds a body with the specified tag.
--- `global` determines whether to only look in the script's hierarchy or the entire scene.
---
---@param tag string
---@param global boolean
---@return Body?
function FindBodyByTag( tag, global )
	return Body( FindBody( tag, global ) )
end

--- Finds all bodies with the specified tag.
--- `global` determines whether to only look in the script's hierarchy or the entire scene.
---
---@param tag string
---@param global boolean
---@return Body[]
function FindBodiesByTag( tag, global )
	local t = FindBodies( tag, global )
	for i = 1, #t do
		t[i] = Body( t[i] )
	end
	return t
end

---@type Body

---@return string
function body_meta:__tostring()
	return string.format( "Body[%d]", self.handle )
end

--- Applies a force to the body at the specified world-space point.
---
---@param pos Vector World-space position
---@param vel Vector World-space force and direction
function body_meta:ApplyImpulse( pos, vel )
	assert( self:IsValid() )
	return ApplyBodyImpulse( self.handle, pos, vel )
end

--- Applies a force to the body at the specified object-space point.
---
---@param pos Vector Object-space position
---@param vel Vector Object-space force and direction
function body_meta:ApplyLocalImpulse( pos, vel )
	local transform = self:GetTransform()
	return self:ApplyImpulse( transform:ToGlobal( pos ), transform:ToGlobalDir( vel ) )
end

--- Draws the outline of the body.
---
---@param r number
---@overload fun(r: number, g: number, b: number, a: number)
function body_meta:DrawOutline( r, ... )
	assert( self:IsValid() )
	return DrawBodyOutline( self.handle, r, ... )
end

--- Draws a highlight of the body.
---
---@param amount number
function body_meta:DrawHighlight( amount )
	assert( self:IsValid() )
	return DrawBodyHighlight( self.handle, amount )
end

--- Sets the transform of the body.
---
---@param tr Transformation
function body_meta:SetTransform( tr )
	assert( self:IsValid() )
	return SetBodyTransform( self.handle, tr )
end

--- Sets if the body should be simulated.
---
---@param bool boolean
function body_meta:SetActive( bool )
	assert( self:IsValid() )
	return SetBodyActive( self.handle, bool )
end

--- Sets if the body should move.
---
---@param bool boolean
function body_meta:SetDynamic( bool )
	assert( self:IsValid() )
	return SetBodyDynamic( self.handle, bool )
end

--- Sets the velocity of the body.
---
---@param vel Vector
function body_meta:SetVelocity( vel )
	assert( self:IsValid() )
	return SetBodyVelocity( self.handle, vel )
end

--- Sets the angular velocity of the body.
---
---@param avel Vector
function body_meta:SetAngularVelocity( avel )
	assert( self:IsValid() )
	return SetBodyAngularVelocity( self.handle, avel )
end

--- Gets the transform of the body.
---
---@return Transformation
function body_meta:GetTransform()
	assert( self:IsValid() )
	return MakeTransformation( GetBodyTransform( self.handle ) )
end

--- Gets the mass of the body.
---
---@return number
function body_meta:GetMass()
	assert( self:IsValid() )
	return GetBodyMass( self.handle )
end

--- Gets the velocity of the body.
---
---@return Vector
function body_meta:GetVelocity()
	assert( self:IsValid() )
	return MakeVector( GetBodyVelocity( self.handle ) )
end

--- Gets the velocity at the position on the body.
---
---@param pos Vector
---@return Vector
function body_meta:GetVelocityAtPos( pos )
	assert( self:IsValid() )
	return MakeVector( GetBodyVelocityAtPos( self.handle, pos ) )
end

--- Gets the angular velocity of the body.
---
---@return Vector
function body_meta:GetAngularVelocity()
	assert( self:IsValid() )
	return MakeVector( GetBodyAngularVelocity( self.handle ) )
end

--- Gets the shape of the body.
---
---@return Shape[]
function body_meta:GetShapes()
	assert( self:IsValid() )
	local shapes = GetBodyShapes( self.handle )
	for i = 1, #shapes do
		shapes[i] = Shape( shapes[i] )
	end
	return shapes
end

--- Gets the vehicle of the body.
---
---@return Vehicle?
function body_meta:GetVehicle()
	assert( self:IsValid() )
	return Vehicle( GetBodyVehicle( self.handle ) )
end

--- Gets the bounds of the body.
---
---@return Vector min
---@return Vector max
function body_meta:GetWorldBounds()
	assert( self:IsValid() )
	local min, max = GetBodyBounds( self.handle )
	return MakeVector( min ), MakeVector( max )
end

--- Gets the center of mas in object-space.
---
---@return Vector
function body_meta:GetLocalCenterOfMass()
	assert( self:IsValid() )
	return MakeVector( GetBodyCenterOfMass( self.handle ) )
end

--- Gets the center of mass in world-space.
---
---@return Vector
function body_meta:GetWorldCenterOfMass()
	return self:GetTransform():ToGlobal( self:GetLocalCenterOfMass() )
end

--- Gets the closest point to the body from a given origin.
---
---@param origin Vector
---@return boolean hit
---@return Vector point
---@return Vector normal
---@return Shape shape
function body_meta:GetClosestPoint( origin )
	local hit, point, normal, shape = GetBodyClosestPoint( self.handle, origin )
	if not hit then
		return false
	end
	return hit, MakeVector( point ), MakeVector( normal ), Shape( shape )
end

--- Gets all the dynamic bodies in the jointed structure.
--- The result will include the current body.
---
---@return Body[] jointed
function body_meta:GetJointedBodies()
	local list = GetJointedBodies( self.handle )
	for i = 1, #list do
		list[i] = Body( list[i] )
	end
	return list
end

--- Gets if the body is currently being simulated.
---
---@return boolean
function body_meta:IsActive()
	assert( self:IsValid() )
	return IsBodyActive( self.handle )
end

--- Gets if the body is dynamic.
---
---@return boolean
function body_meta:IsDynamic()
	assert( self:IsValid() )
	return IsBodyDynamic( self.handle )
end

--- Gets if the body is visble on screen.
---
---@param maxdist number
---@return boolean
function body_meta:IsVisible( maxdist )
	assert( self:IsValid() )
	return IsBodyVisible( self.handle, maxdist )
end

--- Gets if the body has been broken.
---
---@return boolean
function body_meta:IsBroken()
	return not self:IsValid() or IsBodyBroken( self.handle )
end

--- Gets if the body somehow attached to something static.
---
---@return boolean
function body_meta:IsJointedToStatic()
	assert( self:IsValid() )
	return IsBodyJointedToStatic( self.handle )
end

 end)();
--src/entities/joint.lua
(function() ----------------
-- Joint class and related functions
-- @script entities.joint

---@class Joint: Entity
local joint_meta
joint_meta = global_metatable( "joint", "entity" )

--- Tests if the parameter is a joint entity.
---
---@param e any
---@return boolean
function IsJoint( e )
	return IsEntity( e ) and e.type == "joint"
end

--- Wraps the given handle with the joint class.
---
---@param handle number
---@return Joint?
function Joint( handle )
	if handle > 0 then
		return setmetatable( { handle = handle, type = "joint" }, joint_meta )
	end
end

--- Finds a joint with the specified tag.
--- `global` determines whether to only look in the script's hierarchy or the entire scene.
---
---@param tag string
---@param global boolean
---@return Joint?
function FindJointByTag( tag, global )
	return Joint( FindJoint( tag, global ) )
end

--- Finds all joints with the specified tag.
--- `global` determines whether to only look in the script's hierarchy or the entire scene.
---
---@param tag string
---@param global boolean
---@return Joint[]
function FindJointsByTag( tag, global )
	local t = FindJoints( tag, global )
	for i = 1, #t do
		t[i] = Joint( t[i] )
	end
	return t
end

---@type Joint

---@return string
function joint_meta:__tostring()
	return string.format( "Joint[%d]", self.handle )
end

--- Detatches the joint from the given shape.
---
---@param shape Shape
function joint_meta:DetachFromShape( shape )
	DetachJointFromShape( self.handle, GetEntityHandle( shape ) )
end

--- Makes the joint behave as a motor.
---
---@param velocity number
---@param strength number
function joint_meta:SetMotor( velocity, strength )
	assert( self:IsValid() )
	return SetJointMotor( self.handle, velocity, strength )
end

--- Makes the joint behave as a motor moving to the specified target.
---
---@param target number
---@param maxVel number
---@param strength number
function joint_meta:SetMotorTarget( target, maxVel, strength )
	assert( self:IsValid() )
	return SetJointMotorTarget( self.handle, target, maxVel, strength )
end

--- Gets the type of the joint.
---
---@return string
function joint_meta:GetJointType()
	assert( self:IsValid() )
	return GetJointType( self.handle )
end

--- Finds the other shape the joint is attached to.
---
---@param shape Shape | number
---@return Shape
function joint_meta:GetOtherShape( shape )
	assert( self:IsValid() )
	return Shape( GetJointOtherShape( self.handle, GetEntityHandle( shape ) ) )
end

--- Gets the limits of the joint.
---
---@return number min
---@return number max
function joint_meta:GetLimits()
	assert( self:IsValid() )
	return GetJointLimits( self.handle )
end

--- Gets the current position or angle of the joint.
---
---@return number
function joint_meta:GetMovement()
	assert( self:IsValid() )
	return GetJointMovement( self.handle )
end

--- Gets if the joint is broken.
---
---@return boolean
function joint_meta:IsBroken()
	return not self:IsValid() or IsJointBroken( self.handle )
end


 end)();
--src/entities/light.lua
(function() ----------------
-- Light class and related functions
-- @script entities.light

---@class Light: Entity
local light_meta
light_meta = global_metatable( "light", "entity" )

--- Tests if the parameter is a light entity.
---
---@param e any
---@return boolean
function IsLight( e )
	return IsEntity( e ) and e.type == "light"
end

--- Wraps the given handle with the light class.
---
---@param handle number
---@return Light?
function Light( handle )
	if handle > 0 then
		return setmetatable( { handle = handle, type = "light" }, light_meta )
	end
end

--- Finds a light with the specified tag.
--- `global` determines whether to only look in the script's hierarchy or the entire scene.
---
---@param tag string
---@param global boolean
---@return Light?
function FindLightByTag( tag, global )
	return Light( FindLight( tag, global ) )
end

--- Finds all lights with the specified tag.
--- `global` determines whether to only look in the script's hierarchy or the entire scene.
---
---@param tag string
---@param global boolean
---@return Light[]
function FindLightsByTag( tag, global )
	local t = FindLights( tag, global )
	for i = 1, #t do
		t[i] = Light( t[i] )
	end
	return t
end

---@type Light

---@return string
function light_meta:__tostring()
	return string.format( "Light[%d]", self.handle )
end

--- Sets if the light is enabled.
---
---@param enabled boolean
function light_meta:SetEnabled( enabled )
	assert( self:IsValid() )
	return SetLightEnabled( self.handle, enabled )
end

--- Sets the color of the light.
---
---@param r number
---@param g number
---@param b number
function light_meta:SetColor( r, g, b )
	assert( self:IsValid() )
	return SetLightColor( self.handle, r, g, b )
end

--- Sets the intensity of the light.
---
---@param intensity number
function light_meta:SetIntensity( intensity )
	assert( self:IsValid() )
	return SetLightIntensity( self.handle, intensity )
end

--- Gets the transform of the light.
---
---@return Transformation
function light_meta:GetTransform()
	assert( self:IsValid() )
	return MakeTransformation( GetLightTransform( self.handle ) )
end

--- Gets the shape the light is attached to.
---
---@return Shape
function light_meta:GetShape()
	assert( self:IsValid() )
	return Shape( GetLightShape( self.handle ) )
end

--- Gets if the light is active.
---
---@return boolean
function light_meta:IsActive()
	assert( self:IsValid() )
	return IsLightActive( self.handle )
end

--- Gets if the specified point is affected by the light.
---
---@param point Vector
---@return boolean
function light_meta:IsPointAffectedByLight( point )
	assert( self:IsValid() )
	return IsPointAffectedByLight( self.handle, point )
end

 end)();
--src/entities/location.lua
(function() ----------------
-- Location class and related functions
-- @script entities.location

---@class Location: Entity
local location_meta
location_meta = global_metatable( "location", "entity" )

--- Tests if the parameter is a location entity.
---
---@param e any
---@return boolean
function IsLocation( e )
	return IsEntity( e ) and e.type == "location"
end

--- Wraps the given handle with the location class.
---
---@param handle number
---@return Location?
function Location( handle )
	if handle > 0 then
		return setmetatable( { handle = handle, type = "location" }, location_meta )
	end
end

--- Finds a location with the specified tag.
--- `global` determines whether to only look in the script's hierarchy or the entire scene.
---
---@param tag string
---@param global boolean
---@return Location?
function FindLocationByTag( tag, global )
	return Location( FindLocation( tag, global ) )
end

--- Finds all locations with the specified tag.
--- `global` determines whether to only look in the script's hierarchy or the entire scene.
---
---@param tag string
---@param global boolean
---@return Location[]
function FindLocationsByTag( tag, global )
	local t = FindLocations( tag, global )
	for i = 1, #t do
		t[i] = Location( t[i] )
	end
	return t
end

---@type Location

---@return string
function location_meta:__tostring()
	return string.format( "Location[%d]", self.handle )
end

--- Gets the transform of the location.
---
---@return Transformation
function location_meta:GetTransform()
	assert( self:IsValid() )
	return MakeTransformation( GetLocationTransform( self.handle ) )
end

 end)();
--src/entities/player.lua
(function() ----------------
-- Player class and related functions
-- @script entities.player

---@class Player
local player_meta
player_meta = global_metatable( "player" )

---@type Player
PLAYER = setmetatable( {}, player_meta )

---@param data string
---@return Player self
function player_meta:__unserialize( data )
	return self
end

---@return string data
function player_meta:__serialize()
	return ""
end

---@return string
function player_meta:__tostring()
	return string.format( "Player" )
end

--- Gets the type of the entity.
---
---@return string type
function player_meta:GetType()
	return "player"
end

--- Repawns the player.
function player_meta:Respawn()
	return RespawnPlayer()
end

--- Release what the player is currently holding.
---
function player_meta:ReleaseGrab()
	ReleasePlayerGrab()
end

--- Sets the transform of the player.
---
---@param transform Transformation
function player_meta:SetTransform( transform )
	return SetPlayerTransform( transform )
end

--- Sets the transform of the camera.
---
---@param transform Transformation
function player_meta:SetCamera( transform )
	return SetCameraTransform( transform )
end

--- Sets the Field of View of the camera.
---
---@param degrees number
function player_meta:SetFov( degrees )
	return SetCameraFov( degrees )
end

--- Sets the Depth of Field of the camera.
---
---@param distance number
---@param amount number
function player_meta:SetDof( distance, amount )
	return SetCameraDof( distance, amount )
end

--- Sets the transform of the player spawn.
---
---@param transform Transformation
function player_meta:SetSpawnTransform( transform )
	return SetPlayerSpawnTransform( transform )
end

--- Sets the vehicle the player is currently riding.
---
---@param handle Vehicle | number
function player_meta:SetVehicle( handle )
	return SetPlayerVehicle( GetEntityHandle( handle ) )
end

--- Sets the velocity of the player.
---
---@param velocity Vector
function player_meta:SetVelocity( velocity )
	return SetPlayerVelocity( velocity )
end

--- Sets the screen the player is currently viewing.
---
---@param handle Screen | number
function player_meta:SetScreen( handle )
	return SetPlayerScreen( GetEntityHandle( handle ) )
end

--- Sets the health of the player.
---
---@param health number
function player_meta:SetHealth( health )
	return SetPlayerHealth( health )
end

--- Sets the velocity of the ground for the player,
--- Effectively turning it into a conveyor belt of sorts.
---
---@param vel Vector
function player_meta:SetGroundVelocity(vel)
	SetPlayerGroundVelocity(vel)
end

--- Gets the transform of the player.
---
---@return Transformation
function player_meta:GetTransform()
	return MakeTransformation( GetPlayerTransform() )
end

--- Gets the transform of the player camera.
---
---@return Transformation
function player_meta:GetPlayerCamera()
	return MakeTransformation( GetPlayerCameraTransform() )
end

--- Gets the transform of the camera.
---
---@return Transformation
function player_meta:GetCamera()
	return MakeTransformation( GetCameraTransform() )
end

--- Gets the velocity of the player.
---
---@return Vector
function player_meta:GetVelocity()
	return MakeVector( GetPlayerVelocity() )
end

--- Gets the vehicle the player is currently riding.
---
---@return Vehicle
function player_meta:GetVehicle()
	return Vehicle( GetPlayerVehicle() )
end

--- Gets the shape the player is currently grabbing.
---
---@return Shape
function player_meta:GetGrabShape()
	return Shape( GetPlayerGrabShape() )
end

--- Gets the body the player is currently grabbing.
---
---@return Body
function player_meta:GetGrabBody()
	return Body( GetPlayerGrabBody() )
end

--- Gets the pick-able shape the player is currently targetting.
---
---@return Shape
function player_meta:GetPickShape()
	return Shape( GetPlayerPickShape() )
end

--- Gets the pick-able body the player is currently targetting.
---
---@return Body
function player_meta:GetPickBody()
	return Body( GetPlayerPickBody() )
end

--- Gets the interactible shape the player is currently targetting.
---
---@return Shape
function player_meta:GetInteractShape()
	return Shape( GetPlayerInteractShape() )
end

--- Gets the interactible body the player is currently targetting.
---
---@return Body
function player_meta:GetInteractBody()
	return Body( GetPlayerInteractBody() )
end

--- Gets the screen the player is currently interacting with.
---
---@return Screen
function player_meta:GetScreen()
	return Screen( GetPlayerScreen() )
end

--- Gets the player health.
---
---@return number
function player_meta:GetHealth()
	return GetPlayerHealth()
end

 end)();
--src/entities/screen.lua
(function() ----------------
-- Screen class and related functions
-- @script entities.screen

---@class Screen: Entity
local screen_meta
screen_meta = global_metatable( "screen", "entity" )

--- Tests if the parameter is a screen entity.
---
---@param e any
---@return boolean
function IsScreen( e )
	return IsEntity( e ) and e.type == "screen"
end

--- Wraps the given handle with the screen class.
---
---@param handle number
---@return Screen?
function Screen( handle )
	if handle > 0 then
		return setmetatable( { handle = handle, type = "screen" }, screen_meta )
	end
end

--- Finds a screen with the specified tag.
--- `global` determines whether to only look in the script's hierarchy or the entire scene.
---
---@param tag string
---@param global boolean
---@return Screen?
function FindScreenByTag( tag, global )
	return Screen( FindScreen( tag, global ) )
end

--- Finds all screens with the specified tag.
--- `global` determines whether to only look in the script's hierarchy or the entire scene.
---
---@param tag string
---@param global boolean
---@return Screen[]
function FindScreensByTag( tag, global )
	local t = FindScreens( tag, global )
	for i = 1, #t do
		t[i] = Screen( t[i] )
	end
	return t
end

---@type Screen

---@return string
function screen_meta:__tostring()
	return string.format( "Screen[%d]", self.handle )
end

--- Sets if the screen is enabled.
---
---@param enabled boolean
function screen_meta:SetEnabled( enabled )
	assert( self:IsValid() )
	return SetScreenEnabled( self.handle, enabled )
end

--- Gets the shape the screen is attached to.
---
---@return Shape
function screen_meta:GetShape()
	assert( self:IsValid() )
	return Shape( GetScreenShape( self.handle ) )
end

--- Gets if the screen is enabled.
---
---@return boolean
function screen_meta:IsEnabled()
	assert( self:IsValid() )
	return IsScreenEnabled( self.handle )
end

 end)();
--src/entities/shape.lua
(function() ----------------
-- Shape class and related functions
-- @script entities.shape

---@class Shape: Entity
local shape_meta
shape_meta = global_metatable( "shape", "entity" )

--- Tests if the parameter is a shape entity.
---
---@param e any
---@return boolean
function IsShape( e )
	return IsEntity( e ) and e.type == "shape"
end

--- Wraps the given handle with the shape class.
---
---@param handle number
---@return Shape?
function Shape( handle )
	if handle > 0 then
		return setmetatable( { handle = handle, type = "shape" }, shape_meta )
	end
end

--- Finds a shape with the specified tag.
--- `global` determines whether to only look in the script's hierarchy or the entire scene.
---
---@param tag string
---@param global boolean
---@return Shape?
function FindShapeByTag( tag, global )
	return Shape( FindShape( tag, global ) )
end

--- Finds all shapes with the specified tag.
--- `global` determines whether to only look in the script's hierarchy or the entire scene.
---
---@param tag string
---@param global boolean
---@return Shape[]
function FindShapesByTag( tag, global )
	local t = FindShapes( tag, global )
	for i = 1, #t do
		t[i] = Shape( t[i] )
	end
	return t
end

---@type Shape

---@return string
function shape_meta:__tostring()
	return string.format( "Shape[%d]", self.handle )
end

--- Draws the outline of the shape.
---
---@param r number
---@overload fun(r: number, g: number, b: number, a: number)
function shape_meta:DrawOutline( r, ... )
	assert( self:IsValid() )
	return DrawShapeOutline( self.handle, r, ... )
end

--- Draws a highlight of the shape.
---
---@param amount number
function shape_meta:DrawHighlight( amount )
	assert( self:IsValid() )
	return DrawShapeHighlight( self.handle, amount )
end

--- Sets the transform of the shape relative to its body.
---
---@param transform Transformation
function shape_meta:SetLocalTransform( transform )
	assert( self:IsValid() )
	return SetShapeLocalTransform( self.handle, transform )
end

--- Sets the emmissivity scale of the shape.
---
---@param scale number
function shape_meta:SetEmissiveScale( scale )
	assert( self:IsValid() )
	return SetShapeEmissiveScale( self.handle, scale )
end

--- Sets the collision filter of the shape.
--- A shape will only collide with another if the following is true:
--- ```
--- (A.layer & B.mask) && (B.layer & A.mask)
--- ```
---
---@param layer? number bit array (8 bits, 0-255)
---@param mask? number bit mask (8 bits, 0-255)
function shape_meta:SetCollisionFilter( layer, mask )
	SetShapeCollisionFilter( self.handle, layer or 1, mask or 255 )
end

--- Gets the transform of the shape relative to its body.
---
---@return Transformation
function shape_meta:GetLocalTransform()
	assert( self:IsValid() )
	return MakeTransformation( GetShapeLocalTransform( self.handle ) )
end

--- Gets the transform of the shape.
---
---@return Transformation
function shape_meta:GetWorldTransform()
	assert( self:IsValid() )
	return MakeTransformation( GetShapeWorldTransform( self.handle ) )
end

--- Gets the body of this shape.
---
---@return Body
function shape_meta:GetBody()
	assert( self:IsValid() )
	return Body( GetShapeBody( self.handle ) )
end

--- Gets the joints attached to this shape.
---
---@return Joint[]
function shape_meta:GetJoints()
	assert( self:IsValid() )
	local joints = GetShapeJoints( self.handle )
	for i = 1, #joints do
		joints[i] = Joint( joints[i] )
	end
	return joints
end

--- Gets the lights attached to this shape.
---
---@return Light[]
function shape_meta:GetLights()
	assert( self:IsValid() )
	local lights = GetShapeLights( self.handle )
	for i = 1, #lights do
		lights[i] = Light( lights[i] )
	end
	return lights
end

--- Gets the bounds of the shape.
---
---@return Vector min
---@return Vector max
function shape_meta:GetWorldBounds()
	assert( self:IsValid() )
	local min, max = GetShapeBounds( self.handle )
	return MakeVector( min ), MakeVector( max )
end

--- Gets the material and color of the shape at the specified position.
---
---@param pos Vector
---@return string type
---@return number r
---@return number g
---@return number b
---@return number a
function shape_meta:GetMaterialAtPos( pos )
	assert( self:IsValid() )
	return GetShapeMaterialAtPosition( self.handle, pos )
end

--- Gets the size of the shape in voxels.
---
---@return number x
---@return number y
---@return number z
function shape_meta:GetSize()
	assert( self:IsValid() )
	return GetShapeSize( self.handle )
end

--- Gets the count of voxels in the shape.
---
---@return number
function shape_meta:GetVoxelCount()
	assert( self:IsValid() )
	return GetShapeVoxelCount( self.handle )
end

--- Gets the closest point to the shape from a given origin.
---
---@param origin Vector
---@return boolean hit
---@return Vector point
---@return Vector normal
function shape_meta:GetClosestPoint( origin )
	local hit, point, normal = GetShapeClosestPoint( self.handle, origin )
	if not hit then
		return false
	end
	return hit, MakeVector( point ), MakeVector( normal )
end

--- Gets if the shape is currently visible.
---
---@param maxDist number
---@param rejectTransparent? boolean
---@return boolean
function shape_meta:IsVisible( maxDist, rejectTransparent )
	assert( self:IsValid() )
	return IsShapeVisible( self.handle, maxDist, rejectTransparent )
end

--- Gets if the shape has been broken.
---
---@return boolean
function shape_meta:IsBroken()
	return not self:IsValid() or IsShapeBroken( self.handle )
end

 end)();
--src/entities/trigger.lua
(function() ----------------
-- Trigger class and related functions
-- @script entities.trigger

---@class Trigger: Entity
local trigger_meta
trigger_meta = global_metatable( "trigger", "entity" )

--- Tests if the parameter is a trigger entity.
---
---@param e any
---@return boolean
function IsTrigger( e )
	return IsEntity( e ) and e.type == "trigger"
end

--- Wraps the given handle with the trigger class.
---
---@param handle number
---@return Trigger?
function Trigger( handle )
	if handle > 0 then
		return setmetatable( { handle = handle, type = "trigger" }, trigger_meta )
	end
end

--- Finds a trigger with the specified tag.
--- `global` determines whether to only look in the script's hierarchy or the entire scene.
---
---@param tag string
---@param global boolean
---@return Trigger?
function FindTriggerByTag( tag, global )
	return Trigger( FindTrigger( tag, global ) )
end

--- Finds all triggers with the specified tag.
--- `global` determines whether to only look in the script's hierarchy or the entire scene.
---
---@param tag string
---@param global boolean
---@return Trigger[]
function FindTriggersByTag( tag, global )
	local t = FindTriggers( tag, global )
	for i = 1, #t do
		t[i] = Trigger( t[i] )
	end
	return t
end

---@type Trigger

---@return string
function trigger_meta:__tostring()
	return string.format( "Trigger[%d]", self.handle )
end

--- Sets the transform of the trigger.
---
---@param transform Transformation
function trigger_meta:SetTransform( transform )
	assert( self:IsValid() )
	return SetTriggerTransform( self.handle, transform )
end

--- Gets the transform of the trigger.
---
---@return Transformation
function trigger_meta:GetTransform()
	assert( self:IsValid() )
	return MakeTransformation( GetTriggerTransform( self.handle ) )
end

--- Gets the distance to the trigger from a given origin.
--- Negative values indicate the origin is inside the trigger.
---
---@param origin Vector
function trigger_meta:GetDistance(origin)
	return GetTriggerDistance(self.handle, origin)
end

--- Gets the closest point to the trigger from a given origin.
---
---@param origin Vector
function trigger_meta:GetClosestPoint(origin)
	return MakeVector(GetTriggerDistance(self.handle, origin))
end

--- Gets the bounds of the trigger.
---
---@return Vector min
---@return Vector max
function trigger_meta:GetWorldBounds()
	assert( self:IsValid() )
	local min, max = GetTriggerBounds( self.handle )
	return MakeVector( min ), MakeVector( max )
end

--- Gets if the specified body is in the trigger.
---
---@param handle Body | number
---@return boolean
function trigger_meta:IsBodyInTrigger( handle )
	assert( self:IsValid() )
	return IsBodyInTrigger( self.handle, GetEntityHandle( handle ) )
end

--- Gets if the specified vehicle is in the trigger.
---
---@param handle Vehicle | number
---@return boolean
function trigger_meta:IsVehicleInTrigger( handle )
	assert( self:IsValid() )
	return IsVehicleInTrigger( self.handle, GetEntityHandle( handle ) )
end

--- Gets if the specified shape is in the trigger.
---
---@param handle Shape | number
---@return boolean
function trigger_meta:IsShapeInTrigger( handle )
	assert( self:IsValid() )
	return IsShapeInTrigger( self.handle, GetEntityHandle( handle ) )
end

--- Gets if the specified point is in the trigger.
---
---@param point Vector
---@return boolean
function trigger_meta:IsPointInTrigger( point )
	assert( self:IsValid() )
	return IsPointInTrigger( self.handle, point )
end

--- Gets if the trigger is empty.
---
---@param demolision boolean
---@return boolean empty
---@return Vector? highpoint
function trigger_meta:IsEmpty( demolision )
	assert( self:IsValid() )
	local empty, highpoint = IsTriggerEmpty( self.handle, demolision )
	return empty, highpoint and MakeVector( highpoint )
end

 end)();
--src/entities/vehicle.lua
(function() ----------------
-- Vehicle class and related functions
-- @script entities.vehicle

---@class Vehicle: Entity
local vehicle_meta
vehicle_meta = global_metatable( "vehicle", "entity" )

--- Tests if the parameter is a vehicle entity.
---
---@param e any
---@return boolean
function IsVehicle( e )
	return IsEntity( e ) and e.type == "vehicle"
end

--- Wraps the given handle with the vehicle class.
---
---@param handle number
---@return Vehicle?
function Vehicle( handle )
	if handle > 0 then
		return setmetatable( { handle = handle, type = "vehicle" }, vehicle_meta )
	end
end

--- Finds a vehicle with the specified tag.
--- `global` determines whether to only look in the script's hierarchy or the entire scene.
---
---@param tag string
---@param global boolean
---@return Vehicle?
function FindVehicleByTag( tag, global )
	return Vehicle( FindVehicle( tag, global ) )
end

--- Finds all vehicles with the specified tag.
--- `global` determines whether to only look in the script's hierarchy or the entire scene.
---
---@param tag string
---@param global boolean
---@return Vehicle[]
function FindVehiclesByTag( tag, global )
	local t = FindVehicles( tag, global )
	for i = 1, #t do
		t[i] = Vehicle( t[i] )
	end
	return t
end

---@type Vehicle

---@return string
function vehicle_meta:__tostring()
	return string.format( "Vehicle[%d]", self.handle )
end

--- Drives the vehicle by setting its controls.
---
---@param drive number
---@param steering number
---@param handbrake number
function vehicle_meta:Drive( drive, steering, handbrake )
	assert( self:IsValid() )
	return DriveVehicle( self.handle, drive, steering, handbrake )
end

--- Gets the transform of the vehicle.
---
---@return Transformation
function vehicle_meta:GetTransform()
	assert( self:IsValid() )
	return MakeTransformation( GetVehicleTransform( self.handle ) )
end

--- Gets the body of the vehicle.
---
---@return Body
function vehicle_meta:GetBody()
	assert( self:IsValid() )
	return Body( GetVehicleBody( self.handle ) )
end

--- Gets the health of the vehicle.
---
---@return number
function vehicle_meta:GetHealth()
	assert( self:IsValid() )
	-- TODO: calculate ourselves if we need to
	return GetVehicleHealth( self.handle )
end

--- Gets the position of the driver camera in object-space.
---
---@return Vector
function vehicle_meta:GetDriverPos()
	assert( self:IsValid() )
	return MakeVector( GetVehicleDriverPos( self.handle ) )
end

--- Gets the position of the driver camera in world-space.
---
---@return Vector
function vehicle_meta:GetGlobalDriverPos()
	return self:GetTransform():ToGlobal( self:GetDriverPos() )
end

 end)();
--src/animation/animation.lua
(function() 
local animator_meta = global_metatable( "animator" )

function animator_meta:Update( dt )
	self.value = self._func( self._state, self._modifier * dt ) or self._state.value or 0
	return self.value
end

function animator_meta:Reset()
	self._state = {}
	if self._init then
		self._init( self._state )
	end
	self.value = self._state.value or 0
end

function animator_meta:SetModifier( num )
	self._modifier = num
end

function animator_meta:__newindex( k, v )
	self._state[k] = v
end

function animator_meta:__index( k )
	local v = animator_meta[k]
	if v then
		return v
	end
	return rawget( self, "_state" )[k]
end

Animator = {
	Base = function( easing )
		local t = setmetatable( {
			_state = {},
			_func = type( easing ) == "table" and easing.update or easing,
			_init = type( easing ) == "table" and easing.init,
			_modifier = 1,
			value = 0,
		}, animator_meta )
		if t._init then
			t._init( t._state )
		end
		return t
	end,
}

Animator.LinearApproach = function( init, speed, down_speed )
	return Animator.Base {
		update = function( state, dt )
			if state.target < state.value then
				state.value = state.value + math.max( state.target - state.value, dt * state.down_speed )
			elseif state.target > state.value then
				state.value = state.value + math.min( state.target - state.value, dt * state.speed )
			end
		end,
		init = function( state )
			state.value = init
			state.speed = speed
			state.down_speed = down_speed or -speed
			state.target = init
		end,
	}
end

Animator.SpeedLinearApproach = function( init, acceleration, down_acceleration )
	return Animator.Base {
		update = function( state, dt )
			state.driver.target = state.target
			state.driver.speed = state.acceleration
			state.driver.down_speed = state.down_acceleration
			state.value = state.value + state.driver:Update( dt ) * dt
		end,
		init = function( state )
			state.driver = Animator.LinearApproach( init, acceleration )
			state.target = init
			state.acceleration = acceleration
			state.down_acceleration = down_acceleration
			state.value = 0
		end,
	}
end

 end)();
--src/animation/armature.lua
(function() ----------------
-- Armature library
-- @script animation.armature

---@class Armature
---@field refs any
---@field root any
---@field scale number | nil
---@field dirty boolean
local armature_meta
armature_meta = global_metatable( "armature" )

--[[

Armature {
    shapes = {
        "core_2",
        "core_1",
        "core_0",
        "arm_21",
        "arm_11",
        "arm_01",
        "arm_20",
        "arm_10",
        "arm_00",
        "body"
    },

    bones = {
        name = "root",
        shapes = {
            body = Transformation(Vec(0,0,0), QuatEuler(0,0,0)),
        },
        {
            name = "core_0",
            shapes = {
                core_0 = Transformation(Vec(0,0,0), QuatEuler(0,0,0)),
            },
        },
        {
            name = "core_1",
            shapes = {
                core_1 = Transformation(Vec(0,0,0), QuatEuler(0,0,0)),
            },
        },
        {
            name = "core_2",
            shapes = {
                core_2 = Transformation(Vec(0,0,0), QuatEuler(0,0,0)),
            },
        },
        {
            name = "arm_00",
            shapes = {
                arm_00 = Transformation(Vec(0,0,0), QuatEuler(0,0,0)),
            },
            {
                name = "arm_01",
                shapes = {
                    arm_01 = Transformation(Vec(0,0,0), QuatEuler(0,0,0)),
                },
            },
        },
        {
            name = "arm_10",
            shapes = {
                arm_10 = Transformation(Vec(0,0,0), QuatEuler(0,0,0)),
            },
            {
                name = "arm_11",
                shapes = {
                    arm_11 = Transformation(Vec(0,0,0), QuatEuler(0,0,0)),
                },
            },
        },
        {
            name = "arm_20",
            shapes = {
                arm_20 = Transformation(Vec(0,0,0), QuatEuler(0,0,0)),
            },
            {
                name = "arm_21",
                shapes = {
                    arm_21 = Transformation(Vec(0,0,0), QuatEuler(0,0,0)),
                },
            },
        },
    }
}

]]

--- Loads armature information from a prefab and a list of shapes.
---
---@param xml string
---@param parts table[]
---@param scale? number
function LoadArmatureFromXML( xml, parts, scale ) -- Example below
	scale = scale or 1
	local dt = ParseXML( xml )
	assert( (dt.type == "prefab" and dt.children[1] and dt.children[1].type == "group") or dt.type == "group", "Invalid Tool XML" )
	local shapes = {}
	local offsets = {}
	for i = 1, #parts do
		shapes[i] = parts[i][1]
		local v = parts[i][2]
		-- Compensate for the editor placing vox parts relative to the center of the base
		offsets[parts[i][1]] = Vec( math.floor( v[1] / 2 ) / 10, 0, -math.floor( v[2] / 2 ) / 10 )
	end

	local function parseVec( str )
		if not str then
			return Vec( 0, 0, 0 )
		end
		local x, y, z = str:match( "([%d.-]+) ([%d.-]+) ([%d.-]+)" )
		return Vec( tonumber( x ), tonumber( y ), tonumber( z ) )
	end

	local function parseTransform( attr )
		local pos, angv = parseVec( attr.pos ), parseVec( attr.rot )
		return Transform( Vec( pos[1], pos[2], pos[3] ), QuatEuler( angv[1], angv[2], angv[3] ) )
	end

	local function translatebone( node, isLocation )
		local t = { name = node.attributes.name, transform = parseTransform( node.attributes ) }
		local sub = t
		if not isLocation then
			t.name = "__FIXED_" .. node.attributes.name
			t[1] = { name = node.attributes.name }
			sub = t[1]
		end
		sub.shapes = {}
		for i = 1, #node.children do
			local child = node.children[i]
			if child.type == "vox" then
				local name = child.attributes.object
				local tr = parseTransform( child.attributes )
				local s = child.attributes.scale and tonumber( child.attributes.scale ) or 1
				tr.pos = VecSub( tr.pos, VecScale( offsets[name], s ) )
				tr.rot = QuatRotateQuat( tr.rot, QuatEuler( -90, 0, 0 ) )
				sub.shapes[name] = tr
			elseif child.type == "group" then
				sub[#sub + 1] = translatebone( child )
			elseif child.type == "location" then
				sub[#sub + 1] = translatebone( child, true )
			end
		end
		return t
	end
	local bones = translatebone( dt.type == "prefab" and dt.children[1] or dt )[1]
	bones.transform = Transform( Vec(), QuatEuler( 0, 0, 0 ) )
	bones.name = "root"

	local arm = Armature { shapes = shapes, scale = scale, bones = bones }
	arm:ComputeBones()
	return arm, dt
end
--[=[
--[[---------------------------------------------------
    LoadArmatureFromXML is capable of taking the XML of a prefab and turning it into a useable armature object for tools and such.
    Two things are required: the XML of the prefab itself, and a list of all the objects inside the vox for position correction.
    The list of objects should be as it appears in MagicaVoxel, with every slot corresponding to an object in the vox file.
    One notable limitation is that there can only be one vox file used and that all the objects inside it can only be used once.
--]]---------------------------------------------------

-- Loading the armature from the prefab and the objects list
local armature = LoadArmatureFromXML([[
<prefab version="0.7.0">
    <group id_="1196432640" open_="true" name="instance=MOD/physgun.xml" pos="-3.4 0.7 0.0" rot="0.0 0.0 0.0">
        <vox id_="1866644736" pos="-0.125 -0.125 0.125" file="MOD/physgun.vox" object="body" scale="0.5"/>
        <group id_="279659168" open_="true" name="core0" pos="0.0 0.0 -0.075" rot="0.0 0.0 0.0">
            <vox id_="496006720" pos="-0.025 -0.125 0.0" rot="0.0 0.0 0.0" file="MOD/physgun.vox" object="core_0" scale="0.5"/>
        </group>
        <group id_="961930560" open_="true" name="core1" pos="0.0 0.0 -0.175" rot="0.0 0.0 0.0">
            <vox id_="1109395584" pos="-0.025 -0.125 0.0" rot="0.0 0.0 0.0" file="MOD/physgun.vox" object="core_1" scale="0.5"/>
        </group>
        <group id_="806535232" open_="true" name="core2" pos="0.0 0.0 -0.275" rot="0.0 0.0 0.0">
            <vox id_="378362432" pos="-0.025 -0.125 0.0" rot="0.0 0.0 0.0" file="MOD/physgun.vox" object="core_2" scale="0.5"/>
        </group>
        <group id_="1255943040" open_="true" name="arms_rot" pos="0.0 0.0 -0.375" rot="0.0 0.0 0.0">
            <group id_="439970016" open_="true" name="arm0_base" pos="0.0 0.1 0.0" rot="0.0 0.0 0.0">
                <vox id_="1925106432" pos="-0.025 0.0 0.025" file="MOD/physgun.vox" object="arm_00" scale="0.5"/>
                <group id_="2122316288" open_="true" name="arm0_tip" pos="0.0 0.2 -0.0" rot="0.0 0.0 0.0">
                    <vox id_="572557440" pos="-0.025 0.0 0.025" file="MOD/physgun.vox" object="arm_01" scale="0.5"/>
                </group>
            </group>
            <group id_="516324128" open_="true" name="arm1_base" pos="0.087 -0.05 0.0" rot="180.0 180.0 -60.0">
                <vox id_="28575440" pos="-0.025 0.0 0.025" file="MOD/physgun.vox" object="arm_10" scale="0.5"/>
                <group id_="962454912" open_="true" name="arm1_tip" pos="0.0 0.2 0.0" rot="0.0 0.0 0.0">
                    <vox id_="1966724352" pos="-0.025 0.0 0.025" file="MOD/physgun.vox" object="arm_11" scale="0.5"/>
                </group>
            </group>
            <group id_="634361664" open_="true" name="arm2_base" pos="-0.087 -0.05 0.0" rot="180.0 180.0 60.0">
                <vox id_="1049360960" pos="-0.025 0.0 0.025" file="MOD/physgun.vox" object="arm_20" scale="0.5"/>
                <group id_="1428116608" open_="true" name="arm2_tip" pos="0.0 0.2 0.0" rot="0.0 0.0 0.0">
                    <vox id_="1388661504" pos="-0.025 0.0 0.025" file="MOD/physgun.vox" object="arm_21" scale="0.5"/>
                </group>
            </group>
        </group>
        <group id_="1569551872" open_="true" name="nozzle" pos="0.0 0.0 -0.475">
            <vox id_="506099872" pos="-0.025 -0.125 0.1" file="MOD/physgun.vox" object="cannon" scale="0.5"/>
        </group>
    </group>
</prefab>
]], {
    -- The list of objects as it appears in MagicaVoxel. Each entry has the name of the object followed by the size as seen in MagicaVoxel.
    -- Please note that the order MUST be the same as in MagicaVoxel and that there can be no gaps.
    {"cannon", Vec(5, 3, 5)},
    {"core_2", Vec(5, 2, 5)},
    {"core_1", Vec(5, 2, 5)},
    {"core_0", Vec(5, 2, 5)},
    {"arm_21", Vec(1, 1, 2)},
    {"arm_11", Vec(1, 1, 2)},
    {"arm_01", Vec(1, 1, 2)},
    {"arm_20", Vec(1, 1, 4)},
    {"arm_10", Vec(1, 1, 4)},
    {"arm_00", Vec(1, 1, 4)},
    {"body", Vec(9, 6, 5)}
})
-----------------------------------------------------

-- Every frame you can animate the armature by setting the local transform of bones and then applying the changes to the shapes of the object.
armature:SetBoneTransform("core0", Transform(Vec(), QuatEuler(0, 0, GetTime()*73)))
armature:SetBoneTransform("core1", Transform(Vec(), QuatEuler(0, 0, -GetTime()*45)))
armature:SetBoneTransform("core2", Transform(Vec(), QuatEuler(0, 0, GetTime()*83)))
armature:SetBoneTransform("arms_rot", Transform(Vec(), QuatEuler(0, 0, GetTime()*20)))
local tr = Transform(Vec(0,0,0), QuatEuler(-40 + 5 * math.sin(GetTime()), 0, 0))
armature:SetBoneTransform("arm0_base", tr)
armature:SetBoneTransform("arm0_tip", tr)
armature:SetBoneTransform("arm1_base", tr)
armature:SetBoneTransform("arm1_tip", tr)
armature:SetBoneTransform("arm2_base", tr)
armature:SetBoneTransform("arm2_tip", tr)
-- shapes is the list of all the shapes of the vox, it can be obtained with GetBodyShapes()
armature:Apply(shapes)

--]=]

--- Creates a new armature.
---
---@param definition table
---@return Armature
function Armature( definition )
	local ids = {}
	for i, name in ipairs( definition.shapes ) do
		ids[name] = #definition.shapes - i + 1
	end
	local armature = {
		root = definition.bones,
		refs = {},
		scale = definition.scale,
		__noquickload = function()
		end,
		dirty = true,
	}
	local function dobone( b )
		if b.name then
			armature.refs[b.name] = b
		end
		b.transform = b.transform or Transform()
		b.shape_offsets = {}
		b.dirty = true
		if b.shapes then
			for name, transform in pairs( b.shapes ) do
				table.insert( b.shape_offsets,
				              { id = ids[name], tr = Transform( VecScale( transform.pos, definition.scale or 1 ), transform.rot ) } )
			end
		end
		b.children = {}
		for i = 1, #b do
			b.children[i] = dobone( b[i] )
		end
		return b
	end
	dobone( armature.root )
	return setmetatable( armature, armature_meta )
end

---@type Armature

local function computebone( bone, transform, scale, dirty )
	dirty = dirty or bone.dirty or bone.jiggle_transform
	if dirty or not bone.gr_transform then
		bone.gr_transform = TransformToParentTransform( transform, bone.transform )
		if bone.jiggle_transform then
			bone.gr_transform = TransformToParentTransform( bone.gr_transform, bone.jiggle_transform )
		end
		bone.g_transform = Transform( VecScale( bone.gr_transform.pos, scale ), bone.gr_transform.rot )
		bone.dirty = false
	end
	for i = 1, #bone.children do
		computebone( bone.children[i], bone.gr_transform, scale, dirty )
	end
end

--- Computes the bone positions.
function armature_meta:ComputeBones()
	computebone( self.root, Transform(), self.scale or 1 )
	self.dirty = false
end

local function applybone( shapes, bone )
	for i = 1, #bone.shape_offsets do
		local offset = bone.shape_offsets[i]
		SetShapeLocalTransform( GetEntityHandle and GetEntityHandle( shapes[offset.id] ) or shapes[offset.id],
		                        TransformToParentTransform( bone.g_transform, offset.tr ) )
	end
	for i = 1, #bone.children do
		applybone( shapes, bone.children[i] )
	end
end

--- Applies the bone positions to a list of shapes.
---
---@param shapes Shape[] | number[]
function armature_meta:Apply( shapes )
	if self.dirty or self.jiggle then
		self:ComputeBones()
	end
	applybone( shapes, self.root )
end

--- Sets the local transform of a bone.
---
---@param bone string
---@param transform Transformation
function armature_meta:SetBoneTransform( bone, transform )
	local b = self.refs[bone]
	if not b then
		return
	end
	self.dirty = true
	b.dirty = true
	b.transform = transform
end

--- Gets the local transform of a bone.
---
---@param bone string
---@return Transformation
function armature_meta:GetBoneTransform( bone )
	local b = self.refs[bone]
	if not b then
		return Transform()
	end
	return b.transform
end

--- Gets the global transform of a bone.
---
---@param bone string
---@return Transformation
function armature_meta:GetBoneGlobalTransform( bone )
	local b = self.refs[bone]
	if not b then
		return Transform()
	end
	if self.dirty then
		self:ComputeBones()
	end
	return b.g_transform
end

---@alias JiggleConstaint { gravity?: number }

--- Sets the jiggle constraints of a bone.
---
---@param bone string
---@param jiggle number
---@param constraint? JiggleConstaint
function armature_meta:SetBoneJiggle( bone, jiggle, constraint )
	local b = self.refs[bone]
	if not b then
		return
	end
	self.dirty = true
	if jiggle > 0 then
		self.jiggle = true
	end
	b.jiggle = math.atan( jiggle ) / math.pi * 2
	b.jiggle_constraint = constraint
end

--- Gets the jiggle constraints of a bone.
---
---@param bone string
---@return number jiggle
---@return JiggleConstaint constraints
function armature_meta:GetBoneJiggle( bone )
	local b = self.refs[bone]
	if not b then
		return 0
	end
	return b.jiggle, b.jiggle_constraint
end

--- Resets the jiggle state of all bones.
function armature_meta:ResetJiggle()
	for _, b in pairs( self.refs ) do
		b.jiggle_transform = nil
	end
	self.dirty = true
end

local function updatebone( bone, current_transform, prev_transform, dt, gravity )
	local current_transform_local = TransformToParentTransform( current_transform, bone.transform )
	local prev_transform_local = TransformToParentTransform( prev_transform, bone.old_transform or bone.transform )
	bone.old_transform = bone.transform
	if bone.jiggle then
		prev_transform_local = TransformToParentTransform( prev_transform_local, bone.jiggle_transform or Transform() )

		local local_diff = TransformToLocalTransform( current_transform_local, prev_transform_local )
		local target = TransformToParentPoint( local_diff, Vec( 0, 0, -2 / dt ) )

		if bone.jiggle_constraint and bone.jiggle_constraint.gravity then
			target = VecAdd( target,
			                 TransformToLocalVec( current_transform_local, VecScale( gravity, bone.jiggle_constraint.gravity ) ) )
		end

		local lookat = QuatLookAt( Vec(), target )

		bone.jiggle_transform = Transform( Vec(), QuatSlerp( lookat, QuatEuler( 0, 0, 0 ), 1 - bone.jiggle ) )
		current_transform_local = TransformToParentTransform( current_transform_local, bone.jiggle_transform )
	end
	for i = 1, #bone.children do
		updatebone( bone.children[i], current_transform_local, prev_transform_local, dt, gravity )
	end
end

--- Updates the physics of the armature.
---
---@param diff Transformation
---@param dt number
---@param gravity? Vector
function armature_meta:UpdatePhysics( diff, dt, gravity )
	dt = dt or 0.01666
	diff.pos = VecScale( diff.pos, 1 / dt )
	updatebone( self.root, Transform(), diff, dt, gravity or Vec( 0, -10, 0 ) )
end

local function DebugAxis( tr, s )
	s = s or 1
	DebugLine( tr.pos, TransformToParentPoint( tr, Vec( 1 * s, 0, 0 ) ), 1, 0, 0 )
	DebugLine( tr.pos, TransformToParentPoint( tr, Vec( 0, 1 * s, 0 ) ), 0, 1, 0 )
	DebugLine( tr.pos, TransformToParentPoint( tr, Vec( 0, 0, 1 * s ) ), 0, 0, 1 )
end

--- Draws debug info of the armature at the specified transform.
---
---@param transform? Transformation
function armature_meta:DrawDebug( transform )
	transform = transform or Transform()
	DebugAxis( transform, 0.05 )
	for k, v in pairs( self.refs ) do
		local r = TransformToParentTransform( transform, v.g_transform )
		local g = v.name:find( "^__FIXED_" ) and 1 or 0
		for i = 1, #v.children do
			DebugLine( r.pos, TransformToParentTransform( transform, v.children[i].g_transform ).pos, 1, 1 - g, g, .4 )
		end
		for i = 1, #v.shape_offsets do
			local offset = v.shape_offsets[i]
			local p = TransformToParentTransform( transform, TransformToParentTransform( v.g_transform, offset.tr ) )
			DebugAxis( p, 0.03 )
			DebugLine( r.pos, p.pos, 0, 1, 1, .4 )
		end
	end
end

 end)();
--src/tool/tool.lua
(function() ----------------
-- Tool Framework
-- @script tool.tool

---@class Tool
---@field _TRANSFORM Transformation
---@field _TRANSFORM_FIX Transformation
---@field _TRANSFORM_DIFF Transformation
---@field _ARMATURE Armature
---@field _TOOLAMMOSTRING string
---@field armature Armature
---@field _SHAPES Shape[]
---@field _OBJECTS table[]
---@field model string
---@field printname string
---@field id string
local tool_meta
tool_meta = global_metatable( "tool", nil, true )

local extra_tools = {}

--- Registers a tool using UMF.
---
---@param id string
---@param data table
---@return Tool
function RegisterToolUMF( id, data )
	if LoadArmatureFromXML and type( data.model ) == "table" then
		local arm, xml = LoadArmatureFromXML( data.model.prefab, data.model.objects, data.model.scale )
		data.armature = arm
		data._ARMATURE = arm
		data._OBJECTS = data.model.objects
		local function findvox( xml )
			if xml.type == "vox" then
				return xml.attributes["file"]
			end
			for i, c in ipairs( xml.children ) do
				local t = findvox( c )
				if t then
					return t
				end
			end
		end
		data.model = data.model.path or findvox( xml )
	end
	setmetatable( data, tool_meta )
	data.id = id
	extra_tools[id] = data
	RegisterTool( id, data.printname or id, data.model or "", data.group or 6 )
	SetBool( "game.tool." .. id .. ".enabled", true )
	for k, f in pairs( tool_meta._C ) do
		local v = rawget( data, k )
		if v ~= nil then
			rawset( data, k, nil )
			f( data, v )
		end
	end
	return data
end

---@type Tool

function tool_meta._C:ammo( val )
	local key = "game.tool." .. self.id .. ".ammo"
	local keystr = key .. ".display"
	if val ~= nil then
		if type( val ) == "number" then
			SetFloat( key, val )
			ClearKey( keystr )
			rawset( self, "_TOOLAMMOSTRING", false )
		else
			SetFloat( key, 0 )
			SetString( key .. ".display", tostring( val ) )
			rawset( self, "_TOOLAMMOSTRING", tostring( val ) )
		end
	elseif HasKey( keystr ) then
		return GetString( keystr )
	else
		return GetFloat( key )
	end
end

function tool_meta._C:enabled( val )
	local key = "game.tool." .. self.id .. ".enabled"
	if val ~= nil then
		SetBool( key, val )
	else
		return GetBool( key )
	end
end

--- Draws the tool in the world instead of the player view.
---
---@param transform Transformation
function tool_meta:DrawInWorld( transform )
	SetToolTransform( TransformToLocalTransform( GetCameraTransform(), transform ) )
end

--- Gets the transform of the tool.
---
---@return Transformation
function tool_meta:GetTransform()
	return self._TRANSFORM or MakeTransformation( GetBodyTransform( GetToolBody() ) )
end

--- Gets the predicted transform of the tool.
---
---@return Transformation
function tool_meta:GetPredictedTransform()
	return self._TRANSFORM_FIX or MakeTransformation( GetBodyTransform( GetToolBody() ) )
end

--- Gets the transform delta of the tool.
---
---@return Transformation
function tool_meta:GetTransformDelta()
	return self._TRANSFORM_DIFF or Transformation( Vec(), Quat() )
end

--- Gets the transform of a bone on the tool in world-space.
---
---@param bone string
---@param nopredicted? boolean
---@return Transformation
function tool_meta:GetBoneGlobalTransform( bone, nopredicted )
	if not self._ARMATURE then
		return Transformation( Vec(), Quat() )
	end
	return (nopredicted and self:GetTransform() or self:GetPredictedTransform()):ToGlobal(
		       self._ARMATURE:GetBoneGlobalTransform( bone ) )
end

--- Draws the debug armature of the tool.
---
---@param nobones? boolean Don't draw bones.
---@param nobounds? boolean Don't draw bounds.
---@param nopredicted? boolean Don't use the predicted transform.
function tool_meta:DrawDebug( nobones, nobounds, nopredicted )
	if not self._ARMATURE or not self._SHAPES then
		return
	end
	local ptr = (nopredicted and self:GetTransform() or self:GetPredictedTransform())
	if not nobones and self._ARMATURE then
		self._ARMATURE:DrawDebug( ptr )
	end
	if not nobounds and self._OBJECTS then
		local s = self._OBJECTS
		for i = 1, #self._SHAPES do
			visual.drawbox( ptr:ToGlobal( self._SHAPES[i]:GetLocalTransform() ), Vec( 0, 0, 0 ),
			                VecScale( s[#s + 1 - i][2], .05 ), { r = 1, g = 1, b = 1, a = .2, writeZ = false } )
		end
	end
end

--- Callback called when the level loads.
function tool_meta:Initialize()
end

--- Callback called when tick() is called.
---
---@param dt number
function tool_meta:Tick( dt )
end

--- Callback called when draw() is called.
---
---@param dt number
function tool_meta:Draw( dt )
end

--- Callback called to animate the armature.
---
---@param body Body
---@param shapes Shape[]
function tool_meta:Animate( body, shapes )
end

--- Callback called when the tool is deployed.
function tool_meta:Deploy()
end

--- Callback called when the tool is holstered.
function tool_meta:Holster()
end

local function istoolactive()
	return GetBool( "game.player.canusetool" )
end

local prev
hook.add( "api.mouse.wheel", "api.tool_loader", function( ds )
	if not istoolactive() then
		return
	end
	local tool = prev and extra_tools[prev]
	if tool and tool.MouseWheel then
		tool:MouseWheel( ds )
	end
end )

hook.add( "base.update", "api.tool_loader", function( dt )
	local cur = GetString( "game.player.tool" )
	local tool = extra_tools[cur]
	if tool then
		if tool.Update then
			softassert( pcall( tool.Update, tool, dt ) )
		end
	end
end )

hook.add( "base.tick", "api.tool_loader", function( dt )
	local cur = GetString( "game.player.tool" )

	local prevtool = prev and extra_tools[prev]
	if prevtool then
		if prevtool.ShouldLockMouseWheel then
			local s, b = softassert( pcall( prevtool.ShouldLockMouseWheel, prevtool ) )
			if s then
				SetBool( "game.input.locktool", not not b )
			end
			if b then
				SetString( "game.player.tool", prev )
				cur = prev
			end
		end
		if prev ~= cur and prevtool.Holster then
			softassert( pcall( prevtool.Holster, prevtool ) )
		end
	end

	local tool = extra_tools[cur]
	if tool then
		if prev ~= cur then
			if tool.Deploy then
				softassert( pcall( tool.Deploy, tool ) )
			end
			if tool._ARMATURE then
				tool._ARMATURE:ResetJiggle()
			end
		end
		local body = GetToolBody()
		if not tool._BODY or tool._BODY.handle ~= body then
			tool._BODY = Body( body )
			tool._SHAPES = tool._BODY and tool._BODY:GetShapes()
		end
		if tool._BODY then
			tool._TRANSFORM = tool._BODY:GetTransform()
			tool._TRANSFORM_DIFF = tool._TRANSFORM_OLD and tool._TRANSFORM:ToLocal( tool._TRANSFORM_OLD ) or
				                       Transformation( Vec(), Quat() )
			local reverse_diff = tool._TRANSFORM_OLD and tool._TRANSFORM_OLD:ToLocal( tool._TRANSFORM ) or
				                     Transformation( Vec(), Quat() )
			-- reverse_diff.pos = VecScale(reverse_diff.pos, 60 * dt)
			tool._TRANSFORM_FIX = tool._TRANSFORM:ToGlobal( reverse_diff )
			if tool.Animate then
				softassert( pcall( tool.Animate, tool, tool._BODY, tool._SHAPES ) )
			end
			if tool._ARMATURE then
				tool._ARMATURE:UpdatePhysics( tool:GetTransformDelta(), GetTimeStep(),
				                              TransformToLocalVec( tool:GetTransform(), Vec( 0, -10, 0 ) ) )
				tool._ARMATURE:Apply( tool._SHAPES )
			end
		end
		if tool._TOOLAMMOSTRING then
			-- Fix sandbox ammo string
			SetInt( "game.tool." .. tool.id .. ".ammo", 0 )
		end
		if tool.Tick then
			softassert( pcall( tool.Tick, tool, dt ) )
		end
		if tool._TRANSFORM then
			tool._TRANSFORM_OLD = tool._TRANSFORM
		end
	end
	prev = cur
end )

hook.add( "api.firsttick", "api.tool_loader", function()
	for id, tool in pairs( extra_tools ) do
		if tool.Initialize then
			softassert( pcall( tool.Initialize, tool ) )
		end
	end
end )

hook.add( "base.draw", "api.tool_loader", function( dt )
	local tool = extra_tools[GetString( "game.player.tool" )]
	if tool and tool.Draw then
		softassert( pcall( tool.Draw, tool, dt ) )
	end
end )

hook.add( "api.mouse.pressed", "api.tool_loader", function( button )
	local tool = extra_tools[GetString( "game.player.tool" )]
	local event = button == "lmb" and "LeftClick" or "RightClick"
	if tool and tool[event] and istoolactive() then
		softassert( pcall( tool[event], tool ) )
	end
end )

hook.add( "api.mouse.released", "api.tool_loader", function( button )
	local tool = extra_tools[GetString( "game.player.tool" )]
	local event = button == "lmb" and "LeftClickReleased" or "RightClickReleased"
	if tool and tool[event] and istoolactive() then
		softassert( pcall( tool[event], tool ) )
	end
end )

 end)();
--src/tdui/base.lua
(function() 
--[[
-- prototype code (desired outcome)
TDUI.Label = TDUI.Panel {

	text = ""
	font = RegisterFont("font/consolas.ttf"),
	fontSize = 24,

	Draw = function(self, w, h)
		UiFont(self.font, self.fontSize)
		UiAlign("left top")
		UiText(self.text)
		-- This example doesn't account for:
		--  * custom alignment
		--  * wrapping on width
		--  * Layout calculation
	end,
}

local window = TDUI.Frame {
	title = "Test Window",

	width = "80%h",
	height = "80%h",
	resizeable = true,

	padding = 10,

	TDUI.Label {
		text = "Something"
	}
}
]]

local function createchild( self, def )
	setmetatable( def, { __index = self, __call = createchild, __PANEL = true } )
	if self and self.__PerformInherit then
		self:__PerformInherit( def )
	end
	if def.__PerformRegister then
		def:__PerformRegister()
	end
	return def
end

TDUI = createchild( nil, {} )

local function parseFour( data )
	local dtype = type( data )
	if dtype == "number" then
		return { data, data, data, data }
	elseif dtype == "string" then
		local tmp = {}
		for match in data:gmatch( "[^ ]+" ) do
			tmp[#tmp + 1] = tonumber( match )
		end
		data = tmp
		dtype = "table"
	end
	if dtype == "table" then
		if #data == 0 then
			return { 0, 0, 0, 0 }
		end
		if #data == 1 then
			return { data[1], data[1], data[1], data[1] }
		end
		if #data < 4 then
			return { data[1], data[2], data[1], data[2] }
		end
		return data
	end
	return { 0, 0, 0, 0 }
end

local function parsePos( data, w, h, def )
	if type( data ) == "number" then
		return data
	end
	if type( data ) == "function" then
		return data( w, h, def )
	end
	if type( data ) ~= "string" then
		return 0
	end
	if data:find( "function" ) then
		return 0
	end

	local code = "local _,_w,_h = ...\nreturn" .. data:gsub( "(-?)([%d.]+)(%%?)([wh]?)", function( sub, n, prc, mod )
		if prc == "" and mod == "" then
			return sub .. n
		end
		return sub .. "(" .. n .. "*_" .. mod .. ")"
	end )
	local fn, err = loadstring( code )
	assert( fn, err )
	setfenv( fn, {} )

	return fn( def / 100, w / 100, h / 100 )
end

local function parseAlign( data )
	local alignx, aligny = 1, 1
	for str in data:gmatch( "%w+" ) do
		if str == "left" then
			alignx = 1
		end
		if str == "center" then
			alignx = 0
		end
		if str == "right" then
			alignx = -1
		end
		if str == "top" then
			aligny = 1
		end
		if str == "middle" then
			aligny = 0
		end
		if str == "bottom" then
			aligny = -1
		end
	end
	return alignx, aligny
end

TDUI.Slot = function( name )
	return { __SLOT = name }
end

-- Base Panel,
TDUI.Panel = TDUI {
	__alignx = 1,
	__aligny = 1,
	__realx = 0,
	__realy = 0,
	__realw = 0,
	__realh = 0,
	margin = { 0, 0, 0, 0 },
	padding = { 0, 0, 0, 0 },
	boxsizing = "parent",
	align = "left top",
	clip = false,
	visible = true,

	layout = TDUI.Layout,

	oninit = function( self )
	end,

	predraw = function( self, w, h )
	end,
	ondraw = function( self, w, h )
		-- UiColor(1, 1, 1)
		-- UiTranslate(-40, -40)
		-- UiImageBox("common/box-solid-shadow-50.png", w+80, h+81, 50, 50)
		-- UiTranslate(40, 40)
		-- UiColor(1, 0, 0, 0.2)
		-- UiRect(w, h)
	end,
	postdraw = function( self, w, h )
	end,

	__Draw = function( self )
		if not self.visible then
			return
		end
		if not rawget( self, "__validated" ) then
			self:InvalidateLayout( true )
		end
		local w, h = self:GetComputedSize()
		self:predraw( w, h )
		self:ondraw( w, h )

		if self.clip then
			UiPush()
			UiWindow( w, h, true )
		end

		local x, y = 0, 0
		for i = 1, #self do
			local child = self[i]
			local dfx, dfy = child:GetComputedPos()
			UiTranslate( dfx - x, dfy - y )
			child:__Draw()
			x, y = dfx, dfy
		end
		UiTranslate( -x, -y )

		if self.clip then
			UiPop()
		end

		self:postdraw( w, h )
	end,

	__PerformRegister = function( self )
		self.margin = parseFour( self.margin )
		self.padding = parseFour( self.padding )
		self.__alignx, self.__aligny = parseAlign( self.align )
		local i = 1
		self.__dynamic = {}
		local hasslots, slots = false, rawget( self, "__SLOTS" ) or {}
		while i <= #self do
			if type( self[i] ) == "function" or (type( self[i] ) == "table" and type( self[i].__SLOT ) == "string") then
				local id = #self.__dynamic + 1
				local result
				if self[i] == TDUI.Slot or (type( self[i] ) == "table" and type( self[i].__SLOT ) == "string") then
					local name = self[i] == TDUI.Slot and "default" or self[i].__SLOT
					result = {}
					local content
					slots[name] = function( c )
						content = c
						self:__RefreshDynamic( id )
					end
					self.__dynamic[id] = {
						func = function()
							return content
						end,
						min = i,
						count = 0,
					}
					hasslots = true
				else
					result = self[i]( self, id )
					self.__dynamic[id] = { func = self[i], min = i, count = #result }
				end
				if #result == 0 then
					table.remove( self, i )
				elseif #result == 1 then
					self[i] = result[1]
				else
					for j = #self, i + 1, -1 do
						self[j + #result - 1] = self[j]
					end
					for j = 1, #result do
						self[i + j - 1] = result[j]
					end
				end
				i = i - 1
			else
				local cslots = rawget( self[i], "__SLOTS" )
				if cslots then -- TODO: WHY DOES THIS SECTION WORK???
					hasslots = true -- need to use __dynamic to make sure the right child is being referenced
					for name, update in pairs( cslots ) do
						slots[name] = update
					end
					self[i].__SLOTS = nil
				end
				rawset( self[i], "__parent", self )
			end
			i = i + 1
		end
		if hasslots then
			self.__SLOTS = slots
		end
		self:oninit()
	end,

	__PerformInherit = function( self, child )
		local SLOTS = rawget( self, "__SLOTS" )
		if SLOTS then
			for name, update in pairs( SLOTS ) do
				local src = name == "default" and child or child[name]
				update( src )
			end
		end
		if SLOTS and SLOTS.default then
			for i = 1, #child do
				child[i] = nil
			end
		end
		if #self > 0 then
			for i = #child, 1, -1 do
				child[i + #self] = child[i]
			end
			for i = 1, #self do
				local meta = getmetatable( self[i] )
				if meta and meta.__PANEL then
					child[i] = self[i] {}
				else
					child[i] = self[i]
				end
			end
		end
	end,

	__RefreshDynamic = function( self, id )
		local dyn = self.__dynamic[id]
		if not dyn then
			return
		end
		local result = dyn.func( self, id )
		local d = #result - dyn.count
		if d > 0 then
			for i = #self, dyn.min + dyn.count, -1 do
				self[i + d] = self[i]
			end
		elseif d < 0 then
			for i = dyn.min + dyn.count, #self - d do
				self[i + d] = self[i]
			end
		end
		for i = 1, #result do
			self[dyn.min + i - 1] = result[i]
		end
		dyn.count = #result
		for i = id + 1, #self.__dynamic do
			self.__dynamic[i].min = self.__dynamic[i].min + d
		end
		self:InvalidateLayout()
	end,

	onlayout = function( self, data, pw, ph, ew, eh )
		-- onlayout must do 2 things:
		--  1. Position its children within the available space
		--  2. Compute its own size for the layout of its parent

		-- TODO: Optimize for static sizes and unchanged bounds

		local selflayout = self.layout
		if selflayout then
			local f = selflayout.onlayout
			if f and f ~= self.onlayout then
				return f( self, selflayout, pw, ph, ew, eh )
			end
		end
		warning( "Unable to compute layout" )
		self.__validated = true
		self:ComputeSize( pw, ph )
		for i = 1, #self do
			local child = self[i]
			child:onlayout( child, self.__realw, self.__realh, self.__realw, self.__realh )
			child:ComputePosition( 0, 0, self.__realw, self.__realh )
		end
		return self.__realw, self.__realh

		--[[self.__realx = self.x and parsePos(self.x, pw, ph, pw) or 0
		self.__realy = self.y and parsePos(self.y, pw, ph, ph) or 0
		self.__realw = self.width and parsePos(self.width, pw, ph, pw) or 256
		self.__realh = self.height and parsePos(self.height, pw, ph, ph) or 256
		self.__validated = true
		for i = 1, #self do
			local child = self[i]
			child:__PerformLayout(self.__realw, self.__realh)
		end]]
	end,

	ComputePosition = function( self, dx, dy, pw, ph )
		if self.boxsizing == "parent" then
			local parent = self:GetParent()
			if parent then
				pw = pw - self.margin[4] - self.margin[2]
				ph = ph - self.margin[1] - self.margin[3]
			end
		end

		local x = self.x and parsePos( self.x, pw, ph, pw ) or 0
		if self.__alignx == 1 then
			self.__realx = x + self.margin[4] + dx
		elseif self.__alignx == 0 then
			self.__realx = x + (pw - self.__realw) / 2 + dx
		elseif self.__alignx == -1 then
			self.__realx = x + pw - self.margin[2] - self.__realw + dx
		end

		local y = self.y and parsePos( self.y, pw, ph, ph ) or 0
		if self.__aligny == 1 then
			self.__realy = y + self.margin[1] + dy
		elseif self.__aligny == 0 then
			self.__realy = y + (ph - self.__realh) / 2 + dy
		elseif self.__aligny == -1 then
			self.__realy = y + ph - self.margin[3] - self.__realh + dy
		end

		return self.__realx, self.__realy
	end,

	ComputeSize = function( self, pw, ph )
		if self.boxsizing == "parent" then
			local parent = self:GetParent()
			if parent then
				pw = pw - self.margin[4] - self.margin[2]
				ph = ph - self.margin[1] - self.margin[3]
			end
		end
		self.__realw = (self.width and parsePos( self.width, pw, ph, pw ) or 0)
		self.__realh = (self.height and parsePos( self.height, pw, ph, ph ) or 0)
		if self.ratio then
			if self.width and not self.height then
				self.__realh = self.__realw * self.ratio
			elseif self.height and not self.width then
				self.__realw = self.__realh / self.ratio
			end
		end
		return self.__realw - self.padding[4] - self.padding[2], self.__realh - self.padding[1] - self.padding[3]
	end,

	InvalidateLayout = function( self, immediate )
		if immediate then
			local cw, ch = self:GetComputedSize()
			local pw, ph = self:GetParentSize()
			self:onlayout( self, pw, ph, self.__prevew or pw, self.__preveh or ph )
			local nw, nh = self:GetComputedSize()
			if nw ~= cw or nh ~= ch then
				self:InvalidateParentLayout( true )
			end
		else
			self.__validated = false
		end
	end,

	InvalidateParentLayout = function( self, immediate )
		local parent = self:GetParent()
		if parent then
			return parent:InvalidateLayout( immediate )
		else
			local pw, ph = UiWidth(), UiHeight()
			self:InvalidateLayout( immediate )
			self.__realx = self.x and parsePos( self.x, pw, ph, pw ) or 0
			self.__realy = self.y and parsePos( self.y, pw, ph, ph ) or 0
		end
	end,

	SetParent = function( self, parent )
		local prev = self:GetParent()
		if prev then
			for i = 1, #prev do
				if prev[i] == self then
					table.remove( prev, i )
					prev:InvalidateLayout()
					break
				end
			end
		end
		if parent then
			parent[#parent + 1] = self
			rawset( self, "__parent", parent )
			parent:InvalidateLayout()
		end
	end,

	GetParent = function( self )
		return rawget( self, "__parent" )
	end,

	GetComputedPos = function( self )
		return self.__realx, self.__realy
	end,

	GetComputedSize = function( self )
		return self.__realw, self.__realh
	end,

	SetSize = function( self, w, h )
		self.width, self.height = w, h
		self:InvalidateLayout()
	end,
	SetWidth = function( self, w )
		self.width = w
		self:InvalidateLayout()
	end,
	SetHeight = function( self, h )
		self.height = h
		self:InvalidateLayout()
	end,

	SetPos = function( self, x, y )
		self.x, self.y = x, y
		self:InvalidateLayout()
	end,
	SetX = function( self, x )
		self.x = x
		self:InvalidateLayout()
	end,
	SetY = function( self, y )
		self.y = y
		self:InvalidateLayout()
	end,

	SetMargin = function( self, top, right, bottom, left )
		if right then
			top = { top, right, bottom, left }
		end
		self.margin = parseFour( top )
		self:InvalidateLayout()
	end,

	SetPadding = function( self, top, right, bottom, left )
		if right then
			top = { top, right, bottom, left }
		end
		self.padding = parseFour( top )
		self:InvalidateLayout()
	end,

	GetParentSize = function( self )
		local parent = self:GetParent()
		if parent then
			return parent:GetComputedSize()
		else
			return UiWidth(), UiHeight()
		end
	end,

	Hide = function( self )
		self.visible = false
	end,
	Show = function( self )
		self.visible = true
	end,
}

TDUI.Layout = TDUI.Panel {
	onlayout = function( self, data, pw, ph, ew, eh )
		self.__validated = true
		self.__prevew, self.__preveh = ew, eh
		local nw, nh = self:ComputeSize( pw, ph )
		local p1, p2, p3, p4 = self.padding[1], self.padding[2], self.padding[3], self.padding[4]
		for i = 1, #self do
			local child = self[i]
			child:onlayout( child, nw, nh, ew, eh )
			child:ComputePosition( p4, p1, nw, nh )
		end
		return self.__realw + self.margin[4] + self.margin[2], self.__realh + self.margin[1] + self.margin[3]
	end,
}

TDUI.SimpleForEach = function( tab, callback )
	return function()
		local rt = {}
		for i = 1, #tab do
			local e = callback( tab[i], i, tab )
			if e then
				rt[#rt + 1] = e
			end
		end
		return rt
	end
end

TDUI.Panel.layout = TDUI.Layout

local ScreenPanel = TDUI.Panel { x = 0, y = 0, width = 0, height = 0 }

function TDUI.Panel:Popup( parent )
	self:SetParent( parent or ScreenPanel )
end

function TDUI.Panel:Close()
	self:SetParent()
end

hook.add( "base.draw", "api.tdui.ScreenPanel", function()
	if ScreenPanel.width == 0 then
		ScreenPanel:SetSize( UiWidth(), UiHeight() )
	end
	UiPush()
	softassert( pcall( ScreenPanel.__Draw, ScreenPanel ) )
	UiPop()
end )

 end)();
--src/tdui/image.lua
(function() 
TDUI.Image = TDUI.Panel {
	path = "",
	fit = "fit",

	ondraw = function( self, w, h )
		if not HasFile( self.path ) then
			return
		end
		local iw, ih = self:GetImageSize()
		UiPush()
		if self.fit == "stretch" then
			UiScale( w / iw, h / ih )
		elseif self.fit == "cover" then
			local r, ir = w / h, iw / ih
			UiWindow( w, h, true )
			if r > ir then
				UiTranslate( 0, h / 2 - ih * w / iw / 2 )
				UiScale( w / iw )
			else
				UiTranslate( w / 2 - iw * h / ih / 2, 0 )
				UiScale( h / ih )
			end
		elseif self.fit == "fit" then
			local r, ir = w / h, iw / ih
			if r > ir then
				UiTranslate( w / 2 - iw * h / ih / 2, 0 )
				UiScale( h / ih )
			else
				UiTranslate( 0, h / 2 - ih * w / iw / 2 )
				UiScale( w / iw )
			end
		end
		self:DrawImage( iw, ih )
		UiPop()
	end,

	GetImageSize = function( self )
		return UiGetImageSize( self.path )
	end,
	DrawImage = function( self, w, h )
		UiImage( self.path )
	end,
}

TDUI.AtlasImage = TDUI.Image {
	atlas_width = 1,
	atlas_height = 1,
	atlas_x = 1,
	atlas_y = 1,

	GetImageSize = function( self )
		local iw, ih = UiGetImageSize( self.path )
		return iw / self.atlas_width, ih / self.atlas_height
	end,
	DrawImage = function( self, w, h )
		UiWindow( w, h, true )
		UiTranslate( (1 - self.atlas_x) * w, (1 - self.atlas_y) * h )
		UiImage( self.path )
	end,
}

 end)();
--src/tdui/layout.lua
(function() 
TDUI.StackLayout = TDUI.Layout {
	orientation = "vertical",

	onlayout = function( self, data, pw, ph, ew, eh )
		self.__validated = true
		self.__prevew, self.__preveh = ew, eh
		local isvertical = data.orientation == "vertical"
		local nw, nh = self:ComputeSize( pw, ph )
		local pdw, pdh = self.padding[4] + self.padding[2], self.padding[1] + self.padding[3]
		local nfw, nfh = nw == -pdw, nh == -pdh
		if not nfw then
			ew = nw
		else
			ew = ew - pdw
		end
		if not nfh then
			eh = nh
		else
			eh = eh - pdh
		end
		if isvertical then
			if nfh then
				nh = 0
			end
		else
			if nfw then
				nw = 0
			end
		end
		for i = 1, #self do
			local child = self[i]
			local cw, ch = child:onlayout( child, nw, nh, ew, eh )
			if isvertical then
				if nfw and cw > nw and cw <= ew then
					nw = cw
				end
				if nfh then
					nh = nh + ch
				end
			else
				if nfw then
					nw = nw + cw
				end
				if nfh and ch > nh and ch <= eh then
					nh = ch
				end
			end
		end
		local dx, dy = self.padding[4], self.padding[1]
		for i = 1, #self do
			local child = self[i]
			local cw, ch = child:onlayout( child, nw, nh, ew, eh )
			child:ComputePosition( dx, dy, nw, nh )
			if isvertical then
				dy = dy + ch
			else
				dx = dx + cw
			end
		end
		if nfw then
			self.__realw = nw + pdw
		end
		if nfh then
			self.__realh = nh + pdh
		end
		return self.__realw + self.margin[4] + self.margin[2], self.__realh + self.margin[1] + self.margin[3]
	end,
}

TDUI.WrapLayout = TDUI.Layout {
	orientation = "vertical",

	onlayout = function( self, data, pw, ph, ew, eh )
		self.__validated = true
		self.__prevew, self.__preveh = ew, eh
		local isvertical = data.orientation == "vertical"
		local nw, nh = self:ComputeSize( pw, ph )
		local pdw, pdh = self.padding[4] + self.padding[2], self.padding[1] + self.padding[3]
		local nfw, nfh = nw == -pdw, nh == -pdh
		if not nfw then
			ew = nw
		else
			ew = ew - pdw
		end
		if not nfh then
			eh = nh
		else
			eh = eh - pdh
		end
		if isvertical then
			if nfh then
				nh = 0
			end
		else
			if nfw then
				nw = 0
			end
		end
		for i = 1, #self do
			local child = self[i]
			local cw, ch = child:onlayout( child, nw, nh, ew, eh )
			if isvertical then
				if nfw and cw > nw and cw <= ew then
					nw = cw
				end
				if nfh then
					nh = nh + ch
				end
			else
				if nfw then
					nw = nw + cw
				end
				if nfh and ch > nh and ch <= eh then
					nh = ch
				end
			end
		end
		local dx, dy = self.padding[4], self.padding[1]
		local curr = 0
		for i = 1, #self do
			local child = self[i]
			local cw, ch = child:onlayout( child, nw, nh, ew, eh )
			if isvertical then
				if nw + pdw < dx + cw then
					dx = self.padding[4]
					dy = dy + curr
					curr = 0
				end
				child:ComputePosition( dx, dy, nw, nh )
				curr = math.max( curr, ch )
				dx = dx + cw
			else
				if nh + pdh < dy + ch then
					dy = self.padding[1]
					dx = dx + curr
					curr = 0
				end
				child:ComputePosition( dx, dy, nw, nh )
				curr = math.max( curr, cw )
				dy = dy + ch
			end
		end
		if nfw then
			self.__realw = nw + pdw
		end
		if nfh then
			self.__realh = nh + pdh
		end
		return self.__realw + self.margin[4] + self.margin[2], self.__realh + self.margin[1] + self.margin[3]
	end,
}

 end)();
--src/tdui/panel.lua
(function() 
TDUI.SlicePanel = TDUI.Panel {
	color = { 1, 1, 1, 1 },

	predraw = function( self, w, h )
		UiPush()
		UiColor( self.color[1] or 1, self.color[2] or 1, self.color[3] or 1, self.color[4] or 1 )
		local t = self.template
		UiTranslate( -t.offset_left, -t.offset_top )
		UiImageBox( t.image, w + t.offset_left + t.offset_right, h + t.offset_top + t.offset_bottom, t.slice_x, t.slice_y )
		UiPop()
	end,
}

TDUI.SlicePanel.SolidShadow50 = {
	image = "ui/common/box-solid-shadow-50.png",
	slice_x = 50,
	slice_y = 50,
	offset_left = 40,
	offset_top = 40,
	offset_bottom = 41,
	offset_right = 40,
}

TDUI.SlicePanel.template = TDUI.SlicePanel.SolidShadow50

 end)();
--src/tdui/window.lua
(function() 
TDUI.Window = TDUI.Panel {
	color = { 1, 1, 1, 1 },

	predraw = function( self, w, h )
	end,

	TDUI.Panel { TDUI.Slot "title" },

	TDUI.Panel { TDUI.Slot },
}

 end)();
--src/_index.lua
(function() -- 
 end)();
for i = 1, #__RUNLATER do local f = loadstring(__RUNLATER[i]) if f then pcall(f) end end
