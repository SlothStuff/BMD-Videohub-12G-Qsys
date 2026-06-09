-- page_labels.lua
-- Included inside GetControlLayout(props)

local inputsTitle  = labelEdit and "INPUTS"  or "INPUTS (read-only)"
local outputsTitle = labelEdit and "OUTPUTS" or "OUTPUTS (read-only)"

table.insert(graphics, {
  Type="GroupBox", Text="Labels",
  Position={LAYOUT.Margin, LAYOUT.Margin},
  Size={LAYOUT.W - LAYOUT.Margin*2, LAYOUT.HeaderH - LAYOUT.Margin},
  Fill=STYLE.BgSection, StrokeColor=STYLE.Stroke, StrokeWidth=1,
  CornerRadius=STYLE.RadiusBox, Font="Roboto", FontSize=10, IsBold=true, Color=STYLE.FgTitle
})

layout["ConnStatusShort"] = {
  PrettyName  = "Status~Connection",
  Style       = "Text",
  IsReadOnly  = true,
  Position    = { LAYOUT.W - LAYOUT.Margin - 26, LAYOUT.Margin + 20 },
  Size        = { 22, 20 },
  Color       = STYLE.StatusOff,
  TextColor   = STYLE.FgLabel,
  FontSize    = 8,
  IsBold      = true,
  StrokeWidth = 0,
  HTextAlign  = "Center"
}

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

local bankRows  = labelBankEnd - labelBankStart + 1
local colBoxH   = bankRows * 28 + 24
local colBoxY   = LAYOUT.HeaderH + 4

table.insert(graphics, {
  Type="GroupBox", Text=inputsTitle,
  Position={LAYOUT.LBL_LeftX, colBoxY},
  Size={LAYOUT.LBL_LeftW, colBoxH},
  Fill=STYLE.BgSection, StrokeColor=STYLE.Stroke, StrokeWidth=1,
  CornerRadius=STYLE.RadiusBox, Font="Roboto", FontSize=10, IsBold=true, Color=STYLE.FgTitle
})

table.insert(graphics, {
  Type="GroupBox", Text=outputsTitle,
  Position={LAYOUT.LBL_RightX, colBoxY},
  Size={LAYOUT.LBL_RightW, colBoxH},
  Fill=STYLE.BgSection, StrokeColor=STYLE.Stroke, StrokeWidth=1,
  CornerRadius=STYLE.RadiusBox, Font="Roboto", FontSize=10, IsBold=true, Color=STYLE.FgTitle
})

-- Disclaimer shown only when label editing is enabled
if labelEdit then
  local disclaimerY = colBoxY + colBoxH + 6
  table.insert(graphics, {
    Type       = "Label",
    Text       = "\xe2\x9a\xa0  Changes to labels are written directly to the Videohub device.",
    Position   = { LAYOUT.Margin, disclaimerY },
    Size       = { LAYOUT.W - LAYOUT.Margin * 2, 14 },
    Color      = STYLE.Warning,
    FontSize   = 9,
    IsBold     = false,
    HTextAlign = "Center"
  })
end

for i = labelBankStart, labelBankEnd do
  local rowY = colBoxY + 24 + (i - labelBankStart) * 28

  if i <= inputCount then
    table.insert(graphics, {
      Type="Label", Text=tostring(i),
      Position={LAYOUT.LBL_LeftX + 4, rowY}, Size={24, 24},
      Color=STYLE.FgDim, FontSize=10, TextAlign=3
    })

    layout["Input Label " .. i] = {
      PrettyName="Labels~Input " .. i,
      Style="Text", IsReadOnly=(not labelEdit),
      Position={LAYOUT.LBL_LeftX + 32, rowY}, Size={LAYOUT.LBL_FieldW, 24}
    }
  end

  if i <= outputCount then
    table.insert(graphics, {
      Type="Label", Text=tostring(i),
      Position={LAYOUT.LBL_RightX + 4, rowY}, Size={24, 24},
      Color=STYLE.FgDim, FontSize=10, TextAlign=3
    })

    layout["Output Label " .. i] = {
      PrettyName="Labels~Output " .. i,
      Style="Text", IsReadOnly=(not labelEdit),
      Position={LAYOUT.LBL_RightX + 32, rowY}, Size={LAYOUT.LBL_FieldW, 24}
    }
  end
end
