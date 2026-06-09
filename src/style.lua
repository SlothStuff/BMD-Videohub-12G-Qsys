-- Centralized style constants.
-- All colors and visual parameters are defined here.
-- Change values here to restyle the entire plugin UI.

STYLE = {
  -- Canvas backgrounds
  BgPlugin  = { 40,  40,  40  },
  BgSection = { 50,  50,  50  },
  BgDark    = { 30,  30,  30  },
  BgField   = { 60,  60,  60  },

  -- Borders
  Stroke        = { 80,  80,  80  },
  StrokeAccent  = { 0,   134, 214 },

  -- Text
  FgTitle  = { 200, 200, 200 },
  FgLabel  = { 180, 180, 180 },
  FgDim    = { 120, 120, 120 },

  -- Buttons
  BtnOn    = { 0,   134, 214 },
  BtnOff   = { 70,  70,  70  },
  BtnDanger= { 200, 50,  50  },

  -- Status indicators
  StatusOk    = { 0,   180, 0   },
  StatusWarn  = { 220, 160, 0   },
  StatusFault = { 200, 50,  50  },
  StatusOff   = { 80,  80,  80  },

  -- Meter / bar fills
  MeterLow  = { 0,   180, 0   },
  MeterMid  = { 220, 160, 0   },
  MeterHigh = { 200, 50,  50  },

  -- Accent (brand color)
  Accent = { 0, 134, 214 },

  -- Corner radii (minimum values; increase per design)
  RadiusBtn   = 5,  -- all buttons
  RadiusBox   = 4,  -- section groupboxes
  RadiusField = 2,  -- text fields and meters
}
