# VS Code extension repairs — 2026-09-05

The coordinated app remains VS Code 1.136.1. Workspace extensions run on MSI;
both desktop clients use that shared installation. `release.json` records the
upstream VSIX hashes and each exact local repair, including input/output hashes.
These are local fixes, not new publisher releases.

| Extension | Cause | Repair and validation |
| --- | --- | --- |
| Chat Customizations 1.1.2026090319 | Its language client requires a log output channel, but receives a plain channel. Initialization fails and logging masks the original exception. | Create the channel with `{ log: true }`. Native VS Code startup, a real language-server IPC request, and shutdown passed. |
| Codex 26.901.22334 | A hidden editor can reach the renderer watchdog before VS Code creates its iframe. The watchdog then replaces its HTML, so revealing it cannot recover. | Run the existing 30-second watchdog while the view is visible. A native hidden-editor test reproduced the original failure and loaded successfully with the repair. |

Apply or verify the declared MSI repairs with the **repository helper**:

```sh
python3 config/vscode/extensions.py repair \
  --target msi-ssh \
  --code "$HOME/.vscode-server/bin/a44adf7f53e00964ab890f9f8758a334f1fc15bc/bin/code-server" \
  --extensions-dir "$HOME/.vscode-server/extensions" \
  --user-data-dir "$HOME/.vscode-server/data" \
  --cache-dir "$HOME/.cache/vscode-release/2026-09-04/vsix"
```

Use `check` instead of `repair` for verification. Repair checks the entire pinned
extension set before editing, accepts only original or declared repaired bytes,
and is safe to repeat. Staging a later release applies its declared repairs too.
Remove a repair when selecting a publisher version that fixes the same defect.

Backups and receipts are under
`~/.cache/vscode-release/2026-09-05-extension-repair/`. The original September 4
cutover cache and installed Nix helper describe the original release; do not use
them to reapply or verify these repairs. The updated helper is included in the
next coordinated Nix activation. No app-server binary or chat history is patched.

Loaded extension hosts retain their old JavaScript until the window reloads.
Save work and reload the MSI SSH window after the active agent turn finishes;
then verify opening a chat, switching away for over 30 seconds, reopening it,
and reconnecting. Isolated tests do not replace this user-window acceptance.

The Mac also had two ordinary Copilot cache files at `0444`; they were changed
to `0644` without changing contents. MSI's copies were already writable. A
separate local empty Mac window was activating local Copilot, whose copy routine
can recreate read-only cache files from the Nix store. Close that local window
and use the VS Code MSI launcher. Never make the Nix store writable.


`vscode-icons` 12.19.0 writes its two declared theme JSON files at runtime.
Its packaged `IconsGenerator.persist` writes both VS Code and Zed themes after
customization/project detection. Replaying the default generator produced the
Mac's files byte-for-byte: the default Angular-disabled preset removes the
`ng_tailwind` mappings present in the published manifests. `generatedFiles`
therefore treats only those two paths as generated JSON objects; they must remain
regular nonsymlink files inside the extension. Every executable and icon asset
still matches the pinned VSIX. The existing generated themes are preserved.
