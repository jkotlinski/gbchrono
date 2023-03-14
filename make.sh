rgbasm.exe -h test.s -o test.o
rgblink.exe test.o -o test.gb
rgbfix.exe -c -v -p 0 test.gb
