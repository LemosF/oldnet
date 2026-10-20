"""OldNet - 6 sons de erro 'futuristas' (UI sci-fi). Original, sintetizado, mesma familia de timbres dos restantes sons OldNet
(blips, varrimentos, bit-crush, sinos/FM). Uso: ..\\..\\.venv\\Scripts\\python.exe synth_futuristic.py -> ./out
"""
import os
import sys

import numpy as np
import soundfile as sf

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "sounds"))
from synth import SR, TAU, ar, bell, click, crush, echo, finalize, glide, mix, noise, stutter, tt  # noqa: E402


def lp(x, k):
    return np.convolve(x, np.ones(k) / k, mode="same")


def fmglide(f0, f1, d, ratio=2.0, idx=3.0, vol=0.35):
    t = tt(d)
    f = f0 * (f1 / f0) ** (t / d)
    ph = TAU * np.cumsum(f) / SR
    return vol * np.sin(ph + idx * np.sin(ratio * ph) * np.exp(-t / (d * .6))) * ar(len(t), .004, d * .35)


def ringmod(x, f):
    return x * np.sin(TAU * f * np.arange(len(x)) / SR)


def hologram():     # dois chirps FM de vidro a descer + shimmer em ring-mod + stutter curto
    a = mix([(fmglide(1600, 500, .28), 0), (fmglide(1200, 380, .28), .12)])
    return mix([(stutter(a + .3 * ringmod(a, 90), .3, .03, 2), 0)])


def shield():       # escudo de energia a falhar: ruido que escurece + ping metalico + pancada
    sweep = np.concatenate([noise(.05, .5, lp=k, decay=1.5) for k in (2, 4, 8, 16, 32, 64)])
    return mix([(sweep, 0), (bell(2200, .5, .22), 0), (glide(110, 50, .2, "sine", .6), .25)])


def reject():       # "uh-oh" com portamento (tri) + ar
    return mix([(glide(660, 520, .12, "tri", .35), 0), (glide(520, 330, .22, "tri", .35), .13), (noise(.3, .05, lp=2, decay=.6), 0)])


def corrupt():      # rajada de blips com tom aleatorio (dados corrompidos) + pancada
    rng = np.random.default_rng(9)
    freqs = rng.uniform(600, 3000, 8)
    blips = [(crush(glide(f, f, .03, "square", .22), 4, 3), i * .035) for i, f in enumerate(freqs)]
    return mix(blips + [(glide(120, 50, .22, "sine", .55), .3)])


def powerfail():    # motor/energia a parar (dente-de-serra a cair com tremolo) + relay
    t = tt(.7)
    f = 900 * (40 / 900) ** (t / .7)
    x = .3 * (2 * ((np.cumsum(f) / SR) % 1) - 1) * (0.55 + 0.45 * np.sin(TAU * 14 * t)) * ar(len(t), .004, .3)
    return mix([(click(.5), 0), (lp(x, 3), .02)])


def lockerr():      # bip-bip-bzzt
    def tone(f, d):
        return .35 * np.sin(TAU * f * tt(d)) * ar(int(SR * d), .004, .01)
    return mix([(tone(1500, .07), 0), (tone(1500, .07), .12), (crush(glide(150, 150, .22, "saw", .35), 4, 3), .26)])


SOUNDS = {"hologram": hologram, "shield": shield, "reject": reject, "corrupt": corrupt, "powerfail": powerfail, "lockerr": lockerr}

if __name__ == "__main__":
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")
    os.makedirs(out, exist_ok=True)
    for name, fn in SOUNDS.items():
        sf.write(os.path.join(out, f"futuristic-error-{name}.ogg"), finalize(fn()), SR, format="OGG", subtype="VORBIS")
    print(len(SOUNDS), "ficheiros em", out)
