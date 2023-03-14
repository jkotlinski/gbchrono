rgbasm.exe -h gbtime.s -o gbtime.o
rgblink.exe gbtime.o -o gbtime.gb
rgbfix.exe -t GBTIME -v -p 0 gbtime.gb
