---@param command string
function Command(command, ...) end

---@param quat table
---@return string
function QuatStr(quat) end

---@param transform table
---@return string
function TransformStr(transform) end

---@param vector table
---@return string
function VecStr(vector) end

---@param file string
---@return boolean
function HasFile(file) end

function init() end

---@param dt number
function tick(dt) end

---@param dt number
function update(dt) end

---@param dt number
function draw(dt) end

function handleCommand() end