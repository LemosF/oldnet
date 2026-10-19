"""OldNet OS - sintetizador de sons originais (nada vem de jogos, anime ou Windows).

A = lado "quente" (sinos e melodias simples, inspirado no espirito XP/95, tudo original)
B = lado "HUD cyberpunk" (blips, varrimentos, bit-crush, glitch)
Uso: python synth.py  -> escreve OGG em ./out/<nome>-a.ogg e <nome>-b.ogg
"""
import os
import numpy as np
import soundfile as sf

SR = 44100
rng = np.random.default_rng(2077)
TAU = 2 * np.pi


def tt(d):
    return np.arange(int(SR * d)) / SR


def osc(phase, wave):
    if wave == "sine":
        return np.sin(phase)
    if wave == "tri":
        return (2 / np.pi) * np.arcsin(np.sin(phase))
    if wave == "saw":
        return 2 * ((phase / TAU) % 1) - 1
    if wave == "square":
        return np.tanh(4 * np.sin(phase))
    raise ValueError(wave)


def ar(n, a=0.004, r=0.08):
    e = np.ones(n)
    na, nr = max(1, min(n, int(SR * a))), max(1, min(n, int(SR * r)))
    e[:na] = np.linspace(0, 1, na)
    e[-nr:] *= np.linspace(1, 0, nr)
    return e


def bell(f, d=1.2, vol=0.4):
    t = tt(d)
    s = sum(a * np.sin(TAU * f * m * t) * np.exp(-t / (d * dec))
            for m, a, dec in [(1, 1, .35), (2.76, .35, .15), (5.4, .15, .08)])
    s *= np.minimum(1, t / 0.003)
    return vol * s / 1.5


def chip(f, d=0.2, vol=0.3, wave="tri"):
    t = tt(d)
    return vol * osc(TAU * f * t, wave) * np.exp(-t / (d * 0.5)) * ar(len(t), .003, .02)


def glide(f0, f1, d, wave="sine", vol=0.3):
    t = tt(d)
    f = f0 * (f1 / f0) ** (t / d)
    return vol * osc(TAU * np.cumsum(f) / SR, wave) * ar(len(t), .004, d * .2)


def blip(f0, f1, d=0.07, vol=0.35):
    return glide(f0, f1, d, "sine", vol) * np.exp(-tt(d) / (d * 0.8))


def pad(freqs, d=2.4, vol=0.15):
    t = tt(d)
    s = sum(np.sin(TAU * f * t) + 0.3 * np.sin(TAU * 2 * f * t) for f in freqs)
    e = np.minimum(1, t / 0.35) * np.exp(-t / (d * 0.45))
    return vol * s * e / len(freqs)


def noise(d, vol=0.3, lp=1, decay=0.4):
    t = tt(d)
    x = rng.uniform(-1, 1, len(t))
    if lp > 1:
        x = np.convolve(x, np.ones(lp) / lp, mode="same")
    return vol * x * np.exp(-t / (d * decay)) * ar(len(t), .002, .02)


def crush(x, bits=6, down=3):
    x = np.repeat(x[::down], down)[:len(x)]
    q = 2 ** (bits - 1)
    return np.round(x * q) / q


def echo(x, delay=0.16, fb=0.35, taps=3):
    n = int(SR * delay)
    out = np.concatenate([x, np.zeros(n * taps)])
    for i in range(1, taps + 1):
        out[n * i:n * i + len(x)] += x * fb ** i
    return out


def stutter(x, start, size, reps):
    a = int(SR * start)
    b = a + int(SR * size)
    return np.concatenate([x[:a]] + [x[a:b]] * reps + [x[b:]])


def mix(parts):
    total = max(int(SR * at) + len(s) for s, at in parts)
    out = np.zeros(total)
    for s, at in parts:
        i = int(SR * at)
        out[i:i + len(s)] += s
    return out


def finalize(x):
    x = np.asarray(x, dtype=np.float64)
    # volume percebido semelhante entre sons (RMS), com margem para o overshoot do Vorbis
    x = x * (0.14 / (np.sqrt(np.mean(x ** 2)) + 1e-9))
    x = x * min(1.0, 0.7 / (np.max(np.abs(x)) + 1e-9))
    n = min(int(SR * 0.03), len(x) // 3)
    x[-n:] *= np.linspace(1, 0, n)
    m = min(int(SR * .002), len(x) // 3)
    x[:m] *= np.linspace(0, 1, m)
    return x.astype(np.float32)


def click(vol=0.3):
    return noise(0.012, vol, lp=6, decay=0.3)


# notas
D5, Fs5, A5, D6 = 587.33, 739.99, 880.0, 1174.66
E6, B6, A6 = 1318.51, 1975.53, 1760.0
C5, E5, G5, C6 = 523.25, 659.25, 783.99, 1046.5


# ---------- sons: (versao A, versao B) ----------
def login_a():
    notes = [D5, Fs5, A5, D6]
    return mix([(bell(f, 1.8, .45), i * .16) for i, f in enumerate(notes)]
               + [(pad([293.66, 440, 587.33], 2.6, .2), 0)])


def login_b():
    parts = [(glide(200, 2400, .35, "saw", .15), 0)]
    parts += [(crush(blip(f, f, .09, .4), 5, 3), .4 + i * .12) for i, f in enumerate([D5, Fs5, A5, D6])]
    parts += [(bell(D6, 1.6, .35), .88), (pad([293.66, 440], 2.4, .15), .35)]
    return mix(parts)


def logout_a():
    notes = [D6, A5, Fs5, D5]
    return mix([(bell(f, 1.4, .35), i * .15) for i, f in enumerate(notes)]
               + [(pad([293.66, 440], 2.0, .15), 0)])


def logout_b():
    parts = [(glide(2000, 120, .7, "saw", .12), 0)]
    parts += [(chip(f, .14, .25), i * .1) for i, f in enumerate([A5, Fs5, D5, A5 / 2])]
    parts += [(noise(.5, .06, lp=12), .5)]
    return mix(parts)


def shutdown_a():
    notes = [A5, E5 * 2 / 2 * 1.0, C5, 392.0]
    notes = [880.0, 659.25, 523.25, 392.0]
    return mix([(bell(f, 2.0, .35), i * .35) for i, f in enumerate(notes)]
               + [(pad([196, 293.66], 2.8, .2), 0)])


def shutdown_b():
    sweep = echo(glide(1400, 40, 1.4, "saw", .25), .2, .3, 2)
    crackle = np.zeros(int(SR * 1.4))
    idx = rng.integers(0, len(crackle), 70)
    crackle[idx] = rng.uniform(-1, 1, 70)
    crackle = np.convolve(crackle, np.ones(8) / 8, mode="same") * np.linspace(1, 0, len(crackle)) * .5
    return mix([(sweep, 0), (crackle, 0), (glide(70, 45, .35, "sine", .4), 1.3)])


def message_a():
    return mix([(bell(E6, .7, .4), 0), (bell(B6, .9, .35), .12)])


def message_b():
    return mix([(echo(blip(900, 1600, .06, .4), .12, .4, 2), 0), (echo(blip(1300, 2200, .06, .4), .12, .4, 2), .09)])


def bell_a():
    return bell(A6, 1.1, .5)


def bell_b():
    return mix([(click(.4), 0), (blip(2400, 2400, .05, .35), .01), (echo(blip(1800, 1800, .12, .3), .1, .35, 2), .06)])


def error_a():
    return mix([(chip(220, .18, .3, "square"), 0), (chip(164.8, .4, .3, "square"), .17)])


def error_b():
    parts = [(crush(glide(110, 110, .09, "saw", .3), 4, 4), i * .13) for i in range(3)]
    parts.append((glide(300, 80, .15, "saw", .25), .4))
    return mix(parts)


def warning_a():
    return mix([(chip(440, .13, .3), 0), (chip(440, .22, .3), .17)])


def warning_b():
    parts = []
    for i, f in enumerate([700, 520, 700]):
        parts += [(blip(f, f, .08, .3), i * .12), (click(.12), i * .12)]
    return mix(parts)


def info_a():
    return mix([(bell(987.77, .6, .35), 0), (bell(E6, .8, .35), .13)])


def info_b():
    return mix([(glide(600, 1800, .12, "sine", .3), 0), (blip(1800, 1800, .05, .3), .12)])


def device_added_a():
    return mix([(chip(C5, .15), 0), (chip(G5, .28), .1)])


def device_added_b():
    return mix([(glide(300, 1500, .18, "tri", .3), 0), (click(.4), .18), (blip(1500, 1500, .06, .3), .2)])


def device_removed_a():
    return mix([(chip(G5, .15), 0), (chip(C5, .28), .1)])


def device_removed_b():
    return mix([(glide(1500, 300, .2, "tri", .3), 0), (click(.4), .2)])


def complete_a():
    notes = [C5, E5, G5, C6]
    return mix([(chip(f, .12, .25), i * .07) for i, f in enumerate(notes)] + [(bell(C6 * 2, 1.0, .3), .28)])


def complete_b():
    return mix([(blip(1200, 1200, .07, .35), 0), (blip(1800, 1800, .09, .35), .09),
                (bell(2093, .9, .25), .15), (bell(3136, .7, .15), .2)])


def trash_a():
    return mix([(noise(.3, .5, lp=20, decay=.3), 0), (glide(110, 60, .15, "sine", .4), .02)])


def trash_b():
    return mix([(crush(noise(.3, .5, lp=3, decay=.35), 4, 5), 0), (glide(800, 100, .25, "square", .12), 0)])


def button_a():
    return glide(1000, 700, .025, "sine", .35) * np.exp(-tt(.025) / .01)


def button_b():
    return blip(1800, 2400, .03, .35)


def quickhack_a():
    notes = [E5, G5, 987.77, D6, E6, 1567.98]
    return mix([(chip(f, .09, .2, "square"), i * .045) for i, f in enumerate(notes)] + [(bell(E6 * 2, .9, .25), .3)])


def quickhack_b():
    x = crush(glide(400, 3000, .25, "saw", .18), 5, 3)
    return mix([(stutter(x, .12, .03, 4), 0), (blip(3000, 3000, .05, .25), .36)])


def blackice_a():
    return mix([(chip(f, .15, .3), i * .16) for i, f in enumerate([880, 660] * 3)])


def blackice_b():
    t = tt(1.0)
    pulse = 0.5 + 0.5 * np.sin(TAU * 8 * t)
    base = osc(TAU * np.cumsum(70 + 700 * t ** 2) / SR, "saw") * pulse * .3 * ar(len(t), .01, .15)
    return mix([(np.convolve(base, np.ones(4) / 4, mode="same"), 0), (noise(1.0, .08, lp=8, decay=1.0), 0)])


def jackin_a():
    notes = [D5, Fs5, A5, D6, Fs5 * 2, A5 * 2, D6 * 2, Fs5 * 4 / 2]
    parts = [(chip(f, .1, .2), i * .06) for i, f in enumerate(notes[:7])]
    parts += [(bell(D6, 1.6, .3), .5), (bell(A5, 1.6, .25), .5), (pad([293.66, 440], 2.0, .15), .45)]
    return mix(parts)


def jackin_b():
    t = tt(.9)
    rush = rng.uniform(-1, 1, len(t)) * (t / .9) ** 2 * .35
    sweep = crush(glide(100, 4000, .9, "saw", .18), 5, 3)
    x = mix([(rush, 0), (sweep, 0)])
    x = stutter(x, .6, .04, 4)
    return mix([(x, 0), (click(.5), .95), (bell(D6, 1.4, .3), 1.0), (bell(A5, 1.4, .22), 1.0)])


SOUNDS = {
    "desktop-login": (login_a, login_b),
    "desktop-logout": (logout_a, logout_b),
    "desktop-shutdown": (shutdown_a, shutdown_b),
    "message-new-instant": (message_a, message_b),
    "bell": (bell_a, bell_b),
    "dialog-error": (error_a, error_b),
    "dialog-warning": (warning_a, warning_b),
    "dialog-information": (info_a, info_b),
    "device-added": (device_added_a, device_added_b),
    "device-removed": (device_removed_a, device_removed_b),
    "complete": (complete_a, complete_b),
    "trash-empty": (trash_a, trash_b),
    "button-pressed": (button_a, button_b),
    "oldnet-quickhack": (quickhack_a, quickhack_b),
    "oldnet-blackice-alert": (blackice_a, blackice_b),
    "oldnet-jack-in": (jackin_a, jackin_b),
}

if __name__ == "__main__":
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")
    os.makedirs(out, exist_ok=True)
    for name, (fa, fb) in SOUNDS.items():
        for tag, fn in (("a", fa), ("b", fb)):
            sf.write(os.path.join(out, f"{name}-{tag}.ogg"), finalize(fn()), SR, format="OGG", subtype="VORBIS")
    print(f"{len(SOUNDS) * 2} ficheiros em {out}")
