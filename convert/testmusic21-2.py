#!/usr/bin/python3
from music21 import *

p = converter.parse('canon/score.xml')
#x = allBach[0]
#p = s.parse()

#partStream = p.parts.stream()
thenotes = p.flatten()
for n in thenotes.notes.stream():
    #print(f"pitch: {n.pitch.name} octave: {n.pitch.octave}, duration: {n.duration.quarterLength}")
    n.show('text')
    if n.note:
        print("note")
    if n.chord:
        print("chord")
