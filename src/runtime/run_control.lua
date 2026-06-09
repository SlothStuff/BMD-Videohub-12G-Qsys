-- EventHandler wiring for Videohub 12G plugin.
-- Routing EventHandlers echo-suppress by comparing against CurrentRoutes/InputLabels/OutputLabels
-- caches (set in handlers.lua before the control string is updated) so that device-initiated
-- updates don't loop back as new commands.

-- Detect I/O counts from instantiated controls (avoids needing MODEL_IO at runtime).
-- Q-SYS Count > 1 controls are accessed as Controls["Name"][i], not Controls["Name i"].
local outputCount = 0
local inputCount  = 0
local _outCtrl = Controls["Output Routing"]
local _inCtrl  = Controls["Input Label"]
if _outCtrl then
  for i = 1, 130 do
    if _outCtrl[i] then outputCount = i end
  end
end
if _inCtrl then
  for i = 1, 130 do
    if _inCtrl[i] then inputCount = i end
  end
end

local useTake     = Properties["Use Take"].Value
local lockEnabled = Properties["Lock Controls Enabled"].Value

local function UpdateTakePending()
  local pending = next(StagedRoutes) ~= nil
  local led = Controls["Take Pending"]
  if led then led.Boolean = pending end
end

-- ─────────────────────────────────────────────
-- Routing
-- ─────────────────────────────────────────────

for i = 1, outputCount do
  local idx = i
  Controls["Output Routing"][idx].EventHandler = function(ctrl)
    local input1 = tonumber(ctrl.String)
    if not input1 or input1 < 1 then return end
    -- Suppress echo: HandleRouting sets CurrentRoutes[n] before updating the control
    if input1 == CurrentRoutes[idx] then return end
    if useTake then
      StagedRoutes[idx] = input1
      UpdateTakePending()
    else
      RouteOutput(idx, input1)
    end
  end
end

-- Route Display ComboBox: selecting a label name routes by name lookup
for i = 1, outputCount do
  local idx  = i
  local disp = Controls["Route Display"][idx]
  if disp then
    disp.EventHandler = function(c)
      local choices = Controls["Route Display"][idx].Choices
      if not choices then return end
      local input1
      for k, label in ipairs(choices) do
        if label == c.String then
          input1 = k
          break
        end
      end
      if not input1 then return end
      if input1 == CurrentRoutes[idx] then return end
      if useTake then
        StagedRoutes[idx] = input1
        UpdateTakePending()
      else
        RouteOutput(idx, input1)
      end
    end
  end
end

-- ─────────────────────────────────────────────
-- Take
-- ─────────────────────────────────────────────

if useTake and Controls["Take"] then
  Controls["Take"].EventHandler = function()
    for out1, in1 in pairs(StagedRoutes) do
      RouteOutput(out1, in1)
    end
    StagedRoutes = {}
    UpdateTakePending()
  end
end

-- ─────────────────────────────────────────────
-- Locks
-- ─────────────────────────────────────────────

if lockEnabled then
  for i = 1, outputCount do
    local idx = i
    local lockBtn   = Controls["Lock Output"][idx]
    local unlockBtn = Controls["Unlock Output"][idx]
    if lockBtn   then lockBtn.EventHandler   = function() LockOutput(idx)   end end
    if unlockBtn then unlockBtn.EventHandler = function() UnlockOutput(idx) end end
  end
end

-- ─────────────────────────────────────────────
-- Labels
-- ─────────────────────────────────────────────

for i = 1, inputCount do
  local idx  = i
  local ctrl = Controls["Input Label"][idx]
  if ctrl then
    ctrl.EventHandler = function(c)
      -- Suppress echo: HandleInputLabels sets InputLabels[n] before updating the control
      if c.String == InputLabels[idx] then return end
      SetInputLabel(idx, c.String)
    end
  end
end

for i = 1, outputCount do
  local idx  = i
  local ctrl = Controls["Output Label"][idx]
  if ctrl then
    ctrl.EventHandler = function(c)
      -- Suppress echo: HandleOutputLabels sets OutputLabels[n] before updating the control
      if c.String == OutputLabels[idx] then return end
      SetOutputLabel(idx, c.String)
    end
  end
end

-- ─────────────────────────────────────────────
-- Poll rate
-- ─────────────────────────────────────────────

Controls.PollRate.EventHandler = function(ctrl)
  if socket.IsConnected then
    PollTimer:Stop()
    local rate = math.max(1, tonumber(ctrl.String) or 30)
    PollTimer:Start(rate)
  end
end

-- ─────────────────────────────────────────────
-- Presets
-- ─────────────────────────────────────────────

for i = 1, 8 do
  local idx = i

  Controls["Preset Save"][idx].EventHandler = function()
    -- Serialize only confirmed routes; skip outputs not yet reported by device
    local entries = {}
    for j = 1, outputCount do
      if CurrentRoutes[j] then
        entries[#entries + 1] = j .. "=" .. CurrentRoutes[j]
      end
    end
    Controls["Preset Data"][idx].String = table.concat(entries, ",")
    print(string.format("[PRESET] Saved preset %d (%d/%d outputs confirmed)", idx, #entries, outputCount))
  end

  Controls["Preset Load"][idx].EventHandler = function()
    local data = Controls["Preset Data"][idx].String
    if data == "" then
      print(string.format("[PRESET] Preset %d is empty", idx))
      return
    end
    -- Clear any existing staged routes before merging the preset
    StagedRoutes = {}
    local applied = 0
    for entry in data:gmatch("[^,]+") do
      local out1, in1 = entry:match("^(%d+)=(%d+)$")
      if out1 then
        local output1 = tonumber(out1)
        local input1  = tonumber(in1)
        if output1 >= 1 and output1 <= outputCount and input1 >= 1 and input1 <= inputCount then
          if useTake then
            StagedRoutes[output1] = input1
          else
            RouteOutput(output1, input1)
          end
          applied = applied + 1
        end
      end
    end
    if useTake then UpdateTakePending() end
    print(string.format("[PRESET] Loaded preset %d (%d routes applied)", idx, applied))
  end
end
