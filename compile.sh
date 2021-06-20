rm *.sfc
echo "Compiling..."
ca65 main.asm -g
echo "Compiled. Linking..."
ld65 -C lorom256k.cfg -o main.sfc main.o -Ln labels.txt
echo "Linked. Cleaning up..."
rm *.o
echo "Goodbye"