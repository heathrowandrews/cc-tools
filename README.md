# cc-tools

A command center for running multiple [Claude Code](https://claude.ai/claude-code) sessions in macOS Terminal.app.

Tiles your Terminal windows into a grid, color-codes them by status (working, waiting for approval, done), and gives you a live dashboard — all automatic.

![](https://img.shields.io/badge/⚡_working-00ff00?style=flat-square) ![](https://img.shields.io/badge/🔶_approval-ff9900?style=flat-square) ![](https://img.shields.io/badge/✓_done-555555?style=flat-square) ![](https://img.shields.io/badge/💤_stale-222222?style=flat-square&labelColor=222222)

## What it does

- **cc-snap** — Watches for Terminal windows running Claude Code, tiles them edge-to-edge, and live-colors each window based on session status (cyberpunk palette)
- **cc-hub** — Mission control dashboard showing all active sessions at a glance
- **cc-hub-hook** — Claude Code hook that reports session status changes
- **cc-grid** — tmux-based grid launcher for opening multiple Claude Code sessions at once
- **cc-start** — One command to launch the full command center

### Status colors

| Status | Look | Meaning |
|--------|------|---------|
| **⚡ working** | Bright neon green on dark green | Claude is thinking or running tools |
| **🔶 approval** | Hot amber/orange on warm glow | Claude needs you to approve a tool call |
| **✓ done** | Muted green on dark gray | Claude finished, your move |
| **💤 stale** | Ghost text on near-black | Done for 3+ minutes, cooling off |
| **○ idle** | Dim green on dark | Session started, no activity yet |
| **⊘ ended** | Near-invisible | Session closed |

## Requirements

- macOS (uses Terminal.app + AppleScript for window management)
- [Claude Code](https://claude.ai/claude-code) CLI
- bash 4+ (`brew install bash` if needed)
- tmux (only for `cc-grid`, optional)

## Install

```bash
git clone https://github.com/heathrowandrews/cc-tools.git
cd cc-tools
./install.sh
```

Or manually copy the scripts to somewhere on your `$PATH`:

```bash
cp cc-grid cc-hub cc-hub-hook cc-snap cc-start ~/.local/bin/
chmod +x ~/.local/bin/cc-{grid,hub,hub-hook,snap,start}
```

### Set up the Claude Code hooks

Add this to your Claude Code settings (`~/.claude/settings.json`) to enable automatic status reporting:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "cc-hub-hook approval", "timeout": 5000 }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "cc-hub-hook working", "timeout": 5000 }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "cc-hub-hook done", "timeout": 5000 }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "cc-hub-hook done", "timeout": 5000 }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "cc-hub-hook idle", "timeout": 5000 }
        ]
      }
    ],
    "SessionEnd": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "cc-hub-hook ended", "timeout": 5000 }
        ]
      }
    ]
  }
}
```

The hook flow:
- **PreToolUse → approval**: Flashes amber before each tool. Auto-approved tools flip back to green instantly. Tools needing your OK stay amber until you approve.
- **PostToolUse → working**: Green glow — Claude is alive and running.
- **Notification/Stop → done**: Gray — Claude's turn is over, waiting on you.
- **SessionStart → idle**: Dark — just booted up.
- **SessionEnd → ended**: Near-invisible — session is gone.
- **Stale (auto)**: After 3 min of "done", cc-snap auto-dims to near-black. No hook needed.

## Usage

### Quick start — full command center

```bash
cc-start
```

This launches the hub dashboard and snap daemon. Then just open Claude Code in any Terminal window — it auto-joins the grid.

### Individual tools

```bash
# Tile + color all Claude windows once
cc-snap

# Run snap daemon in background (auto-tiles continuously)
cc-snap --bg

# Stop the daemon
cc-snap --stop

# View session statuses
cc-hub

# Live dashboard (refreshes every 3s)
cc-hub --live

# Compact header bar
cc-hub --header

# Launch a tmux grid with specific projects
cc-grid ~/Projects/my-app ~/Projects/my-api

# Interactive project picker
cc-grid

# Open recent projects automatically
cc-grid --all
```

## How it works

1. **cc-hub-hook** is called by Claude Code hooks on every status change, writing JSON status files to `/tmp/cc-hub/`
2. **cc-snap** watches for Terminal windows running Claude Code, reads those status files, and uses AppleScript to tile windows and set colors
3. **cc-hub** reads the same status files to show a dashboard

The status flow:
```
Claude Code hook fires
    -> cc-hub-hook writes /tmp/cc-hub/<session>.json
    -> cc-snap reads status, tiles window, sets colors
    -> cc-hub reads status for dashboard display
```

## License

MIT
