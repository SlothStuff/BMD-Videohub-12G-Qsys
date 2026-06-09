-- Videohub12G - Debug Build
-- by Sweetwater Integration
-- 06/2026
-- Connect the "code" pin to a Q-SYS Control Script for live runtime debugging.

PluginInfo = {
  Name         = "Sweetwater Integration~Blackmagic~Videohub 12G - Debug",
  Version      = "0.1.0",
  BuildVersion = "0.1.0.0",
  Id           = "<guid>-debug",
  Author       = "Sweetwater Integration",
  Description  = "Debug build - Control for Blackmagic Videohub 12G routers (Mini 4x2 through 80x80)"
}

function GetColor(props)
  return { 200, 100, 0 }
end

function GetPrettyName(props)
  return "DEBUG: Videohub 12G v" .. PluginInfo.Version
end

--[[ #include "pages.lua" ]]
--[[ #include "properties.lua" ]]
--[[ #include "style.lua" ]]

function GetControls(props)
  local ctrls = {}
  --[[ #include "controls/ctrl_control.lua" ]]
  table.insert(ctrls, {
    Name        = "code",
    ControlType = "Text",
    UserPin     = true,
    PinStyle    = "Input",
    Count       = 1
  })
  return ctrls
end

--[[ #include "layout/constants.lua" ]]

function GetControlLayout(props)
  local layout   = {}
  local graphics = {}

  local pageList    = BuildPageList(props)
  local CurrentPage = pageList[props["page_index"].Value].name

  local modelIO     = MODEL_IO[props["Videohub Model"].Value] or MODEL_IO["Videohub 20x20 12G"]
  local inputCount  = modelIO.inputs
  local outputCount = modelIO.outputs
  local lockEnabled = props["Lock Controls Enabled"].Value
  local useTake     = props["Use Take"].Value
  local labelEdit   = props["Allow Label Editing"].Value

  table.insert(graphics, {
    Type = "GroupBox", Position = { 0, 0 }, Size = { LAYOUT.W, LAYOUT.H },
    Fill = { 200, 100, 0 }, StrokeColor = { 200, 100, 0 }, StrokeWidth = 0, CornerRadius = 0
  })

  local bankStart, bankEnd
  if CurrentPage == "Control" then
    bankStart, bankEnd = 1, outputCount
  else
    local s, e = CurrentPage:match("^Outputs (%d+)-(%d+)$")
    if s then bankStart, bankEnd = tonumber(s), tonumber(e) end
  end

  local labelBankStart, labelBankEnd
  if CurrentPage == "Labels" then
    labelBankStart = 1
    labelBankEnd   = math.max(inputCount, outputCount)
  else
    local s, e = CurrentPage:match("^Labels (%d+)-(%d+)$")
    if s then labelBankStart, labelBankEnd = tonumber(s), tonumber(e) end
  end

  if bankStart then
    --[[ #include "layout/page_control.lua" ]]
  elseif CurrentPage == "Presets" then
    --[[ #include "layout/page_presets.lua" ]]
  elseif labelBankStart then
    --[[ #include "layout/page_labels.lua" ]]
  elseif CurrentPage == "Setup" then
    --[[ #include "layout/page_setup.lua" ]]
  end

  layout["code"] = { PrettyName = "code", Style = "None" }

  return layout, graphics
end

if Controls then
  -- Runtime intentionally empty for debug build.
  -- 1. Wire the "code" pin to a Control Script component in QDS.
  -- 2. Paste runtime code into the Control Script.
  -- 3. Emulate or push to Core — use the PLUGIN's Debug window.
end
