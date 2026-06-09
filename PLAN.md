# Videohub 12G — Q-SYS Plugin Build Plan

**Project:** `Sweetwater Integration~Blackmagic~Videohub 12G`
**Type:** TCP Client
**Target Devices:** Blackmagic Videohub Mini 4×2 12G → Videohub 80×80 12G (7 models)
**Protocol:** TCP text-based, block-delimited by `\n\n`, port 9990
**Target Designer Version:** Q-SYS 10.0+
**Date:** 06/2026
**Author:** Sweetwater Integration

---

## Project Summary

This plugin provides full runtime control of all Blackmagic Videohub 12G router models from a single Q-SYS plugin block. The integrator selects the Videohub model at design time (driving the correct number of routing, label, and lock controls), then configures the IP address at runtime. Each output exposes a Routing pin that accepts the integer input number to route to it. Models with ≤ 20 inputs render the routing control as a ComboBox (options 1–N); models with > 20 inputs use a plain text-entry field. An optional Take mode buffers route changes until the operator fires the Take trigger. Output locking and label editing are each separately gated by design-time properties.

---

## Model → I/O Count Map

| Property Value               | Inputs | Outputs | Routing widget (inputCount ≤ 20?) |
|------------------------------|--------|---------|-----------------------------------|
| Videohub Mini 4×2 12G        |  4     |  2      | ComboBox (1–4)                    |
| Videohub Mini 6×2 12G        |  6     |  2      | ComboBox (1–6)                    |
| Videohub Mini 8×4 12G        |  8     |  4      | ComboBox (1–8)                    |
| Videohub 10×10 12G           | 10     | 10      | ComboBox (1–10)                   |
| Videohub 20×20 12G           | 20     | 20      | ComboBox (1–20)                        |
| Videohub 40×40 12G           | 40     | 40      | Text edit                         |
| Videohub 80×80 12G           | 80     | 80      | Text edit                         |

---

## Design-Time Properties

| Name                    | Type    | Default                  | Notes |
|-------------------------|---------|--------------------------|-------|
| `Videohub Model`        | enum    | `Videohub 20×20 12G`     | Drives inputCount / outputCount for all control arrays |
| `Lock Controls Enabled` | boolean | `false`                  | When true: lock/unlock pins and UI are created |
| `Use Take`              | boolean | `false`                  | When true: route changes stage locally; TAKE button commits all at once |
| `Allow Label Editing`   | boolean | `true`                   | When false: label controls are read-only on the Labels page |
| `Debug Print`           | boolean | `false`                  | Enables TX/RX console logging |

`RectifyProperties`: no properties are hidden — all five are always visible.

---

## Control Definitions (GetControls)

All `Count = outputCount` / `Count = inputCount` values are derived from the model property at design time.

### Routing Control Type Rule

`GetControls(props)` inspects `inputCount`:

```lua
if inputCount <= 20 then
  -- ComboBox: choices are the string "1" through the string N
  { Name = "Output Routing", ControlType = "Text", TextBoxType = "ComboBox",
    Choices = buildChoices(inputCount),   -- {"1","2",...,N}
    UserPin = true, PinStyle = "Both", Count = outputCount }
else
  -- Plain text box: operator types or wires an integer value as a string
  { Name = "Output Routing", ControlType = "Text",
    UserPin = true, PinStyle = "Both", Count = outputCount }
end
```

Runtime reads value as: `local inputNum = tonumber(Controls["Output Routing " .. i].String)`

> **No Knob controls appear anywhere in the UI.** All interactive controls are Text,
> ComboBox, Button, or Status indicator. Bank-navigation state uses hidden Lua globals,
> not control pins, to avoid any Knob type.

### Status Group
| Control Name     | Type              | Count | UserPin | PinStyle | Notes |
|------------------|-------------------|-------|---------|----------|-------|
| ConnectionStatus | Indicator/Status  | 1     | true    | Output   | 0=OK, 1=Warn, 2=Fault |
| DeviceInfo       | Text (read-only)  | 1     | true    | Output   | Model + firmware from device |

### Setup Group
| Control Name | Type            | Count | UserPin | PinStyle | Notes |
|--------------|-----------------|-------|---------|----------|-------|
| IPAddress    | Text            | 1     | true    | Both     | Default `192.168.1.1` |
| Port         | Text            | 1     | true    | Both     | Default `9990` |
| PollRate     | Text            | 1     | true    | Both     | Default `30` (PING interval, seconds) |
| Reconnect    | Button/Trigger  | 1     | true    | Input    | Triggers `Connect()` |

### Routing Group
| Control Name  | Type               | Count       | UserPin  | PinStyle | Notes |
|---------------|--------------------|-------------|----------|----------|-------|
| Output Routing| Text (ComboBox or plain; see rule above) | outputCount | true | Both | `.String` = input number, e.g. `"5"` |
| Route Display | Text (read-only)   | outputCount | **false** | —       | Layout-only; shows input label for current route |

> **Mental model:** "Output 3 Routing = `"5"`" means Input 5 is routed **to** Output 3.
> `Route Display` controls are hidden from the external pin list and exist solely to
> show the human-readable input name in the plugin's built-in UI.

### Take Group *(created only when `Use Take = true`)*
| Control Name | Type           | Count | UserPin | PinStyle | Notes |
|--------------|----------------|-------|---------|----------|-------|
| Take         | Button/Trigger | 1     | true    | Input    | Commits all staged route changes to device |
| Take Pending | Indicator/LED  | 1     | true    | Output   | Lit when uncommitted staged changes exist |

> **Take behavior:** Changes to `Output Routing N` are held in `StagedRoutes[]`; pressing Take
> sends all staged routes at once. The Videohub protocol has no Take command — staging is plugin-side.

### Locks Group *(created only when `Lock Controls Enabled = true`)*
| Control Name      | Type           | Count       | UserPin | PinStyle | Notes |
|-------------------|----------------|-------------|---------|----------|-------|
| Output Lock State | Indicator/LED  | outputCount | true    | Output   | 0=Unlocked, 1=Owned (locked by us), 2=Locked by Other |
| Lock Output       | Button/Trigger | outputCount | true    | Input    | Sends `O` (owned/locked) |
| Unlock Output     | Button/Trigger | outputCount | true    | Input    | Sends `U` (unlock) |

> **Bug fix from reference plugin:** Lock command sends `"O"`, not `"L"`. `"L"` is a status
> code meaning "locked by another client" — it is not a valid lock command.

### Labels Group
| Control Name | Type | Count       | UserPin | PinStyle | Notes |
|--------------|------|-------------|---------|----------|-------|
| Input Label  | Text | inputCount  | true    | Both     | Read from device; writeable back to device |
| Output Label | Text | outputCount | true    | Both     | Same; `IsReadOnly` in layout when `Allow Label Editing = false` |

### Presets Group
| Control Name | Type           | Count | UserPin   | PinStyle | Notes |
|--------------|----------------|-------|-----------|----------|-------|
| Preset Name  | Text           | 8     | true      | Both     | User-editable; persisted in Q-SYS design file |
| Preset Save  | Button/Trigger | 8     | true      | Input    | Snapshots `CurrentRoutes[]` to `Preset Data N` |
| Preset Load  | Button/Trigger | 8     | true      | Input    | Deserializes and routes (or stages if Use Take ON) |
| Preset Data  | Text           | 8     | **false** | Both     | Hidden; CSV-serialized input numbers per output |

### Diagnostics Group
| Control Name | Type | Count | UserPin | PinStyle |
|--------------|------|-------|---------|----------|
| LastTx       | Text | 1     | true    | Output   |
| LastRx       | Text | 1     | true    | Output   |

---

## Pages (5 total)

Canvas size: **640 × 720 px** (identical across all pages)

| # | Page        | Content |
|---|-------------|---------|
| 1 | Control     | Routing matrix with bank navigation; Take button (if enabled); connection status |
| 2 | Presets     | 8 named presets with SAVE + LOAD buttons |
| 3 | Labels      | Editable (or read-only) input and output label fields, two-column |
| 4 | Setup       | IP, Port, PollRate, Reconnect; device info read-back |
| 5 | Diagnostics | Sweetwater logo, plugin name/version, Last TX/RX |

---

## Control Page Layout Detail

```
Routing: for each OUTPUT row, you select which INPUT is routed TO that output.
"Output 3 Routing = '5'" → Input 5 feeds into Output 3.

┌────────────────────────────────────────────────────────────────┐
│ Videohub 12G                                [●] Connection     │  46px header
├────────────────────────────────────────────────────────────────┤
│ OUT # │ Output Name        │ IN │ Input Name          │[Lock?] │  26px col header
│  1    │ [Output Label 1  ] │[▼1]│ Camera 1            │ [🔒]   │  26px each row
│  2    │ [Output Label 2  ] │[▼5]│ Playback Server     │ [🔒]   │
│  ...  │ ...                │ ...│ ...                 │        │
│  20   │ [Output Label 20 ] │[▼3]│ Rooftop Cam         │ [🔒]   │
├────────────────────────────────────────────────────────────────┤
│  [◄ PREV BANK]      Bank 1 of 4      [NEXT BANK ►]            │  32px nav
├────────────────────────────────────────────────────────────────┤
│  [TAKE]  Take Pending: [●]                                     │  34px (Use Take only)
└────────────────────────────────────────────────────────────────┘
```

Column widths (locks enabled): `# 36` | `Output Name 150` | `IN 60` | `Input Name 190` | `Lock 80`
Column widths (no locks): `# 36` | `Output Name 160` | `IN 60` | `Input Name 300`

- **IN column**: `Output Routing N` shown as ComboBox (≤10 inputs) or Text edit (>10 inputs)
- **Input Name column**: `Route Display N` read-only Text, updated at runtime from input label table
- **Bank nav**: rendered only when outputCount > 20; state stored in Lua globals `BankCurrent`, not a control pin
- **Take row**: only rendered when `Use Take = true` property

---

## Labels Page Layout Detail

```
┌────────────────────────────────────────────────────────────────┐
│ Labels                                      [●] Connection     │  46px header
├──────────────────────────┬─────────────────────────────────────┤
│ INPUTS                   │ OUTPUTS                             │
│ 1  [Input Label 1      ] │ 1  [Output Label 1               ] │
│ 2  [Input Label 2      ] │ 2  [Output Label 2               ] │
│ ...                      │ ...                                 │
│ N  [Input Label N      ] │ N  [Output Label N               ] │
│                          │                                     │
│ [◄ PREV]  1 / 4  [NEXT►] │ [◄ PREV]  1 / 4  [NEXT►]          │
└──────────────────────────┴─────────────────────────────────────┘
```

- When `Allow Label Editing = false`: `IsReadOnly = true` in layout; GroupBox header appends "(read-only)"
- Label `EventHandler` sends `INPUT LABELS:\nN label\n\n` or `OUTPUT LABELS:\nN label\n\n` on change
- Separate bank globals `LabelBankInput`, `LabelBankOutput` (Lua globals, not control pins) manage independent column scrolling for asymmetric models

---

## Presets Page Layout Detail

```
┌────────────────────────────────────────────────────────────────┐
│ Presets                                     [●] Connection     │  46px header
├────────────────────────────────────────────────────────────────┤
│  1  [Preset Name 1                       ]  [SAVE]  [LOAD]    │  38px each
│  2  [Preset Name 2                       ]  [SAVE]  [LOAD]    │
│  3  [Preset Name 3                       ]  [SAVE]  [LOAD]    │
│  4  [Preset Name 4                       ]  [SAVE]  [LOAD]    │
│  5  [Preset Name 5                       ]  [SAVE]  [LOAD]    │
│  6  [Preset Name 6                       ]  [SAVE]  [LOAD]    │
│  7  [Preset Name 7                       ]  [SAVE]  [LOAD]    │
│  8  [Preset Name 8                       ]  [SAVE]  [LOAD]    │
└────────────────────────────────────────────────────────────────┘
```

---

## TCP Protocol Handler Architecture

### Buffer Strategy — Manual Accumulation
```lua
RecvBuffer = ""   -- MUST be global

socket.Data = function(sock)
  RecvBuffer = RecvBuffer .. sock:Read(sock.BufferLength)
  ProcessBuffer()
end

function ProcessBuffer()
  while true do
    local s, e = RecvBuffer:find("\n\n")
    if not s then break end
    local block = RecvBuffer:sub(1, e)
    RecvBuffer   = RecvBuffer:sub(e + 1)
    ProcessBlock(block)
  end
end
```

### Block Dispatch
```lua
function ProcessBlock(text)
  local header = text:match("^([A-Z ]+):")
  if not header then return end
  if     header == "PROTOCOL PREAMBLE"        then HandlePreamble(text)
  elseif header == "VIDEOHUB DEVICE"          then HandleDevice(text)
  elseif header == "INPUT LABELS"             then HandleInputLabels(text)
  elseif header == "OUTPUT LABELS"            then HandleOutputLabels(text)
  elseif header == "VIDEO OUTPUT ROUTING"     then HandleRouting(text)
  elseif header == "VIDEO OUTPUT LOCKS"       then HandleLocks(text)
  elseif text:match("^ACK")                   then HandleAck()
  elseif text:match("^NAK")                   then HandleNak()
  -- All other blocks silently ignored per protocol spec
  end
end
```

### Key Handler Behaviors
- **`HandleDevice`**: Parse `Video inputs` / `Video outputs`; compare with property. Log mismatch warning but continue operating.
- **`HandleInputLabels`**: Update `Controls["Input Label N"].String`; rebuild `Route Display N` for any outputs currently routing to that input.
- **`HandleRouting`**: Protocol is zero-based. Convert: `output1 = outputIdx0 + 1`, `input1 = inputIdx0 + 1`. Set `Controls["Output Routing " .. output1].String = tostring(input1)`. Update `Controls["Route Display " .. output1].String = InputLabels[input1]`. Update `CurrentRoutes[output1] = input1`.
- **`HandleLocks`**: Only run if `Lock Controls Enabled = true`. `U`→0, `O`→1, `L`→2 for LED value.

### Routing Commands
```lua
function RouteOutput(output1, input1)
  Send(string.format("VIDEO OUTPUT ROUTING:\n%d %d\n\n", output1 - 1, input1 - 1))
end

function LockOutput(output1)
  Send(string.format("VIDEO OUTPUT LOCKS:\n%d O\n\n", output1 - 1))
end

function UnlockOutput(output1)
  Send(string.format("VIDEO OUTPUT LOCKS:\n%d U\n\n", output1 - 1))
end
```

### Take Logic
```lua
StagedRoutes = {}   -- global; [output1] = input1; only used when UseTake is true

Controls["Output Routing " .. i].EventHandler = function(ctrl)
  local input1 = tonumber(ctrl.String)
  if not input1 then return end
  if UseTake then
    StagedRoutes[i] = input1
    Controls["Take Pending"].Boolean = true
  else
    RouteOutput(i, input1)
  end
end

Controls.Take.EventHandler = function()
  for output1, input1 in pairs(StagedRoutes) do
    RouteOutput(output1, input1)
  end
  StagedRoutes = {}
  Controls["Take Pending"].Boolean = false
end
```

### Label Change Commands
```lua
function SetInputLabel(input1, label)
  Send(string.format("INPUT LABELS:\n%d %s\n\n", input1 - 1, label))
end
function SetOutputLabel(output1, label)
  Send(string.format("OUTPUT LABELS:\n%d %s\n\n", output1 - 1, label))
end
```

---

## Orchestration Model

This plugin is large enough that implementing all phases inline would consume the main conversation context. Instead, a **delegated orchestration** model is used:

```
Main conversation (Orchestrator)
  │
  ├── delegates WRITE tasks → Implementation Agents (general-purpose subagents)
  │     Each receives: relevant reference docs + plan section + existing files to read
  │     Each returns: summary of what was written + any open questions
  │
  ├── delegates REVIEW tasks → Specialist Review Agents (code-reviewer, security-reviewer)
  │     Each receives: the file(s) just written
  │     Each returns: findings with severity; HIGH/CRITICAL must be fixed before next phase
  │
  └── delegates FIX tasks → build-error-resolver
        Only invoked if build fails
```

**Orchestrator responsibilities (inline, not delegated):**
- Reading the current state of files between phases to verify correctness
- Deciding whether findings from review agents require a fix phase
- Tracking overall progress and phase order
- Running the final build command and GitHub push

**Implementation agent prompt template:** Each agent is given:
1. The relevant section of this PLAN.md
2. The skill reference doc(s) for that phase (`plugin-api.md`, `tcp-patterns.md`, etc.)
3. The existing files it needs to read for context (e.g., `ctrl_control.lua` before writing `page_control.lua`)
4. A clear deliverable: exactly which file(s) to write and what must be in them

**Context discipline:** The orchestrator reads only file summaries between phases, not full file contents, unless a specific issue requires it. This keeps the main context lean across 12 phases.

---

## Implementation Phases

| # | Phase | Who writes | Who reviews | Est. Time |
|---|-------|-----------|-------------|-----------|
| 1 | Scaffold — copy templates, replace tokens, add Labels + Presets page stubs | Orchestrator (PowerShell only) | — | 10 min |
| 2 | Properties + Controls — `properties.lua`, `ctrl_control.lua` | **Implementation Agent** | **code-reviewer** | 20 min |
| 3 | Layout constants — `constants.lua`, `style.lua` (640×720 canvas) | **Implementation Agent** | — | 5 min |
| 4 | Control page layout — `page_control.lua` | **Implementation Agent** | **code-reviewer** | 35 min |
| 5 | Presets page layout — `page_presets.lua` | **Implementation Agent** | **code-reviewer** | 15 min |
| 6 | Labels page layout — `page_labels.lua` | **Implementation Agent** | **code-reviewer** | 20 min |
| 7 | Setup + Diagnostics page layouts | **Implementation Agent** | — | 10 min |
| 8 | TCP protocol handler — `handlers.lua` | **Implementation Agent** | **code-reviewer** | 35 min |
| 9 | Command wiring — `run_control.lua` | **Implementation Agent** | **code-reviewer** | 25 min |
| 10 | Build + verify — `.\build\build.ps1` | Orchestrator | **build-error-resolver** (if needed) | 10 min |
| 11 | Security review | — | **security-reviewer** | 10 min |
| 12 | GitHub repo — create `BMD-Videohub-12G-Qsys`, push | Orchestrator | — | 5 min |

**Total estimated time:** 3 – 4 hours

### Role Definitions

| Role | Agent type | Does what |
|------|-----------|-----------|
| Orchestrator | Main conversation | Manages phase order, scaffolding, build, git; reads files to verify between phases |
| Implementation Agent | `general-purpose` subagent | Writes Lua source files for one phase; receives plan + references as context |
| code-reviewer | `everything-claude-code:code-reviewer` subagent | Reviews completed files; returns findings only — does NOT write code |
| security-reviewer | `everything-claude-code:security-reviewer` subagent | Final security pass after build; returns findings only |
| build-error-resolver | `everything-claude-code:build-error-resolver` subagent | Fixes build/compile errors only; invoked on failure |

---

## Bugs Avoided from Reference Plugin

1. **Lock sends `"L"` instead of `"O"`** — correct lock command is `"O"` (owned by this client).
2. **`Disable` button is a no-op** — Lock feature is a proper design-time property here.
3. **Dead `ProcessLine` code path** — single clean buffer accumulation strategy.
4. **Stale `Active Input` control reference** — all runtime control references validated against `GetControls`.
5. **Double ACK processing risk** — ACK handled once, no redundant re-invocation.

---

## Risk Assessment

### HIGH

| Risk | Likelihood | Mitigation |
|------|-----------|-----------|
| `Output Routing N` ComboBox `.String` set at runtime to a value not in `Choices` | Possible when device state changes | Set `.String` directly; Q-SYS allows out-of-Choices values on Text controls at runtime |

### MEDIUM

| Risk | Likelihood | Mitigation |
|------|-----------|-----------|
| Encryption tool not cloned | Possible | `.\tools\setup-encryption-tool.ps1` handles before Phase 10 |
| `Allow Label Editing = false` requires props-aware layout code | Certain | `GetControlLayout(props)` reads property and sets `IsReadOnly` accordingly |
| GitHub CLI not authenticated | Possible | Verify `gh auth status` before Phase 12 |

### LOW

| Risk | Likelihood | Mitigation |
|------|-----------|-----------|
| GUID collision | Very low | Auto-generated by compile.ps1 on first build |
| Canvas 640×720 feels large | Low | Standard for complex AV router plugins |

---

## Deliverables

- `src/` — 11 Lua source files (modular, `#include`-based)
- `dist/v0.1-{date}/Videohub12G_v0.1.qplug` — unencrypted (development)
- `dist/v0.1-{date}/Videohub12G_v0.1.qplugx` — encrypted (delivery)
- `.plugin-guid` — stable GUID (committed to source control)
- GitHub repo: `BMD-Videohub-12G-Qsys` (private, pushed after successful build)

---

*Generated by qsys-plugin skill · Confirm to proceed: "yes" / "modify: [your changes]"*
