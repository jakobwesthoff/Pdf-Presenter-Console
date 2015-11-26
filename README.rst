============
Discontinued
============

**Discontinued Project**: This project has been discontinued. A well maintained fork, with new functionality is available here: https://pdfpc.github.io/

Thanks to the pdfpc team, which took over this tool to make it even better.

=====================
Pdf Presenter Console
=====================

About
=====

The Pdf Presenter Console (PPC) is a GTK based presentation viewer application
which uses Keynote like multi-monitor output to provide meta information to the
speaker during the presentation. It is able to show a normal presentation
window on one screen, while showing a more sophisticated overview on the other
one providing information like a picture of the next slide, as well as the left
over time till the end of the presentation. The input files processed by PPC
are PDF documents, which can be created using nearly any of today's presentation
software.

Motivation
==========

The idea to create PPC came up during the IPC 2009 where I saw a lot of people
running around with their MacBooks using Keynote to present their slides. I
always liked the presenter console of Keynote. Therefore I began to research if
any solution like this existed for my Linux system. I came across the Sun
presenter console for Open-Office Impress, which seemed to do exactly what I
wanted. Unfortunately I stopped using Impress for creating presentations in
favor to Latex Beamer quite some time ago. Therefore this Open-Office plugin was
no solution to my problem. I wanted something flexible which would be able to
use simple PDF documents as input. I found some projects which were started
having the same intentions than I did. Unfortunately these projects did either
never reach the implementation phase or they were implemented but I did not get
them to work properly. 

All this brought me to the decision to create a simple presenter console on my
own. At this point the Pdf Presenter Console was born.

Requirements
============

In order to compile and run the Pdf Presenter Console the following
requirements need to be met:

- Vala Compiler Version >=0.11.0
- CMake Version >=2.6
- Gtk+ 2.x
- libPoppler with glib bindings

Compile and install
===================

After retrieving the archive unpack it using the following command::

    tar xvzf pdf_presenter_console-VERSION.tar.gz

Switch to the unpacked source directory and create some sort of build
directory. This may be done as follows::

    cd pdf_presenter_console-VERSION
    mkdir build
    cd build

After you are inside the build directory create the needed Makefiles using
CMake::

    cmake ../

If you have put your build directory elsewhere on your system adapt the path
above accordingly. You need to provide CMake with the pdf_presenter_console
directory which you just decompressed.

You may alter the final installation prefix at this time. By default the
pdf_presenter_console executable will be installed under */usr/local/bin*. If
you want to change that, for example to be */usr/bin* you may specify another
installation prefix as follows::

    cmake -DCMAKE_INSTALL_PREFIX="/usr" ../

If all requirements are met CMake will tell you that it created all the
necessary build files for you. If any of the requirements were not met you
will be informed of it to provide the necessary files or install the
appropriate packages.

The next step is to compile the source using GNU Make or any other make
derivative you may have installed. Simply issue the following command to start
building the application::

    make

After the build completes successfully the *pdf_presenter_console* executable
can be found inside the *src* directory of you build path. If you want to
install it automatically to the *bin* directory below the before provided
prefix do as follows::

    make install

You may need to prefix this command with a *sudo* or obtain super-user rights
in any other way applicable to your situation.

Congratulations you just installed Pdf Presenter Console on your system.


Retrieving the current trunk from the softwares git repository
--------------------------------------------------------------

If you want to use the bleeding edge version of this software, you may always
retrieve the current development branch from its git repository. Do this on
your own risk. It may not compile, make your socks disappear or even eat your
cat ;).

The repository is hosted at github__. If the git executable is available on
your system it can be retrieved using the following command::

    git clone git://github.com/jakobwesthoff/Pdf-Presenter-Console.git

After it has been transfered you need to switch to the
``Pdf-Presenter-Console`` directory, which has just been created. From inside
this directory use these commands to retrieve all needed submodules::

    git submodule init
    git submodule update

You are now set to compile and install the presenter as described in the
section above. However as mentioned above the code might not compile at all.


__ http://github.com/jakobwesthoff/Pdf-Presenter-Console


Startup and usage
=================

The Pdf Presenter Console is run by calling it's executable on the commandline
followed by the pdf you want to present::

    pdf_presenter_console your/pdf/file.pdf

Calling the application like this is the easiest way to go. There are certain
commandline options you may use to customize the behavior of the presenter to
your likings::

    Usage:
      pdf_presenter_console [OPTION...] <pdf-file>

    Help Options:
      -h, --help                    Show help options

    Application Options:
      -d, --duration=N              Duration in minutes of the presentation used for timer display. (Default 45 minutes)
      -l, --last-minutes=N          Time in minutes, from which on the timer changes its color. (Default 5 minutes)
      -u, --current-size=N          Percentage of the presenter screen to be used for the current slide. (Default 60)
      -s, --switch-screens          Switch the presentation and the presenter screen.
      -c, --disable-cache           Disable caching and pre-rendering of slides to save memory at the cost of speed.
      -z, --disable-compression     Disable the compression of slide images to trade memory consumption for speed. (Avg. factor 30)


Caching / Prerendering
----------------------

To allow fast changes between the different slides of the presentation the pdf
pages are prerendered to memory. The small white line on the bottom of the
presenter screen indicates how many percent of the slides have been
pre-rendered already. During the initial rendering phase this will slow-down
slide changes, as a lot of cpu power is used for the rendering process in the
background. After the cache is fully primed however the changing of slides
should be much faster as with normal pdf viewers.

As the prerendering takes a lot of memory it can be disabled using the
*--disable-cache* switch at the cost of speed.


Cache compression
-----------------

Since version 2.0 of the Pdf-Presenter-Console the prerendered and cached
slides can be compressed in memory to save up some memory. Without compression
a set of about 100 pdf pages can easily grow up to about 1.5gb size. Netbooks
with only 1gb of memory would swap themselves to death if prerendering is
enabled in such a situation. The compression is enabled by default as it does
not harm rendering speed in a noticeable way on most systems. It does however
slows down prerendering by about a factor of 2. If you have got enough memory
and want to ensure the fastest possible prerendering you can disable slide
compression by using the *-z* switch. But be warned using the uncompressed
prerendering storage will use about 30 times the memory the new compressed
storage utilizes (aka the 1.5gb become about 50mb)


Keybindings
-----------

During the presentation the following key strokes and mouse clicks are detected
and interpreted:

- Left cursor key / Page up / Right mouse button 
    - Go back one slide
- Right cursor key / Page down / Return / Space / Left mouse button
    - Go forward one slide
- Home
    - Go back to the first slide and reset the timer
- Escape / q /Alt+F4
    - Quit the presentation viewer


Timer
-----

The timer is started if you are navigating away from the first page for the
first time. This feature is quite useful as you may want to show the titlepage
of your presentation while people are still entering the room and the
presentation hasn't really begun yet. If you want to start over you can use the
*Home* key which will make the presenter go back to the first page and reset
the timer as well.

At the moment the timer reaches the defined ``last-minutes`` value it will
change color to indicate your talk is nearing its end.

As soon as the timer reaches the zero mark (00:00:00) it will turn red and
count further down showing a negative time, to provide information on how many
minutes you are overtime.

Download
========

The most recent release can always be obtained from:

    http://westhoffswelt.de

The latest and bleeding edge development version can be obtained by checking
out the development git repository using the following command::

    $ git clone git://github.com/jakobwesthoff/Pdf-Presenter-Console.git

The trunk version is not guaranteed to build or be working correctly. So be
warned if you use it. 


Contact
=======

Every comment or idea for a future version of this presenter is welcome. Just
send a mail to jakob@westhoffswelt.de. 

Other ways of contact can be retrieved through visiting

    http://westhoffswelt.de



..
   Local Variables:
   mode: rst
   fill-column: 79
   End: 
   vim: et syn=rst tw=79
