#!/usr/bin/env python3
"""Erzeugt BordBar/Klingel.wav: zwei Schläge auf eine Rezeptionsklingel („Ding-Ding!“).

Aufruf aus dem Ordner BordBar/:  python3 Tools/klingel.py
"""
import math
import struct
import wave
from pathlib import Path

SAMPLE_RATE = 44_100
DURATION = 1.6          # Sekunden
STRIKES = (0.0, 0.28)   # Zeitpunkte der beiden Schläge
FUNDAMENTAL = 1_760.0   # Hz – liegt dort, wo iPhone-Lautsprecher am lautesten sind
# Unharmonische Obertöne (Verhältnis, Lautstärke, Abklingrate) machen den metallischen Klang.
PARTIALS = (
    (1.00, 1.00, 2.5),
    (2.32, 0.55, 4.0),
    (4.25, 0.30, 7.0),
    (6.63, 0.15, 11.0),
)

count = int(SAMPLE_RATE * DURATION)
signal = [0.0] * count
for strike in STRIKES:
    offset = int(strike * SAMPLE_RATE)
    for i in range(offset, count):
        t = (i - offset) / SAMPLE_RATE
        signal[i] += sum(
            gain * math.exp(-decay * t) * math.sin(2 * math.pi * FUNDAMENTAL * ratio * t)
            for ratio, gain, decay in PARTIALS
        )

scale = 0.9 * 32767 / max(abs(s) for s in signal)
target = Path(__file__).resolve().parent.parent / "BordBar" / "Klingel.wav"
with wave.open(str(target), "wb") as wav:
    wav.setnchannels(1)
    wav.setsampwidth(2)
    wav.setframerate(SAMPLE_RATE)
    wav.writeframes(b"".join(struct.pack("<h", int(s * scale)) for s in signal))
print(f"{target} geschrieben")
