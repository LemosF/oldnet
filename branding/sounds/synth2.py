"""OldNet - segundo lote de sons (14 eventos freedesktop, versoes A e B). Original, sintetizado.
Reutiliza os helpers de ../sounds/synth.py.  Uso: ..\\.venv\\Scripts\\python.exe synth2.py -> ./out
"""
import os
import sys

import numpy as np
import soundfile as sf

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "sounds"))
from synth import (SR, bell, blip, chip, click, crush, echo, finalize, glide, mix, noise, pad, stutter,  # noqa: E402
                   C5, E5, G5, C6, D5, Fs5, A5, D6, E6, B6, A6)

G6, B5, E4, C4, A4 = 1567.98, 987.77, 329.63, 261.63, 440.0
A_, B_ = {}, {}


def reg(name):
    def deco(pair_fn):
        a, b = pair_fn()
        A_[name], B_[name] = a, b
        return pair_fn
    return deco


@reg("audio-volume-change")
def _():
    return (lambda: bell(1000, .16, .4),
            lambda: mix([(blip(1400, 1600, .04, .35), 0), (click(.3), 0)]))


@reg("message-new-email")
def _():
    return (lambda: mix([(chip(f, .1, .22), i * .09) for i, f in enumerate([E5, G5, C6])] + [(bell(C6 * 2, 1.0, .3), .25)]),
            lambda: mix([(glide(300, 1800, .15, "saw", .12), 0)] +
                        [(crush(blip(f, f, .06, .35), 5, 3), .17 + i * .08) for i, f in enumerate([1800, 1500, 1200])]))


@reg("battery-low")
def _():
    return (lambda: mix([(bell(A5, 1.0, .4), 0), (bell(E5, 1.3, .4), .3)]),
            lambda: mix([(crush(glide(220, 220, .12, "saw", .3), 5, 3), 0), (crush(glide(220, 220, .12, "saw", .3), 5, 3), .2),
                         (glide(600, 150, .35, "tri", .25), .42)]))


@reg("battery-caution")
def _():
    return (lambda: mix([(chip(f, .12, .3, "square"), i * .14) for i, f in enumerate([A5, E5, A5 / 2])] + [(pad([220, 329.63], .9, .12), 0)]),
            lambda: mix([(glide(320, 90, .22, "sine", .45), 0)] +
                        [(echo(blip(f, f, .07, .35), .09, .3, 2), .26 + i * .17) for i, f in enumerate([880, 660, 880])] +
                        [(stutter(crush(glide(900, 300, .12, "tri", .25), 5, 3), .03, .03, 3), .8)]))


@reg("power-plug")
def _():
    return (lambda: mix([(chip(C5, .1, .28), 0), (chip(G5, .2, .28), .08), (click(.3), .02)]),
            lambda: mix([(glide(200, 1200, .2, "tri", .3), 0), (click(.5), .2), (blip(1200, 1200, .05, .3), .22)]))


@reg("power-unplug")
def _():
    return (lambda: mix([(chip(G5, .1, .28), 0), (chip(C5, .22, .28), .08), (click(.3), .02)]),
            lambda: mix([(glide(1200, 200, .22, "tri", .3), 0), (click(.5), .22)]))


@reg("dialog-question")
def _():
    return (lambda: mix([(chip(A5, .12, .28), 0), (bell(B5 * 1.12, .8, .35), .13)]),
            lambda: echo(glide(700, 1100, .14, "sine", .35), .12, .3, 2))


@reg("outcome-success")
def _():
    return (lambda: mix([(bell(f, 1.4, .4), i * .1) for i, f in enumerate([G5, B5, D6, G6])] + [(bell(G6 * 2, 1.0, .18), .35)]),
            lambda: mix([(glide(500, 2400, .2, "saw", .12), 0), (blip(1500, 1500, .07, .35), .22), (blip(2000, 2000, .09, .35), .31),
                         (bell(3136, .9, .22), .35), (bell(2093, 1.0, .25), .35)]))


@reg("outcome-failure")
def _():
    return (lambda: mix([(chip(E4, .22, .3, "square"), 0), (chip(C4, .5, .3, "square"), .2), (bell(C4, 1.2, .3), .2)]),
            lambda: mix([(stutter(crush(glide(500, 60, .35, "saw", .3), 4, 5), .1, .04, 3), 0), (noise(.3, .2, lp=4, decay=.5), 0)]))


@reg("window-attention")
def _():
    return (lambda: mix([(bell(A6, .5, .4), 0), (bell(A6, .7, .4), .16)]),
            lambda: mix([(blip(2000, 2000, .05, .35), 0), (blip(2000, 2000, .05, .35), .1), (blip(2400, 2400, .08, .3), .2)]))


@reg("screen-capture")
def _():
    return (lambda: mix([(noise(.03, .6, lp=3, decay=.4), 0), (noise(.05, .5, lp=12, decay=.4), .05), (glide(180, 90, .06, "sine", .3), .05)]),
            lambda: mix([(glide(3200, 800, .1, "saw", .12), 0), (click(.5), .1), (blip(900, 900, .04, .3), .12)]))


@reg("alarm-clock-elapsed")
def _():
    return (lambda: mix([(bell(f, .6, .4), i * .22) for i, f in enumerate([D6, A5] * 4)]),
            lambda: mix([(blip(f, f, .07, .35), r * .9 + i * .11) for r in range(2) for i, f in enumerate([1400, 1800, 2200])] +
                        [(glide(500, 2600, .25, "tri", .1), r * .9 + .38) for r in range(2)] +
                        [(bell(2800, .6, .18), r * .9 + .38) for r in range(2)]))


@reg("phone-incoming-call")
def _():
    return (lambda: mix([(bell(f, .7, .4), i * .2 + (i // 2) * .25) for i, f in enumerate([E6, C6, E6, C6, E6, C6])]),
            lambda: mix([(chip(f, .09, .28, "tri"), j * 1.0 + i * .08) for j in range(2) for i, f in enumerate([659.25, 783.99, 987.77, 1318.51])] +
                        [(bell(2637, .8, .16), j * 1.0 + .3) for j in range(2)] +
                        [(glide(120, 90, .35, "sine", .25), j * 1.0) for j in range(2)]))


@reg("battery-full")
def _():
    return (lambda: mix([(bell(f, 1.4, .3), i * .18) for i, f in enumerate([C6, E6, G6])] + [(pad([523.25, 783.99], 1.6, .1), 0)]),
            lambda: mix([(glide(400, 1600, .3, "tri", .25), 0), (blip(1600, 1600, .06, .3), .32), (blip(2000, 2000, .08, .3), .4),
                         (bell(3136, 1.0, .2), .4)]))


if __name__ == "__main__":
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")
    os.makedirs(out, exist_ok=True)
    for name in A_:
        for tag, d in (("a", A_), ("b", B_)):
            sf.write(os.path.join(out, f"{name}-{tag}.ogg"), finalize(d[name]()), SR, format="OGG", subtype="VORBIS")
    print(len(A_) * 2, "ficheiros em", out)
