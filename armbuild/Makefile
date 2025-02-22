TARGET = build

PREFIX = arm-none-eabi-

CFLAGS = -march=armv4 -mfloat-abi=soft
# CFLAGS += -Wall -fdata-sections -ffunction-sections
LDFLAGS = -Tlink.ld

OBJ = startup.o
SRC = $(wildcard *.c)
OBJ += $(patsubst %.c,%.o,$(SRC))


%.o: %.s
	$(PREFIX)as $< -o $@

%.o: %.c
	$(PREFIX)gcc -c $(CFLAGS) $< -o $@

all: $(OBJ)
	$(PREFIX)ld $(LDFLAGS) $(OBJ) -o $(addsuffix .elf,$(TARGET))
	$(PREFIX)objcopy -Obinary $(addsuffix .elf,$(TARGET)) $(addsuffix .bin,$(TARGET))
	python testdata_gen.py -i $(addsuffix .bin,$(TARGET)) -o $(addsuffix .txt,$(TARGET))

debug: 
	$(PREFIX)objdump -h $(addsuffix .elf,$(TARGET))
	$(PREFIX)objdump -d $(addsuffix .elf,$(TARGET))

clean:
	rm -rf $(OBJ) $(addsuffix .elf,$(TARGET)) $(addsuffix .bin,$(TARGET)) $(addsuffix .txt,$(TARGET))