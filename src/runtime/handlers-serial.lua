-- Serial (RS-232) handlers.
-- RS-232 has no connection state — use a heartbeat timer to detect loss of communication.
-- The Connected event fires when the port opens regardless of whether a device is wired.
-- Do not set ConnectionStatus to OK until the device sends a valid response.

DebugTx = false
DebugRx = false
DebugFn = false

function SetupDebugPrint()
  local mode = Properties["Debug Print"].Value
  DebugTx = mode == "Tx/Rx" or mode == "Tx" or mode == "All"
  DebugRx = mode == "Tx/Rx" or mode == "Rx" or mode == "All"
  DebugFn = mode == "Function Calls" or mode == "All"
end

-- All objects must be global to prevent garbage collection
MySerialPort     = SerialPorts[1]
PollTimer        = Timer.New()
HeartbeatTimer   = Timer.New()

PollRate         = 5    -- seconds between polls (adjust for device requirements)
HeartbeatTimeout = 30   -- fault if no data received for this many seconds (must be > PollRate)

function Send(cmd)
  if MySerialPort.IsOpen then
    if DebugTx then
      print("TX: " .. tostring(cmd))
      if Controls.LastTx then Controls.LastTx.String = tostring(cmd) end
    end
    MySerialPort:Write(cmd)
  else
    print("[SEND] Port not open — cannot send: " .. tostring(cmd))
  end
end

function ParseResponse(data)
  if DebugRx then
    print("RX: " .. tostring(data))
    if Controls.LastRx then Controls.LastRx.String = tostring(data) end
  end
  Controls.ConnectionStatus.Value = 0   -- first valid data = device confirmed present
  -- TODO: parse device responses here
end

function Heartbeat()
  HeartbeatTimer:Stop()
  HeartbeatTimer:Start(HeartbeatTimeout)
end

HeartbeatTimer.EventHandler = function()
  print("[HEARTBEAT] No data from device — reinitializing")
  Controls.ConnectionStatus.Value = 2
  Initialize()
end

MySerialPort.Connected = function(port)
  print("[EVENT] Serial port connected (device presence unconfirmed)")
  -- Status set to Initializing — will become OK on first valid response
  Controls.ConnectionStatus.Value = 1
  PollTimer:Start(PollRate)
  Heartbeat()
end

MySerialPort.Reconnect = function(port)
  print("[EVENT] Serial port reconnecting")
  Controls.ConnectionStatus.Value = 1
end

MySerialPort.Closed = function(port)
  print("[EVENT] Serial port closed")
  Controls.ConnectionStatus.Value = 2
  PollTimer:Stop()
  HeartbeatTimer:Stop()
end

MySerialPort.Error = function(port, err)
  print("[EVENT] Serial error: " .. tostring(err))
  Controls.ConnectionStatus.Value = 2
  PollTimer:Stop()
  HeartbeatTimer:Stop()
end

MySerialPort.Data = function(port)
  -- Change delimiter to match your device protocol ("\r", "\n", "\r\n", etc.)
  local data = port:ReadLine(SerialPorts.EOL.Custom, "\r")
  while data do
    Heartbeat()
    ParseResponse(data)
    data = port:ReadLine(SerialPorts.EOL.Custom, "\r")
  end
end

PollTimer.EventHandler = function()
  if DebugFn then print("[POLL] Polling device") end
  -- TODO: send poll command, e.g.:
  -- Send("POWR?\r")
end

function OpenPort()
  local baudStr = Controls.BaudRate and Controls.BaudRate.String or "9600"
  local baud    = tonumber(baudStr) or 9600
  local ok, err = pcall(function()
    if MySerialPort.IsOpen then MySerialPort:Close() end
    MySerialPort:Open(baud, 8, "N")
    print(string.format("[SERIAL] Port opened at %d baud (8N1)", baud))
  end)
  if not ok then
    print("[SERIAL] Open error: " .. tostring(err))
    Controls.ConnectionStatus.Value = 2
  end
end

function Initialize()
  print("====================================")
  print(" Videohub 12G v" .. PluginInfo.Version .. " Starting")
  print("====================================")
  SetupDebugPrint()
  print(string.format("[BOOT] Debug mode : %s", Properties["Debug Print"].Value))
  print(string.format("[BOOT] Baud rate  : %s", Controls.BaudRate and Controls.BaudRate.String or "9600 (default)"))
  print(string.format("[BOOT] Heartbeat  : %ds", HeartbeatTimeout))

  -- Delay 1 second — allows virtual serial server ports to initialize before Open()
  Timer.CallAfter(function() OpenPort() end, 1)
end
