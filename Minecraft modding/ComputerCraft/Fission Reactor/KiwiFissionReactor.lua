-- Reactor Controller - Auto Monitor Detection + Lockout Timer
-- Optimized to reduce flicker by only redrawing updated info

local reactor = peripheral.wrap("fissionReactorLogicAdapter_3")
local chatBox = peripheral.find("chatBox")

-- Auto-detect top and bottom monitors based on height
local allMonitors = { peripheral.find("monitor") }

if #allMonitors < 2 then
  error("Could not find two monitors.")
end

-- Sort monitors: tallest is info screen (top), shortest is button screen (bottom)
table.sort(allMonitors, function(a, b)
  local _, ha = a.getSize()
  local _, hb = b.getSize()
  return ha > hb
end)

local topMonitor = allMonitors[1]
local bottomMonitor = allMonitors[2]

-- Safety limits
local MIN_FUEL = 10
local MIN_COOLANT = 10
local MAX_DAMAGE = 5

-- Lockout state
local actionLock = false
local lockoutSeconds = 0
local prevValues = {}

-- Monitor Setup
local function clearMonitor(mon)
  if mon and mon.setBackgroundColor then
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.white)
    mon.clear()
  end
end

local function centerText(mon, text, y, color)
  if not mon then return end
  local w, _ = mon.getSize()
  local x = math.floor((w - #text) / 2) + 1
  mon.setCursorPos(x, y)
  if color then mon.setTextColor(color) end
  mon.write(text)
  mon.setTextColor(colors.white)
end

-- Button Setup
local buttons = {}

local function drawButton(label, x, y, w, h, color, action)
  table.insert(buttons, {label=label, x=x, y=y, w=w, h=h, color=color, action=action})
  if bottomMonitor then
    bottomMonitor.setBackgroundColor(color)
    for i = 0, h - 1 do
      bottomMonitor.setCursorPos(x, y + i)
      bottomMonitor.write(string.rep(" ", w))
    end
    bottomMonitor.setCursorPos(x + math.floor((w - #label) / 2), y + math.floor(h / 2))
    bottomMonitor.setTextColor(colors.white)
    bottomMonitor.write(label)
    bottomMonitor.setBackgroundColor(colors.black)
  end
end

-- Button Actions
local function scramReactor()
  if reactor and reactor.scram then
    reactor.scram()
  end
end

local function tryActivateReactor()
  local methods = {
    function() if reactor.setStatus then reactor.setStatus(true) end end,
    function() if reactor.activate then reactor.activate() end end,
    function() if reactor.start then reactor.start() end end
  }
  for _, method in ipairs(methods) do
    local ok = pcall(method)
    if ok then return true end
  end
  return false
end

local function tryStartReactor()
  local coolant = reactor.getCoolantFilledPercentage()
  local fuel = reactor.getFuelFilledPercentage()
  local damage = reactor.getDamagePercent()
  if coolant > MIN_COOLANT and fuel > MIN_FUEL and damage < MAX_DAMAGE then
    tryActivateReactor()
  end
end

local function adjustBurnRate(delta)
  local current = reactor.getBurnRate()
  local maxRate = reactor.getMaxBurnRate()
  local newRate = math.max(0.01, math.min(current + delta, maxRate))
  reactor.setBurnRate(newRate)
end

-- Lockout timer
local function startLockoutTimer()
  lockoutSeconds = 10
  while lockoutSeconds > 0 do
    sleep(1)
    lockoutSeconds = lockoutSeconds - 1
  end
  actionLock = false
end

local function runWithLock(action)
  if not actionLock then
    actionLock = true
    parallel.waitForAll(function() action() end, startLockoutTimer)
  end
end

-- Draw Buttons
local function drawButtons()
  clearMonitor(bottomMonitor)
  buttons = {}
  drawButton("START", 2, 2, 10, 3, colors.green, function() runWithLock(tryStartReactor) end)
  drawButton("STOP", 14, 2, 10, 3, colors.red, function() runWithLock(scramReactor) end)
  drawButton("+0.01", 26, 2, 8, 3, colors.orange, function() adjustBurnRate(0.01) end)
  drawButton("+1", 36, 2, 6, 3, colors.orange, function() adjustBurnRate(1) end)
  drawButton("-0.01", 44, 2, 8, 3, colors.cyan, function() adjustBurnRate(-0.01) end)
  drawButton("-1", 54, 2, 6, 3, colors.cyan, function() adjustBurnRate(-1) end)
end

-- Touch Handling
local function handleTouch()
  while true do
    local _, side, x, y = os.pullEvent("monitor_touch")
    if side == peripheral.getName(bottomMonitor) then
      for _, btn in pairs(buttons) do
        if x >= btn.x and x <= (btn.x + btn.w - 1) and y >= btn.y and y <= (btn.y + btn.h - 1) then
          btn.action()
          break
        end
      end
    end
  end
end

-- Optimized Info Display
local function updateLine(label, value, lineNum, color)
  if prevValues[lineNum] ~= value then
    centerText(topMonitor, string.rep(" ", 40), lineNum) -- clear line
    centerText(topMonitor, value, lineNum, color)
    prevValues[lineNum] = value
  end
end

local function updateInfo()
  clearMonitor(topMonitor)
  centerText(topMonitor, "FISSION REACTOR STATUS", 1, colors.yellow)

  while true do
    local status = reactor.getStatus()
    local temp = reactor.getTemperature()
    local fuel = reactor.getFuelFilledPercentage()
    local coolant = reactor.getCoolantFilledPercentage()
    local waste = reactor.getWasteFilledPercentage()
    local damage = reactor.getDamagePercent()
    local burnRate = reactor.getBurnRate()
    local maxRate = reactor.getMaxBurnRate()

    updateLine("status", status and "[ ONLINE ]" or "[ OFFLINE ]", 2, status and colors.lime or colors.red)
    updateLine("temp", string.format("Temp: %d C", temp), 4)
    updateLine("fuel", string.format("Fuel: %d%%", fuel), 5)
    updateLine("coolant", string.format("Coolant: %d%%", coolant), 6)
    updateLine("waste", string.format("Waste: %d%%", waste), 7)
    updateLine("damage", string.format("Damage: %d%%", damage), 8)
    updateLine("burnRate", string.format("Burn Rate: %.2f / %.2f", burnRate, maxRate), 9)

    if lockoutSeconds > 0 then
      updateLine("lockout", "BUTTON LOCKOUT TIMER: " .. lockoutSeconds, 11, colors.yellow)
      updateLine("manual", "IF REACTOR DOESN'T START IN 10 SECONDS START MANUALLY", 12, colors.lightGray)
    else
      updateLine("lockout", "", 11)
      updateLine("manual", "", 12)
    end

    sleep(0.5)
  end
end

-- Chatbox Listener
local function listenChat()
  if not chatBox then return end
  while true do
    local _, username, message = os.pullEvent("chat")
    message = message:lower()
    if message:find("server will restart in") then
      runWithLock(scramReactor)
    elseif message:find("server has started") then
      shell.run("startup")
    end
  end
end

-- Init
clearMonitor(topMonitor)
clearMonitor(bottomMonitor)
drawButtons()

parallel.waitForAny(updateInfo, handleTouch, listenChat)
