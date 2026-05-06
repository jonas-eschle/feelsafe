# Voice recording placeholder assets

These 14 `angela_<langCode>.m4a` files are **silent placeholders** —
1-second silent AAC-LC audio in an MP4/M4A container. They exist so
the bundled-voice playback path can be exercised end-to-end during
development and testing, including the
`AudioService.playVoiceRecording` asset-exists check (which would
otherwise fall through to TTS for every locale).

**They are NOT shipping audio. Replace them with real voice talent
before release.**

The reference English script — to be voiced by every locale's
talent — is the spec 11 §DE-2 line:

> "Hi, I am running late. I will call you back soon."

(used as the TTS fallback in `AudioService` when the asset is
missing).

## Languages covered

`en, de, es, fr, ru, zh, zh_TW, hi, fa, uk, pl, el, ar, he`

These match the 14 supported locales in `lib/l10n/l10n/`.

## Regenerating the silent placeholders

The placeholders were generated with a small Python script that uses
`av` (PyAV / ffmpeg bindings) to encode 1 second of silence as
AAC-LC inside an iPod/M4A container. Because the runtime AudioService
treats a missing asset as a TTS fallback signal, you can also simply
delete a placeholder while iterating on translations and the app
will fall back gracefully.

To regenerate, install `av` (`uv pip install av`) and run a script
along the lines of:

```python
import av, numpy as np
LANGS = ['en','de','es','fr','ru','zh','zh_TW','hi','fa','uk','pl','el','ar','he']
for lang in LANGS:
    container = av.open(f'assets/voice/angela_{lang}.m4a', mode='w', format='ipod')
    stream = container.add_stream('aac', rate=44100)
    stream.layout = 'mono'
    silence = np.zeros((1, 44100), dtype=np.float32)
    frame = av.AudioFrame.from_ndarray(silence, format='fltp', layout='mono')
    frame.rate = 44100
    frame.pts = 0
    for p in stream.encode(frame): container.mux(p)
    for p in stream.encode():       container.mux(p)
    container.close()
```

ffmpeg-on-PATH equivalent (one file at a time):

```bash
ffmpeg -f lavfi -i anullsrc=r=44100:cl=mono -t 1 -c:a aac assets/voice/angela_en.m4a
```
