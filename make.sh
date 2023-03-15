rgbasm.exe -h gbchrono.s -o gbchrono.o
rgblink.exe gbchrono.o -o gbchrono.gb
rgbfix.exe -t GBCHRONO -v -p 0 gbchrono.gb
