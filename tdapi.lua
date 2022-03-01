---No Description
---
--- ---
--- Example
---```lua
-----Retrieve blinkcount parameter, or set to 5 if omitted
---parameterBlinkCount = GetIntParam("blinkcount", 5)
---```
---@param name string
---@param default number
---@return number value
function GetIntParam(name, default) end

---No Description
---
--- ---
--- Example
---```lua
-----Retrieve speed parameter, or set to 10.0 if omitted
---parameterSpeed = GetFloatParam("speed", 10.0)
---```
---@param name string
---@param default number
---@return number value
function GetFloatParam(name, default) end

---No Description
---
--- ---
--- Example
---```lua
-----Retrieve playsound parameter, or false if omitted
---parameterPlaySound = GetBoolParam("playsound", false)
---```
---@param name string
---@param default boolean
---@return boolean value
function GetBoolParam(name, default) end

---No Description
---
--- ---
--- Example
---```lua
-----Retrieve mode parameter, or "idle" if omitted
---parameterMode = GetSrtingParam("mode", "idle")
---```
---@param name string
---@param default string
---@return string value
function GetStringParam(name, default) end

---No Description
---
--- ---
--- Example
---```lua
---local v = GetVersion()
-----v is "0.5.0"
---```
---@return string version
function GetVersion() end

---No Description
---
--- ---
--- Example
---```lua
---if HasVersion("0.6.0") then
---	--conditional code that only works on 0.6.0 or above
---else
---	--legacy code that works on earlier versions
---end
---```
---@param version string
---@return boolean match
function HasVersion(version) end

---Returns running time of this script. If called from update, this returns
---the simulated time, otherwise it returns wall time.
---
--- ---
--- Example
---```lua
---local t = GetTime()
---```
---@return number time
function GetTime() end

---Returns timestep of the last frame. If called from update, this returns
---the simulation time step, which is always one 60th of a second (0.0166667).
---If called from tick or draw it returns the actual time since last frame.
---
--- ---
--- Example
---```lua
---local dt = GetTimeStep()
---```
---@return number dt
function GetTimeStep() end

---No Description
---
--- ---
--- Example
---```lua
---name = InputLastPressedKey()
---```
---@return string name
function InputLastPressedKey() end

---No Description
---
--- ---
--- Example
---```lua
---if InputPressed("interact") then
---	...
---end
---```
---@param input string
---@return boolean pressed
function InputPressed(input) end

---No Description
---
--- ---
--- Example
---```lua
---if InputReleased("interact") then
---	...
---end
---```
---@param input string
---@return boolean pressed
function InputReleased(input) end

---No Description
---
--- ---
--- Example
---```lua
---if InputDown("interact") then
---...
---end
---```
---@param input string
---@return boolean pressed
function InputDown(input) end

---No Description
---
--- ---
--- Example
---```lua
---scrollPos = scrollPos + InputValue("mousewheel")
---```
---@param input string
---@return number value
function InputValue(input) end

---Set value of a number variable in the global context with an optional transition.
---If a transition is provided the value will animate from current value to the new value during the transition time.
---Transition can be one of the following:
---
---Transition  Description
---linear	 Linear transitioncosine	 Slow at beginning and endeasein	 Slow at beginningeaseout	 Slow at endbounce	 Bounce and overshoot new value
---
--- ---
--- Example
---```lua
---myValue = 0
---SetValue("myValue", 1, "linear", 0.5)
---
---This will change the value of myValue from 0 to 1 in a linear fasion over 0.5 seconds
---```
---@param variable string
---@param value number
---@param transition string
---@param time number
function SetValue(variable, value, transition, time) end

---Calling this function will add a button on the bottom bar when the game is paused. Use this
---as a way to bring up mod settings or other user interfaces while the game is running. 
---Call this function every frame from the tick function for as long as the pause menu button
---should still be visible.
---
--- ---
--- Example
---```lua
---function tick()
---	if PauseMenuButton("MyMod Settings") then
---		visible = true
---	end
---end
---
---function draw()
---	if visible then
---		UiMakeInteractive()
---		...
---	end
---end
---```
---@param title string
---@return boolean
function PauseMenuButton(title) end

---Start a level
---
--- ---
--- Example
---```lua
-----Start level with no active layers
---StartLevel("level1", "MOD/level1.xml")
---
-----Start level with two layers
---StartLevel("level1", "MOD/level1.xml", "vehicles targets")
---```
---@param mission string
---@param path string
---@param layers string
function StartLevel(mission, path, layers) end

---Set paused state of the game
---
--- ---
--- Example
---```lua
-----Pause game and bring up pause menu on HUD
---SetPaused(true)
---```
---@param paused boolean
function SetPaused(paused) end

---Restart level
---
--- ---
--- Example
---```lua
---if shouldRestart then
---Restart()
---end
---```
function Restart() end

---Go to main menu
---
--- ---
--- Example
---```lua
---if shouldExitLevel then
---Menu()
---end
---```
function Menu() end

---Remove registry node, including all child nodes.
---
--- ---
--- Example
---```lua
-----If the registry looks like this:
-----	score
-----		levels
-----			level1 = 5
-----			level2 = 4
---
---ClearKey("score.levels")
---
-----Afterwards, the registry will look like this:
-----	score
---```
---@param key string
function ClearKey(key) end

---List all child keys of a registry node.
---
--- ---
--- Example
---```lua
-----If the registry looks like this:
-----	score
-----		levels
-----			level1 = 5
-----			level2 = 4
---
---local list = ListKeys("score.levels")
---for i=1, #list do
---	print(list[i])
---end
---
-----This will output:
-----level1
-----level2
---```
---@param parent string
---@return table children
function ListKeys(parent) end

---Returns true if the registry contains a certain key
---
--- ---
--- Example
---```lua
---local foo = HasKey("score.levels")
---```
---@param key string
---@return boolean exists
function HasKey(key) end

---No Description
---
--- ---
--- Example
---```lua
---SetInt("score.levels.level1", 4)
---```
---@param key string
---@param value number
function SetInt(key, value) end

---No Description
---
--- ---
--- Example
---```lua
---local a = GetInt("score.levels.level1")
---```
---@param key string
---@return number value
function GetInt(key) end

---No Description
---
--- ---
--- Example
---```lua
---SetFloat("level.time", 22.3)
---```
---@param key string
---@param value number
function SetFloat(key, value) end

---No Description
---
--- ---
--- Example
---```lua
---local time = GetFloat("level.time")
---```
---@param key string
---@return number value
function GetFloat(key) end

---No Description
---
--- ---
--- Example
---```lua
---SetBool("level.robots.enabled", true)
---```
---@param key string
---@param value boolean
function SetBool(key, value) end

---No Description
---
--- ---
--- Example
---```lua
---local isRobotsEnabled = GetBool("level.robots.enabled")
---```
---@param key string
---@return boolean value
function GetBool(key) end

---No Description
---
--- ---
--- Example
---```lua
---SetString("level.name", "foo")
---```
---@param key string
---@param value string
function SetString(key, value) end

---No Description
---
--- ---
--- Example
---```lua
---local name = GetString("level.name")
---```
---@param key string
---@return string value
function GetString(key) end

---Create new vector and optionally initializes it to the provided values.
---A Vec is equivalent to a regular lua table with three numbers.
---
--- ---
--- Example
---```lua
-----These are equivalent
---local a1 = Vec()
---local a2 = {0, 0, 0}
---
-----These are equivalent
---local b1 = Vec(0, 1, 0)
---local b2 = {0, 1, 0}
---```
---@param x number
---@param y number
---@param z number
---@return table vec
function Vec(x, y, z) end

---Vectors should never be assigned like regular numbers. Since they are
---implemented with lua tables assignment means two references pointing to
---the same data. Use this function instead.
---
--- ---
--- Example
---```lua
-----Do this to assign a vector
---local right1 = Vec(1, 2, 3)
---local right2 = VecCopy(right1)
---
-----Never do this unless you REALLY know what you're doing
---local wrong1 = Vec(1, 2, 3)
---local wrong2 = wrong1
---```
---@param org table
---@return table new
function VecCopy(org) end

---No Description
---
--- ---
--- Example
---```lua
---local v = Vec(1,1,0)
---local l = VecLength(v)
---
-----l now equals 1.41421356
---```
---@param vec table
---@return number length
function VecLength(vec) end

---If the input vector is of zero length, the function returns {0,0,1}
---
--- ---
--- Example
---```lua
---local v = Vec(0,3,0)
---local n = VecNormalize(v)
---
-----n now equals {0,1,0}
---```
---@param vec table
---@return table norm
function VecNormalize(vec) end

---No Description
---
--- ---
--- Example
---```lua
---local v = Vec(1,2,3)
---local n = VecScale(v, 2)
---
-----n now equals {2,4,6}
---```
---@param vec table
---@param scale number
---@return table norm
function VecScale(vec, scale) end

---No Description
---
--- ---
--- Example
---```lua
---local a = Vec(1,2,3)
---local b = Vec(3,0,0)
---local c = VecAdd(a, b)
---
-----c now equals {4,2,3}
---```
---@param a table
---@param b table
---@return table c
function VecAdd(a, b) end

---No Description
---
--- ---
--- Example
---```lua
---local a = Vec(1,2,3)
---local b = Vec(3,0,0)
---local c = VecSub(a, b)
---
-----c now equals {-2,2,3}
---```
---@param a table
---@param b table
---@return table c
function VecSub(a, b) end

---No Description
---
--- ---
--- Example
---```lua
---local a = Vec(1,2,3)
---local b = Vec(3,1,0)
---local c = VecDot(a, b)
---
-----c now equals 5
---```
---@param a table
---@param b table
---@return number c
function VecDot(a, b) end

---No Description
---
--- ---
--- Example
---```lua
---local a = Vec(1,0,0)
---local b = Vec(0,1,0)
---local c = VecCross(a, b)
---
-----c now equals {0,0,1}
---```
---@param a table
---@param b table
---@return table c
function VecCross(a, b) end

---No Description
---
--- ---
--- Example
---```lua
---local a = Vec(2,0,0)
---local b = Vec(0,4,2)
---local t = 0.5
---
-----These two are equivalent
---local c1 = VecLerp(a, b, t)
---lcoal c2 = VecAdd(VecScale(a, 1-t), VecScale(b, t))
---
-----c1 and c2 now equals {1, 2, 1}
---```
---@param a table
---@param b table
---@param t number
---@return table c
function VecLerp(a, b, t) end

---Create new quaternion and optionally initializes it to the provided values.
---Do not attempt to initialize a quaternion with raw values unless you know
---what you are doing. Use QuatEuler or QuatAxisAngle instead.
---If no arguments are given, a unit quaternion will be created: {0, 0, 0, 1}.
---A quaternion is equivalent to a regular lua table with four numbers.
---
--- ---
--- Example
---```lua
-----These are equivalent
---local a1 = Quat()
---local a2 = {0, 0, 0, 1}
---```
---@param x number
---@param y number
---@param z number
---@param w number
---@return table quat
function Quat(x, y, z, w) end

---Quaternions should never be assigned like regular numbers. Since they are
---implemented with lua tables assignment means two references pointing to
---the same data. Use this function instead.
---
--- ---
--- Example
---```lua
-----Do this to assign a quaternion
---local right1 = QuatEuler(0, 90, 0)
---local right2 = QuatCopy(right1)
---
-----Never do this unless you REALLY know what you're doing
---local wrong1 = QuatEuler(0, 90, 0)
---local wrong2 = wrong1
---```
---@param org table
---@return table new
function QuatCopy(org) end

---Create a quaternion representing a rotation around a specific axis
---
--- ---
--- Example
---```lua
-----Create quaternion representing rotation 30 degrees around Y axis
---local q = QuatAxisAngle(Vec(0,1,0), 30)
---```
---@param axis table
---@param angle number
---@return table quat
function QuatAxisAngle(axis, angle) end

---Create quaternion using euler angle notation. The order of applied rotations uses the
---"NASA standard aeroplane" model:
---Rotation around Y axis (yaw or heading)
---Rotation around Z axis (pitch or attitude)
---Rotation around X axis (roll or bank)
---
--- ---
--- Example
---```lua
-----Create quaternion representing rotation 30 degrees around Y axis and 25 degrees around Z axis
---local q = QuatEuler(0, 30, 25)
---```
---@param x number
---@param y number
---@param z number
---@return table quat
function QuatEuler(x, y, z) end

---Return euler angles from quaternion. The order of rotations uses the "NASA standard aeroplane" model:
---Rotation around Y axis (yaw or heading)
---Rotation around Z axis (pitch or attitude)
---Rotation around X axis (roll or bank)
---
--- ---
--- Example
---```lua
-----Return euler angles from quaternion q
---rx, ry, rz = GetQuatEuler(q)
---```
---@param quat table
---@return number x
---@return number y
---@return number z
function GetQuatEuler(quat) end

---Create a quaternion pointing the negative Z axis (forward) towards
---a specific point, keeping the Y axis upwards. This is very useful
---for creating camera transforms.
---
--- ---
--- Example
---```lua
---local eye = Vec(0, 10, 0)
---local target = Vec(0, 1, 5)
---local rot = QuatLookAt(eye, target)
---SetCameraTransform(Transform(eye, rot))
---```
---@param eye table
---@param target table
---@return table quat
function QuatLookAt(eye, target) end

---Spherical, linear interpolation between a and b, using t. This is
---very useful for animating between two rotations.
---
--- ---
--- Example
---```lua
---local a = QuatEuler(0, 10, 0)
---local b = QuatEuler(0, 0, 45)
---
-----Create quaternion half way between a and b
---local q = QuatSlerp(a, b, 0.5)
---```
---@param a table
---@param b table
---@param t number
---@return table c
function QuatSlerp(a, b, t) end

---Rotate one quaternion with another quaternion. This is mathematically
---equivalent to c = a * b using quaternion multiplication.
---
--- ---
--- Example
---```lua
---local a = QuatEuler(0, 10, 0)
---local b = QuatEuler(0, 0, 45)
---local q = QuatRotateQuat(a, b)
---
-----q now represents a rotation first 10 degrees around
-----the Y axis and then 45 degrees around the Z axis.
---```
---@param a table
---@param b table
---@return table c
function QuatRotateQuat(a, b) end

---A transform is a regular lua table with two entries: pos and rot,
---a vector and quaternion representing transform position and rotation.
---
--- ---
--- Example
---```lua
-----Create transform located at {0, 0, 0} with no rotation
---local t1 = Transform()
---
-----Create transform located at {10, 0, 0} with no rotation
---local t2 = Transform(Vec(10, 0,0))
---
-----Create transform located at {10, 0, 0}, rotated 45 degrees around Y axis
---local t2 = Transform(Vec(10, 0,0), QuatEuler(0, 45, 0))
---```
---@param pos table
---@param rot table
---@return table transform
function Transform(pos, rot) end

---Transforms should never be assigned like regular numbers. Since they are
---implemented with lua tables assignment means two references pointing to
---the same data. Use this function instead.
---
--- ---
--- Example
---```lua
-----Do this to assign a quaternion
---local right1 = Transform(Vec(1,0,0), QuatEuler(0, 90, 0))
---local right2 = TransformCopy(right1)
---
-----Never do this unless you REALLY know what you're doing
---local wrong1 = Transform(Vec(1,0,0), QuatEuler(0, 90, 0))
---local wrong2 = wrong1
---```
---@param org table
---@return table new
function TransformCopy(org) end

---Transform child transform out of the parent transform.
---This is the opposite of TransformToLocalTransform.
---
--- ---
--- Example
---```lua
---local b = GetBodyTransform(body)
---local s = GetShapeLocalTransform(shape)
---
-----b represents the location of body in world space
-----s represents the location of shape in body space
---
---local w = TransformToParentTransform(b, s)
---
-----w now represents the location of shape in world space
---```
---@param parent table
---@param child table
---@return table transform
function TransformToParentTransform(parent, child) end

---Transform one transform into the local space of another transform.
---This is the opposite of TransformToParentTransform.
---
--- ---
--- Example
---```lua
---local b = GetBodyTransform(body)
---local w = GetShapeWorldTransform(shape)
---
-----b represents the location of body in world space
-----w represents the location of shape in world space
---
---local s = TransformToLocalTransform(b, w)
---
-----s now represents the location of shape in body space.
---```
---@param parent table
---@param child table
---@return table transform
function TransformToLocalTransform(parent, child) end

---Transfom vector v out of transform t only considering rotation.
---
--- ---
--- Example
---```lua
---local t = GetBodyTransform(body)
---local localUp = Vec(0, 1, 0)
---local up = TransformToParentVec(t, localUp)
---
-----up now represents the local body up direction in world space
---```
---@param t table
---@param v table
---@return table r
function TransformToParentVec(t, v) end

---Transfom vector v into transform t only considering rotation.
---
--- ---
--- Example
---```lua
---local t = GetBodyTransform(body)
---local worldUp = Vec(0, 1, 0)
---local up = TransformToLocalVec(t, worldUp)
---
-----up now represents the world up direction in local body space
---```
---@param t table
---@param v table
---@return table r
function TransformToLocalVec(t, v) end

---Transfom position p out of transform t.
---
--- ---
--- Example
---```lua
---local t = GetBodyTransform(body)
---local bodyPoint = Vec(0, 0, -1)
---local p = TransformToParentPoint(t, bodyPoint)
---
-----p now represents the local body point {0, 0, -1 } in world space
---```
---@param t table
---@param p table
---@return table r
function TransformToParentPoint(t, p) end

---Transfom position p into transform t.
---
--- ---
--- Example
---```lua
---local t = GetBodyTransform(body)
---local worldOrigo = Vec(0, 0, 0)
---local p = TransformToLocalPoint(t, worldOrigo)
---
-----p now represents the position of world origo in local body space
---```
---@param t table
---@param p table
---@return table r
function TransformToLocalPoint(t, p) end

---No Description
---
--- ---
--- Example
---```lua
-----Add "special" tag to an entity
---SetTag(handle, "special")
---
-----Add "team" tag to an entity and give it value "red"
---SetTag(handle, "team", "red")
---```
---@param handle number
---@param tag string
---@param value string
function SetTag(handle, tag, value) end

---Remove tag from an entity. If the tag had a value it is removed too.
---
--- ---
--- Example
---```lua
---RemoveTag(handle, "special")
---```
---@param handle number
---@param tag string
function RemoveTag(handle, tag) end

---No Description
---
--- ---
--- Example
---```lua
---SetTag(handle, "special")
---local hasSpecial = HasTag(handle, "special") 
----- hasSpecial will be true
---```
---@param handle number
---@param tag string
---@return boolean exists
function HasTag(handle, tag) end

---No Description
---
--- ---
--- Example
---```lua
---SetTag(handle, "special")
---value = GetTagValue(handle, "special")
----- value will be ""
---
---SetTag(handle, "special", "foo")
---value = GetTagValue(handle, "special")
----- value will be "foo"
---```
---@param handle number
---@param tag string
---@return string value
function GetTagValue(handle, tag) end

---All entities can have an associated description. For bodies and
---shapes this can be provided through the editor. This function 
---retrieves that description.
---
--- ---
--- Example
---```lua
---local desc = GetDescription(body)
---```
---@param handle number
---@return string description
function GetDescription(handle) end

---All entities can have an associated description. The description for 
---bodies and shapes will show up on the HUD when looking at them.
---
--- ---
--- Example
---```lua
---SetDescription(body, "Target object")
---```
---@param handle number
---@param description string
function SetDescription(handle, description) end

---Remove an entity from the scene. All entities owned by this entity
---will also be removed.
---
--- ---
--- Example
---```lua
---Delete(body)
-----All shapes associated with body will also be removed
---```
---@param handle number
function Delete(handle) end

---No Description
---
--- ---
--- Example
---```lua
---valid = IsHandleValid(body)
---
-----valid is true if body still exists
---
---Delete(body)
---valid = IsHandleValid(body)
---
-----valid will now be false
---```
---@param handle number
---@return boolean exists
function IsHandleValid(handle) end

---No Description
---
--- ---
--- Example
---```lua
-----Search for a body tagged "target" in script scope
---local target = FindBody("target")
---
-----Search for a body tagged "escape" in entire scene
---local escape = FindBody("escape", true)
---```
---@param tag string
---@param global boolean
---@return number handle
function FindBody(tag, global) end

---No Description
---
--- ---
--- Example
---```lua
-----Search for bodies tagged "target" in script scope
---local targets = FindBodies("target")
---for i=1, #targets do
---	local target = targets[i]
---	...
---end
---```
---@param tag string
---@param global boolean
---@return table list
function FindBodies(tag, global) end

---No Description
---
--- ---
--- Example
---```lua
---local t = GetBodyTransform(body)
---```
---@param handle number
---@return table transform
function GetBodyTransform(handle) end

---No Description
---
--- ---
--- Example
---```lua
-----Move a body 1 meter upwards
---local t = GetBodyTransform(body)
---t.pos = VecAdd(t.pos, Vec(0, 1, 0))
---SetBodyTransform(body, t)
---```
---@param handle number
---@param transform table
function SetBodyTransform(handle, transform) end

---No Description
---
--- ---
--- Example
---```lua
---local mass = GetBodyMass(body)
---```
---@param handle number
---@return number mass
function GetBodyMass(handle) end

---Check if body is dynamic. Note that something that was created static 
---may become dynamic due to destruction.
---
--- ---
--- Example
---```lua
---local dynamic = IsBodyDynamic(body)
---```
---@param handle number
---@return boolean dynamic
function IsBodyDynamic(handle) end

---Change the dynamic state of a body. There is very limited use for this
---function. In most situations you should leave it up to the engine to decide.
---Use with caution.
---
--- ---
--- Example
---```lua
---SetBodyDynamic(body, false)
---```
---@param handle number
---@param dynamic boolean
function SetBodyDynamic(handle, dynamic) end

---This can be used for animating bodies with preserved physical interaction,
---but in most cases you are better off with a motorized joint instead.
---
--- ---
--- Example
---```lua
---local vel = Vec(2,0,0)
---SetBodyVelocity(body, vel)
---```
---@param handle number
---@param velocity table
function SetBodyVelocity(handle, velocity) end

---No Description
---
--- ---
--- Example
---```lua
---local linVel = GetBodyVelocity(body)
---```
---@param handle number
---@return table velocity
function GetBodyVelocity(handle) end

---Return the velocity on a body taking both linear and angular velocity into account.
---
--- ---
--- Example
---```lua
---local vel = GetBodyVelocityAtPos(body, pos)
---```
---@param handle number
---@param pos table
---@return table velocity
function GetBodyVelocityAtPos(handle, pos) end

---This can be used for animating bodies with preserved physical interaction,
---but in most cases you are better off with a motorized joint instead.
---
--- ---
--- Example
---```lua
---local angVel = Vec(2,0,0)
---SetBodyAngularVelocity(body, angVel)
---```
---@param handle number
---@param angVel table
function SetBodyAngularVelocity(handle, angVel) end

---No Description
---
--- ---
--- Example
---```lua
---local angVel = GetBodyAngularVelocity(body)
---```
---@param handle number
---@return table angVel
function GetBodyAngularVelocity(handle) end

---Check if body is body is currently simulated. For performance reasons,
---bodies that don't move are taken out of the simulation. This function
---can be used to query the active state of a specific body. Only dynamic
---bodies can be active.
---
--- ---
--- Example
---```lua
---if IsBodyActive(body) then
---	...
---end
---```
---@param handle number
---@return boolean active
function IsBodyActive(handle) end

---Apply impulse to dynamic body at position (give body a push).
---
--- ---
--- Example
---```lua
---local pos = Vec(0,1,0)
---local imp = Vec(0,0,10)
---ApplyBodyImpulse(body, pos, imp)
---```
---@param handle number
---@param position table
---@param impulse table
function ApplyBodyImpulse(handle, position, impulse) end

---Return handles to all shapes owned by a body
---
--- ---
--- Example
---```lua
---local shapes = GetBodyShapes(body)
---for i=1,#shapes do
---	local shape = shapes[i]
---end
---```
---@param handle number
---@return table list
function GetBodyShapes(handle) end

---No Description
---
--- ---
--- Example
---```lua
---local vehicle = GetBodyVehicle(body)
---```
---@param body number
---@return number handle
function GetBodyVehicle(body) end

---Return the world space, axis-aligned bounding box for a body.
---
--- ---
--- Example
---```lua
---local min, max = GetBodyBounds(body)
---local boundsSize = VecSub(max, min)
---local center = VecLerp(min, max, 0.5)
---```
---@param handle number
---@return table min
---@return table max
function GetBodyBounds(handle) end

---No Description
---
--- ---
--- Example
---```lua
-----Visualize center of mass on for body
---local com = GetBodyCenterOfMass(body)
---local worldPoint = TransformToParentPoint(GetBodyTransform(body), com)
---DebugCross(worldPoint)
---```
---@param handle number
---@return table point
function GetBodyCenterOfMass(handle) end

---This will check if a body is currently visible in the camera frustum and
---not occluded by other objects.
---
--- ---
--- Example
---```lua
---if IsBodyVisible(body, 25) then
---	--Body is within 25 meters visible to the camera
---end
---```
---@param handle number
---@param maxDist number
---@param rejectTransparent boolean
---@return boolean visible
function IsBodyVisible(handle, maxDist, rejectTransparent) end

---Determine if any shape of a body has been broken.
---
--- ---
--- Example
---```lua
---local broken = IsBodyBroken(body)
---```
---@param handle number
---@return boolean broken
function IsBodyBroken(handle) end

---Determine if a body is in any way connected to a static object, either by being static itself or
---be being directly or indirectly jointed to something static.
---
--- ---
--- Example
---```lua
---local connectedToStatic = IsBodyJointedToStatic(body)
---```
---@param handle number
---@return boolean result
function IsBodyJointedToStatic(handle) end

---Render next frame with an outline around specified body.
---If no color is given, a white outline will be drawn.
---
--- ---
--- Example
---```lua
-----Draw white outline at 50% transparency
---DrawBodyOutline(body, 0.5)
---
-----Draw green outline, fully opaque
---DrawBodyOutline(body, 0, 1, 0, 1)
---```
---@param handle number
---@param r number
---@param g number
---@param b number
---@param a number
function DrawBodyOutline(handle, r, g, b, a) end

---Flash the appearance of a body when rendering this frame. This is
---used for valuables in the game.
---
--- ---
--- Example
---```lua
---DrawBodyHighlight(body, 0.5)
---```
---@param handle number
---@param amount number
function DrawBodyHighlight(handle, amount) end

---No Description
---
--- ---
--- Example
---```lua
-----Search for a shape tagged "mybox" in script scope
---local target = FindShape("mybox")
---
-----Search for a shape tagged "laserturret" in entire scene
---local escape = FindShape("laserturret", true)
---```
---@param tag string
---@param global boolean
---@return number handle
function FindShape(tag, global) end

---No Description
---
--- ---
--- Example
---```lua
-----Search for shapes tagged "alarmbox" in script scope
---local shapes = FindShapes("alarmbox")
---for i=1, #shapes do
---	local shape = shapes[i]
---	...
---end
---```
---@param tag string
---@param global boolean
---@return table list
function FindShapes(tag, global) end

---No Description
---
--- ---
--- Example
---```lua
-----Shape transform in body local space
---local shapeTransform = GetShapeLocalTransform(shape)
---
-----Body transform in world space
---local bodyTransform = GetBodyTransform(GetShapeBody(shape))
---
-----Shape transform in world space
---local worldTranform = TransformToParentTransform(bodyTransform, shapeTransform)
---```
---@param handle number
---@return table transform
function GetShapeLocalTransform(handle) end

---No Description
---
--- ---
--- Example
---```lua
---local transform = Transform(Vec(0, 1, 0), QuatEuler(0, 90, 0))
---SetShapeLocalTransform(shape, transform)
---```
---@param handle number
---@param transform table
function SetShapeLocalTransform(handle, transform) end

---This is a convenience function, transforming the shape out of body space
---
--- ---
--- Example
---```lua
---local worldTransform = GetShapeWorldTransform(shape)
---
-----This is equivalent to
---local shapeTransform = GetShapeLocalTransform(shape)
---local bodyTransform = GetBodyTransform(GetShapeBody(shape))
---worldTranform = TransformToParentTransform(bodyTransform, shapeTransform)
---```
---@param handle number
---@return table transform
function GetShapeWorldTransform(handle) end

---Get handle to the body this shape is owned by. A shape is always owned by a body,
---but can be transfered to a new body during destruction.
---
--- ---
--- Example
---```lua
---local body = GetShapeBody(shape)
---```
---@param handle number
---@return number handle
function GetShapeBody(handle) end

---No Description
---
--- ---
--- Example
---```lua
---local hinges = GetShapeJoints(door)
---for i=1, #hinges do
---	local joint = hinges[i]
---	...
---end
---```
---@param shape number
---@return table list
function GetShapeJoints(shape) end

---No Description
---
--- ---
--- Example
---```lua
---local lights = GetShapeLights(shape)
---for i=1, #lights do
---	local light = lights[i]
---	...
---end
---```
---@param shape number
---@return table list
function GetShapeLights(shape) end

---Return the world space, axis-aligned bounding box for a shape.
---
--- ---
--- Example
---```lua
---local min, max = GetShapeBounds(shape)
---local boundsSize = VecSub(max, min)
---local center = VecLerp(min, max, 0.5)
---```
---@param handle number
---@return table min
---@return table max
function GetShapeBounds(handle) end

---Scale emissiveness for shape. If the shape has light sources attached,
---their intensity will be scaled by the same amount.
---
--- ---
--- Example
---```lua
-----Pulsate emissiveness and light intensity for shape
---local scale = math.sin(GetTime())*0.5 + 0.5
---SetShapeEmissiveScale(shape, scale)
---```
---@param handle number
---@param scale number
function SetShapeEmissiveScale(handle, scale) end

---Return material properties for a particular voxel
---
--- ---
--- Example
---```lua
---local hit, dist, normal, shape = QueryRaycast(pos, dir, 10)
---if hit then
---	local hitPoint = VecAdd(pos, VecScale(dir, dist))
---	local mat = GetShapeMaterialAtPosition(shape, hitPoint)
---	DebugPrint("Raycast hit voxel made out of " .. mat)
---end
---```
---@param handle number
---@param pos table
---@return string type
---@return number r
---@return number g
---@return number b
---@return number a
function GetShapeMaterialAtPosition(handle, pos) end

---Return material properties for a particular voxel in the voxel grid indexed by integer values.
---The first index is zero (not one, as opposed to a lot of lua related things)
---
--- ---
--- Example
---```lua
---local mat = GetShapeMaterialAtIndex(shape, 0, 0, 0)
---DebugPrint("The voxel closest to origo is of material: " .. mat)
---```
---@param handle number
---@param x number
---@param y number
---@param z number
---@return string type
---@return number r
---@return number g
---@return number b
---@return number a
function GetShapeMaterialAtIndex(handle, x, y, z) end

---This will return the closest point of a specific shape
---
--- ---
--- Example
---```lua
---local hit, p, n = GetShapeClosestPoint(s, Vec(0, 5, 0))
---if hit then
-----Point p of shape s is closest to (0,5,0)
---end
---```
---@param shape number
---@param origin table
---@param maxDist number
---@return boolean hit
---@return table point
---@return table normal
function GetShapeClosestPoint(shape, origin, maxDist) end

---Return the size of a shape in voxels
---
--- ---
--- Example
---```lua
---local x, y, z = GetShapeSize(shape)
---```
---@param handle number
---@return number xsize
---@return number ysize
---@return number zsize
---@return number scale
function GetShapeSize(handle) end

---Return the number of voxels in a shape, not including empty space
---
--- ---
--- Example
---```lua
---local voxelCount = GetShapeVoxelCount(shape)
---```
---@param handle number
---@return number count
function GetShapeVoxelCount(handle) end

---This will check if a shape is currently visible in the camera frustum and
---not occluded by other objects.
---
--- ---
--- Example
---```lua
---if IsShapeVisible(shape, 25) then
---	--Shape is within 25 meters visible to the camera
---end
---```
---@param handle number
---@param maxDist number
---@param rejectTransparent boolean
---@return boolean visible
function IsShapeVisible(handle, maxDist, rejectTransparent) end

---Determine if shape has been broken. Note that a shape can be transfered
---to another body during destruction, but might still not be considered
---broken if all voxels are intact.
---
--- ---
--- Example
---```lua
---local broken = IsShapeBroken(shape)
---```
---@param handle number
---@return boolean broken
function IsShapeBroken(handle) end

---Render next frame with an outline around specified shape.
---If no color is given, a white outline will be drawn.
---
--- ---
--- Example
---```lua
-----Draw white outline at 50% transparency
---DrawShapeOutline(shape, 0.5)
---
-----Draw green outline, fully opaque
---DrawShapeOutline(shape, 0, 1, 0, 1)
---```
---@param handle number
---@param r number
---@param g number
---@param b number
---@param a number
function DrawShapeOutline(handle, r, g, b, a) end

---Flash the appearance of a shape when rendering this frame.
---
--- ---
--- Example
---```lua
---DrawShapeHighlight(shape, 0.5)
---```
---@param handle number
---@param amount number
function DrawShapeHighlight(handle, amount) end

---No Description
---
--- ---
--- Example
---```lua
---local loc = FindLocation("start")
---```
---@param tag string
---@param global boolean
---@return number handle
function FindLocation(tag, global) end

---No Description
---
--- ---
--- Example
---```lua
-----Search for locations tagged "waypoint" in script scope
---local locations = FindLocations("waypoint")
---for i=1, #locs do
---	local locs = locations[i]
---	...
---end
---```
---@param tag string
---@param global boolean
---@return table list
function FindLocations(tag, global) end

---No Description
---
--- ---
--- Example
---```lua
---local t = GetLocationTransform(loc)
---```
---@param handle number
---@return table transform
function GetLocationTransform(handle) end

---No Description
---
--- ---
--- Example
---```lua
---local joint = FindJoint("doorhinge")
---```
---@param tag string
---@param global boolean
---@return number handle
function FindJoint(tag, global) end

---No Description
---
--- ---
--- Example
---```lua
-----Search for locations tagged "doorhinge" in script scope
---local hinges = FindJoints("doorhinge")
---for i=1, #hinges do
---	local joint = hinges[i]
---	...
---end
---```
---@param tag string
---@param global boolean
---@return table list
function FindJoints(tag, global) end

---No Description
---
--- ---
--- Example
---```lua
---local broken = IsJointBroken(joint)
---```
---@param joint number
---@return boolean broken
function IsJointBroken(joint) end

---Joint type is one of the following: "ball", "hinge", "prismatic" or "rope".
---An empty string is returned if joint handle is invalid.
---
--- ---
--- Example
---```lua
---if GetJointType(joint) == "rope" then
---	--Joint is rope
---end
---```
---@param joint number
---@return string type
function GetJointType(joint) end

---A joint is always connected to two shapes. Use this function if you know 
---one shape and want to find the other one.
---
--- ---
--- Example
---```lua
-----joint is connected to a and b
---
---otherShape = GetJointOtherShape(joint, a)
-----otherShape is now b
---
---otherShape = GetJointOtherShape(joint, b)
-----otherShape is now a
---```
---@param joint number
---@param shape number
---@return number other
function GetJointOtherShape(joint, shape) end

---Set joint motor target velocity. If joint is of type hinge, velocity is
---given in radians per second angular velocity. If joint type is prismatic joint
---velocity is given in meters per second. Calling this function will override and
---void any previous call to SetJointMotorTarget.
---
--- ---
--- Example
---```lua
-----Set motor speed to 0.5 radians per second
---SetJointMotor(hinge, 0.5)
---```
---@param joint number
---@param velocity number
---@param strength number
function SetJointMotor(joint, velocity, strength) end

---If a joint has a motor target, it will try to maintain its relative movement. This
---is very useful for elevators or other animated, jointed mechanisms.
---If joint is of type hinge, target is an angle in degrees (-180 to 180) and velocity
---is given in radians per second. If joint type is prismatic, target is given
---in meters and velocity is given in meters per second. Setting a motor target will
---override any previous call to SetJointMotor.
---
--- ---
--- Example
---```lua
-----Make joint reach a 45 degree angle, going at a maximum of 3 radians per second
---SetJointMotorTarget(hinge, 45, 3)
---```
---@param joint number
---@param target number
---@param maxVel number
---@param strength number
function SetJointMotorTarget(joint, target, maxVel, strength) end

---Return joint limits for hinge or prismatic joint. Returns angle or distance
---depending on joint type.
---
--- ---
--- Example
---```lua
---local min, max = GetJointLimits(hinge)
---```
---@param joint number
---@return number min
---@return number max
function GetJointLimits(joint) end

---Return the current position or angle or the joint, measured in same way
---as joint limits.
---
--- ---
--- Example
---```lua
---local current = GetJointMovement(hinge)
---```
---@param joint number
---@return number movement
function GetJointMovement(joint) end

---No Description
---
--- ---
--- Example
---```lua
---local light = FindLight("main")
---```
---@param tag string
---@param global boolean
---@return number handle
function FindLight(tag, global) end

---No Description
---
--- ---
--- Example
---```lua
-----Search for lights tagged "main" in script scope
---local lights = FindLights("main")
---for i=1, #lights do
---	local light = lights[i]
---	...
---end
---```
---@param tag string
---@param global boolean
---@return table list
function FindLights(tag, global) end

---If light is owned by a shape, the emissive scale of that shape will be set
---to 0.0 when light is disabled and 1.0 when light is enabled.
---
--- ---
--- Example
---```lua
---SetLightEnabled(light, false)
---```
---@param handle number
---@param enabled boolean
function SetLightEnabled(handle, enabled) end

---This will only set the color tint of the light. Use SetLightIntensity for brightness.
---Setting the light color will not affect the emissive color of a parent shape.
---
--- ---
--- Example
---```lua
-----Set light color to yellow
---SetLightColor(light, 1, 1, 0)
---```
---@param handle number
---@param r number
---@param g number
---@param b number
function SetLightColor(handle, r, g, b) end

---If the shape is owned by a shape you most likely want to use
---SetShapeEmissiveScale instead, which will affect both the emissiveness 
---of the shape and the brightness of the light at the same time.
---
--- ---
--- Example
---```lua
-----Pulsate light
---SetLightIntensity(light, math.sin(GetTime())*0.5 + 1.0)
---```
---@param handle number
---@param intensity number
function SetLightIntensity(handle, intensity) end

---Lights that are owned by a dynamic shape are automatcially moved with that shape
---
--- ---
--- Example
---```lua
---local pos = GetLightTransform(light).pos
---```
---@param handle number
---@return table transform
function GetLightTransform(handle) end

---No Description
---
--- ---
--- Example
---```lua
---local shape = GetLightShape(light)
---```
---@param handle number
---@return number handle
function GetLightShape(handle) end

---No Description
---
--- ---
--- Example
---```lua
---if IsLightActive(light) then
---	--Do something
---end
---```
---@param handle number
---@return boolean active
function IsLightActive(handle) end

---No Description
---
--- ---
--- Example
---```lua
---local point = Vec(0, 10, 0)
---local affected = IsPointAffectedByLight(light, point)
---```
---@param handle number
---@param point table
---@return boolean affected
function IsPointAffectedByLight(handle, point) end

---No Description
---
--- ---
--- Example
---```lua
---local goal = FindTrigger("goal")
---```
---@param tag string
---@param global boolean
---@return number handle
function FindTrigger(tag, global) end

---No Description
---
--- ---
--- Example
---```lua
-----Find triggers tagged "toxic" in script scope
---local triggers = FindTriggers("toxic")
---for i=1, #triggers do
---	local trigger = triggers[i]
---	...
---end
---```
---@param tag string
---@param global boolean
---@return table list
function FindTriggers(tag, global) end

---No Description
---
--- ---
--- Example
---```lua
---local t = GetTriggerTransform(trigger)
---```
---@param handle number
---@return table transform
function GetTriggerTransform(handle) end

---No Description
---
--- ---
--- Example
---```lua
---local t = Transform(Vec(0, 1, 0), QuatEuler(0, 90, 0))
---SetTriggerTransform(trigger, t)
---```
---@param handle number
---@param transform table
function SetTriggerTransform(handle, transform) end

---Return the lower and upper points in world space of the trigger axis aligned bounding box
---
--- ---
--- Example
---```lua
---local mi, ma = GetTriggerBounds(trigger)
---local list = QueryAabbShapes(mi, ma)
---```
---@param handle number
---@return table min
---@return table max
function GetTriggerBounds(handle) end

---This function will only check the center point of the body
---
--- ---
--- Example
---```lua
---if IsBodyInTrigger(trigger, body) then
---	...
---end
---```
---@param trigger number
---@param body number
function IsBodyInTrigger(trigger, body) end

---This function will only check origo of vehicle
---
--- ---
--- Example
---```lua
---if IsVehicleInTrigger(trigger, vehicle) then
---	...
---end
---```
---@param trigger number
---@param vehicle number
function IsVehicleInTrigger(trigger, vehicle) end

---This function will only check the center point of the shape
---
--- ---
--- Example
---```lua
---if IsShapeInTrigger(trigger, shape) then
---	...
---end
---```
---@param trigger number
---@param shape number
function IsShapeInTrigger(trigger, shape) end

---No Description
---
--- ---
--- Example
---```lua
---local p = Vec(0, 10, 0)
---if IsPointInTrigger(trigger, p) then
---	...
---end
---```
---@param trigger number
---@param point table
function IsPointInTrigger(trigger, point) end

---This function will check if trigger is empty. If trigger contains any part of a body
---it will return false and the highest point as second return value.
---
--- ---
--- Example
---```lua
---local empty, highPoint = IsTriggerEmpty(trigger)
---if not empty then
---	--highPoint[2] is the tallest point in trigger
---end
---```
---@param handle number
---@param demolision boolean
---@return boolean empty
---@return table maxpoint
function IsTriggerEmpty(handle, demolision) end

---No Description
---
--- ---
--- Example
---```lua
---local screen = FindTrigger("tv")
---```
---@param tag string
---@param global boolean
---@return number handle
function FindScreen(tag, global) end

---No Description
---
--- ---
--- Example
---```lua
-----Find screens tagged "tv" in script scope
---local screens = FindScreens("tv")
---for i=1, #screens do
---	local screen = screens[i]
---	...
---end
---```
---@param tag string
---@param global boolean
---@return table list
function FindScreens(tag, global) end

---Enable or disable screen
---
--- ---
--- Example
---```lua
---SetScreenEnabled(screen, true)
---```
---@param screen number
---@param enabled boolean
function SetScreenEnabled(screen, enabled) end

---No Description
---
--- ---
--- Example
---```lua
---local b = IsScreenEnabled(screen)
---```
---@param screen number
---@return boolean enabled
function IsScreenEnabled(screen) end

---Return handle to the parent shape of a screen
---
--- ---
--- Example
---```lua
---local shape = GetScreenShape(screen)
---```
---@param screen number
---@return number shape
function GetScreenShape(screen) end

---No Description
---
--- ---
--- Example
---```lua
---local vehicle = FindVehicle("mycar")
---```
---@param tag string
---@param global boolean
---@return number handle
function FindVehicle(tag, global) end

---No Description
---
--- ---
--- Example
---```lua
-----Find all vehicles in level tagged "boat"
---local boats = FindVehicles("boat")
---for i=1, #boats do
---	local boat = boats[i]
---	...
---end
---```
---@param tag string
---@param global boolean
---@return table list
function FindVehicles(tag, global) end

---No Description
---
--- ---
--- Example
---```lua
---local t = GetVehicleTransform(vehicle)
---```
---@param vehicle number
---@return table transform
function GetVehicleTransform(vehicle) end

---No Description
---
--- ---
--- Example
---```lua
---local body = GetVehicleBody(vehicle)
---if IsBodyBroken(body) then
-----Vehicle body is broken
---end
---```
---@param vehicle number
---@return number body
function GetVehicleBody(vehicle) end

---No Description
---
--- ---
--- Example
---```lua
---local health = GetVehicleHealth(vehicle)
---```
---@param vehicle number
---@return number health
function GetVehicleHealth(vehicle) end

---No Description
---
--- ---
--- Example
---```lua
---local driverPos = GetVehicleDriverPos(vehicle)
---local t = GetVehicleTransform(vehicle)
---local worldPos = TransformToParentPoint(t, driverPos)
---```
---@param vehicle number
---@return table pos
function GetVehicleDriverPos(vehicle) end

---This function applies input to vehicles, allowing for autonomous driving. The vehicle
---will be turned on automatically and turned off when no longer called. Call this from
---the tick function, not update.
---
--- ---
--- Example
---```lua
---function tick()
---	--Drive mycar forwards
---	local v = FindVehicle("mycar")
---	DriveVehicle(v, 1, 0, false)
---end
---```
---@param vehicle number
---@param drive number
---@param steering number
---@param handbrake boolean
function DriveVehicle(vehicle, drive, steering, handbrake) end

---Return center point of player. This function is deprecated. 
---Use GetPlayerTransform instead.
---
--- ---
--- Example
---```lua
---local p = GetPlayerPos()
---
-----This is equivalent to
---p = VecAdd(GetPlayerTransform().pos, Vec(0,1,0))
---```
---@return table position
function GetPlayerPos() end

---The player transform is located at the bottom of the player. The player transform
---considers heading (looking left and right). Forward is along negative Z axis.
---Player pitch (looking up and down) does not affect player transform unless includePitch
---is set to true. If you want the transform of the eye, use GetPlayerCameraTransform() instead.
---
--- ---
--- Example
---```lua
---local t = GetPlayerTransform()
---```
---@param includePitch boolean
---@return table transform
function GetPlayerTransform(includePitch) end

---Instantly teleport the player to desired transform. Unless includePitch is
---set to true, up/down look angle will be set to zero during this process.
---Player velocity will be reset to zero.
---
--- ---
--- Example
---```lua
---local t = Transform(Vec(10, 0, 0), QuatEuler(0, 90, 0))
---SetPlayerTransform(t)
---```
---@param transform table
---@param includePitch boolean
function SetPlayerTransform(transform, includePitch) end

---The player camera transform is usually the same as what you get from GetCameraTransform,
---but if you have set a camera transform manually with SetCameraTransform, you can retrieve
---the standard player camera transform with this function.
---
--- ---
--- Example
---```lua
---local t = GetPlayerCameraTransform()
---```
---@return table transform
function GetPlayerCameraTransform() end

---Call this function during init to alter the player spawn transform.
---
--- ---
--- Example
---```lua
---local t = Transform(Vec(10, 0, 0), QuatEuler(0, 90, 0))
---SetPlayerSpawnTransform(t)
---```
---@param transform table
function SetPlayerSpawnTransform(transform) end

---No Description
---
--- ---
--- Example
---```lua
---local vel = GetPlayerVelocity()
---```
---@return table velocity
function GetPlayerVelocity() end

---Drive specified vehicle.
---
--- ---
--- Example
---```lua
---local car = FindVehicle("mycar")
---SetPlayerVehicle(car)
---```
---@param vehicle number
function SetPlayerVehicle(vehicle) end

---No Description
---
--- ---
--- Example
---```lua
---SetPlayerVelocity(Vec(0, 5, 0))
---```
---@param velocity table
function SetPlayerVelocity(velocity) end

---No Description
---
--- ---
--- Example
---```lua
---local vehicle = GetPlayerVehicle()
---if vehicle ~= 0 then
---	...
---end
---```
---@return number handle
function GetPlayerVehicle() end

---No Description
---
--- ---
--- Example
---```lua
---local shape = GetPlayerGrabShape()
---if shape ~= 0 then
---	...
---end
---```
---@return number handle
function GetPlayerGrabShape() end

---No Description
---
--- ---
--- Example
---```lua
---local body = GetPlayerGrabBody()
---if body ~= 0 then
---	...
---end
---```
---@return number handle
function GetPlayerGrabBody() end

---No Description
---
--- ---
--- Example
---```lua
---local shape = GetPlayerPickShape()
---if shape ~= 0 then
---	...
---end
---```
---@return number handle
function GetPlayerPickShape() end

---No Description
---
--- ---
--- Example
---```lua
---local body = GetPlayerPickBody()
---if body ~= 0 then
---	...
---end
---```
---@return number handle
function GetPlayerPickBody() end

---Interactable shapes has to be tagged with "interact". The engine
---determines which interactable shape is currently interactable.
---
--- ---
--- Example
---```lua
---local shape = GetPlayerInteractShape()
---if shape ~= 0 then
---	...
---end
---```
---@return number handle
function GetPlayerInteractShape() end

---Interactable shapes has to be tagged with "interact". The engine
---determines which interactable body is currently interactable.
---
--- ---
--- Example
---```lua
---local body = GetPlayerInteractBody()
---if body ~= 0 then
---	...
---end
---```
---@return number handle
function GetPlayerInteractBody() end

---Set the screen the player should interact with. For the screen
---to feature a mouse pointer and receieve input, the screen also
---needs to have interactive property.
---
--- ---
--- Example
---```lua
-----Interact with screen
---SetPlayerScreen(screen)
---
-----Do not interact with screen
---SetPlayerScreen(0)
---```
---@param handle number
function SetPlayerScreen(handle) end

---No Description
---
--- ---
--- Example
---```lua
-----Interact with screen
---local screen = GetPlayerScreen()
---```
---@return number handle
function GetPlayerScreen() end

---No Description
---
--- ---
--- Example
---```lua
---SetPlayerHealth(0.5)
---```
---@param health number
function SetPlayerHealth(health) end

---No Description
---
--- ---
--- Example
---```lua
---local health = GetPlayerHealth()
---```
---@return number health
function GetPlayerHealth() end

---Respawn player at spawn position without modifying the scene
---
--- ---
--- Example
---```lua
---RespawnPlayer()
---```
function RespawnPlayer() end

---Register a custom tool that will show up in the player inventory and 
---can be selected with scroll wheel. Do this only once per tool.
---You also need to enable the tool in the registry before it can be used.
---
--- ---
--- Example
---```lua
---function init()
---	RegisterTool("lasergun", "Laser Gun", "MOD/vox/lasergun.vox")
---	SetBool("game.tool.lasergun.enabled", true)
---end
---
---function tick()
---	if GetString("game.player.tool") == "lasergun" then
---		--Tool is selected. Tool logic goes here.
---	end
---end
---```
---@param id string
---@param name string
---@param file string
---@param group number
function RegisterTool(id, name, file, group) end

---Return body handle of the visible tool. You can use this to retrieve tool shapes
---and animate them, change emissiveness, etc. Do not attempt to set the tool body
---transform, since it is controlled by the engine. Use SetToolTranform for that.
---
--- ---
--- Example
---```lua
---local toolBody = GetToolBody()
---if toolBody~=0 then
---	...
---end
---```
---@return number handle
function GetToolBody() end

---Apply an additional transform on the visible tool body. This can be used to
---create tool animations. You need to set this every frame from the tick function.
---The optional sway parameter control the amount of tool swaying when walking.
---Set to zero to disable completely.
---
--- ---
--- Example
---```lua
-----Offset the tool half a meter to the right
---local offset = Transform(Vec(0.5, 0, 0))
---SetToolTransform(offset)
---```
---@param transform table
---@param sway number
function SetToolTransform(transform, sway) end

---No Description
---
--- ---
--- Example
---```lua
---local snd = LoadSound("beep.ogg")
---```
---@param path string
---@return number handle
function LoadSound(path) end

---No Description
---
--- ---
--- Example
---```lua
---local loop = LoadLoop("siren.ogg")
---```
---@param path string
---@return number handle
function LoadLoop(path) end

---No Description
---
--- ---
--- Example
---```lua
---function init()
---	snd = LoadSound("beep.ogg")
---end
---
---function tick()
---	if trigSound then
---		local pos = Vec(100, 0, 0)
---		PlaySound(snd, pos, 0.5)
---	end
---end
---```
---@param handle number
---@param pos table
---@param volume number
function PlaySound(handle, pos, volume) end

---Call this function continuously to play loop
---
--- ---
--- Example
---```lua
---function init()
---	loop = LoadLoop("siren.ogg")
---end
---
---function tick()
---	local pos = Vec(100, 0, 0)
---	PlayLoop(loop, pos, 0.5)
---end
---```
---@param handle number
---@param pos table
---@param volume number
function PlayLoop(handle, pos, volume) end

---No Description
---
--- ---
--- Example
---```lua
---PlayMusic("MOD/music/background.ogg")
---```
---@param path string
function PlayMusic(path) end

---No Description
---
--- ---
--- Example
---```lua
---StopMusic()
---```
function StopMusic() end

---No Description
---
--- ---
--- Example
---```lua
---function init()
---	arrow = LoadSprite("arrow.png")
---end
---```
---@param path string
---@return number handle
function LoadSprite(path) end

---Draw sprite in world at next frame. Call this function from the tick callback.
---
--- ---
--- Example
---```lua
---function init()
---	arrow = LoadSprite("arrow.png")
---end
---
---function tick()
---	--Draw sprite using transform
---	--Size is two meters in width and height
---	--Color is white, fully opaue
---	local t = Transform(Vec(0, 10, 0), QuatEuler(0, GetTime(), 0))
---	DrawSprite(arrow, t, 2, 2, 1, 1, 1, 1)
---end
---```
---@param handle number
---@param transform table
---@param width number
---@param height number
---@param r number
---@param g number
---@param b number
---@param a number
---@param depthTest boolean
---@param additive boolean
function DrawSprite(handle, transform, width, height, r, g, b, a, depthTest,
                    additive) end

---Set required layers for next query. Available layers are:
---
---Layer  Description
---physical	 have a physical representationdynamic		 part of a dynamic bodystatic		 part of a static bodylarge		 above debris thresholdsmall		 below debris threshold
---
--- ---
--- Example
---```lua
-----Raycast dynamic, physical objects above debris threshold, but not specific vehicle
---QueryRequire("physical dynamic large")
---QueryRejectVehicle(vehicle)
---QueryRaycast(...)
---```
---@param layers string
function QueryRequire(layers) end

---Exclude vehicle from the next query
---
--- ---
--- Example
---```lua
-----Do not include vehicle in next raycast
---QueryRejectVehicle(vehicle)
---QueryRaycast(...)
---```
---@param vehicle number
function QueryRejectVehicle(vehicle) end

---Exclude body from the next query
---
--- ---
--- Example
---```lua
-----Do not include body in next raycast
---QueryRejectBody(body)
---QueryRaycast(...)
---```
---@param body number
function QueryRejectBody(body) end

---Exclude shape from the next query
---
--- ---
--- Example
---```lua
-----Do not include shape in next raycast
---QueryRejectShape(shape)
---QueryRaycast(...)
---```
---@param shape number
function QueryRejectShape(shape) end

---This will perform a raycast or spherecast (if radius is more than zero) query.
---If you want to set up a filter for the query you need to do so before every call
---to this function.
---
--- ---
--- Example
---```lua
-----Raycast from a high point straight downwards, excluding a specific vehicle
---QueryRejectVehicle(vehicle)
---local hit, d = QueryRaycast(Vec(0, 100, 0), Vec(0, -1, 0), 100)
---if hit then
---	...hit something at distance d
---end
---```
---@param origin table
---@param direction table
---@param maxDist number
---@param radius number
---@param rejectTransparent boolean
---@return boolean hit
---@return number dist
---@return table normal
---@return number shape
function QueryRaycast(origin, direction, maxDist, radius, rejectTransparent) end

---This will query the closest point to all shapes in the world. If you 
---want to set up a filter for the query you need to do so before every call
---to this function.
---
--- ---
--- Example
---```lua
-----Find closest point within 10 meters of {0, 5, 0}, excluding any point on myVehicle
---QueryRejectVehicle(myVehicle)
---local hit, p, n, s = QueryClosestPoint(Vec(0, 5, 0), 10)
---if hit then
---	--Point p of shape s is closest
---end
---```
---@param origin table
---@param maxDist number
---@return boolean hit
---@return table point
---@return table normal
---@return number shape
function QueryClosestPoint(origin, maxDist) end

---Return all shapes within the provided world space, axis-aligned bounding box
---
--- ---
--- Example
---```lua
---local list = QueryAabbShapes(Vec(0, 0, 0), Vec(10, 10, 10))
---for i=1, #list do
---	local shape = list[i]
---	..
---end
---```
---@param min table
---@param max table
---@return table list
function QueryAabbShapes(min, max) end

---Return all bodies within the provided world space, axis-aligned bounding box
---
--- ---
--- Example
---```lua
---local list = QueryAabbBodies(Vec(0, 0, 0), Vec(10, 10, 10))
---for i=1, #list do
---	local body = list[i]
---	..
---end
---```
---@param min table
---@param max table
---@return table list
function QueryAabbBodies(min, max) end

---No Description
---
--- ---
--- Example
---```lua
---local vol, pos = GetLastSound()
---```
---@return number volume
---@return table position
function GetLastSound() end

---No Description
---
--- ---
--- Example
---```lua
---local wet, d = IsPointInWater(Vec(10, 0, 0))
---if wet then
---	...point d meters into water
---end
---```
---@param point table
---@return boolean inWater
---@return number depth
function IsPointInWater(point) end

---Reset to default particle state, which is a plain, white particle of radius 0.5.
---Collision is enabled and it alpha animates from 1 to 0.
---
--- ---
--- Example
---```lua
---ParticleReset()
---```
function ParticleReset() end

---Set type of particle
---
--- ---
--- Example
---```lua
---ParticleType("smoke")
---```
---@param type string
function ParticleType(type) end

---No Description
---
--- ---
--- Example
---```lua
-----Smoke particle
---ParticleTile(0)
---
-----Fire particle
---ParticleTile(5)
---```
---@param type integer
function ParticleTile(type) end

---Set particle color to either constant (three arguments) or linear interpolation (six arguments)
---
--- ---
--- Example
---```lua
-----Constant red
---ParticleColor(1,0,0)
---
-----Animating from yellow to red
---ParticleColor(1,1,0, 1,0,0)
---```
---@param r0 number
---@param g0 number
---@param b0 number
---@param r1 number
---@param g1 number
---@param b1 number
function ParticleColor(r0, g0, b0, r1, g1, b1) end

---Set the particle radius. Max radius for smoke particles is 1.0.
---
--- ---
--- Example
---```lua
-----Constant radius 0.4 meters
---ParticleRadius(0.4)
---
-----Interpolate from small to large
---ParticleRadius(0.1, 0.7)
---```
---@param r0 number
---@param r1 number
---@param interpolation string
---@param fadein number
---@param fadeout number
function ParticleRadius(r0, r1, interpolation, fadein, fadeout) end

---Set the particle alpha (opacity).
---
--- ---
--- Example
---```lua
-----Interpolate from opaque to transparent
---ParticleAlpha(1.0, 0.0)
---```
---@param a0 number
---@param a1 number
---@param interpolation string
---@param fadein number
---@param fadeout number
function ParticleAlpha(a0, a1, interpolation, fadein, fadeout) end

---Set particle gravity. It will be applied along the world Y axis. A negative value will move the particle downwards.
---
--- ---
--- Example
---```lua
-----Move particles slowly upwards
---ParticleGravity(2)
---```
---@param g0 number
---@param g1 number
---@param interpolation string
---@param fadein number
---@param fadeout number
function ParticleGravity(g0, g1, interpolation, fadein, fadeout) end

---Particle drag will slow down fast moving particles. It's implemented slightly different for
---smoke and plain particles. Drag must be positive, and usually look good between zero and one.
---
--- ---
--- Example
---```lua
-----Sow down fast moving particles
---ParticleDrag(0.5)
---```
---@param d0 number
---@param d1 number
---@param interpolation string
---@param fadein number
---@param fadeout number
function ParticleDrag(d0, d1, interpolation, fadein, fadeout) end

---Draw particle as emissive (glow in the dark). This is useful for fire and embers.
---
--- ---
--- Example
---```lua
-----Highly emissive at start, not emissive at end
---ParticleEmissive(5, 0)
---```
---@param d0 number
---@param d1 number
---@param interpolation string
---@param fadein number
---@param fadeout number
function ParticleEmissive(d0, d1, interpolation, fadein, fadeout) end

---Makes the particle rotate. Positive values is counter-clockwise rotation.
---
--- ---
--- Example
---```lua
-----Rotate fast at start and slow at end
---ParticleEmissive(10, 1)
---```
---@param r0 number
---@param r1 number
---@param interpolation string
---@param fadein number
---@param fadeout number
function ParticleRotation(r0, r1, interpolation, fadein, fadeout) end

---Stretch particle along with velocity. 0.0 means no stretching. 1.0 stretches with the particle motion over
---one frame. Larger values stretches the particle even more.
---
--- ---
--- Example
---```lua
-----Stretch particle along direction of motion
---ParticleStretch(1.0)
---```
---@param s0 number
---@param s1 number
---@param interpolation string
---@param fadein number
---@param fadeout number
function ParticleStretch(s0, s1, interpolation, fadein, fadeout) end

---Make particle stick when in contact with objects. This can be used for friction.
---
--- ---
--- Example
---```lua
-----Make particles stick to objects
---ParticleSticky(0.5)
---```
---@param s0 number
---@param s1 number
---@param interpolation string
---@param fadein number
---@param fadeout number
function ParticleSticky(s0, s1, interpolation, fadein, fadeout) end

---Control particle collisions. A value of zero means that collisions are ignored. One means full collision.
---It is sometimes useful to animate this value from zero to one in order to not collide with objects around
---the emitter.
---
--- ---
--- Example
---```lua
-----Disable collisions
---ParticleCollide(0)
---
-----Enable collisions over time
---ParticleCollide(0, 1)
---
-----Ramp up collisions very quickly, only skipping the first 5% of lifetime
---ParticleCollide(1, 1, "constant", 0.05)
---```
---@param c0 number
---@param c1 number
---@param interpolation string
---@param fadein number
---@param fadeout number
function ParticleCollide(c0, c1, interpolation, fadein, fadeout) end

---Set particle bitmask. The value 256 means fire extinguishing particles and is currently the only 
---flag in use. There might be support for custom flags and queries in the future.
---
--- ---
--- Example
---```lua
-----Fire extinguishing particle
---ParticleFlags(256)
---SpawnParticle(...)
---```
---@param bitmask number
function ParticleFlags(bitmask) end

---Spawn particle using the previously set up particle state. You can call this multiple times
---using the same particle state, but with different position, velocity and lifetime. You can
---also modify individual properties in the particle state in between calls to to this function.
---
--- ---
--- Example
---```lua
---ParticleReset()
---ParticleType("smoke")
---ParticleColor(0.7, 0.6, 0.5)
-----Spawn particle at world origo with upwards velocity and a lifetime of ten seconds
---SpawnParticle(Vec(0, 0, 0), Vec(0, 1, 0), 10.0)
---```
---@param pos table
---@param velocity table
---@param lifetime number
function SpawnParticle(pos, velocity, lifetime) end

---Shoot bullet or rocket (used for chopper)
---
--- ---
--- Example
---```lua
---Shoot(Vec(0, 10, 0), Vec(0, 0, 1))
---```
---@param origin table
---@param direction table
---@param type number
function Shoot(origin, direction, type) end

---Make a hole in the environment. Radius is given in meters. 
---Soft materials: glass, foliage, dirt, wood, plaster and plastic. 
---Medium materials: concrete, brick and weak metal. 
---Hard materials: hard metal and hard masonry.
---
--- ---
--- Example
---```lua
---MakeHole(pos, 1.2, 1.0)
---```
---@param position table
---@param r0 number
---@param r1 number
---@param r2 number
---@param silent boolean
function MakeHole(position, r0, r1, r2, silent) end

---No Description
---
--- ---
--- Example
---```lua
---Explosion(Vec(0, 10, 0), 1)
---```
---@param pos table
---@param size number
function Explosion(pos, size) end

---No Description
---
--- ---
--- Example
---```lua
---SpawnFire(Vec(0, 10, 0))
---```
---@param pos table
function SpawnFire(pos) end

---No Description
---
--- ---
--- Example
---```lua
---local c = GetFireCount()
---```
---@return number count
function GetFireCount() end

---No Description
---
--- ---
--- Example
---```lua
---local hit, pos = QueryClosestFire(GetPlayerTransform().pos, 5.0)
---if hit then
---	--There is a fire within 5 meters to the player. Mark it with a debug cross.
---	DebugCross(pos)
---end
---```
---@param origin table
---@param maxDist number
---@return boolean hit
---@return table pos
function QueryClosestFire(origin, maxDist) end

---No Description
---
--- ---
--- Example
---```lua
---local count = QueryAabbFireCount(Vec(0,0,0), Vec(10,10,10))
---```
---@param min table
---@param max table
---@return number count
function QueryAabbFireCount(min, max) end

---No Description
---
--- ---
--- Example
---```lua
---local removedCount= RemoveAabbFires(Vec(0,0,0), Vec(10,10,10))
---```
---@param min table
---@param max table
---@return number count
function RemoveAabbFires(min, max) end

---No Description
---
--- ---
--- Example
---```lua
---local t = GetCameraTransform()
---```
---@return table transform
function GetCameraTransform() end

---Override current camera transform for this frame. Call continuously to keep overriding.
---
--- ---
--- Example
---```lua
---SetCameraTransform(Transform(Vec(0, 10, 0), QuatEuler(0, 90, 0)))
---```
---@param transform table
---@param fov number
function SetCameraTransform(transform, fov) end

---Override field of view for the next frame for all camera modes, except when explicitly set in SetCameraTransform
---
--- ---
--- Example
---```lua
---function tick()
---	SetCameraFov(60)
---end
---```
---@param float number
function SetCameraFov(float) end

---Add a temporary point light to the world for this frame. Call continuously
---for a steady light.
---
--- ---
--- Example
---```lua
-----Pulsating, yellow light above world origo
---local intensity = 3 + math.sin(GetTime())
---PointLight(Vec(0, 5, 0), 1, 1, 0, intensity)
---```
---@param pos table
---@param r number
---@param g number
---@param b number
---@param intensity number
function PointLight(pos, r, g, b, intensity) end

---Experimental. Scale time in order to make a slow-motion effect. Audio will
---also be affected. Note that this will affect physics behavior and is not
---intended for gameplay purposes. Calling this function will slow down time
---for the next frame only. Call every frame from tick function to get steady
---slow-motion.
---
--- ---
--- Example
---```lua
-----Slow down time when holding down a key
---if InputDown('t') then
---SetTimeScale(0.2)
---end
---```
---@param scale number
function SetTimeScale(scale) end

---Reset the environment properties to default. This is often useful before 
---setting up a custom environment.
---
--- ---
--- Example
---```lua
---SetEnvironmentDefault()
---```
function SetEnvironmentDefault() end

---This function is used for manipulating the environment properties. The available properties are 
---exactly the same as in the editor.
---
--- ---
--- Example
---```lua
---SetEnvironmentProperty("skybox", "cloudy.dds")
---SetEnvironmentProperty("rain", 0.7)
---SetEnvironmentProperty("fogcolor", 0.5, 0.5, 0.8)
---SetEnvironmentProperty("nightlight", false)
---```
---@param name string
---@param value0 any
---@param value1 any
---@param value2 any
---@param value3 any
function SetEnvironmentProperty(name, value0, value1, value2, value3) end

---This function is used for querying the current environment properties. The available properties are
---exactly the same as in the editor.
---
--- ---
--- Example
---```lua
---local skyboxPath = GetEnvironmentProperty("skybox")
---local rainValue = GetEnvironmentProperty("rain")
---local r,g,b = GetEnvironmentProperty("fogcolor")
---local enabled = GetEnvironmentProperty("nightlight")
---```
---@param name string
---@return any value0
---@return any value1
---@return any value2
---@return any value3
---@return any value4
function GetEnvironmentProperty(name) end

---Reset the post processing properties to default.
---
--- ---
--- Example
---```lua
---SetPostProcessingDefault()
---```
function SetPostProcessingDefault() end

---This function is used for manipulating the post processing properties. The available properties are
---exactly the same as in the editor.
---
--- ---
--- Example
---```lua
-----Sepia post processing
---SetPostProcessingProperty("saturation", 0.4)
---SetPostProcessingProperty("colorbalance", 1.3, 1.0, 0.7)
---```
---@param name string
---@param value0 number
---@param value1 number
---@param value2 number
function SetPostProcessingProperty(name, value0, value1, value2) end

---This function is used for querying the current post processing properties. 
---The available properties are exactly the same as in the editor.
---
--- ---
--- Example
---```lua
---local saturation = GetPostProcessingProperty("saturation")
---local r,g,b = GetPostProcessingProperty("colorbalance")
---```
---@param name string
---@return number value0
---@return number value1
---@return number value2
function GetPostProcessingProperty(name) end

---Draw a 3D line. In contrast to DebugLine, it will not show behind objects. Default color is white.
---
--- ---
--- Example
---```lua
-----Draw white debug line
---DrawLine(Vec(0, 0, 0), Vec(-10, 5, -10))
---
-----Draw red debug line
---DrawLine(Vec(0, 0, 0), Vec(10, 5, 10), 1, 0, 0)
---```
---@param p0 table
---@param p1 table
---@param r number
---@param g number
---@param b number
---@param a number
function DrawLine(p0, p1, r, g, b, a) end

---Draw a 3D debug overlay line in the world. Default color is white.
---
--- ---
--- Example
---```lua
-----Draw white debug line
---DebugLine(Vec(0, 0, 0), Vec(-10, 5, -10))
---
-----Draw red debug line
---DebugLine(Vec(0, 0, 0), Vec(10, 5, 10), 1, 0, 0)
---```
---@param p0 table
---@param p1 table
---@param r number
---@param g number
---@param b number
---@param a number
function DebugLine(p0, p1, r, g, b, a) end

---Draw a debug cross in the world to highlight a location. Default color is white.
---
--- ---
--- Example
---```lua
---DebugCross(Vec(10, 5, 5))
---```
---@param p0 table
---@param r number
---@param g number
---@param b number
---@param a number
function DebugCross(p0, r, g, b, a) end

---Show a named valued on screen for debug purposes.
---Up to 32 values can be shown simultaneously. Values updated the current
---frame are drawn opaque. Old values are drawn transparent in white.
---The function will also recognize vectors, quaternions and transforms as
---second argument and convert them to strings automatically.
---
--- ---
--- Example
---```lua
---local t = 5
---DebugWatch("time", t)
---```
---@param name string
---@param value string
function DebugWatch(name, value) end

---Display message on screen. The last 20 lines are displayed.
---
--- ---
--- Example
---```lua
---DebugPrint("time")
---```
---@param message string
function DebugPrint(message) end

---Calling this function will disable game input, bring up the mouse pointer
---and allow Ui interaction with the calling script without pausing the game.
---This can be useful to make interactive user interfaces from scripts while
---the game is running. Call this continuously every frame as long as Ui 
---interaction is desired.
---
--- ---
--- Example
---```lua
---UiMakeInteractive()
---```
function UiMakeInteractive() end

---Push state onto stack. This is used in combination with UiPop to
---remember a state and restore to that state later.
---
--- ---
--- Example
---```lua
---UiColor(1,0,0)
---UiText("Red")
---UiPush()
---	UiColor(0,1,0)
---	UiText("Green")
---UiPop()
---UiText("Red")
---```
function UiPush() end

---Pop state from stack and make it the current one. This is used in
---combination with UiPush to remember a previous state and go back to
---it later.
---
--- ---
--- Example
---```lua
---UiColor(1,0,0)
---UiText("Red")
---UiPush()
---	UiColor(0,1,0)
---	UiText("Green")
---UiPop()
---UiText("Red")
---```
function UiPop() end

---No Description
---
--- ---
--- Example
---```lua
---local w = UiWidth()
---```
---@return number width
function UiWidth() end

---No Description
---
--- ---
--- Example
---```lua
---local h = UiHeight()
---```
---@return number height
function UiHeight() end

---No Description
---
--- ---
--- Example
---```lua
---local c = UiCenter()
-----Same as 
---local c = UiWidth()/2
---```
---@return number center
function UiCenter() end

---No Description
---
--- ---
--- Example
---```lua
---local m = UiMiddle()
-----Same as
---local m = UiHeight()/2
---```
---@return number middle
function UiMiddle() end

---No Description
---
--- ---
--- Example
---```lua
-----Set color yellow
---UiColor(1,1,0)
---```
---@param r number
---@param g number
---@param b number
---@param a number
function UiColor(r, g, b, a) end

---Color filter, multiplied to all future colors in this scope
---
--- ---
--- Example
---```lua
---UiPush()
---	--Draw menu in transparent, yellow color tint
---	UiColorFilter(1, 1, 0, 0.5)
---	drawMenu()
---UiPop()
---```
---@param r number
---@param g number
---@param b number
---@param a number
function UiColorFilter(r, g, b, a) end

---Translate cursor
---
--- ---
--- Example
---```lua
---UiPush()
---	UiTranslate(100, 0)
---	UiText("Indented")
---UiPop()
---```
---@param x number
---@param y number
function UiTranslate(x, y) end

---Rotate cursor
---
--- ---
--- Example
---```lua
---UiPush()
---	UiRotate(45)
---	UiText("Rotated")
---UiPop()
---```
---@param angle number
function UiRotate(angle) end

---Scale cursor either uniformly (one argument) or non-uniformly (two arguments)
---
--- ---
--- Example
---```lua
---UiPush()
---	UiScale(2)
---	UiText("Double size")
---UiPop()
---```
---@param x number
---@param y number
function UiScale(x, y) end

---Set up new bounds. Calls to UiWidth, UiHeight, UiCenter and UiMiddle
---will operate in the context of the window size. 
---If clip is set to true, contents of window will be clipped to 
---bounds (only works properly for non-rotated windows).
---
--- ---
--- Example
---```lua
---UiPush()
---	UiWindow(400, 200)
---	local w = UiWidth()
---	--w is now 400
---UiPop()
---```
---@param width number
---@param height number
---@param clip boolean
function UiWindow(width, height, clip) end

---Return a safe drawing area that will always be visible regardless of
---display aspect ratio. The safe drawing area will always be 1920 by 1080
---in size. This is useful for setting up a fixed size UI.
---
--- ---
--- Example
---```lua
---function draw()
---	local x0, y0, x1, y1 = UiSafeMargins()
---	UiTranslate(x0, y0)
---	UiWindow(x1-x0, y1-y0, true)
---	--The drawing area is now 1920 by 1080 in the center of screen
---	drawMenu()
---end
---```
---@return number x0
---@return number y0
---@return number x1
---@return number y1
function UiSafeMargins() end

---The alignment determines how content is aligned with respect to the
---cursor.
---
---Alignment  Description
---left	 Horizontally align to the leftright	 Horizontally align to the rightcenter	 Horizontally align to the centertop		 Vertically align to the topbottom	 Veritcally align to the bottommiddle	 Vertically align to the middle
---
--- ---
--- Example
---```lua
---UiAlign("left")
---UiText("Aligned left at baseline")
---
---UiAlign("center middle")
---UiText("Fully centered")
---```
---@param alignment string
function UiAlign(alignment) end

---Disable input for everything, except what's between UiModalBegin and UiModalEnd 
---(or if modal state is popped)
---
--- ---
--- Example
---```lua
---UiModalBegin()
---if UiTextButton("Okay") then
---	--All other interactive ui elements except this one are disabled
---end
---UiModalEnd()
---
-----This is also okay
---UiPush()
---	UiModalBegin()
---	if UiTextButton("Okay") then
---		--All other interactive ui elements except this one are disabled
---	end
---UiPop()
-----No longer modal
---```
function UiModalBegin() end

---Disable input for everything, except what's between UiModalBegin and UiModalEnd
---Calling this function is optional. Modality is part of the current state and will
---be lost if modal state is popped.
---
--- ---
--- Example
---```lua
---UiModalBegin()
---if UiTextButton("Okay") then
---	--All other interactive ui elements except this one are disabled
---end
---UiModalEnd()
---```
function UiModalEnd() end

---Disable input
---
--- ---
--- Example
---```lua
---UiPush()
---	UiDisableInput()
---	if UiTextButton("Okay") then
---		--Will never happen
---	end
---UiPop()
---```
function UiDisableInput() end

---Enable input that has been previously disabled
---
--- ---
--- Example
---```lua
---UiDisableInput()
---if UiButtonText("Okay") then
---	--Will never happen
---end
---
---UiEnableInput()
---if UiButtonText("Okay") then
---	--This can happen
---end
---```
function UiEnableInput() end

---This function will check current state receives input. This is the case 
---if input is not explicitly disabled with (with UiDisableInput) and no other
---state is currently modal (with UiModalBegin). Input functions and UI
---elements already do this check internally, but it can sometimes be useful 
---to read the input state manually to trigger things in the UI.
---
--- ---
--- Example
---```lua
---if UiReceivesInput() then
---	highlightItemAtMousePointer()
---end
---```
---@return boolean receives
function UiReceivesInput() end

---Get mouse pointer position relative to the cursor
---
--- ---
--- Example
---```lua
---local x, y = UiGetMousePos()
---```
---@return number x
---@return number y
function UiGetMousePos() end

---Check if mouse pointer is within rectangle. Note that this function respects
---alignment.
---
--- ---
--- Example
---```lua
---if UiIsMouseInRect(100, 100) then
---	-- mouse pointer is in rectangle
---end
---```
---@param w number
---@param h number
---@return boolean inside
function UiIsMouseInRect(w, h) end

---Convert world space position to user interface X and Y coordinate relative
---to the cursor. The distance is in meters and positive if in front of camera,
---negative otherwise.
---
--- ---
--- Example
---```lua
---local x, y, dist = UiWorldToPixel(point)
---if dist > 0 then
---UiTranslate(x, y)
---UiText("Label")
---end
---```
---@param point table
---@return number x
---@return number y
---@return number distance
function UiWorldToPixel(point) end

---Convert X and Y UI coordinate to a world direction, as seen from current camera.
---This can be used to raycast into the scene from the mouse pointer position.
---
--- ---
--- Example
---```lua
---UiMakeInteractive()
---local x, y = UiGetMousePos()
---local dir = UiPixelToWorld(x, y)
---local pos = GetCameraTransform().pos
---local hit, dist = QueryRaycast(pos, dir, 100)
---if hit then
---	DebugPrint("hit distance: " .. dist)
---end
---```
---@param x number
---@param y number
---@return table direction
function UiPixelToWorld(x, y) end

---Perform a gaussian blur on current screen content
---
--- ---
--- Example
---```lua
---UiBlur(1.0)
---drawMenu()
---```
---@param amount number
function UiBlur(amount) end

---No Description
---
--- ---
--- Example
---```lua
---UiFont("bold.ttf", 24)
---UiText("Hello")
---```
---@param path string
---@param size number
function UiFont(path, size) end

---No Description
---
--- ---
--- Example
---```lua
---local h = UiFontHeight()
---```
---@return number size
function UiFontHeight() end

---No Description
---
--- ---
--- Example
---```lua
---UiFont("bold.ttf", 24)
---UiText("Hello")
---
---...
---
-----Automatically advance cursor
---UiText("First line", true)
---UiText("Second line", true)
---```
---@param text string
---@param move boolean
---@return number w
---@return number h
function UiText(text, move) end

---No Description
---
--- ---
--- Example
---```lua
---local w, h = UiGetTextSize("Some text")
---```
---@param text string
---@return number w
---@return number h
function UiGetTextSize(text) end

---No Description
---
--- ---
--- Example
---```lua
---UiWordWrap(200)
---UiText("Some really long text that will get wrapped into several lines")
---```
---@param width number
function UiWordWrap(width) end

---No Description
---
--- ---
--- Example
---```lua
-----Black outline, standard thickness
---UiTextOutline(0,0,0,1)
---UiText("Text with outline")
---```
---@param r number
---@param g number
---@param b number
---@param a number
---@param thickness number
function UiTextOutline(r, g, b, a, thickness) end

---No Description
---
--- ---
--- Example
---```lua
-----Black drop shadow, 50% transparent, distance 2
---UiTextShadow(0, 0, 0, 0.5, 2.0)
---UiText("Text with drop shadow")
---```
---@param r number
---@param g number
---@param b number
---@param a number
---@param distance number
---@param blur number
function UiTextShadow(r, g, b, a, distance, blur) end

---Draw solid rectangle at cursor position
---
--- ---
--- Example
---```lua
-----Draw full-screen black rectangle
---UiColor(0, 0, 0)
---UiRect(UiWidth(), UiHeight())
---
-----Draw smaller, red, rotating rectangle in center of screen
---UiPush()
---	UiColor(1, 0, 0)
---	UiTranslate(UiCenter(), UiMiddle())
---	UiRotate(GetTime())
---	UiAlign("center middle")
---	UiRect(100, 100)
---UiPop()
---```
---@param w number
---@param h number
function UiRect(w, h) end

---Draw image at cursor position
---
--- ---
--- Example
---```lua
-----Draw image in center of screen
---UiPush()
---	UiTranslate(UiCenter(), UiMiddle())
---	UiAlign("center middle")
---	UiImage("test.png")
---UiPop()
---```
---@param path string
---@return number w
---@return number h
function UiImage(path) end

---Get image size
---
--- ---
--- Example
---```lua
---local w,h = UiGetImageSize("test.png")
---```
---@param path string
---@return number w
---@return number h
function UiGetImageSize(path) end

---Draw 9-slice image at cursor position. Width should be at least 2*borderWidth.
---Height should be at least 2*borderHeight.
---
--- ---
--- Example
---```lua
---UiImageBox("menu-frame.png", 200, 200, 10, 10)
---```
---@param path string
---@param width number
---@param height number
---@param borderWidth number
---@param borderHeight number
function UiImageBox(path, width, height, borderWidth, borderHeight) end

---UI sounds are not affected by acoustics simulation. Use LoadSound / PlaySound for that.
---
--- ---
--- Example
---```lua
---UiSound("click.ogg")
---```
---@param path string
---@param volume number
---@param pitch number
---@param pan number
function UiSound(path, volume, pitch, pan) end

---Call this continuously to keep playing loop. 
---UI sounds are not affected by acoustics simulation. Use LoadLoop / PlayLoop for that.
---
--- ---
--- Example
---```lua
---if animating then
---	UiSoundLoop("screech.ogg")
---end
---```
---@param path string
---@param volume number
function UiSoundLoop(path, volume) end

---Mute game audio and optionally music for the next frame. Call
---continuously to stay muted.
---
--- ---
--- Example
---```lua
---if menuOpen then
---	UiMute(1.0)
---end
---```
---@param amount number
---@param music boolean
function UiMute(amount, music) end

---Set up 9-slice image to be used as background for buttons.
---
--- ---
--- Example
---```lua
---UiButtonImageBox("button-9slice.png", 10, 10)
---if UiTextButton("Test") then
---	...
---end
---```
---@param path string
---@param borderWidth number
---@param borderHeight number
---@param r number
---@param g number
---@param b number
---@param a number
function UiButtonImageBox(path, borderWidth, borderHeight, r, g, b, a) end

---Button color filter when hovering mouse pointer.
---
--- ---
--- Example
---```lua
---UiButtonHoverColor(1, 0, 0)
---if UiTextButton("Test") then
---	...
---end
---```
---@param r number
---@param g number
---@param b number
---@param a number
function UiButtonHoverColor(r, g, b, a) end

---Button color filter when pressing down.
---
--- ---
--- Example
---```lua
---UiButtonPressColor(0, 1, 0)
---if UiTextButton("Test") then
---	...
---end
---```
---@param r number
---@param g number
---@param b number
---@param a number
function UiButtonPressColor(r, g, b, a) end

---The button offset when being pressed
---
--- ---
--- Example
---```lua
---UiButtonPressDistance(4)
---if UiTextButton("Test") then
---	...
---end
---```
---@param dist number
function UiButtonPressDist(dist) end

---No Description
---
--- ---
--- Example
---```lua
---if UiTextButton("Test") then
---	...
---end
---```
---@param text string
---@param w number
---@param h number
---@return boolean pressed
function UiTextButton(text, w, h) end

---No Description
---
--- ---
--- Example
---```lua
---if UiImageButton("image.png") then
---	...
---end
---```
---@param path number
---@param w number
---@param h number
---@return boolean pressed
function UiImageButton(path, w, h) end

---No Description
---
--- ---
--- Example
---```lua
---if UiBlankButton(30, 30) then
---	...
---end
---```
---@param w number
---@param h number
---@return boolean pressed
function UiBlankButton(w, h) end

---No Description
---
--- ---
--- Example
---```lua
---value = UiSlider("dot.png", "x", value, 0, 100)
---```
---@param path number
---@param axis string
---@param current number
---@param min number
---@param max number
---@return number value
---@return boolean done
function UiSlider(path, axis, current, min, max) end

---No Description
---
--- ---
--- Example
---```lua
-----Turn off screen running current script
---screen = UiGetScreen()
---SetScreenEnabled(screen, false)
---```
---@return number handle
function UiGetScreen() end
