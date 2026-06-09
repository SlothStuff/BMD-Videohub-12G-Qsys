-- Centralized style constants.
-- All colors and visual parameters are defined here.
-- Change values here to restyle the entire plugin UI.

STYLE = {
  -- Canvas backgrounds (dark navy, matching Sweetwater reference palette)
  BgPlugin  = { 12,  14,  16  },
  BgSection = { 22,  25,  29  },
  BgDark    = { 12,  14,  16  },
  BgField   = { 32,  37,  43  },

  -- Borders
  Stroke        = { 66,  76,  88  },
  StrokeAccent  = { 22,  102, 128 },

  -- Text
  FgTitle  = { 235, 240, 244 },
  FgLabel  = { 218, 224, 230 },
  FgDim    = { 175, 185, 194 },

  -- Buttons
  BtnOn    = { 22,  102, 128 },
  BtnOff   = { 52,  58,  66  },
  BtnDanger= { 135, 42,  42  },

  -- Status indicators
  StatusOk    = { 24,  120, 75  },
  StatusWarn  = { 154, 118, 30  },
  StatusFault = { 135, 42,  42  },
  StatusOff   = { 66,  76,  88  },

  -- Meter / bar fills
  MeterLow  = { 24,  120, 75  },
  MeterMid  = { 154, 118, 30  },
  MeterHigh = { 135, 42,  42  },

  -- Accent (teal brand color)
  Accent = { 22, 102, 128 },

  -- Warning banner color (amber)
  Warning = { 220, 160, 30 },

  -- Corner radii (minimum values; increase per design)
  RadiusBtn   = 5,  -- all buttons
  RadiusBox   = 4,  -- section groupboxes
  RadiusField = 2,  -- text fields and meters
}
