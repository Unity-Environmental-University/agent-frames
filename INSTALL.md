# Install

## Requirements

- `bash` (any reasonably modern version — 3.2 on macOS works)
- `awk`, `sed`, `grep`, `date`, `shasum` (standard unix)
- `python3` (used by the sed-replace step in setup, not at runtime)

No npm, no pip, no compile. ~700 lines of bash.

## Quick install

```bash
git clone https://github.com/YOUR-USERNAME/agent-frames.git ~/agent-frames
ln -s ~/agent-frames/bin/frame ~/.local/bin/frame
# ensure ~/.local/bin is on your PATH; if not:
#   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

Verify:

```bash
frame --help
bash ~/agent-frames/test/smoke.bash  # 22 checks, takes ~5 seconds
```

## Alternative: clone-and-use-without-installing

If you don't want to link it into PATH, just clone and call it directly:

```bash
git clone https://github.com/YOUR-USERNAME/agent-frames.git
~/agent-frames/bin/frame --help
```

## Environment variables

| Variable | Default | Meaning |
|---|---|---|
| `AGENT_FRAMES_SESSION` | hash of `pwd` | Session key. State files share this prefix. **Export explicitly** when calling from tools that wipe env between invocations (e.g. Claude Code's Bash tool). |
| `FRAME_EDGE_BRIDGE` | unset | If `1` and `edge` is in PATH, also mirror writes to the [rhizome](https://github.com/anthropics/rhizome) knowledge graph. Default is self-contained TSV only. |

## State files

Everything lives under `~/.agent_frames/`:

```
~/.agent_frames/
├── <session>.frames.tsv          # id, type, parent, opened-at, state
├── <session>.strikes.tsv         # frame-id, ts, origin
├── <session>.tries.tsv           # frame-id, ts, action, state
├── <session>.edges.tsv           # ts, subject, predicate, object, phase
├── <session>.circle-strikes.tsv  # frame-id, ts, cause (side log)
├── <session>.current             # pointer to current frame
└── <session>.root                # pointer to root frame
```

All TSV, all grep/awk-friendly. No binary state.

## Uninstall

```bash
rm ~/.local/bin/frame
rm -rf ~/agent-frames
rm -rf ~/.agent_frames  # if you also want to clear your history
```
