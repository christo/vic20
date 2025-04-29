ASSEMBLER = 64tass
PROGRAM = customchar.prg
# DEFAULT_OPTIONS = -C -a
DEFAULT_OPTIONS = -C -a -l customchar.list.txt

all: $(PROGRAM)

$(PROGRAM): customchar.asm
	$(ASSEMBLER) $(DEFAULT_OPTIONS) -i $< -o $(PROGRAM)

clean:
	rm $(PROGRAM)