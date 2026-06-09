-- Videohub12G page definitions.
-- Pages are dynamic: large models get multiple routing and label pages (banks of 20).

MODEL_IO = {
  ["Videohub Mini 4x2 12G"]  = { inputs = 4,  outputs = 2  },
  ["Videohub Mini 6x2 12G"]  = { inputs = 6,  outputs = 2  },
  ["Videohub Mini 8x4 12G"]  = { inputs = 8,  outputs = 4  },
  ["Videohub 10x10 12G"]     = { inputs = 10, outputs = 10 },
  ["Videohub 20x20 12G"]     = { inputs = 20, outputs = 20 },
  ["Videohub 40x40 12G"]     = { inputs = 40, outputs = 40 },
  ["Videohub 80x80 12G"]     = { inputs = 80,  outputs = 80  },
  ["Videohub 120x120 12G"]   = { inputs = 120, outputs = 120 },
}
BANK_SIZE = 20  -- rows per routing or labels page

-- Shared helper: called by both GetPages and GetControlLayout.
function BuildPageList(props)
  local modelIO     = MODEL_IO[props["Videohub Model"].Value] or MODEL_IO["Videohub 20x20 12G"]
  local outputCount = modelIO.outputs
  local inputCount  = modelIO.inputs
  local pages       = {}

  -- Routing pages: one "Control" page for <= BANK_SIZE outputs;
  -- multiple "Outputs S-E" pages for larger models.
  if outputCount <= BANK_SIZE then
    table.insert(pages, { name = "Control" })
  else
    local numBanks = math.ceil(outputCount / BANK_SIZE)
    for i = 1, numBanks do
      local s = (i - 1) * BANK_SIZE + 1
      local e = math.min(i * BANK_SIZE, outputCount)
      table.insert(pages, { name = string.format("Outputs %d-%d", s, e) })
    end
  end

  table.insert(pages, { name = "Presets" })

  -- Label pages: one "Labels" page when max(inputs, outputs) <= BANK_SIZE;
  -- multiple "Labels S-E" pages otherwise.
  local labelMax = math.max(inputCount, outputCount)
  if labelMax <= BANK_SIZE then
    table.insert(pages, { name = "Labels" })
  else
    local numLabelBanks = math.ceil(labelMax / BANK_SIZE)
    for i = 1, numLabelBanks do
      local s = (i - 1) * BANK_SIZE + 1
      local e = math.min(i * BANK_SIZE, labelMax)
      table.insert(pages, { name = string.format("Labels %d-%d", s, e) })
    end
  end

  table.insert(pages, { name = "Setup" })
  table.insert(pages, { name = "Diagnostics" })
  return pages
end

function GetPages(props)
  return BuildPageList(props)
end
