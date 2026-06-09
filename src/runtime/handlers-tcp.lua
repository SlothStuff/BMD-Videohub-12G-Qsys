-- TCP Client handlers.
-- Manages a persistent TCP connection with automatic reconnection.
--
-- Network config (IP, Port, PollRate) is read from runtime Controls — not Properties.
-- This lets operators change the target device address while the system is live
-- without pushing a new design file. EventHandlers on IPAddress/Port/Reconnect
-- call Connect() automatically on any change.

DebugTx = false
DebugRx = false
DebugFn = false

function SetupDebugPrint()
  local mode = Properties["Debug Print"].Value
  DebugTx = mode == "Tx/Rx" or mode == "Tx" or mode == "All"
  DebugRx = mode == "Tx/Rx" or mode == "Rx" or mode == "All"
  DebugFn = mode == "Function Calls" or mode == "All"
end

-- Socket and timer must be global to prevent garbage collection
socket = TcpSocket.New()
socket.ReadTimeout      = 0
socket.WriteTimeout     = 0
socket.ReconnectTimeout = 5

PollTimer = Timer.New()

function Send(cmd)
  if socket.IsConnected then
    if DebugTx then
      print("TX: " .. tostring(cmd))
      Controls.LastTx.String = tostring(cmd)
    end
    socket:Write(cmd)
  else
    print("[SEND] Not connected — cannot send: " .. tostring(cmd))
  end
end

function ParseResponse(data)
  if DebugRx then
    print("RX: " .. tostring(data))
    Controls.LastRx.String = tostring(data)
  end
  -- TODO: parse device responses here
  -- Example:
  -- if data:match("^POWR") then
  --   Controls.Power.Boolean = data:match("POWR(%d)") == "1"
  -- end
end

socket.Connected = function(sock)
  print(string.format("[EVENT] Connected to %s:%s", Controls.IPAddress.String, Controls.Port.String))
  Controls.ConnectionStatus.Value = 0
  local rate = tonumber(Controls.PollRate.String) or 30
  PollTimer:Start(rate)
  -- TODO: send any required login or initialization command here
end

socket.Reconnect = function(sock)
  print("[EVENT] Reconnecting to " .. Controls.IPAddress.String)
  Controls.ConnectionStatus.Value = 1
end

socket.Closed = function(sock)
  print("[EVENT] Connection closed")
  Controls.ConnectionStatus.Value = 2
  PollTimer:Stop()
end

socket.Error = function(sock, err)
  print("[EVENT] Socket error: " .. tostring(err))
  Controls.ConnectionStatus.Value = 2
  PollTimer:Stop()
end

socket.Timeout = function(sock)
  print("[EVENT] Socket timeout")
  Controls.ConnectionStatus.Value = 1
  PollTimer:Stop()
end

socket.Data = function(sock)
  -- Read all available lines. Change delimiter to match your device's protocol.
  -- Common alternatives: TcpSocket.EOL.CrLf, TcpSocket.EOL.Lf, "\n"
  local data = sock:ReadLine(TcpSocket.EOL.Custom, "\r")
  while data do
    ParseResponse(data)
    data = sock:ReadLine(TcpSocket.EOL.Custom, "\r")
  end
end

PollTimer.EventHandler = function()
  if DebugFn then print("[POLL] Polling device") end
  -- TODO: send poll or heartbeat command, e.g.:
  -- Send("POWR?\r")
end

function Connect()
  local ip   = Controls.IPAddress.String
  local port = tonumber(Controls.Port.String) or 23
  if ip == "" then
    print("[CONNECT] No IP address configured")
    Controls.ConnectionStatus.Value = 5
    return
  end
  if DebugFn then print(string.format("[CONNECT] Connecting to %s:%d", ip, port)) end
  Controls.ConnectionStatus.Value = 1
  if socket.IsConnected then socket:Disconnect() end
  socket:Connect(ip, port)
end

-- Reconnect whenever IP, port, or the Reconnect button changes
Controls.IPAddress.EventHandler = Connect
Controls.Port.EventHandler      = Connect
Controls.Reconnect.EventHandler = Connect

function Initialize()
  print("====================================")
  print(" Videohub 12G v" .. PluginInfo.Version .. " Starting")
  print("====================================")
  SetupDebugPrint()
  print(string.format("[BOOT] Debug mode : %s", Properties["Debug Print"].Value))

  -- Set defaults if controls have never been configured
  if Controls.IPAddress.String == "" then Controls.IPAddress.String = "192.168.1.1" end
  if Controls.Port.String      == "" then Controls.Port.String      = "9990" end
  if Controls.PollRate.String  == "" then Controls.PollRate.String  = "30" end

  print(string.format("[BOOT] Target     : %s:%s", Controls.IPAddress.String, Controls.Port.String))
  print(string.format("[BOOT] Poll rate  : %ss", Controls.PollRate.String))

  Connect()
end
