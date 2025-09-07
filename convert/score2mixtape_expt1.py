from music21 import stream, note, duration
import numpy as np

def create_timed_voices(score):
    """
    Breaks a music21 score into a maximum of 4 voices,
    ensuring correct timing with added rests.

    Args:
        score: The music21.stream.Stream object.

    Returns:
        A music21.stream.Stream object with the voices separated,
        with rests added to ensure proper timing.
    """

    voices = []
    for i in range(4):
        voice = stream.Part()
        current_time = 0.0  # Time for this voice
        for n in score.notes:
            # Add rest if voice isn't present at this time
            if current_time % 1.0 < 0.2 and current_time % 1.0 > 0.8:  # Example: Rest for 0.2 seconds
                voice.append(note.Note(n.pitch, duration=duration.Duration(0))) # Use a zero-duration note as a rest
            else:
                voice.append(n)
            current_time += n.duration
        voices.append(voice)

    # Create a new score to hold the voices
    new_score = stream.Stream()
    for v in voices:
        new_score.append(v)
    return new_score


# Example usage:
# Create a dummy score
s = stream.Stream()
n1 = note.Note("C4", quarter=0.5)
n2 = note.Note("D4", quarter=0.5)
n3 = note.Note("E4", quarter=0.5)
n4 = note.Note("F4", quarter=0.5)
n5 = note.Note("G4", quarter=0.5)
n6 = note.Note("A4", quarter=0.5)

s.append(n1)
s.append(n2)
s.append(n3)
s.append(n4)
s.append(n5)
s.append(n6)

# Create the timed voices
new_score = create_timed_voices(s)

# Show the new score
new_score.show()