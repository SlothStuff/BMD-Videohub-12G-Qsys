-- page_presets.lua
-- Included inside GetControlLayout(props)

table.insert(graphics, {
  Type="GroupBox", Text="Presets",
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
  Color       = STYLE.BgSection,
  TextColor   = STYLE.FgLabel,
  FontSize    = 8,
  IsBold      = true,
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

local presetsBoxH = 8 * 38 + 24
table.insert(graphics, {
  Type="GroupBox", Text="Presets",
  Position={LAYOUT.Margin, LAYOUT.HeaderH + 4},
  Size={LAYOUT.W - LAYOUT.Margin*2, presetsBoxH},
  Fill=STYLE.BgSection, StrokeColor=STYLE.Stroke, StrokeWidth=1,
  CornerRadius=STYLE.RadiusBox, Font="Roboto", FontSize=10, IsBold=true, Color=STYLE.FgTitle
})

for i = 1, 8 do
  local rowY = LAYOUT.HeaderH + 4 + 16 + (i - 1) * 38

  table.insert(graphics, {
    Type="Label", Text=tostring(i),
    Position={16, rowY}, Size={20, 26},
    Color=STYLE.FgDim, FontSize=10, TextAlign=3
  })

  layout["Preset Name " .. i] = {
    PrettyName="Presets~Preset " .. i .. " Name",
    Style="Text",
    Position={42, rowY}, Size={340, 26}
  }

  layout["Preset Save " .. i] = {
    PrettyName="Presets~Preset " .. i .. " Save",
    Style="Button", ButtonStyle="Trigger",
    Legend="SAVE",
    Color=STYLE.BtnOff, CornerRadius=STYLE.RadiusBtn,
    Position={392, rowY}, Size={70, 26}
  }

  layout["Preset Load " .. i] = {
    PrettyName="Presets~Preset " .. i .. " Load",
    Style="Button", ButtonStyle="Trigger",
    Legend="LOAD",
    Color=STYLE.Accent, CornerRadius=STYLE.RadiusBtn,
    Position={470, rowY}, Size={70, 26}
  }
end
