#!/home/rricca/sounds/mixtape/bin/python3
import music21 as m21
import numpy as np
import sys

filepath = sys.argv[1]

def normalize_durations(sc):
    """
    Normalizes all note durations in a music21 score to a common denominator,
    making the shortest note's duration equal to 1.

    Args:
        score: The music21 score object.

    Returns:
        The modified music21 score object with normalized durations.
    """
    if not sc.parts:
        print("Warning: The score is empty.  Returning the original score.")
        return sc

    # 1. Find the shortest note duration
    durs= []
    for p in sc.parts:
        p.flatten()
        for n in p.notesAndRests:
            durs.append(n.duration.quarterLength)

    #durations = [n.duration.quarterLength for n in score.notes]
    if len(durs) > 0:
        shortest_duration = min(durs)
        print(f"shortest: {shortest_duration}")
        # 2. Normalize all durations
        for i, p in enumerate(sc.parts):
            p.flatten()
            for n in p.notesAndRests:
                if n.duration.quarterLength != shortest_duration:
                    new_duration = shortest_duration * (n.duration.quarterLength / shortest_duration)
                    n.duration = m21.duration.Duration(new_duration)
                else:
                    n.duration = m21.duration.Duration(1)

    return sc


def midi_to_score(sf):
    sc = m21.converter.parse(sf)
    score = normalize_durations(sc)
    #score = normalize_durations(sc)
    num_instruments = len(score.parts)
    print('Number of voices:', num_instruments)

    songnotes = [[],[],[],[]]
    shortest_duration = 100

    #measure1 = score.parts[0].measure(1)
    #print(f"measure1: {measure1}")
    #time_signature = measure1.getTimeSignatures()[0]
    #print(f"time_signature: {time_signature}")
    #quarters_per_measure = time_signature.denominator
    #print (f"q/m: {quarters_per_measure}")

    for i, p in enumerate(score.parts):
    #    #print(f"Part {i+1}: {p.getInstrument().instrumentName}")
    #    ch = p.chordify();
        f = p.flatten()
        # You can also iterate over elements within each part
        #print("  Elements in this part:")
        # Iterate through the notes in the Stream to find the shortest duration
        for ql in f.notes:
            if ((ql.duration.quarterLength < shortest_duration) and (ql.duration.quarterLength != 0)):
                shortest_duration = ql.duration.quarterLength

    mult = 1/shortest_duration
    print("mult = ", mult)
    #numbeats = quarters_per_measure * mult
    #print (f"beats: {numbeats}")

    for i, p in enumerate(score.parts):
        #p = normalize_durations(p)
        #ch = p.chordify();
        #f = ch.flatten()
        f = p.flatten()
        for element in f.notesAndRests:
            if isinstance(element, m21.note.Note):
                m = m21.note.Note(element.nameWithOctave)
                dur = element.duration.quarterLength
                if dur != 0:
                    #print(f"Found a note: {element.nameWithOctave} {element.octave} {m.pitch.midi} {dur}")
                    element.duration = m21.duration.Duration(int(dur * mult))
                    songnotes[i].append(element) 
            elif isinstance(element, m21.note.Rest):
                dur = element.duration.quarterLength
                if dur != 0:
                    element.duration = m21.duration.Duration(int(dur * mult))
                    songnotes[1].append(element) 
            elif isinstance(element, m21.chord.Chord):
                # Handle chords -  you can expand this to handle various chord types
                #print("FOUND CHORD")
                for j, tone in enumerate(element.pitches):
                    dur = element.duration.quarterLength
                    newnote = m21.note.Note(tone.ps)
                    newnote.duration = m21.duration.Duration(int(dur * mult))
                    #print(m21.note.Note(tone.ps))
                    if j < 4:
                        songnotes[j].append(newnote)   

    return songnotes



mynotes = midi_to_score(filepath)
#print(f"mag: {mag}")

for i in range(3): 
    for elem in mynotes[i]:
        if isinstance(elem, m21.note.Note):
            #dur = int(elem.quarterLength * mag)
            dur = int(elem.quarterLength)
            rawdur=elem.quarterLength
            voi = i
            oct = int(elem.pitch.midi // 12)
            pit = int(elem.pitch.midi % 12)
            dut = 7
            ivo = 12
            svo = 10
            dec = 1
            #print(f"rawdur:{rawdur}")
            print(f"ADD {dur:02x}{voi:01x}{oct:01x}{pit:01x}{dut:01x}{ivo:01x}{svo:01x}{dec:01x}")
        elif isinstance(elem, m21.note.Rest):
            #dur = int(elem.quarterLength * mag)
            dur = int(elem.quarterLength)
            voi = i
            oct = 1
            pit = 12
            dut = 7
            ivo = 12
            svo = 10
            dec = 1
            print(f"ADD {dur:02x}{voi:01x}{oct:01x}{pit:01x}{dut:01x}{ivo:01x}{svo:01x}{dec:01x}")
            
