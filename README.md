# Mixtape Desktop Synthesizer

<img src="/home/rricca/Documents/Mixtape_Audio_Lab_Manual/mixtape-dev/mixtape_image1.png"  />

### Thank you for checking out this Proof of Concept (POC)!

#### What is Mixtape?

- 	It is a 4 Voice Electronic Synthesizer
- 	4 bit independent VCA with Attack, Decay, Sustain, and Release (ADSR)
- 	512kbit memory for storing music, plus demos that are always available
- 	3 buttons to quickly load and play your music into memory
- 	Visual representation of Music and progress bar with LEDs
- 	Headphone jack with gain and volume controls
- 	USB powered, with USB Serial connection at 115200 baud
- 	Command line interface for entering music and controlling the synthesizer
- 	Musescore, MIDI, MusicXML, and other formats can be converted with Mixtape scripts or create your own with Humdrum-Tools and other libraries
- 	Bootloaded Firmware – Your feedback could result in firmware enhancements that can be distributed over the internet!



This repository contains some perl scripts and MusicXML samples to load onto mixtape. These scripts have been tested on Linux, but should also work on BSD and Apple Macintosh OSX.

You will need to install the following perl modules, with your local packaging system:

###### Ubuntu:

```
> sudo apt install libxml-simple-perl libxml-xslt-perl
```

###### Perl CPAN on a Unix Flavor:

```
> sudo perl -MCPAN -e shell
# install XML::Simple
# install XML::XSLT
```

The scripts are a work in progress. Currently, readxml_measure.pl seems to be the most reliable. Please modify and share to make it work for you.

```
> git clone http://github.com/ramonricca/mixtape
> cd mixtape
> chmod u+x scripts/*.pl
> ./scripts/readxml_measure.pl sampleXML/odetojoy.xml > ode.txt
```

Then upload the ode.txt file to mixtape with your serial terminal. Please see the file "mixtape_instructions.pdf" for more information.
