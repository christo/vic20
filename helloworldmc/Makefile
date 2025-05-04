ASSEMBLER = 64tass
PROGRAM = helloworld.prg
DEFAULT_OPTIONS = -C -a

all: $(PROGRAM)

$(PROGRAM): helloworld.asm
	$(ASSEMBLER) $(DEFAULT_OPTIONS) -i $< -o $(PROGRAM)

clean:
	rm $(PROGRAM)
