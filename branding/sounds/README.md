# OldNet sounds

Every sound is synthesized from scratch (numpy + soundfile). No samples are used,
from games, anime, Windows or anywhere else. Licensed Apache-2.0 like the rest of
the repo.

| Script | Events | Variants |
|---|---|---|
| `synth.py` | the first 16 (login, notifications, devices, OldNet events) | a, b |
| `synth2.py` | 14 more freedesktop events (volume, battery, power, email, outcomes…) | a, b |
| `synth3.py` | alternative takes for alarm-clock-elapsed, battery-caution, phone-incoming-call | c, d |

- `-a`: warm chimes and simple melodies
- `-b`: cyberpunk HUD (blips, sweeps, bit-crush, glitch)
- `-c`, `-d`: different concepts (FM arpeggio, sonar, classic phone trill, digital beeper)

`synth2.py` and `synth3.py` reuse the helpers in `synth.py`, so keep the three together.

## Regenerate

```sh
python -m venv .venv && .venv/bin/pip install numpy soundfile
.venv/bin/python synth.py        # out/<event>-a.ogg, out/<event>-b.ogg
.venv/bin/python synth2.py
.venv/bin/python synth3.py       # out/<event>-c.ogg, out/<event>-d.ogg
```

The output is deterministic (fixed seed). All 66 variants ship in
`/usr/share/oldnet/sounds-candidates/`.

## Variants used by the OldNet sound theme

`system_files/usr/share/sounds/OldNet/stereo/<event>.ogg` is a copy of the
chosen variant:

| Event | Variant |
|---|---|
| alarm-clock-elapsed | c |
| audio-volume-change | b |
| battery-caution | b |
| battery-full | b |
| battery-low | b |
| bell | b |
| button-pressed | a |
| complete | a |
| desktop-login | b |
| desktop-logout | b |
| desktop-shutdown | b |
| device-added | b |
| device-removed | b |
| dialog-error | b |
| dialog-information | b |
| dialog-question | b |
| dialog-warning | a |
| message-new-email | b |
| message-new-instant | b |
| oldnet-blackice-alert | b |
| oldnet-jack-in | b |
| oldnet-quickhack | b |
| outcome-failure | b |
| outcome-success | b |
| phone-incoming-call | c |
| power-plug | b |
| power-unplug | b |
| screen-capture | b |
| trash-empty | a |
| window-attention | b |

## Login screen sound

`futuristic-errors/synth_futuristic.py` (also uses `synth.py`) makes the
"lockerr" sound: bip (0.00 s), bip (0.12 s), bzzt (0.26–0.45 s). The SDDM theme
plays it when a login fails, from
`system_files/usr/share/sddm/themes/oldnet/assets/login-failed.wav`. It is a WAV
because Qt's SoundEffect only plays WAV. The theme's animation is timed to it: soft
pulses on the bips, then the panel jolt on the bzzt (`bzztAt` in `Main.qml`).

Not audible yet: the login screen runs as the `sddm` user without PipeWire, so
the sound has no audio device. The theme keeps the code and the timing.
