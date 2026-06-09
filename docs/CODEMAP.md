# Videohub12G — Code Map

> Internal reference. Keep this file up to date as the plugin evolves.

## Overview

Q-SYS plugin for control of Blackmagic Videohub 12G routers via TCP.

| Field | Value |
|-------|-------|
| Plugin Name | Videohub 12G |
| Author | Sweetwater Integration |
| Q-SYS Min Version | 10.3.0 |
| Communication | TCP Client (port 9990) |
| Pages | Control / Outputs N-N, Presets, Labels / Labels N-N, Setup, Diagnostics |

---

## Project Structure

```
BMD-Videohub-12G-Qsys/
├── VERSION                         Current release version string
├── README.md                       User-facing documentation + pin table
├── .plugin-guid                    Persisted GUID (auto-generated on first build)
│
├── src/
│   ├── plugin.lua                  Root entry — includes all design-time modules + runtime
│   ├── plugin-debug.lua            Debug build entry — empty runtime, exposes "code" pin
│   ├── info.lua                    PluginInfo table, GetColor, GetPrettyName
│   ├── pages.lua                   PageNames table, GetPages, BuildPageList
│   ├── properties.lua              GetProperties, RectifyProperties
│   ├── style.lua                   STYLE table — all colors and visual constants
│   │
│   ├── controls/
│   │   ├── controls.lua            GetControls — aggregates ctrl_*.lua via #include
│   │   └── ctrl_control.lua        All control definitions (routing, labels, presets, setup)
│   │
│   ├── layout/
│   │   ├── constants.lua           LAYOUT dimension/spacing constants and MODEL_IO map
│   │   ├── layout.lua              GetControlLayout dispatcher + full-canvas background
│   │   ├── page_control.lua        Routing page — per-output rows with combobox/lock/label
│   │   ├── page_presets.lua        Presets page — 8 named preset slots
│   │   ├── page_labels.lua         Labels page — input and output label editors
│   │   ├── page_setup.lua          Setup page — IP, port, poll rate, reconnect
│   │   └── page_diagnostics.lua    Diagnostics page — logo, version, TX/RX, device info
│   │
│   └── runtime/
│       ├── runtime.lua             Runtime entry — #includes handlers + run_control, calls Initialize()
│       ├── handlers.lua            TCP socket, protocol block parsing, device state caches
│       └── run_control.lua         EventHandler wiring for all controls
│
├── build/
│   ├── config.ps1                  $PluginName constant — dot-sourced by all scripts
│   ├── build.ps1                   Master build (prompts for version, compile + encrypt)
│   ├── compile.ps1                 #include expander → writes .qplug to dist/
│   ├── compile-debug.ps1           Thin wrapper: compiles plugin-debug.lua
│   └── encrypt.ps1                 .qplug → .qplugx via PluginEncryptionTool
│
├── dist/
│   └── v{version}-{date}/
│       ├── Videohub12G_v{version}.qplug
│       └── Videohub12G_v{version}.qplugx
│
├── tools/
│   └── PluginEncryptionTool/       git clone from github.com/qsys-plugins/PluginEncryptionTool
│       └── release/
│           └── plugin_tool_release.exe
│
├── ReferenceDocs/
│   ├── VideohubEthernetProtocol.md/.pdf   Blackmagic protocol v2.3 reference
│   └── Ethereal-CS-88M-QSys-Plugin/       Reference plugin (source + compiled)
│
└── docs/
    ├── CODEMAP.md                  This file
    └── OrangeControlsError.md      Root cause + fix for the orange controls / nil crash
```

---

## Include Chain

```
plugin.lua
  ├── info.lua
  ├── pages.lua
  ├── properties.lua
  ├── controls/controls.lua
  │     └── controls/ctrl_control.lua
  ├── style.lua
  └── layout/layout.lua
        ├── layout/constants.lua
        ├── layout/page_control.lua     (Control or Outputs N-N pages)
        ├── layout/page_presets.lua     (Presets page)
        ├── layout/page_labels.lua      (Labels or Labels N-N pages)
        ├── layout/page_setup.lua       (Setup page)
        └── layout/page_diagnostics.lua (Diagnostics page)

if Controls then
  runtime/runtime.lua
    ├── runtime/handlers.lua
    └── runtime/run_control.lua
  Initialize()
end
```

---

## Control Pins

Count > 1 pins are shown as `Name N` where N = 1 … count for the selected model.
Runtime access: `Controls["Name"][N]` — NOT `Controls["Name N"]` (see OrangeControlsError.md).

| Name | Group | Direction | Type | Range / Choices | Description |
|------|-------|-----------|------|-----------------|-------------|
| ConnectionStatus | Status | Output | number | 0=OK, 1=Warn, 2=Fault, 5=Disabled | Device connection state |
| DeviceInfo | Status | Output | string | — | Model name and I/O count string from device |
| IPAddress | Setup | Both | string | — | Target device IP address |
| Port | Setup | Both | string | — | TCP port (default 9990) |
| PollRate | Setup | Both | string | — | PING keepalive interval in seconds |
| Reconnect | Setup | Input | trigger | — | Disconnect and reconnect immediately |
| Output Routing N | Routing | Both | string | 1–inputCount | Routes input N to this output |
| Input Label N | Labels | Both | string | — | Input channel label (synced to device) |
| Output Label N | Labels | Both | string | — | Output channel label (synced to device) |
| Output Lock State N | Lock | Output | bool | — | true = locked by any client (Lock Controls Enabled only) |
| Lock Output N | Lock | Input | trigger | — | Send lock (O) command for output N (Lock Controls Enabled only) |
| Unlock Output N | Lock | Input | trigger | — | Send unlock (U) command for output N (Lock Controls Enabled only) |
| Take | Take | Input | trigger | — | Commit all staged routes (Use Take only) |
| Take Pending | Take | Output | bool | — | true when staged routes are waiting (Use Take only) |
| Preset Name N | Presets | Both | string | — | Display label for preset slot N (1–8) |
| Preset Save N | Presets | Input | trigger | — | Serialize current confirmed routes to slot N |
| Preset Load N | Presets | Input | trigger | — | Apply stored routes from slot N |
| LastTx | Diagnostics | Output | string | — | Most recent transmitted command (Debug mode) |
| LastRx | Diagnostics | Output | string | — | Most recent received block header (Debug mode) |

---

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| Videohub Model | enum | Videohub 20x20 12G | Sets input/output counts for all indexed controls |
| Lock Controls Enabled | boolean | false | Creates Lock Output / Unlock Output / Output Lock State pins |
| Use Take | boolean | false | Creates Take / Take Pending pins; stages routes until TAKE pressed |
| Allow Label Editing | boolean | true | Enables label text boxes on the Labels page |
| Debug Print | enum | None | None / Tx/Rx / Tx / Rx / All — controls TX/RX debug output |

---

## Key Design Decisions

- **Protocol**: Blackmagic Videohub Ethernet Protocol v2.3, TCP port 9990. Text blocks delimited by `\n\n`. All device indexes are 0-based; plugin state is 1-based throughout.
- **Echo suppression**: `CurrentRoutes`, `InputLabels`, `OutputLabels` caches are updated in the receive handler *before* writing to Controls, so EventHandlers can detect and skip device-initiated updates that would loop back as commands.
- **Dynamic page count**: `BuildPageList` in `pages.lua` generates routing pages in banks of 20 and label pages in banks of 20, keeping the UI manageable for 40x40 and 80x80 models.
- **Preset storage**: Route data is serialized as CSV (`out=in,...`) into hidden `Preset Data N` Text controls so it survives Q-SYS saves without requiring a database or file I/O.
- **Count > 1 runtime access**: Uses `Controls["Name"][i]` — NOT `Controls["Name i"]`. See `docs/OrangeControlsError.md` for the full explanation.
