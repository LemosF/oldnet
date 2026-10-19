"""OldNet - 2 propostas NOVAS (c e d) para alarm-clock-elapsed, battery-caution e phone-incoming-call.
Conceitos diferentes das versoes a/b. Uso: ..\\.venv\\Scripts\\python.exe synth3.py -> ./out/*-c.ogg e *-d.ogg
"""
import os
import sys

import numpy as np
import soundfile as sf

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "sounds"))
from synth import SR, TAU, ar, bell, echo, finalize, glide, mix, tt  # noqa: E402


def fm(f, d, ratio=2.0, idx=3.0, vol=0.4, tau=0.3):
    t = tt(d)
    env = np.exp(-t / (d * tau))
    return vol * np.sin(TAU * f * t + np.sin(TAU * f * ratio * t) * idx * env) * env * np.minimum(1, t / 0.004)


def tone(f, d, vol=0.4):
    return vol * np.sin(TAU * f * tt(d)) * ar(int(SR * d), .004, .015)


def lp(x, k):
    return np.convolve(x, np.ones(k) / k, mode="same")


# ---------------- alarm-clock-elapsed
def alarm_c():      # arpejo FM que repete 3x a ficar mais forte
    notes = [659.25, 830.61, 987.77, 1318.51]
    return mix([(fm(f, .5, 3.0, 2.5, .25 + r * .12, .25), r * .75 + i * .09) for r in range(3) for i, f in enumerate(notes)])


def alarm_d():      # despertador digital de pulso: bip-bip-bip-biiip, duas vezes
    def group():
        return mix([(tone(2048, d, .4), at) for d, at in ((.08, 0), (.08, .14), (.08, .28), (.28, .42))])
    return echo(mix([(group(), 0), (group(), 1.05)]), .11, .25, 2)


# ---------------- battery-caution
def battery_c():    # sonar: ping longo com ecos
    t = tt(.7)
    ping = .45 * np.sin(TAU * 700 * t) * np.exp(-t / .12) * np.minimum(1, t / .003)
    return mix([(echo(ping, .26, .5, 3), 0), (echo(.35 * np.sin(TAU * 520 * t) * np.exp(-t / .12), .26, .45, 2), .9)])


def battery_d():    # queda de tensao + dois batimentos
    return mix([(glide(600, 70, .55, "tri", .3), 0), (glide(80, 50, .12, "sine", .6), .55), (glide(70, 45, .14, "sine", .5), .72)])


# ---------------- phone-incoming-call
def ring():
    t = tt(.4)
    f = np.where(((t * 40) % 1) < .5, 1000, 1250)
    ph = TAU * np.cumsum(f) / SR
    x = lp(.3 * np.sin(ph) + .1 * np.sin(2 * ph), 4)
    return x * ar(len(t), .01, .03)


def phone_c():      # toque de telefone classico (trilo), 2 + 2 toques
    return mix([(ring(), at) for at in (0, .6, 1.5, 2.1)])


def phone_d():      # frase FM minor pentatonica + pulso grave
    notes = [440, 523.25, 659.25, 783.99, 659.25, 523.25]
    phrase = mix([(fm(f, .5, 3.0, 2.2, .3, .25), i * .16) for i, f in enumerate(notes)]
                 + [(glide(110, 80, .3, "sine", .35), 0), (glide(110, 80, .3, "sine", .35), .64)])
    return echo(phrase, .24, .3, 2)


SOUNDS = {"alarm-clock-elapsed": (alarm_c, alarm_d), "battery-caution": (battery_c, battery_d), "phone-incoming-call": (phone_c, phone_d)}

if __name__ == "__main__":
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")
    for name, (c, d) in SOUNDS.items():
        for tag, fn in (("c", c), ("d", d)):
            sf.write(os.path.join(out, f"{name}-{tag}.ogg"), finalize(fn()), SR, format="OGG", subtype="VORBIS")
    print(len(SOUNDS) * 2, "ficheiros novos em", out)
