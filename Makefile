CC := clang
LD := lld

SRCDIR   := src
BUILDDIR := build
TARGET   := $(BUILDDIR)/main.efi

CFLAGS  := -ffreestanding -MMD -mno-red-zone -std=c11 -target x86_64-unknown-windows
LDFLAGS := -flavor link -subsystem:efi_application -entry:efi_main

default: all
all: $(TARGET)

$(BUILDDIR)/%.o: $(SRCDIR)/%.c | $(BUILDDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET): $(BUILDDIR)/main.o | $(BUILDDIR)
	$(LD) $(LDFLAGS) $< -out:$@

$(BUILDDIR):
	mkdir -p $@

-include $(wildcard $(BUILDDIR)/*.d)

clean:
	rm -fv $(BUILDDIR)/*.o $(BUILDDIR)/*.d $(TARGET)

run:
	qemu-system-x86_64 \
		-drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.4m.fd \
		-drive format=raw,file=fat:rw:$(PWD) \
		-net none \
		-display vnc=:0

.PHONY: clean all default run
