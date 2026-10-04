# Local Windows installation

Repository: `https://github.com/calesthio/OpenMontage`

Installed upstream revision: `08e2151fa02de28a5d6a312b3d575692bf147ad7`.

## Activate before running commands

```powershell
Set-Location 'C:\Users\luyun\Projects\OpenMontage'
. .\Activate-OpenMontage.ps1
```

Repeat activation in each new shell. The activation script selects the local Python environment, portable Node/npm, FFmpeg, UTF-8 output, and the dedicated browser for HyperFrames. No global PATH changes were made.

## Installed

- Python 3.13 environment in `.venv`, with upstream `requirements.txt`.
- Piper TTS and reference-analysis packages: yt-dlp, youtube-transcript-api, PySceneDetect/OpenCV, faster-whisper.
- Official Node.js 24.21.0 Windows archive, verified against its published SHA-256, in `.runtime`.
- FFmpeg and FFprobe 9.0.1 copied from the existing local media tools into `.runtime/ffmpeg`.
- Remotion composer dependencies from the upstream lockfile, followed by compatible npm audit fixes. The only tracked change is `remotion-composer/package-lock.json`.
- HyperFrames 0.8.50 in npm's local execution cache.
- Chrome Headless Shell downloaded through the Remotion CLI into `.remotion`.
- `.env` copied from the upstream example. No private provider credentials added.

Python package versions are recorded in `.runtime/python-installed.txt`.

## Backlot

```powershell
python -m backlot open
```

Library: http://127.0.0.1:4750/

The server was started during installation on loopback only. It may need restarting after reboot. It is not a Windows startup service. No sample production was created.

## Verification

- Python dependency consistency check passed.
- Reference-analysis and Piper modules imported successfully.
- Registry discovery reported FFmpeg, Remotion and HyperFrames available.
- Remotion bundled the supplied compositions and enumerated all 13 using the dedicated browser. Two default preview asset requests returned 404; no production render was tested.
- HyperFrames doctor passed Node, FFmpeg, FFprobe and the dedicated Chrome checks. Docker, whisper-cpp, Kokoro and MusicGen are not installed. OpenMontage's separate faster-whisper and Piper packages are installed; model/voice downloads may happen at first use.
- Backlot health endpoint and library page responded successfully.
- Composer npm audit reported zero vulnerabilities after compatible fixes.

For explicit Remotion browser selection, use:

```powershell
Set-Location remotion-composer
npx remotion compositions src/index.tsx --browser-executable="$env:HYPERFRAMES_BROWSER_PATH"
```

## Ark / 1Password reusable session (verified 2026-09-30)

Seedance 2.5 direct Ark access is verified: task `cgt-20260930224028-umabp`
produced a 4-second 854x480 H.264 MP4 with stereo AAC audio (38,830 tokens).
The key remains in 1Password; it is not saved in `.env` or scripts.

Start one long-lived session per production run:

```powershell
powershell -NoProfile -File .runtime/Start-ArkSession.ps1
```

For a Codex agent, launch the command with `exec_command` using `tty: true`.
Keep the returned session ID and use `write_stdin` for every subsequent command.
Do not launch a fresh shell or `op run` for each generation/query. The launcher
resolves `op://Private/volcengine API key/credential` once. Windows Hello may ask
for approval at startup. The worker holds the key in its environment until exit;
locking 1Password does not revoke a key already loaded into this process.
It opens no network listener. Only normal Ark requests go to the network.

Send one JSON object per line (follow each line with a newline):

```json
{"id":"health","action":"ping"}
{"id":"inspect","action":"execute","inputs":{"task_action":"query","task_id":"cgt-20260930224028-umabp"}}
{"id":"preview","action":"dry_run","inputs":{"prompt":"A paper boat on water","duration":4,"resolution":"480p","custom_price_cny_per_million_tokens":70}}
{"action":"quit"}
```

`execute` delegates to the existing `seedance_ark` registry tool; `dry_run` makes
no API submission. Default model is `doubao-seedance-2-5-260628` and default task
action is `create` (submit and return task ID). Paid create/generate calls require
a unique command `id`; repeated IDs in the same worker are rejected. Save the
returned task ID immediately, then query it; never resubmit an ambiguous result.
Normal production pipeline, cost, approval, and output-path rules still apply.
For paid requests, pass the current price and a project-scoped output path.
The session transport does not automatically archive responses: callers must
save needed task IDs and results into the production workspace.

Use `quit` when finished. EOF also shuts it down. A new session may need another
1Password approval. Terminal sessions may not survive app restart; an old saved
session ID is only a hint, so ping before reuse. There is no automatic keepalive
or change to 1Password's authorization settings.

Read-only verification: two queries of the completed test task succeeded through
one worker PID, with no additional credential lookup. An invalid command returned
an error and the worker remained usable. No paid generation was run for this setup.

## ElevenLabs / 1Password sessions

For future projects using ElevenLabs narration, use the existing direct
`elevenlabs_tts` registry tool with this credential reference:
`op://Private/ElevenLabs API Key/credential`.
The reference is stored in the launcher; the resolved key stays in process
memory and is never written to `.env` or scripts.

Start one reusable shell per production run from the repository root:

```powershell
powershell -NoProfile -File .runtime/Start-ElevenLabsSession.ps1
```

1Password may request Windows Hello at startup. The launcher uses `op run`
with secret masking enabled and opens an activated PowerShell session.
All Python commands launched INSIDE this session inherit `ELEVENLABS_API_KEY`.
Ordinary shells, an already-running Backlot server, and merely dot-sourcing
`Activate-OpenMontage.ps1` do not gain access to the key.

For agents: start with `exec_command` and `tty: true`; retain the returned
session ID and send subsequent PowerShell commands using `write_stdin`.
Before reusing a saved session, send `Write-Output 'elevenlabs-session-alive'`.
Do not run a new `op run` per API call or inspect/print the resolved key.
Exit with `exit` when finished. A new session may need another 1Password
approval; locking 1Password does not revoke a key already in process memory.

Run the repeatable, read-only check inside the session:

```powershell
python .runtime/verify_elevenlabs.py
```

It checks registry availability and authenticated user/voice API reads,
printing only status codes and availability booleans. It does not generate
audio or verify paid TTS execution. User-read and voices-read permissions
are needed for this check, and text-to-speech permission is needed for narration.

Verified 2026-10-03: `elevenlabs_tts` reported available, both account and
voice-list reads returned HTTP 200, and a voice was visible. The launcher
passed PowerShell syntax validation, and the check failed safely in a shell
without the credential. No paid audio was generated. The verification shell
was closed afterward; start a new session for the next production run.

When ElevenLabs is selected in a production plan, set the TTS selector's
`preferred_tool` to `elevenlabs_tts` to use this direct account. Choose the
voice/model in the project proposal, verify current pricing, and keep normal
pipeline approvals and project-scoped output paths. This setup does not change
other providers or automatically select ElevenLabs for every project.

## Original installation scope

At initial installation, the media catalog adapter, Sony-to-Fuji color recipe, provider keys, and optional GPU generation models were not configured. Ark access has since been verified through the 1Password session described above. Original media and the existing catalog were not changed.

The activation script, this note, `.runtime/Start-ElevenLabsSession.ps1`, and
`.runtime/verify_elevenlabs.py` are tracked for reuse on this Windows setup.
Downloaded runtimes, environment files, and the separate Ark session helpers
remain locally ignored. A fresh checkout still needs the runtimes listed above;
the activation script does not install them.
