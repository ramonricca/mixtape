#!/usr/bin/python3
from music21 import *
s = converter.parse('canon/score.xml')

bchords = s.chordify()
bchords.show()
