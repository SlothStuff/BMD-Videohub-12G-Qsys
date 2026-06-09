# {{PLUGIN_NAME}} — Code Map

> Internal reference. Keep this file up to date as the plugin evolves.

## Overview

{{DESCRIPTION}}

| Field | Value |
|-------|-------|
| Plugin Name | {{PLUGIN_NAME_PRETTY}} |
| Author | {{AUTHOR}} |
| Q-SYS Min Version | {{QSYS_VERSION}} |
| Communication | (TCP Client / TCP Server / UDP / Serial / None) |
| Pages | Control, Setup |

---

## Project Structure

```
{{PLUGIN_NAME}}/
├── VERSION                         Current release version string
├── README.md                       User-facing documentation + pin table
├── .plugin-guid                    Persisted GUID (auto-generated on first build)
│
├── src/
│   ├── plugin.lua                  Root entry — includes all design-time modules + runtime
│   ├── plugin-debug.lua            Debug build entry — empty runtime, exposes "code" pin
│   ├── info.lua                    PluginInfo table, GetColor, GetPrettyName
│   ├── pages.lua                   PageNames table, GetPages
│   ├── properties.lua              GetProperties, RectifyProperties
│   ├── style.lua                   STYLE table — all colors and visual constants
│   │
│   ├── controls/
│   │   ├── controls.lua            GetControls — aggregates ctrl_*.lua via #include
│   │   └── ctrl_control.lua        Control and Setup page control definitions
│   │
│   ├── layout/
│   │   ├── constants.lua           LAYOUT dimension/spacing constants
│   │   ├── layout.lua              GetControlLayout dispatcher + background graphics
│   │   ├── page_control.lua        Control page layout entries and graphics
│   │   └── page_setup.lua          Setup page layout entries and graphics
│   │
│   └── runtime/
│       ├── runtime.lua             Runtime entry — calls Initialize(), includes handlers
│       ├── handlers.lua            Socket/port/connection event handlers
│       └── run_control.lua         Control page EventHandler assignments
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
│       ├── {{PLUGIN_NAME}}_v{version}.qplug
│       └── {{PLUGIN_NAME}}_v{version}.qplugx
│
├── tools/
│   └── PluginEncryptionTool/       git clone from github.com/qsys-plugins/PluginEncryptionTool
│       └── release/
│           └── plugin_tool_release.exe
│
└── docs/
    └── CODEMAP.md                  This file
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
        ├── layout/page_control.lua   (if CurrentPage == "Control")
        └── layout/page_setup.lua     (if CurrentPage == "Setup")

if Controls then
  runtime/runtime.lua
    ├── runtime/handlers.lua
    └── runtime/run_control.lua
end
```

---

## Control Pins

| Name | Group | Direction | Type | Range / Choices | Description |
|------|-------|-----------|------|-----------------|-------------|
| ConnectionStatus | Status | Output | number | 0=OK, 1=Warn, 2=Fault, 5=Disabled | Device connection state |

<!-- Add a row here for every control in ctrl_control.lua -->

---

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| Debug Print | list | None | Serial debug output: None / Tx / Rx / Tx/Rx / All |
| IP Address | string | 192.168.1.1 | Device IP address |
| Port | integer | 23 | Device TCP port |

<!-- Update to match properties.lua -->

---

## Key Design Decisions

- (Document non-obvious choices, protocol quirks, or constraints here as the plugin evolves)
