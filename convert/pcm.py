#!/usr/bin/python3

#import sounddevice as sd 
import numpy as np 

# Set audio parameters
fs = 44100  # Sampling rate (Hz)
duration = 1  # Duration of recording (seconds)
bit_depth = 8  # Bit depth per sample (16-bit) 

# Generate a simple sine wave
freq = 440  # Frequency (Hz)
t = np.linspace(0, duration, int(fs * duration), dtype=np.float32)
data = np.sin(2 * np.pi * freq * t) 

# Quantize to 16-bit PCM format
data_int = np.int16(data * (2**(bit_depth - 1) - 1)) 

# Play the audio
#sd.play(data_int, fs) 
#sd.wait() 
for element in data_int:
    print(element)

