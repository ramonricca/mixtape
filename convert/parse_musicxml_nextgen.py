#!/usr/bin/python3
import music21 as m21
import sys

filepath = sys.argv[1]

score = m21.converter.parse(filepath)
num_instruments = len(score.parts)
print('Number of instruments:', num_instruments)

songnotes = [[],[],[],[]]
shortest_duration = 100

measure1 = score.parts[0].measure(1)
print(f"measure1: {measure1}")
time_signature = measure1.getTimeSignatures()[0]
print(f"time_signature: {time_signature}")
quarters_per_measure = time_signature.denominator
print (f"q/m: {quarters_per_measure}")

for i, p in enumerate(score.parts):
    #print(f"Part {i+1}: {p.getInstrument().instrumentName}")
    ch = p.chordify();
    f = ch.flatten()
    # You can also iterate over elements within each part
    #print("  Elements in this part:")
    # Iterate through the notes in the Stream to find the shortest duration
    for ql in f.notes:
        if ((ql.duration.quarterLength < shortest_duration) and (ql.duration.quarterLength != 0)):
            shortest_duration = ql.duration.quarterLength

mult = 1/shortest_duration
#print("mult = ", mult)
numbeats = quarters_per_measure * mult
print (f"beats: {numbeats}")

for i, p in enumerate(score.parts):
    f = p.flatten()

    for element in f.notesAndRests:
        if isinstance(element, m21.note.Note):
            m = m21.note.Note(element.nameWithOctave)
            dur = element.duration.quarterLength * mult
            if dur != 0:
                #print(f"Found a note: {element.nameWithOctave} {element.octave} {m.pitch.midi} {dur}")
                songnotes[0].append(element) 
            elif isinstance(element, m21.note.Rest):
                songnotes[1].append(element) 
            elif isinstance(element, m21.chord.Chord):
                # Handle chords -  you can expand this to handle various chord types
                print("FOUND CHORD")
                for j, tone in enumerate(element.pitches):
                    print(m21.note.Note(tone.ps))
                    songnotes[j].append(m21.note.Note(tone.ps))   

print(songnotes)
