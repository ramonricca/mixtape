#!/usr/bin/python3

from music21 import converter

# Specify the path to your MIDI file
midi_file_path = 'HereComesTheSun.mid'

# Specify the desired output path for the MusicXML file
musicxml_file_path = 'sun.xml'

try:
	# Parse the MIDI file into a music21 stream object
    midi_stream = converter.parse(midi_file_path)

    # Export the stream object as a MusicXML file
    midi_stream.write('musicxml', fp=musicxml_file_path)

    print(f"Successfully converted '{midi_file_path}' to '{musicxml_file_path}'")

except Exception as e:
    print(f"An error occurred during conversion: {e}")

