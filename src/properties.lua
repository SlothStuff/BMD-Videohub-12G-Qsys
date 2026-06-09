-- Design-time properties for the Videohub 12G plugin.

function GetProperties()
  local props = {}

  table.insert(props, {
    Name    = "Videohub Model",
    Type    = "enum",
    Choices = {
      "Videohub Mini 4x2 12G",
      "Videohub Mini 6x2 12G",
      "Videohub Mini 8x4 12G",
      "Videohub 10x10 12G",
      "Videohub 20x20 12G",
      "Videohub 40x40 12G",
      "Videohub 80x80 12G",
      "Videohub 120x120 12G",
    },
    Value = "Videohub 20x20 12G",
  })

  -- When true, lock/unlock controls and pins are created
  table.insert(props, {
    Name  = "Lock Controls Enabled",
    Type  = "boolean",
    Value = false,
  })

  -- When true, route changes stage locally until TAKE is pressed
  table.insert(props, {
    Name  = "Use Take",
    Type  = "boolean",
    Value = false,
  })

  -- When false, label controls are read-only on the Labels page
  table.insert(props, {
    Name  = "Allow Label Editing",
    Type  = "boolean",
    Value = true,
  })

  table.insert(props, {
    Name    = "Debug Print",
    Type    = "enum",
    Choices = { "None", "Tx/Rx", "Tx", "Rx", "All" },
    Value   = "None",
  })

  return props
end

function RectifyProperties(props)
  return props
end
