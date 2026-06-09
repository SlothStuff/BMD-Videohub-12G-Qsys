# Videohub 12G Q-SYS Plugin

**Version:** 0.1.0
**Author:** Sweetwater Integration
**Minimum Q-SYS Version:** 10.0

Control for Blackmagic Videohub 12G routers (Mini 4x2 through 80x80) from Q-SYS Designer.

---

## Supported Models

| Model | Inputs | Outputs |
|-------|--------|---------|
| Videohub Mini 4x2 12G | 4 | 2 |
| Videohub Mini 6x2 12G | 6 | 2 |
| Videohub Mini 8x4 12G | 8 | 4 |
| Videohub 10x10 12G | 10 | 10 |
| Videohub 20x20 12G | 20 | 20 |
| Videohub 40x40 12G | 40 | 40 |
| Videohub 80x80 12G | 80 | 80 |

---

## Installation

1. Copy `Videohub12G_v0.1.0.qplugx` to:
   ```
   %USERPROFILE%\Documents\QSC\Q-Sys Designer\Plugins\Videohub12G\
   ```
   Or double-click the `.qplugx` file to install directly.
2. Restart Q-SYS Designer (or reload plugins from the menu).
3. The plugin appears under **Sweetwater Integration → Blackmagic → Videohub 12G** in the component browser.

---

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| Videohub Model | list | Videohub 20x20 12G | Select device model to configure I/O counts |
| Lock Controls Enabled | bool | false | Show Lock/Unlock buttons and LED indicators per output |
| Use Take | bool | false | Stage route changes; send all at once with the TAKE button |
| Allow Label Editing | bool | true | Enable editing of input/output labels from the Labels page |
| Debug Print | list | None | Controls debug output: None / Tx / Rx / Tx/Rx / All |

---

## Pages

| Page | Purpose |
|------|---------|
| Control (or Outputs 1-20, 21-40, …) | Video routing matrix — select input per output |
| Presets | Save and load up to 8 named routing presets |
| Labels (or Labels 1-20, 21-40, …) | View and edit input/output labels |
| Setup | IP address, port, poll rate, reconnect |
| Diagnostics | Logo, version, last TX/RX, device info |

---

## Key Control Pins

| Name | Group | Direction | Type | Description |
|------|-------|-----------|------|-------------|
| ConnectionStatus | Status | Output | number | 0=OK, 1=Warn, 2=Fault, 5=Disabled |
| DeviceInfo | Status | Output | string | Model name and I/O count from device |
| Output Routing N | Routing | Both | string | Integer 1–N: routes input N to output |
| Input Label N | Labels | Both | string | Input channel label (sent to device) |
| Output Label N | Labels | Both | string | Output channel label (sent to device) |
| Output Lock State N | Lock | Output | bool | true = locked (by any client) |
| Lock Output N | Lock | Input | trigger | Send lock (O) command for output N |
| Unlock Output N | Lock | Input | trigger | Send unlock (U) command for output N |
| Take | Take | Input | trigger | Commit all staged routes at once |
| Take Pending | Take | Output | bool | true when staged routes are waiting |
| Preset Name N | Presets | Both | string | Display name for preset slot N |
| Preset Save N | Presets | Input | trigger | Serialize current routes to preset N |
| Preset Load N | Presets | Input | trigger | Apply stored routes from preset N |
| IPAddress | Setup | Both | string | Target device IP address |
| Port | Setup | Both | string | TCP port (default 9990) |
| PollRate | Setup | Both | string | PING keepalive interval in seconds |
| Reconnect | Setup | Input | trigger | Disconnect and reconnect immediately |

---

## Protocol

Uses **Blackmagic Videohub Ethernet Protocol v2.3** over TCP port 9990.
Text-based, `\n\n`-delimited blocks. No authentication required.

---

## Debug Workflow

1. Build the debug plugin: `.\build\compile.ps1 -Version "0.1.0" -DebugBuild`
2. Install the resulting `.qplug` from `dist/`.
3. Add a **Control Script** alongside the plugin in your design.
4. Paste your runtime code from `src/runtime/` into the Control Script.
5. Wire the `code` pin on both components.
6. Emulate or push to Core — use the **plugin's** debug window for errors.

---

## Building from Source

```powershell
# Compile only (no encryption) — prompts for version
.\build\build.ps1 -NoEncrypt

# Compile release + encrypt
.\build\build.ps1

# Debug build only
.\build\compile.ps1 -Version "0.1.0" -DebugBuild
```

Output is written to `dist/v{version}-{date}/`.

### Encryption Tool Setup (required for `.qplugx` output)

```powershell
.\tools\setup-encryption-tool.ps1
```

---

## Version History

| Version | Date | Notes |
|---------|------|-------|
| 0.1.0 | 06/2026 | Initial release |
