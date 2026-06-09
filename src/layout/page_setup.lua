-- Setup page layout.
-- Network configuration is displayed as editable text boxes, not properties.
-- Operators can change the target IP, port, or poll rate while the system is live
-- without pushing a new design file.

-- Header GroupBox
table.insert(graphics, {
  Type         = "GroupBox",
  Text         = "Connection Setup",
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

-- ConnectionStatus (top-right, full-text status — kept as-is per user preference)
layout["ConnectionStatus"] = {
  PrettyName = "Status~Connection Status",
  Style      = "Text",
  IsReadOnly = true,
  Position   = { LAYOUT.W - LAYOUT.Margin - LAYOUT.FieldW, LAYOUT.Margin + 20 },
  Size       = { LAYOUT.FieldW, LAYOUT.ControlH }
}

-- Model mismatch warning banner (transparent overlay, amber text, centered in header)
layout["ModelMismatch"] = {
  PrettyName  = "Status~Model Mismatch",
  Style       = "Text",
  IsReadOnly  = true,
  Position    = { LAYOUT.Margin + 4, LAYOUT.Margin + 20 },
  Size        = { LAYOUT.W - LAYOUT.Margin * 2 - LAYOUT.FieldW - 12, 20 },
  Color       = { 255, 255, 255, 0 },
  TextColor   = STYLE.Warning,
  FontSize    = 9,
  IsBold      = true,
  StrokeWidth = 0,
  HTextAlign  = "Center"
}

-- Settings GroupBox
table.insert(graphics, {
  Type         = "GroupBox",
  Text         = "Settings",
  Position     = { LAYOUT.Margin, LAYOUT.HeaderH + 4 },
  Size         = { LAYOUT.W - LAYOUT.Margin * 2, 6 * LAYOUT.RowSpacing + 20 },
  Fill         = STYLE.BgSection,
  StrokeColor  = STYLE.Stroke,
  StrokeWidth  = 1,
  CornerRadius = STYLE.RadiusBox,
  Font         = "Roboto",
  FontSize     = 10,
  IsBold       = true,
  Color        = STYLE.FgTitle
})

local y = LAYOUT.HeaderH + 28

-- Row 1 — IP Address
table.insert(graphics, {
  Type       = "Label",
  Text       = "IP Address",
  Position   = { LAYOUT.Col1, y },
  Size       = { LAYOUT.LabelW, LAYOUT.ControlH },
  Color      = STYLE.FgLabel,
  FontSize   = 10,
  HTextAlign = "Right"
})
layout["IPAddress"] = {
  PrettyName = "Setup~IP Address",
  Style      = "Text",
  Position   = { LAYOUT.Col2, y },
  Size       = { LAYOUT.FieldW, LAYOUT.ControlH }
}

y = y + LAYOUT.RowSpacing

-- Row 2 — Port
table.insert(graphics, {
  Type       = "Label",
  Text       = "Port",
  Position   = { LAYOUT.Col1, y },
  Size       = { LAYOUT.LabelW, LAYOUT.ControlH },
  Color      = STYLE.FgLabel,
  FontSize   = 10,
  HTextAlign = "Right"
})
layout["Port"] = {
  PrettyName = "Setup~Port",
  Style      = "Text",
  IsReadOnly = true,
  Position   = { LAYOUT.Col2, y },
  Size       = { 80, LAYOUT.ControlH }
}

y = y + LAYOUT.RowSpacing

-- Row 3 — Poll Rate
table.insert(graphics, {
  Type       = "Label",
  Text       = "Poll Rate (s)",
  Position   = { LAYOUT.Col1, y },
  Size       = { LAYOUT.LabelW, LAYOUT.ControlH },
  Color      = STYLE.FgLabel,
  FontSize   = 10,
  HTextAlign = "Right"
})
layout["PollRate"] = {
  PrettyName = "Setup~Poll Rate",
  Style      = "Text",
  Position   = { LAYOUT.Col2, y },
  Size       = { 60, LAYOUT.ControlH }
}

y = y + LAYOUT.RowSpacing

-- Row 4 — Reconnect (no label)
layout["Reconnect"] = {
  PrettyName   = "Setup~Reconnect",
  Style        = "Button",
  ButtonStyle  = "Trigger",
  Legend       = "RECONNECT",
  Position     = { LAYOUT.Col2, y },
  Size         = { 120, LAYOUT.ControlH },
  Color        = STYLE.BtnOff,
  CornerRadius = STYLE.RadiusBtn
}

y = y + LAYOUT.RowSpacing

-- Row 5 — Device Info (read-only)
table.insert(graphics, {
  Type       = "Label",
  Text       = "Device Info",
  Position   = { LAYOUT.Col1, y },
  Size       = { LAYOUT.LabelW, LAYOUT.ControlH },
  Color      = STYLE.FgLabel,
  FontSize   = 10,
  HTextAlign = "Right"
})
layout["DeviceInfo"] = {
  PrettyName = "Status~Device Info",
  Style      = "Text",
  IsReadOnly = true,
  Position   = { LAYOUT.Col2, y },
  Size       = { LAYOUT.FieldW, LAYOUT.ControlH }
}
