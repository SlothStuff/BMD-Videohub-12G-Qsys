-- TCP handler for Blackmagic Videohub Ethernet Protocol v2.3.
-- TCP port 9990, text blocks delimited by "\n\n".
-- Protocol indexes are 0-based; all plugin state uses 1-based.

DebugTx = false
DebugRx = false

-- Updates both the Status indicator and the small abbreviated text control
local function rgb2hex(c) return string.format("#%02X%02X%02X", c[1], c[2], c[3]) end
local function invhex(c)  return rgb2hex({ 255-c[1], 255-c[2], 255-c[3] }) end
local STATUS_SHORT = { [0]="OK",                    [1]="C",                      [2]="F",                      [5]="--" }
local STATUS_COLOR = { [0]=invhex(STYLE.StatusOk), [1]=invhex(STYLE.StatusWarn), [2]=invhex(STYLE.StatusFault), [5]=invhex(STYLE.StatusOff) }
local function SetConnectionStatus(val)
  Controls.ConnectionStatus.Value = val
  local short = Controls["ConnStatusShort"]
  if short then
    short.String = STATUS_SHORT[val] or "--"
    short.Color  = STATUS_COLOR[val] or STATUS_COLOR[5]
  end
end

local function ClearMismatch()
  local mm = Controls["ModelMismatch"]
  if mm then mm.String = "" end
end

function SetupDebugPrint()
  local mode = Properties["Debug Print"].Value
  DebugTx = mode == "Tx/Rx" or mode == "Tx" or mode == "All"
  DebugRx = mode == "Tx/Rx" or mode == "Rx" or mode == "All"
end

-- Must be global to prevent garbage collection
socket    = TcpSocket.New()
PollTimer = Timer.New()

socket.ReadTimeout      = 0
socket.WriteTimeout     = 0
socket.ReconnectTimeout = 5

-- Accumulates raw TCP stream; blocks are split on "\n\n"
RecvBuffer = ""

-- Plugin state caches (all 1-based)
InputLabels   = {}  -- [n] = label string for input n
OutputLabels  = {}  -- [n] = label string for output n
CurrentRoutes = {}  -- [outputN] = inputN  (last confirmed by device)
StagedRoutes  = {}  -- [outputN] = inputN  (pending Take; unused when useTake=false)

-- ─────────────────────────────────────────────
-- Send helpers (protocol uses 0-based indexes)
-- ─────────────────────────────────────────────

function Send(cmd)
  if socket.IsConnected then
    if DebugTx then
      local preview = cmd:gsub("\n", "↵")
      Controls.LastTx.String = preview
      print("TX: " .. preview)
    end
    socket:Write(cmd)
  else
    print("[SEND] Not connected — dropped: " .. tostring(cmd):sub(1, 80))
  end
end

function RouteOutput(output1, input1)
  Send(string.format("VIDEO OUTPUT ROUTING:\n%d %d\n\n", output1 - 1, input1 - 1))
end

function LockOutput(output1)
  Send(string.format("VIDEO OUTPUT LOCKS:\n%d O\n\n", output1 - 1))
end

function UnlockOutput(output1)
  Send(string.format("VIDEO OUTPUT LOCKS:\n%d U\n\n", output1 - 1))
end

function ForceUnlockOutput(output1)
  Send(string.format("VIDEO OUTPUT LOCKS:\n%d F\n\n", output1 - 1))
end

-- Videohub protocol uses \n as delimiter; labels must not contain newlines.
-- The protocol also documents a 62-character label limit.
local function SanitizeLabel(label)
  return label:gsub("[\r\n]", " "):sub(1, 62)
end

function SetInputLabel(input1, label)
  Send(string.format("INPUT LABELS:\n%d %s\n\n", input1 - 1, SanitizeLabel(label)))
end

function SetOutputLabel(output1, label)
  Send(string.format("OUTPUT LABELS:\n%d %s\n\n", output1 - 1, SanitizeLabel(label)))
end

-- ─────────────────────────────────────────────
-- Block handlers
-- ─────────────────────────────────────────────

function HandlePreamble(lines)
  for _, line in ipairs(lines) do
    local ver = line:match("^Version: (.+)$")
    if ver then print("[PREAMBLE] Protocol v" .. ver) end
  end
end

function HandleDevice(lines)
  local info = {}
  for _, line in ipairs(lines) do
    local k, v = line:match("^([^:]+): (.+)$")
    if k then info[k] = v end
  end
  local present = info["Device present"]
  if present == "true" then
    local model = info["Model name"]    or "Unknown"
    local ins   = info["Video inputs"]  or "?"
    local outs  = info["Video outputs"] or "?"
    local text  = string.format("%s  %s in / %s out", model, ins, outs)
    Controls.DeviceInfo.String = text
    print("[DEVICE] " .. text)
    -- Model mismatch check against design-time property selection
    local mm = Controls["ModelMismatch"]
    if mm then
      local selectedIO = MODEL_IO[Properties["Videohub Model"].Value]
      local devIn      = tonumber(ins)
      local devOut     = tonumber(outs)
      if selectedIO and devIn and devOut and
         (selectedIO.inputs ~= devIn or selectedIO.outputs ~= devOut) then
        mm.String = string.format(
          "\xe2\x9a\xa0  MODEL MISMATCH  |  Device: %s\xc3\x97%s  Plugin: %s",
          ins, outs, Properties["Videohub Model"].Value)
      else
        mm.String = ""
      end
    end
  else
    local status = present or "unknown"
    Controls.DeviceInfo.String = "Device: " .. status
    print("[DEVICE] Not ready: " .. status)
    ClearMismatch()
  end
end

function RebuildRouteDisplayChoices()
  local inCtrl  = Controls["Input Label"]
  local outCtrl = Controls["Route Display"]
  if not inCtrl or not outCtrl then return end
  local choices = {}
  local i = 1
  while inCtrl[i] do
    choices[i] = InputLabels[i] or ("Input " .. i)
    i = i + 1
  end
  if #choices == 0 then return end
  local j = 1
  while outCtrl[j] do
    outCtrl[j].Choices = choices
    j = j + 1
  end
end

function HandleInputLabels(lines)
  for _, line in ipairs(lines) do
    local idx, label = line:match("^(%d+) (.*)$")
    if idx then
      local input1        = tonumber(idx) + 1
      InputLabels[input1] = label
      local ctrl          = Controls["Input Label"][input1]
      if ctrl then ctrl.String = label end
      -- Refresh Route Display string for every output currently showing this input
      for out1, in1 in pairs(CurrentRoutes) do
        if in1 == input1 then
          local disp = Controls["Route Display"][out1]
          if disp then disp.String = label end
        end
      end
    end
  end
  RebuildRouteDisplayChoices()
end

function HandleOutputLabels(lines)
  for _, line in ipairs(lines) do
    local idx, label = line:match("^(%d+) (.*)$")
    if idx then
      local output1         = tonumber(idx) + 1
      OutputLabels[output1] = label
      local ctrl            = Controls["Output Label"][output1]
      if ctrl then ctrl.String = label end
    end
  end
end

function HandleRouting(lines)
  for _, line in ipairs(lines) do
    local outIdx, inIdx = line:match("^(%d+) (%d+)$")
    if outIdx then
      local output1          = tonumber(outIdx) + 1
      local input1           = tonumber(inIdx)  + 1
      CurrentRoutes[output1] = input1
      local routing = Controls["Output Routing"][output1]
      if routing then routing.String = tostring(input1) end
      local disp = Controls["Route Display"][output1]
      if disp then disp.String = InputLabels[input1] or ("Input " .. input1) end
    end
  end
end

function HandleLocks(lines)
  if not Properties["Lock Controls Enabled"].Value then return end
  for _, line in ipairs(lines) do
    local outIdx, lockChar = line:match("^(%d+) ([UOL])$")
    if outIdx then
      local output1 = tonumber(outIdx) + 1
      local led     = Controls["Output Lock State"][output1]
      if led then
        -- U = unlocked; O = owned by us; L = locked by another
        led.Boolean = (lockChar ~= "U")
      end
    end
  end
end

function HandleAck()
  if DebugRx then print("[ACK]") end
end

function HandleNak()
  print("[NAK] Last command not understood by device")
end

-- ─────────────────────────────────────────────
-- Buffer processing
-- ─────────────────────────────────────────────

function ProcessBlock(block)
  -- Split at first newline to isolate header from body lines
  local eol = block:find("\n", 1, true)
  local header, body
  if eol then
    header = block:sub(1, eol - 1)
    body   = block:sub(eol + 1)
  else
    header = block
    body   = ""
  end

  -- Collect non-empty body lines
  local lines = {}
  for line in body:gmatch("[^\n]+") do
    if line ~= "" then lines[#lines + 1] = line end
  end

  if DebugRx then
    Controls.LastRx.String = header
    print(string.format("RX: %s (%d lines)", header, #lines))
  end

  if     header == "PROTOCOL PREAMBLE:"    then HandlePreamble(lines)
  elseif header == "VIDEOHUB DEVICE:"      then HandleDevice(lines)
  elseif header == "INPUT LABELS:"         then HandleInputLabels(lines)
  elseif header == "OUTPUT LABELS:"        then HandleOutputLabels(lines)
  elseif header == "VIDEO OUTPUT ROUTING:" then HandleRouting(lines)
  elseif header == "VIDEO OUTPUT LOCKS:"   then HandleLocks(lines)
  elseif header == "ACK"                   then HandleAck()
  elseif header == "NAK"                   then HandleNak()
  -- All unrecognized blocks are silently ignored per protocol spec
  end
end

-- Split RecvBuffer on "\n\n" and dispatch each complete block
function ProcessBuffer()
  while true do
    local blockEnd = RecvBuffer:find("\n\n", 1, true)
    if not blockEnd then break end
    local block = RecvBuffer:sub(1, blockEnd - 1)
    RecvBuffer  = RecvBuffer:sub(blockEnd + 2)
    if block ~= "" then ProcessBlock(block) end
  end
end

-- ─────────────────────────────────────────────
-- Socket callbacks
-- ─────────────────────────────────────────────

socket.Connected = function(sock)
  print(string.format("[EVENT] Connected to %s:%s", Controls.IPAddress.String, Controls.Port.String))
  SetConnectionStatus(0)
  RecvBuffer    = ""
  InputLabels   = {}
  OutputLabels  = {}
  CurrentRoutes = {}
  StagedRoutes  = {}
  local rate = math.max(1, tonumber(Controls.PollRate.String) or 3)
  PollTimer:Start(rate)
end

socket.Reconnect = function(sock)
  print("[EVENT] Reconnecting to " .. Controls.IPAddress.String)
  SetConnectionStatus(1)
  ClearMismatch()
  RecvBuffer = ""
end

socket.Closed = function(sock)
  print("[EVENT] Connection closed")
  SetConnectionStatus(2)
  ClearMismatch()
  PollTimer:Stop()
end

socket.Error = function(sock, err)
  print("[EVENT] Socket error: " .. tostring(err))
  SetConnectionStatus(2)
  PollTimer:Stop()
end

socket.Timeout = function(sock)
  print("[EVENT] Socket timeout")
  SetConnectionStatus(1)
  PollTimer:Stop()
end

local MAX_RECV_BUFFER = 65536  -- 64 KB; far more than any valid Videohub response block

socket.Data = function(sock)
  RecvBuffer = RecvBuffer .. sock:Read(sock.BufferLength)
  if #RecvBuffer > MAX_RECV_BUFFER then
    print("[WARN] RecvBuffer overflow — possible rogue device, resetting connection")
    RecvBuffer = ""
    socket:Disconnect()
  else
    ProcessBuffer()
  end
end

PollTimer.EventHandler = function()
  Send("PING:\n\n")
end

-- ─────────────────────────────────────────────
-- Connection management
-- ─────────────────────────────────────────────

function Connect()
  local ip   = Controls.IPAddress.String
  local port = tonumber(Controls.Port.String) or 9990
  if port < 1 or port > 65535 then port = 9990 end
  if ip == "" then
    print("[CONNECT] No IP address configured")
    SetConnectionStatus(5)
    return
  end
  print(string.format("[CONNECT] %s:%d", ip, port))
  SetConnectionStatus(1)
  if socket.IsConnected then socket:Disconnect() end
  socket:Connect(ip, port)
end

Controls.IPAddress.EventHandler = Connect
Controls.Reconnect.EventHandler = Connect

-- ─────────────────────────────────────────────
-- Initialize
-- ─────────────────────────────────────────────

function Initialize()
  print("====================================")
  print(" Videohub 12G v" .. PluginInfo.Version .. " Starting")
  print("====================================")
  SetupDebugPrint()
  print(string.format("[BOOT] Debug mode : %s", Properties["Debug Print"].Value))

  if Controls.IPAddress.String == "" then Controls.IPAddress.String = "192.168.1.1" end
  Controls.Port.String = "9990"
  if Controls.PollRate.String  == "" then Controls.PollRate.String  = "3"           end

  print(string.format("[BOOT] Target     : %s:%s", Controls.IPAddress.String, Controls.Port.String))
  print(string.format("[BOOT] Poll rate  : %ss",   Controls.PollRate.String))
  print(string.format("[BOOT] Use Take   : %s",    tostring(Properties["Use Take"].Value)))
  print(string.format("[BOOT] Lock ctrl  : %s",    tostring(Properties["Lock Controls Enabled"].Value)))

  RebuildRouteDisplayChoices()
  Connect()
end
