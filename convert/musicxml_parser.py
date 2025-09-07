#!/usr/bin/python3
import music21
import os


def parse_mxl_to_notes(mxl_file_path):
    """
    Parses an MXL audio file into a sequence of notes.  This is a simplified 
    example that relies on assumptions about the MXL file structure.  
    For robust MXL parsing, consider using a dedicated MXL reader library 
    like mxlparse.

    Args:
        mxl_file_path: The path to the MXL audio file.

    Returns:
        A list of music21.note.Note objects representing the notes in the file.
        Returns an empty list if parsing fails.
    """

    try:
        # Load the MXL file
        score = music21.converter.parse(mxl_file_path)
        
        # Extract notes from the score
        notes = []
        for part in score.parts:
            for element in part.recurse():
                if isinstance(element, music21.note.Note):
                    notes.append(element)
                elif isinstance(element, music21.chord.Chord):
                    # Handle chords -  you can expand this to handle various chord types
                    for tone in element.pitches:
                        notes.append(music21.note.Note(tone.ps))
        return notes
    except Exception as e:
        print(f"Error parsing MXL file: {e}")
        return []


# Example Usage:  Replace 'your_audio.mxl' with your actual MXL file.
file_path = 'scot/Scotland_The_Brave.mxl' 

if os.path.exists(file_path):
    note_sequence = parse_mxl_to_notes(file_path)

    if note_sequence:
        print(f"Found {len(note_sequence)} notes in the MXL file.")
        # Example: Print the first 5 notes
        for i in range(min(5, len(note_sequence))):
            print(f"Note {i+1}: {note_sequence[i].nameWithOctave}")
    else:
        print("No notes found or parsing failed.")
else:
    print(f"File not found: {file_path}")