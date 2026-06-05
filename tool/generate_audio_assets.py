#!/usr/bin/env python3
"""Synthesize Guardian Angela's built-in placeholder sound effects.

These are *placeholder* alarm/countdown sounds, analogous to the
TTS-generated placeholder voice clips (see ``AudioService.bootstrapVoiceAssets``
in ``lib/services/audio_service.dart``). They are intentionally simple,
synthesized tones — not licensed sound design — so the engineering build has
real, audible, cross-platform audio for every code-referenced asset.

Scope: this script generates ``siren.wav`` and ``countdown_warning.wav`` only.
``ringtone_default.wav`` is **not** generated here — it is real, license-cleared
ringtone audio preserved from v2 (renamed from the original ``ringtone.wav``).
The previous ``alarm.mp3`` was a 0.26 s silent stub and has been removed in
favour of the synthesized ``siren.wav``.

Format rationale (WAV / 16-bit PCM / 44.1 kHz mono):
- WAV plays on **both** Android (ExoPlayer) and iOS (AVFoundation) via
  ``just_audio``. OGG Vorbis (the previous extension) does **not** decode on
  iOS/AVFoundation, which would leave the alarm silent on iOS — the platform
  matrix (docs/spec/10) lists Loud Alarm / Ringtone / Countdown as YES on iOS.
- No ffmpeg/lame is required; ``soundfile`` (libsndfile) writes WAV directly.

The looping sounds (siren, ringtone) are designed to loop **seamlessly**: their
waveforms begin and end at exactly zero amplitude, so ``LoopMode.all`` produces
no click at the loop boundary. The siren uses a closed-form instantaneous-phase
expression whose endpoints are provably zero for the chosen frequencies.

Run from the repo root:  ``python3 tool/generate_audio_assets.py``
"""

from __future__ import annotations

import pathlib

import numpy as np
import soundfile as sf

SAMPLE_RATE = 44_100
_OUT_DIR = pathlib.Path(__file__).resolve().parent.parent / "assets" / "audio"


def _write(name: str, signal: np.ndarray) -> None:
    """Normalize to a safe peak and write ``signal`` as 16-bit PCM WAV."""
    peak = float(np.max(np.abs(signal)))
    if peak > 0:
        signal = signal / peak
    path = _OUT_DIR / name
    sf.write(path, signal.astype(np.float32), SAMPLE_RATE, subtype="PCM_16")
    seconds = len(signal) / SAMPLE_RATE
    print(f"wrote {path.relative_to(_OUT_DIR.parents[1])}  ({seconds:.2f}s)")


def siren(target_peak: float = 0.92) -> np.ndarray:
    """Wailing two-cycle emergency siren, 4.0 s, seamless loop.

    Instantaneous frequency wails sinusoidally between 600 and 1400 Hz. The
    closed-form phase ``phi(t) = 2*pi*fc*t + (fd/fm)*(1 - cos(2*pi*fm*t))`` is
    exactly zero at t=0 and t=T for fc*T and fm*T integers, so the waveform
    loops without a discontinuity. A little 2nd/3rd harmonic adds an edge that
    cuts through ambient noise; harmonics of ``phi`` keep the zero endpoints.
    """
    fc, fd, fm, duration = 1000.0, 400.0, 0.5, 4.0
    n = int(SAMPLE_RATE * duration)
    t = np.arange(n) / SAMPLE_RATE
    phi = 2 * np.pi * fc * t + (fd / fm) * (1.0 - np.cos(2 * np.pi * fm * t))
    wave = np.sin(phi) + 0.25 * np.sin(2 * phi) + 0.10 * np.sin(3 * phi)
    return wave * target_peak


def _tone_burst(freqs: list[float], duration: float, fade: float = 0.01,
                peak: float = 1.0) -> np.ndarray:
    """A sum-of-sines burst with short raised-cosine fades to avoid clicks."""
    n = int(SAMPLE_RATE * duration)
    t = np.arange(n) / SAMPLE_RATE
    wave = sum(np.sin(2 * np.pi * f * t) for f in freqs) / len(freqs)
    fade_n = max(1, int(SAMPLE_RATE * fade))
    env = np.ones(n)
    ramp = 0.5 * (1 - np.cos(np.linspace(0, np.pi, fade_n)))
    env[:fade_n] = ramp
    env[-fade_n:] = ramp[::-1]
    return wave * env * peak


def _silence(duration: float) -> np.ndarray:
    return np.zeros(int(SAMPLE_RATE * duration))


def countdown_warning() -> np.ndarray:
    """Urgent triple beep, ~0.61 s, played once (not looped).

    Two 1000 Hz beeps and a higher 1320 Hz final beep signal "time is running
    out — check in". 150 ms beeps separated by 80 ms gaps.
    """
    beep = _tone_burst([1000.0], 0.15, peak=0.85)
    high = _tone_burst([1320.0], 0.15, peak=0.85)
    gap = _silence(0.08)
    return np.concatenate([beep, gap, beep, gap, high])


def main() -> None:
    _OUT_DIR.mkdir(parents=True, exist_ok=True)
    _write("siren.wav", siren())
    _write("countdown_warning.wav", countdown_warning())
    # ringtone_default.wav is intentionally NOT generated — it is preserved
    # license-cleared v2 audio (see module docstring).


if __name__ == "__main__":
    main()
