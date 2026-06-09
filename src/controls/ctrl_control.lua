-- Control definitions for the Videohub 12G plugin.
-- This file is #included inside GetControls(props); local ctrls = {} and
-- return ctrls are provided by the caller.

-- ─── Model I/O map ────────────────────────────────────────────────────────────
local MODEL_IO = {
  ["Videohub Mini 4x2 12G"]  = { inputs = 4,  outputs = 2  },
  ["Videohub Mini 6x2 12G"]  = { inputs = 6,  outputs = 2  },
  ["Videohub Mini 8x4 12G"]  = { inputs = 8,  outputs = 4  },
  ["Videohub 10x10 12G"]     = { inputs = 10, outputs = 10 },
  ["Videohub 20x20 12G"]     = { inputs = 20, outputs = 20 },
  ["Videohub 40x40 12G"]     = { inputs = 40, outputs = 40 },
  ["Videohub 80x80 12G"]     = { inputs = 80,  outputs = 80  },
  ["Videohub 120x120 12G"]   = { inputs = 120, outputs = 120 },
}
local modelKey    = props["Videohub Model"].Value
local modelIO     = MODEL_IO[modelKey] or MODEL_IO["Videohub 20x20 12G"]
local inputCount  = modelIO.inputs
local outputCount = modelIO.outputs
local lockEnabled = props["Lock Controls Enabled"].Value
local useTake     = props["Use Take"].Value

-- ─── Status ───────────────────────────────────────────────────────────────────
table.insert(ctrls, {
  Name          = "ConnectionStatus",
  ControlType   = "Indicator",
  IndicatorType = "Status",
  UserPin       = true,
  PinStyle      = "Output",
  Count         = 1,
})

table.insert(ctrls, {
  Name        = "DeviceInfo",
  ControlType = "Text",
  UserPin     = true,
  PinStyle    = "Output",
  Count       = 1,
})

-- ─── Setup ────────────────────────────────────────────────────────────────────
table.insert(ctrls, {
  Name        = "IPAddress",
  ControlType = "Text",
  UserPin     = true,
  PinStyle    = "Both",
  Count       = 1,
})

table.insert(ctrls, {
  Name        = "Port",
  ControlType = "Text",
  UserPin     = true,
  PinStyle    = "Output",
  Count       = 1,
})

table.insert(ctrls, {
  Name        = "PollRate",
  ControlType = "Text",
  UserPin     = true,
  PinStyle    = "Both",
  Count       = 1,
})

table.insert(ctrls, {
  Name        = "Reconnect",
  ControlType = "Button",
  ButtonType  = "Trigger",
  UserPin     = true,
  PinStyle    = "Input",
  Count       = 1,
})

-- ─── Routing ──────────────────────────────────────────────────────────────────
table.insert(ctrls, {
  Name        = "Output Routing",
  ControlType = "Text",
  UserPin     = true,
  PinStyle    = "Both",
  Count       = outputCount,
})

-- Count > 1 access rule: Controls["Output Routing"][1] .. Controls["Output Routing"][N]
-- NOT Controls["Output Routing 1"] — that string-key form is nil in the Q-SYS runtime.
-- Same applies to Route Display, Input Label, Output Label, Lock/Unlock Output, etc.

-- ComboBox showing input label names; selecting routes that output by name
table.insert(ctrls, {
  Name        = "Route Display",
  ControlType = "Text",
  TextBoxType = "ComboBox",
  UserPin     = false,
  PinStyle    = "None",
  Count       = outputCount,
})

-- ─── Take ─────────────────────────────────────────────────────────────────────
if useTake == true then
  table.insert(ctrls, {
    Name        = "Take",
    ControlType = "Button",
    ButtonType  = "Trigger",
    UserPin     = true,
    PinStyle    = "Input",
    Count       = 1,
  })

  table.insert(ctrls, {
    Name          = "Take Pending",
    ControlType   = "Indicator",
    IndicatorType = "Led",
    UserPin       = true,
    PinStyle      = "Output",
    Count         = 1,
  })
end

-- ─── Locks ────────────────────────────────────────────────────────────────────
if lockEnabled == true then
  table.insert(ctrls, {
    Name          = "Output Lock State",
    ControlType   = "Indicator",
    IndicatorType = "Led",
    UserPin       = true,
    PinStyle      = "Output",
    Count         = outputCount,
  })

  table.insert(ctrls, {
    Name        = "Lock Output",
    ControlType = "Button",
    ButtonType  = "Trigger",
    UserPin     = true,
    PinStyle    = "Input",
    Count       = outputCount,
  })

  table.insert(ctrls, {
    Name        = "Unlock Output",
    ControlType = "Button",
    ButtonType  = "Trigger",
    UserPin     = true,
    PinStyle    = "Input",
    Count       = outputCount,
  })
end

-- ─── Labels ───────────────────────────────────────────────────────────────────
table.insert(ctrls, {
  Name        = "Input Label",
  ControlType = "Text",
  UserPin     = true,
  PinStyle    = "Both",
  Count       = inputCount,
})

table.insert(ctrls, {
  Name        = "Output Label",
  ControlType = "Text",
  UserPin     = true,
  PinStyle    = "Both",
  Count       = outputCount,
})

-- ─── Presets ──────────────────────────────────────────────────────────────────
table.insert(ctrls, {
  Name        = "Preset Name",
  ControlType = "Text",
  UserPin     = true,
  PinStyle    = "Both",
  Count       = 8,
})

table.insert(ctrls, {
  Name        = "Preset Save",
  ControlType = "Button",
  ButtonType  = "Trigger",
  UserPin     = true,
  PinStyle    = "Input",
  Count       = 8,
})

table.insert(ctrls, {
  Name        = "Preset Load",
  ControlType = "Button",
  ButtonType  = "Trigger",
  UserPin     = true,
  PinStyle    = "Input",
  Count       = 8,
})

-- Hidden; stores CSV-serialized route data for preset recall
table.insert(ctrls, {
  Name        = "Preset Data",
  ControlType = "Text",
  UserPin     = false,
  PinStyle    = "None",
  Count       = 8,
})

-- ─── Status display ───────────────────────────────────────────────────────────
-- Transparent banner in page header; set by runtime when model ≠ device I/O
table.insert(ctrls, {
  Name        = "ModelMismatch",
  ControlType = "Text",
  UserPin     = false,
  PinStyle    = "None",
  Count       = 1,
})

-- Abbreviated connection status for the small 20×20 indicator on routing/presets/labels pages
table.insert(ctrls, {
  Name        = "ConnStatusShort",
  ControlType = "Text",
  UserPin     = false,
  PinStyle    = "None",
  Count       = 1,
})

-- ─── Diagnostics ──────────────────────────────────────────────────────────────
table.insert(ctrls, {
  Name        = "LastTx",
  ControlType = "Text",
  UserPin     = true,
  PinStyle    = "Output",
  Count       = 1,
})

table.insert(ctrls, {
  Name        = "LastRx",
  ControlType = "Text",
  UserPin     = true,
  PinStyle    = "Output",
  Count       = 1,
})
