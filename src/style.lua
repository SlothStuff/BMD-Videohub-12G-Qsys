-- Centralized style constants.
-- Q-SYS renders colors with an inverted brightness scale (0 = white, 255 = black).
-- Every RGB value below is pre-inverted: displayed color = (255-R, 255-G, 255-B).
-- The intended display appearance is noted in the inline comments.

STYLE = {
  -- Canvas backgrounds (displayed: dark navy)
  BgPlugin  = { 243, 241, 239 },  -- displayed as ~black    (12, 14, 16)
  BgSection = { 233, 230, 226 },  -- displayed as dark navy (22, 25, 29)
  BgDark    = { 243, 241, 239 },
  BgField   = { 223, 218, 212 },  -- displayed as dark field (32, 37, 43)

  -- Borders
  Stroke        = { 189, 179, 167 },  -- displayed as mid border  (66,  76,  88)
  StrokeAccent  = { 233, 153, 127 },  -- displayed as teal accent (22, 102, 128)

  -- Text (displayed: light on dark)
  FgTitle  = { 20,  15,  11  },  -- displayed as near-white  (235, 240, 244)
  FgLabel  = { 37,  31,  25  },  -- displayed as light gray  (218, 224, 230)
  FgDim    = { 80,  70,  61  },  -- displayed as dimmed gray (175, 185, 194)

  -- Buttons
  BtnOn    = { 233, 153, 127 },  -- displayed as teal     (22, 102, 128)
  BtnOff   = { 203, 197, 189 },  -- displayed as dark gray (52,  58,  66)
  BtnDanger= { 120, 213, 213 },  -- displayed as dark red  (135, 42,  42)

  -- Status indicators
  StatusOk    = { 231, 135, 180 },  -- displayed as green (24, 120,  75)
  StatusWarn  = { 101, 137, 225 },  -- displayed as amber (154, 118, 30)
  StatusFault = { 120, 213, 213 },  -- displayed as red   (135,  42,  42)
  StatusOff   = { 189, 179, 167 },  -- displayed as gray   (66,  76,  88)

  -- Meter / bar fills
  MeterLow  = { 231, 135, 180 },  -- displayed as green
  MeterMid  = { 101, 137, 225 },  -- displayed as amber
  MeterHigh = { 120, 213, 213 },  -- displayed as red

  -- Accent (displayed: teal brand color)
  Accent = { 233, 153, 127 },  -- displayed as teal (22, 102, 128)

  -- Warning banner (displayed: amber)
  Warning = { 35, 95, 225 },  -- displayed as amber (220, 160, 30)

  -- Corner radii
  RadiusBtn   = 5,
  RadiusBox   = 4,
  RadiusField = 2,
}
