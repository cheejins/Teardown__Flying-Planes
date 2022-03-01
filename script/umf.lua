local __RUNLATER = {} UMF_RUNLATER = function(code) __RUNLATER[#__RUNLATER + 1] = code end

--src/core/hook.lua
(function() 

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
(function() 
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
	original[name] = _G[name]
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
(function() 
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
(function()

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
(function() 

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
		get_g = function( self, index )
			return GetString( self._list_name .. (index % max) )
		end,
		clear = function( self )
			SetInt( self._pos_name, 0 )
			ClearKey( self._list_name:sub( 1, -2 ) )
		end,
	}
end

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

	hook.add( "api.newmeta", "api.createunserializer", function( name, meta )
		gets[name] = function( key )
			return setmetatable( {}, meta ):__unserialize( GetString( key ) )
		end
		sets[name] = function( key, value )
			return SetString( key, meta.__serialize( value ) )
		end
	end )

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
					root[k] = util.structured_table( key, v )
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
						return gets[entry.type]( entry.key )
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
(function() 
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
(function() 

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
--src/util/meta.lua
(function() 

local registered_meta = {}
local reverse_meta = {}

--- Defines a new metatable type.
---
---@param name string
---@param parent? string
---@return table
function global_metatable( name, parent )
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
		hook.saferun( "api.newmeta", name, meta )
	end
	if parent then
		setmetatable( meta, global_metatable( parent ) )
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
 end)();
--src/util/timer.lua
(function() 

----------------------------------------
--              WARNING               --
--   Timers are reset on quickload!   --
-- Keep this in mind if you use them. --
----------------------------------------
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
(function() 
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
		local points = {}
		local iteration = 1
		local pow, sqrt, sin, cos = math.pow, math.sqrt, math.sin, math.cos
		local r, g, b, a
		local DrawFunction = DrawLine

		radius = sqrt( 2 * pow( radius, 2 ) ) or sqrt( 2 )
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
			points[iteration] = TransformToParentPoint( transform, Vec( sin( (v + rotation) * degreeToRadian ) * radius, 0,
			                                                            cos( (v + rotation) * degreeToRadian ) * radius ) )
			points[iteration + 1] = TransformToParentPoint( transform,
			                                                Vec( sin( ((v + 360 / sides) + rotation) * degreeToRadian ) * radius,
			                                                     0,
			                                                     cos( ((v + 360 / sides) + rotation) * degreeToRadian ) * radius ) )
			if iteration > 2 then
				DrawFunction( points[iteration], points[iteration + 1], r, g, b, a )
			end
			iteration = iteration + 2
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

end
 end)();
--src/util/xml.lua
(function() 
---@class XMLNode
---@field __call fun(children: XMLNode[]): XMLNode
---@field attributes table<string, string> | nil
---@field children XMLNode[] | nil
---@field type string
local xmlnode = {
	--- Renders this node into an XML string.
	---
	---@return string
	Render = function( self )
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
	end,
}

local meta = {
	__call = function( self, children )
		self.children = children
		return self
	end,
	__index = xmlnode,
}

--- Defines an XML node.
---
---@param type string
---@return fun(attributes: table<string, string>): XMLNode
XMLTag = function( type )
	return function( attributes )
		return setmetatable( { type = type, attributes = attributes }, meta )
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
 end)();
--src/vector/quat.lua
(function() 

---@type Vector
local vector_meta = global_metatable( "vector" )
---@class Quaternion
local quat_meta = global_metatable( "quaternion" )

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
	self[1] = self[1] / o
	self[2] = self[2] / o
	self[3] = self[3] / o
	self[4] = self[4] / o
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
(function() 

---@type Vector
local vector_meta = global_metatable( "vector" )
---@type Quaternion
local quat_meta = global_metatable( "quaternion" )
---@class Transformation
---@field pos Vector
---@field rot Quaternion
local transform_meta = global_metatable( "transformation" )

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
(function() 

---@class Vector
local vector_meta = global_metatable( "vector" )
---@type Quaternion
local quat_meta = global_metatable( "quaternion" )

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
 end)();
--src/entities/entity.lua
(function() 

---@class Entity
---@field handle number
---@field type string
local entity_meta = global_metatable( "entity" )

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
(function() 

---@class Body: Entity
local body_meta = global_metatable( "body", "entity" )

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
(function() 

---@class Joint: Entity
local joint_meta = global_metatable( "joint", "entity" )

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

---@return string
function joint_meta:__tostring()
	return string.format( "Joint[%d]", self.handle )
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
(function() 

---@class Light: Entity
local light_meta = global_metatable( "light", "entity" )

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
(function() 

---@class Location: Entity
local location_meta = global_metatable( "location", "entity" )

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
(function() 

---@class Player
local player_meta = global_metatable( "player" )

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
(function() 

---@class Screen: Entity
local screen_meta = global_metatable( "screen", "entity" )

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
(function() 

---@class Shape: Entity
local shape_meta = global_metatable( "shape", "entity" )

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
(function() 

---@class Trigger: Entity
local trigger_meta = global_metatable( "trigger", "entity" )

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
(function() 

---@class Vehicle: Entity
local vehicle_meta = global_metatable( "vehicle", "entity" )

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
(function() 

---@class Armature
---@field refs any
---@field root any
---@field scale number | nil
---@field dirty boolean
local armature_meta = global_metatable( "armature" )

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

--- Loads armature information from a prefab and a list of shapes.
---
---@param xml string
---@param parts table[]
---@param scale? number
function LoadArmatureFromXML( xml, parts, scale ) -- Example below
	scale = scale or 1
	local dt = ParseXML( xml )
	assert( dt.type == "prefab" and dt.children[1] and dt.children[1].type == "group" )
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
	local bones = translatebone( dt.children[1] )[1]
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
 end)();
--src/tool.lua
(function() 

---@class Tool
---@field _TRANSFORM Transformation
---@field _TRANSFORM_FIX Transformation
---@field _TRANSFORM_DIFF Transformation
---@field _ARMATURE Armature
---@field armature Armature
---@field _SHAPES Shape[]
---@field _OBJECTS table[]
---@field model string
---@field printname string
---@field id string
local tool_meta = global_metatable( "tool" )

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

---@type table<string, Tool>
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
	RegisterTool( id, data.printname or id, data.model or "" )
	SetBool( "game.tool." .. id .. ".enabled", true )
	return data
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
--src/_index.lua
(function() 
-- UMF_REQUIRE "tdui"
 end)();
for i = 1, #__RUNLATER do local f = loadstring(__RUNLATER[i]) if f then pcall(f) end end
