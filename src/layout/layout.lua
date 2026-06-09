--[[ #include "constants.lua" ]]

function GetControlLayout(props)
  local layout   = {}
  local graphics = {}

  -- Resolve current page name from the dynamic page list
  local pageList    = BuildPageList(props)
  local CurrentPage = pageList[props["page_index"].Value].name

  -- I/O counts and feature flags for page layout files
  local modelIO     = MODEL_IO[props["Videohub Model"].Value] or MODEL_IO["Videohub 20x20 12G"]
  local inputCount  = modelIO.inputs
  local outputCount = modelIO.outputs
  local lockEnabled = props["Lock Controls Enabled"].Value
  local useTake     = props["Use Take"].Value
  local labelEdit   = props["Allow Label Editing"].Value

  -- Full-canvas background
  table.insert(graphics, {
    Type         = "GroupBox",
    Position     = { 0, 0 },
    Size         = { LAYOUT.W, LAYOUT.H },
    Fill         = STYLE.BgPlugin,
    StrokeColor  = STYLE.BgPlugin,
    StrokeWidth  = 0,
    CornerRadius = 0
  })

  -- Determine routing bank range (used by page_control.lua)
  local bankStart, bankEnd
  if CurrentPage == "Control" then
    bankStart, bankEnd = 1, outputCount
  else
    local s, e = CurrentPage:match("^Outputs (%d+)-(%d+)$")
    if s then
      bankStart = tonumber(s)
      bankEnd   = tonumber(e)
    end
  end

  -- Determine label bank range (used by page_labels.lua)
  local labelBankStart, labelBankEnd
  if CurrentPage == "Labels" then
    labelBankStart = 1
    labelBankEnd   = math.max(inputCount, outputCount)
  else
    local s, e = CurrentPage:match("^Labels (%d+)-(%d+)$")
    if s then
      labelBankStart = tonumber(s)
      labelBankEnd   = tonumber(e)
    end
  end

  -- Page dispatch
  if bankStart then
    --[[ #include "page_control.lua" ]]
  elseif CurrentPage == "Presets" then
    --[[ #include "page_presets.lua" ]]
  elseif labelBankStart then
    --[[ #include "page_labels.lua" ]]
  elseif CurrentPage == "Setup" then
    --[[ #include "page_setup.lua" ]]
  elseif CurrentPage == "Diagnostics" then
    --[[ #include "page_diagnostics.lua" ]]
  end

  return layout, graphics
end
