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

layout["ConnectionStatus"] = {
  PrettyName="Status~Connection", Style="Status",
  Position={LAYOUT.W - LAYOUT.Margin - 24, LAYOUT.Margin + 4}, Size={20, 20}
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
