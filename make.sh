rgbasm.exe -h gbclock.s -o gbclock.o
rgblink.exe gbclock.o -o gbclock.gb
rgbfix.exe -t GBCLOCK -v -p 0 gbclock.gb
