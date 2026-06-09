-- Layout dimension constants for Videohub12G.
-- 640x720 accommodates the 80x80 routing matrix (20 rows/bank) plus header, bank nav, and Take row.

LAYOUT = {
  W          = 640,   -- canvas width (pixels)
  H          = 720,   -- canvas height (pixels)
  Margin     = 12,    -- outer margin on all sides
  ControlH   = 24,    -- standard control row height
  RowSpacing = 26,    -- tight pitch for routing matrix rows
  HeaderH    = 46,    -- page header GroupBox height
  BankNavH   = 32,    -- bank navigation row height
  TakeRowH   = 34,    -- Take button row height
  RowH       = 24,    -- routing/label row content height

  -- Standard two-column label+field layout (used on Setup page)
  Col1   = 12,
  Col2   = 160,
  LabelW = 140,
  FieldW = 220,

  -- Routing matrix column positions (locks disabled)
  R_Num     = 12,    -- output number label x
  R_NumW    = 36,
  R_OutName = 50,    -- output label text x
  R_OutNameW= 158,
  R_InNum   = 212,   -- routing control (ComboBox or Text) x
  R_InNumW  = 60,
  R_InName  = 276,   -- route display (input label name) x
  R_InNameW = 340,

  -- Routing matrix column positions (locks enabled)
  RL_Num     = 12,
  RL_NumW    = 36,
  RL_OutName = 50,
  RL_OutNameW= 148,
  RL_InNum   = 202,
  RL_InNumW  = 54,
  RL_InName  = 260,
  RL_InNameW = 198,
  RL_Lock    = 462,
  RL_LockW   = 80,   -- lock state LED + lock/unlock buttons total

  -- Labels page two-column split
  LBL_LeftX  = 12,
  LBL_LeftW  = 298,
  LBL_RightX = 326,
  LBL_RightW = 302,
  LBL_FieldW = 220,
}
