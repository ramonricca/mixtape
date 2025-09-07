from mxlparse import mxlread
from music21 import *

def parse_mxl_to_notes_with_mxlparse(mxl_file_path):
    try:
        data = mxlread(mxl_file_path)
        notes = []
        for track in data.tracks:
            for element in track.recurse():
                if isinstance(element, music21.note.Note):
                    notes.append(element)
                elif isinstance(element, music21.chord.Chord):
                    for tone in element.pitches:
                        notes.append(music21.note.Note(tone.ps))

        return notes
    except Exception as e:
        print(f"Error parsing MXL file: {e}")
        return []


if __name__ == '__main__':
    file_path = 'your_audio.mxl'
    if os.path.exists(file_path):
        note_sequence = parse_mxl_to_notes_with_mxlparse(file_path)

        if note_sequence:
            print(f"Found {len(note_sequence)} notes in the MXL file.")
            # ... (Print the notes) ...
        else:
            print("No notes found or parsing failed.")
    else:
        print(f"File not found: {file_path}")
        