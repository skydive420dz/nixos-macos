# Mac home cleanup — 2026-09-23

## Scope and decision

Target: `Rafaels-MacBook-Air`, home `/Users/skydive420dz`, configuration
checkout `~/Projects/nixos-macos`.

The user approved removing the audit's listed migration leftovers, retired
configuration backups, local Codex history and inactive diagnostic logs. The
user confirmed that important migrated history worked on MSI and accepted loss
of the remaining local history and backups. Completeness of that migration was
not independently verified.

This was cleanup, not a configuration deployment. No Nix build, activation,
garbage collection, channel update or application installation was performed
as part of removal. Existing system generations were not removed.

## Removed

### Home-folder migration artifacts

All 18 listed items directly under the home directory were removed:

- `nix-migration-system` — only the symlink, not its Nix-store target.
- `nix-migration-activate`
- `nix-migration-build-20260916T0332Z.result`
- `nix-migration-backup-20260916T030736Z/`
- `nix-activation-backup-20260916T1228Z/`
- `nix-repo-before-pull-20260916T1134Z/`
- `kanata-driver-activate-20260917.log`
- `kanata-driver-deactivate-20260917.log`
- `kanata-start-20260917.log`
- `nix-approved-activation-20260916T1230Z.log`
- `nix-approved-backup-20260916T1228Z.log`
- `nix-approved-file-handoff-20260916T1230Z.log`
- `nix-approved-service-check-20260916T1235Z.log`
- `nix-approved-service-check-final-20260916T1238Z.log`
- `nix-kanata-activation-20260917.log`
- `nix-kanata-build-20260917.log`
- `nix-migration-build-20260916T0332Z.log`
- `nix-reviewed-build-20260916T1224Z.log`

The root-owned activation backup required local user action. Its absence was
confirmed afterward. The other 17 home-folder items were removed over SSH.
System generation 1 independently referenced the migration build at inspection.

### Retired configurations and other leftovers

Paths below are relative to the home directory:

- `.cache/vscode-release/2026-09-04/`
- `.cache/vscode-release/2026-09-05-extension-repair/`
- `.config/emacs.doom-upstream-20260607/`
- `.config/emacs.hm-backup/`
- `.config/karabiner/karabiner.json.hm-backup`
- `.ssh/ssh-config.skydive420dz`
- `.ssh/config.before-shared-hosts-2026-08-02`
- `.ssh/known_hosts.old`
- `.config/darktable/data.db-pre-3.6.1`
- `.config/darktable/library.db-pre-3.6.1`
- `.cmake/packages/ZephyrUnittest/40324cf8b0a3e4ce8b1182699e9b4634`
- `.local/share/wezterm/agent.12308`
- `Projects/nixos-macos/result` — a broken symlink.
- `Projects/nixos-macos/nvim.log`

### Local history and inactive logs

Removal waited until the process check no longer showed local VS Code/Codex.
An open-file check preceded deletion. These selected paths were removed:

- `.codex/sessions/`, `session_index.jsonl`, `shell_snapshots/`, `attachments/`
- `.codex/thread_history_1.sqlite`, `goals_1.sqlite`, `logs_2.sqlite`
- Existing matching `-wal` and `-shm` sidecars for the removed databases.
- Existing `.copilot/logs/*.log` and `.npm/_logs/*.log`
- Existing `.local/state/nvim/*.log` and `.local/state/nvf/*.log`
- `.local/state/nvf/smart_splits_nvim/log.txt`
- Existing `.local/share/wezterm/wezterm-gui-log-*.txt`, excluding
  `wezterm-gui-log-19234.txt`, the retained active terminal log.

These patterns describe the files selected during this cleanup, not an ongoing
automatic deletion policy. No cleanup job or timer was installed.

## Preserved

- Current SSH credentials/configuration, application authentication and settings.
- Current shell and Home Manager links, application configurations and packages.
- `.cache/emacs/`, which holds active Emacs runtime/package data.
- `.codex/auth.json`, `config.toml`, `state_5.sqlite`, `queue_1.sqlite`,
  `memories_1.sqlite`, and the retained databases' sidecars.
- `.codex/generated_images/` and current agent skills/configuration.
- Current VS Code profiles/extensions and terminal runtime files.
- `~/.nix-defexpr` and `~/.nix-profile`. Their legacy-profile/channel role was
  left for a separate read-only investigation, not changed here.
- Personal folders and the current configuration repository.

## Evidence and limits

SUPPORTED by the cleanup tool receipts and inspections:

- The first removal pass confirmed 31 selected paths removed. The root-owned
  backup was blocked pending local action; its absence was subsequently checked.
- The second pass confirmed 47 selected paths removed and no remaining candidates
  from that pass's expanded list.
- Content hashes before/after the second pass matched for retained Codex
  authentication/configuration and the three retained database main files, plus
  the SSH private key and configuration. No credential values or hashes are
  published here. This was not an exhaustive comparison of every retained file.
- The repository was clean after removal, before this documentation was added.
- Before removing the repository archive, 143 Git-managed archived files matched
  the retained stash, with no content mismatches. Both saved patches matched Git
  diffs. Additional archived configuration/document files checked against the
  current checkout were identical. Git metadata was not exhaustively compared.

The Codex audit measured approximately 16.90 GiB across its five largest removal
candidate groups. This was an earlier inventory measurement, not a measured
post-cleanup free-space increase. Filesystem snapshots/sharing and concurrent
activity can affect actual reclaimed space.

The audit report was read at `/tmp/mac-home-removal-report-20260923.md` on MSI,
not on the Mac. That temporary report and the session's tool receipts are the
source records; they are not committed here and their temporary paths may expire.
This document records the completed scope rather than promising those paths
remain available.

During the earlier investigation, `nix-store --query --roots` unexpectedly
cleaned stale GC-root bookkeeping. Its output did not report deleting builds.
That side effect occurred before removal and is not omitted from this record.

No post-cleanup interactive application acceptance test was performed. Deleting
local transcripts intentionally means old local conversations may no longer
open even when mixed runtime-state databases retain their entries. The removed
backups and history are not recoverable from this documentation or Git commit.

## Follow-up: redundant .doom.d link

The user separately approved removing only the `.doom.d` Home Manager
declaration and live symlink, with validation and a documented commit.

SUPPORTED by source inspection and the SSH change/validation receipts:

- Removed `home.file.".doom.d".source` from
  `home-manager/modules/programs/emacs.nix`.
- Unlinked `/Users/skydive420dz/.doom.d` after verifying it was a symlink
  resolving to `/Users/skydive420dz/Projects/nixos-macos/config/doom`.
  Its absence was checked with `os.path.lexists`.
- Preserved `/Users/skydive420dz/.config/doom`,
  `/Users/skydive420dz/.config/emacs`, and both repository target directories.
  Before/after checks matched link text, resolved paths, and target inodes.
  This was not a recursive content comparison.
- `nix-instantiate --parse` passed for the candidate on stdin and the edited
  module. `git diff --check` passed.
- The repository was clean before the change. Only the Emacs module and this
  cleanup note are included in the follow-up commit.

DERIVED rationale: the removed link is redundant for the inspected clean Emacs
workflow. The module labels Doom as frozen reference material, and the installed
`emacs-sync` loads `.config/emacs/early-init.el` and `.config/emacs/init.el`.
The retained `.config/doom` still provides access to the reference files.

No build, full flake evaluation, activation, Emacs launch, Doom command, channel
operation, garbage collection, or push was performed. Syntax validation is not
runtime acceptance. Uninspected external scripts may still refer to `.doom.d`.

The currently activated Home Manager generation still declares `.doom.d` and
could recreate it if reactivated. The source change removes that declaration
for a future rebuild; no deployment is claimed here. To undo this cleanup,
restore the declaration from Git and restore `.doom.d` as a symlink to the
preserved reference directory. Do not delete that directory or Nix-store links.
