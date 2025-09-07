# Mixtape Desktop Synthesizer


This repository contains some perl scripts that convert musicxml to mixtape format. These scripts have been tested on Linux, but should also work on BSD and Apple Macintosh OSX, and maybe Windows.

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
> chmod u+x convert/*.p*
> ./convert/readxml_measure.pl sampleXML/odetojoy.xml > ode.txt
```

The readxml_timepart.pl script can be used on musicxml files that have parts separated like P1 P2 etc. Sometimes this happens when different musical instruments are represented on different staffs. To use it try:

```
> ./convert/readxml_timepart.pl musicfile.xml P1 > musicfile.txt
````


Then upload the ode.txt file to mixtape with your serial terminal. Please see the file "mixtape_instructions.pdf" for more information.

#### Python Scripts
I'm learning python for work, and these are incomplete. However, they can be used as a basis for more work --I'm going to try to improve these.

```
$ python3 -m venv mixtape
$ source mixtape/bin/activate
$ pip3 install -U pip
$ pip3 install music21 numpy
```

 