KERNEL_VERSION=4.13.3
KERNEL_DIRECTORY=linux-$(KERNEL_VERSION)
KERNEL_ARCHIVE=$(KERNEL_DIRECTORY).tar.xz
KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/v4.x/$(KERNEL_ARCHIVE)


all: vmlinuz initramfs


# Kernel build targets
vmlinuz: $(KERNEL_DIRECTORY)
	cd $(KERNEL_DIRECTORY) && make defconfig && make -j`nproc`
	cp $(KERNEL_DIRECTORY)/arch/x86_64/boot/bzImage vmlinuz

$(KERNEL_DIRECTORY):
	wget $(KERNEL_URL)
	tar xf $(KERNEL_ARCHIVE)


# Initramfs build targets
initramfs: initfs initfs/init
	cd initfs/ && find . | cpio -o --format=newc > ../initramfs

initfs/init: initfs init.c
	gcc -o initfs/init -static init.c

initfs:
	mkdir -p initfs/bin


# Utility targets
runvm: vmlinuz initramfs
	qemu-system-x86_64 -m 2048 -kernel vmlinuz -initrd initramfs

clean:
	rm -rf vmlinuz $(KERNEL_DIRECTORY) $(KERNEL_ARCHIVE)