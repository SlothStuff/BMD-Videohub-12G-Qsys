-- page_control.lua
-- Included inside GetControlLayout(props).
-- Expects: layout, graphics, LAYOUT, STYLE, bankStart, bankEnd,
--          inputCount, outputCount, lockEnabled, useTake

-- ─────────────────────────────────────────────
-- Header GroupBox
-- ─────────────────────────────────────────────
table.insert(graphics, {
  Type         = "GroupBox",
  Text         = "Videohub 12G",
  Position     = { LAYOUT.Margin, LAYOUT.Margin },
  Size         = { LAYOUT.W - LAYOUT.Margin * 2, LAYOUT.HeaderH - LAYOUT.Margin },
  Fill         = STYLE.BgSection,
  StrokeColor  = STYLE.Stroke,
  StrokeWidth  = 1,
  CornerRadius = STYLE.RadiusBox,
  Font         = "Roboto",
  FontSize     = 10,
  IsBold       = true,
  Color        = STYLE.FgTitle
})

-- Abbreviated connection status (top-right of header)
layout["ConnStatusShort"] = {
  PrettyName  = "Status~Connection",
  Style       = "Text",
  IsReadOnly  = true,
  Position    = { LAYOUT.W - LAYOUT.Margin - 26, LAYOUT.Margin + 20 },
  Size        = { 22, 20 },
  Color       = STYLE.BgSection,
  TextColor   = STYLE.FgLabel,
  FontSize    = 8,
  IsBold      = true,
  HTextAlign  = "Center"
}

-- Model mismatch warning banner (transparent overlay, amber text, centered in header)
layout["ModelMismatch"] = {
  PrettyName  = "Status~Model Mismatch",
  Style       = "Text",
  IsReadOnly  = true,
  Position    = { LAYOUT.Margin + 4, LAYOUT.Margin + 20 },
  Size        = { LAYOUT.W - LAYOUT.Margin * 2 - 36, 20 },
  Color       = { 255, 255, 255, 0 },
  TextColor   = STYLE.Warning,
  FontSize    = 9,
  IsBold      = true,
  StrokeWidth = 0,
  HTextAlign  = "Center"
}

-- Page title label (shown when outputs span multiple banks)
local isMultiBank = (bankEnd < outputCount) or (bankStart > 1)
if isMultiBank then
  local titleText = "Outputs " .. bankStart .. "\xE2\x80\x93" .. bankEnd
  local titleW    = 200
  table.insert(graphics, {
    Type         = "Label",
    Text         = titleText,
    Position     = { math.floor((LAYOUT.W - titleW) / 2), LAYOUT.Margin + 55 },
    Size         = { titleW, 20 },
    Color        = STYLE.FgTitle,
    FontSize     = 10,
    IsBold       = true,
    HTextAlign   = "Center"
  })
end

-- ─────────────────────────────────────────────
-- Column header row
-- ─────────────────────────────────────────────
local yColHeader = LAYOUT.HeaderH + 34

-- Select column geometry based on lock mode
local colNum, colNumW, colOut, colOutW, colIn, colInW, colName, colNameW
if lockEnabled then
  colNum   = LAYOUT.RL_Num;   colNumW  = LAYOUT.RL_NumW
  colOut   = LAYOUT.RL_OutName; colOutW = LAYOUT.RL_OutNameW
  colIn    = LAYOUT.RL_InNum;  colInW  = LAYOUT.RL_InNumW
  colName  = LAYOUT.RL_InName; colNameW = LAYOUT.RL_InNameW
else
  colNum   = LAYOUT.R_Num;   colNumW  = LAYOUT.R_NumW
  colOut   = LAYOUT.R_OutName; colOutW = LAYOUT.R_OutNameW
  colIn    = LAYOUT.R_InNum;  colInW  = LAYOUT.R_InNumW
  colName  = LAYOUT.R_InName; colNameW = LAYOUT.R_InNameW
end

local headerLabelStyle = {
  FontSize = 9, IsBold = true, Color = STYLE.FgLabel, HTextAlign = "Center"
}

table.insert(graphics, {
  Type       = "Label", Text = "#",
  Position   = { colNum, yColHeader }, Size = { colNumW, LAYOUT.RowH },
  FontSize   = headerLabelStyle.FontSize, IsBold = headerLabelStyle.IsBold,
  Color      = headerLabelStyle.Color,   HTextAlign = headerLabelStyle.HTextAlign
})

table.insert(graphics, {
  Type       = "Label", Text = "Output Name",
  Position   = { colOut, yColHeader }, Size = { colOutW, LAYOUT.RowH },
  FontSize   = headerLabelStyle.FontSize, IsBold = headerLabelStyle.IsBold,
  Color      = headerLabelStyle.Color,   HTextAlign = headerLabelStyle.HTextAlign
})

table.insert(graphics, {
  Type       = "Label", Text = "IN #",
  Position   = { colIn, yColHeader }, Size = { colInW, LAYOUT.RowH },
  FontSize   = headerLabelStyle.FontSize, IsBold = headerLabelStyle.IsBold,
  Color      = headerLabelStyle.Color,   HTextAlign = headerLabelStyle.HTextAlign
})

table.insert(graphics, {
  Type       = "Label", Text = "Input",
  Position   = { colName, yColHeader }, Size = { colNameW, LAYOUT.RowH },
  FontSize   = headerLabelStyle.FontSize, IsBold = headerLabelStyle.IsBold,
  Color      = headerLabelStyle.Color,   HTextAlign = headerLabelStyle.HTextAlign
})

if lockEnabled then
  table.insert(graphics, {
    Type       = "Label", Text = "Lock",
    Position   = { LAYOUT.RL_Lock, yColHeader }, Size = { LAYOUT.RL_LockW, LAYOUT.RowH },
    FontSize   = headerLabelStyle.FontSize, IsBold = headerLabelStyle.IsBold,
    Color      = headerLabelStyle.Color,   HTextAlign = headerLabelStyle.HTextAlign
  })
end

-- ─────────────────────────────────────────────
-- Routing rows
-- ─────────────────────────────────────────────
local yRowBase = LAYOUT.HeaderH + 4 + LAYOUT.RowH + 34

for i = bankStart, bankEnd do
  local rowIndex = i - bankStart
  local y = yRowBase + rowIndex * LAYOUT.RowSpacing

  -- 1. Output number label (right-aligned, dimmed)
  table.insert(graphics, {
    Type       = "Label",
    Text       = tostring(i),
    Position   = { colNum, y },
    Size       = { colNumW, LAYOUT.RowH },
    Color      = STYLE.FgDim,
    FontSize   = 10,
    HTextAlign = "Center"
  })

  -- 2. Output Label N (read-only text)
  layout["Output Label " .. i] = {
    PrettyName = "Video~Output " .. i .. " Label",
    Style      = "Text",
    IsReadOnly = true,
    Position   = { colOut, y },
    Size       = { colOutW, LAYOUT.RowH }
  }

  -- 3. Output Routing N (always plain text — user types input number)
  layout["Output Routing " .. i] = {
    PrettyName = "Routing~Output " .. i,
    Style      = "Text",
    Position   = { colIn, y },
    Size       = { colInW, LAYOUT.RowH }
  }

  -- 4. Route Display N (ComboBox — select input by label name)
  layout["Route Display " .. i] = {
    PrettyName = "Routing~Output " .. i .. " Input",
    Style      = "ComboBox",
    Position   = { colName, y },
    Size       = { colNameW, LAYOUT.RowH }
  }

  -- 5. Lock controls (only when lockEnabled)
  if lockEnabled then
    local lockX  = LAYOUT.RL_Lock
    local ledW   = 16
    local ledH   = 16
    local ledY   = y + math.floor((LAYOUT.RowH - ledH) / 2)
    local btnH   = 20
    local btnY   = y + math.floor((LAYOUT.RowH - btnH) / 2)
    local lockBtnW   = 38
    local unlockBtnW = 50
    local gap    = 2

    -- LED indicator
    layout["Output Lock State " .. i] = {
      PrettyName = "Lock~Output " .. i .. " Lock State",
      Style      = "Led",
      Position   = { lockX, ledY },
      Size       = { ledW, ledH }
    }

    -- LOCK button
    local lockBtnX = lockX + ledW + gap
    layout["Lock Output " .. i] = {
      PrettyName   = "Lock~Output " .. i .. " Lock",
      Style        = "Button",
      ButtonStyle  = "Trigger",
      Legend       = "LOCK",
      Position     = { lockBtnX, btnY },
      Size         = { lockBtnW, btnH },
      Color        = STYLE.BtnOff,
      CornerRadius = STYLE.RadiusBtn
    }

    -- UNLOCK button
    local unlockBtnX = lockBtnX + lockBtnW + gap
    layout["Unlock Output " .. i] = {
      PrettyName   = "Lock~Output " .. i .. " Unlock",
      Style        = "Button",
      ButtonStyle  = "Trigger",
      Legend       = "UNLOCK",
      Position     = { unlockBtnX, btnY },
      Size         = { unlockBtnW, btnH },
      Color        = STYLE.BtnOff,
      CornerRadius = STYLE.RadiusBtn
    }
  end
end

-- ─────────────────────────────────────────────
-- Take row (only when useTake=true)
-- ─────────────────────────────────────────────
if useTake then
  local rowCount = bankEnd - bankStart + 1
  local yTake    = yRowBase + rowCount * LAYOUT.RowSpacing + 34

  local takeBtnW = 80
  local takeBtnH = LAYOUT.TakeRowH - 6
  local takeBtnX = colNum
  local takeBtnY = yTake + math.floor((LAYOUT.TakeRowH - takeBtnH) / 2)

  layout["Take"] = {
    PrettyName   = "Take~Take",
    Style        = "Button",
    ButtonStyle  = "Trigger",
    Legend       = "TAKE",
    Position     = { takeBtnX, takeBtnY },
    Size         = { takeBtnW, takeBtnH },
    Color        = STYLE.BtnDanger,
    CornerRadius = STYLE.RadiusBtn
  }

  local ledW      = 16
  local ledH      = 16
  local pendingX  = takeBtnX + takeBtnW + 8
  local pendingY  = yTake + math.floor((LAYOUT.TakeRowH - ledH) / 2)
  local labelX    = pendingX + ledW + 4
  local labelW    = 60

  layout["Take Pending"] = {
    PrettyName = "Take~Pending",
    Style      = "Led",
    Position   = { pendingX, pendingY },
    Size       = { ledW, ledH }
  }

  table.insert(graphics, {
    Type       = "Label",
    Text       = "Pending",
    Position   = { labelX, yTake + math.floor((LAYOUT.TakeRowH - 14) / 2) },
    Size       = { labelW, 14 },
    Color      = STYLE.FgLabel,
    FontSize   = 9,
    HTextAlign = "Left"
  })
end
