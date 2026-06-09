-- Diagnostics / About page.
-- Shows the plugin logo (if configured), version info, description,
-- and live TX/RX diagnostics for rapid debugging.
-- LogoImage is defined in info.lua. Set it to "" to show a text-only page.

-- Main GroupBox
table.insert(graphics, {
  Type         = "GroupBox",
  Text         = "Diagnostics",
  Position     = { LAYOUT.Margin, LAYOUT.Margin },
  Size         = { LAYOUT.W - LAYOUT.Margin * 2, LAYOUT.H - LAYOUT.Margin * 2 },
  Fill         = STYLE.BgSection,
  StrokeColor  = STYLE.Stroke,
  StrokeWidth  = 1,
  CornerRadius = STYLE.RadiusBox,
  Font         = "Roboto",
  FontSize     = 10,
  IsBold       = true,
  Color        = STYLE.FgTitle
})

-- Model mismatch warning banner
layout["ModelMismatch"] = {
  PrettyName  = "Status~Model Mismatch",
  Style       = "Text",
  IsReadOnly  = true,
  Position    = { LAYOUT.Margin + 4, LAYOUT.Margin + 20 },
  Size        = { LAYOUT.W - LAYOUT.Margin * 2 - 8, 14 },
  Color       = { 255, 255, 255, 0 },
  TextColor   = STYLE.Warning,
  FontSize    = 9,
  IsBold      = true,
  StrokeWidth = 0,
  HTextAlign  = "Center"
}

-- Logo (centered horizontally; shown only when LogoImage contains base64 PNG data)
if LogoImage ~= "" then
  table.insert(graphics, {
    Type     = "Image",
    Image    = LogoImage,
    Position = { math.floor((LAYOUT.W - 200) / 2), LAYOUT.Margin + 50 },
    Size     = { 200, 50 }
  })
end

-- Version badge (top-right)
table.insert(graphics, {
  Type       = "Label",
  Text       = "v" .. PluginInfo.Version,
  Position   = { LAYOUT.W - 80, LAYOUT.Margin + 20 },
  Size       = { 66, 16 },
  Color      = STYLE.FgDim,
  FontSize   = 9,
  HTextAlign = "Right"
})

-- Description
table.insert(graphics, {
  Type       = "Label",
  Text       = PluginInfo.Description,
  Position   = { LAYOUT.Margin + 4, LAYOUT.Margin + 105 },
  Size       = { LAYOUT.W - LAYOUT.Margin * 2 - 8, 16 },
  Color      = STYLE.FgDim,
  FontSize   = 9,
  HTextAlign = "Left"
})

-- Separator line
table.insert(graphics, {
  Type        = "GroupBox",
  Position    = { LAYOUT.Margin + 4, LAYOUT.Margin + 120 },
  Size        = { LAYOUT.W - LAYOUT.Margin * 2 - 8, 1 },
  Fill        = STYLE.Stroke,
  StrokeWidth = 0
})

local dy = LAYOUT.Margin + 150

-- Row 1 — Last TX
table.insert(graphics, {
  Type       = "Label",
  Text       = "Last TX",
  Position   = { LAYOUT.Col1, dy },
  Size       = { LAYOUT.LabelW, LAYOUT.ControlH },
  Color      = STYLE.FgDim,
  FontSize   = 9,
  HTextAlign = "Right"
})
layout["LastTx"] = {
  PrettyName = "Diagnostics~Last TX",
  Style      = "Text",
  IsReadOnly = true,
  Position   = { LAYOUT.Col2, dy },
  Size       = { LAYOUT.FieldW, LAYOUT.ControlH }
}

dy = dy + LAYOUT.RowSpacing

-- Row 2 — Last RX
table.insert(graphics, {
  Type       = "Label",
  Text       = "Last RX",
  Position   = { LAYOUT.Col1, dy },
  Size       = { LAYOUT.LabelW, LAYOUT.ControlH },
  Color      = STYLE.FgDim,
  FontSize   = 9,
  HTextAlign = "Right"
})
layout["LastRx"] = {
  PrettyName = "Diagnostics~Last RX",
  Style      = "Text",
  IsReadOnly = true,
  Position   = { LAYOUT.Col2, dy },
  Size       = { LAYOUT.FieldW, LAYOUT.ControlH }
}

dy = dy + LAYOUT.RowSpacing

-- Row 3 — Device Info
table.insert(graphics, {
  Type       = "Label",
  Text       = "Device Info",
  Position   = { LAYOUT.Col1, dy },
  Size       = { LAYOUT.LabelW, LAYOUT.ControlH },
  Color      = STYLE.FgDim,
  FontSize   = 9,
  HTextAlign = "Right"
})
layout["DeviceInfo"] = {
  PrettyName = "Status~Device Info",
  Style      = "Text",
  IsReadOnly = true,
  Position   = { LAYOUT.Col2, dy },
  Size       = { LAYOUT.FieldW, LAYOUT.ControlH }
}
