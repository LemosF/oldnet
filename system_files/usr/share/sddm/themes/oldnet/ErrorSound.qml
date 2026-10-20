// Login-failed sound (bip, bip, bzzt). Loaded through a Loader: without QtMultimedia the
// Loader stays empty and the login screen simply has no sound. SoundEffect needs WAV.
// Source: branding/sounds/futuristic-errors/synth_futuristic.py (lockerr).
import QtQuick
import QtMultimedia

SoundEffect {
    source: "assets/login-failed.wav"
    volume: 0.8
}
