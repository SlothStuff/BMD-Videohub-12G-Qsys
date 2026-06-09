-- UDP handlers (two-way communication).
-- UDP is connectionless — no connection state, no guaranteed delivery.
-- The socket must be global to prevent garbage collection.
-- Network config (IP, Port, PollRate) is read from runtime Controls — not Properties.

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
udp       = UdpSocket.New()
PollTimer = Timer.New()

function Send(data)
  local ip   = Controls.IPAddress.String
  local port = tonumber(Controls.Port.String) or 50000
  if ip == "" then
    print("[SEND] No IP address configured")
    return
  end
  if DebugTx then
    print("TX: " .. tostring(data))
    Controls.LastTx.String = tostring(data)
  end
  udp:Send(ip, port, data)
end

function ParseResponse(data, srcIP)
  if DebugRx then
    print(string.format("RX [%s]: %s", srcIP, tostring(data)))
    Controls.LastRx.String = tostring(data)
  end
  Controls.ConnectionStatus.Value = 0
  -- TODO: parse device responses here
end

udp.EventHandler = function(sock, packet)
  local expectedIP = Controls.IPAddress.String
  -- Accept packets from the configured IP (or all IPs if not set)
  if expectedIP == "" or packet.Address == expectedIP then
    ParseResponse(packet.Data, packet.Address)
  end
end

PollTimer.EventHandler = function()
  if DebugFn then print("[POLL] Sending poll") end
  -- TODO: send poll command, e.g.:
  -- Send("STATUS?\r")
end

function Connect()
  local ip = Controls.IPAddress.String
  if ip == "" then
    print("[CONNECT] No IP address configured")
    Controls.ConnectionStatus.Value = 5
    return
  end
  local ok, err = pcall(function()
    udp:Open()
  end)
  if ok then
    print(string.format("[CONNECT] UDP socket open. Target: %s:%s", ip, Controls.Port.String))
    Controls.ConnectionStatus.Value = 1
    local rate = tonumber(Controls.PollRate.String) or 30
    PollTimer:Start(rate)
  else
    print("[CONNECT] UDP open error: " .. tostring(err))
    Controls.ConnectionStatus.Value = 2
  end
end

Controls.IPAddress.EventHandler = Connect
Controls.Port.EventHandler      = Connect
Controls.Reconnect.EventHandler = Connect

function Initialize()
  print("====================================")
  print(" Videohub 12G v" .. PluginInfo.Version .. " Starting")
  print("====================================")
  SetupDebugPrint()
  print(string.format("[BOOT] Debug mode : %s", Properties["Debug Print"].Value))

  if Controls.IPAddress.String == "" then Controls.IPAddress.String = "192.168.1.1" end
  if Controls.Port.String      == "" then Controls.Port.String      = "9990" end
  if Controls.PollRate.String  == "" then Controls.PollRate.String  = "30" end

  print(string.format("[BOOT] Target     : %s:%s", Controls.IPAddress.String, Controls.Port.String))
  print(string.format("[BOOT] Poll rate  : %ss", Controls.PollRate.String))

  Connect()
end
