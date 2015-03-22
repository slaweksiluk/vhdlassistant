
SRC_DIR = .
FLEXBISON_DIR = flexbison
SOURCES = $(FLEXBISON_DIR)/scanner.c $(FLEXBISON_DIR)/parser.tab.c $(wildcard $(SRC_DIR)/*.c) 
HEADER_FILES = $(wildcard $(SRC_DIR)/*.h)
OBJECTS = $(SOURCES:.c=.o)


INCLUDE_DIRS = -I$(shell pwd)
CC_ARGS=-std=c11 -Wall

BIN_NAME=vhdlparser

%.o: %.c $(HEADER_FILES)
	gcc -c $(CC_ARGS) $(INCLUDE_DIRS) $< -o $@

all: $(OBJECTS)
	gcc  $(OBJECTS) -o $(BIN_NAME)

$(FLEXBISON_DIR)/scanner.c: scanner.l $(FLEXBISON_DIR)/parser.tab.c 
	mkdir -p $(FLEXBISON_DIR)
	flex --header-file=scanner.h --header-file=$(FLEXBISON_DIR)/scanner.h --outfile=$(FLEXBISON_DIR)/scanner.c scanner.l 

$(FLEXBISON_DIR)/parser.tab.c: parser.y
	mkdir -p $(FLEXBISON_DIR) 
	bison parser.y -d  -v -o $(FLEXBISON_DIR)/parser.tab.c

clean:
	rm -f *.o
	rm -fr $(FLEXBISON_DIR)
	rm -f $(BIN_NAME)
	rm -f *.pyc	


