NASM := nasm
LD   := lld-link

SRCDIR   := src
BUILDDIR := build
TARGET   := $(BUILDDIR)/main.efi

NASMFLAGS := -f win64 -Iincludes/
LDFLAGS   := /nologo /entry:efi_main /subsystem:efi_application /nodefaultlib /debug:none

default: all
all: $(TARGET)

$(BUILDDIR)/%.obj: $(SRCDIR)/%.asm | $(BUILDDIR)
	$(NASM) $(NASMFLAGS) -o $@ $<

$(TARGET): $(BUILDDIR)/main.obj | $(BUILDDIR)
	$(LD) $(LDFLAGS) /out:$@ $<

$(BUILDDIR):
	mkdir -p $@

clean:
	rm -fv $(BUILDDIR)/*.obj $(TARGET)

run:
	qemu-system-x86_64 \
		-drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.4m.fd \
		-drive format=raw,file=fat:rw:$(PWD) \
		-net none \
		-display vnc=:0

.PHONY: clean all default run
