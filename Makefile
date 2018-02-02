KERNEL_VERSION=4.15
KERNEL_DIRECTORY=linux-$(KERNEL_VERSION)
KERNEL_ARCHIVE=$(KERNEL_DIRECTORY).tar.xz
KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/v4.x/$(KERNEL_ARCHIVE)

BUSYBOX_VERSION=1.28.0
BUSYBOX_DIRECTORY=busybox-$(BUSYBOX_VERSION)
BUSYBOX_ARCHIVE=$(BUSYBOX_DIRECTORY).tar.bz2
BUSYBOX_URL=https://busybox.net/downloads/$(BUSYBOX_ARCHIVE)


all: vmlinuz initramfs


# Kernel build targets
vmlinuz: $(KERNEL_DIRECTORY)
	cd $(KERNEL_DIRECTORY) && make defconfig && make -j`nproc`
	cp $(KERNEL_DIRECTORY)/arch/x86_64/boot/bzImage vmlinuz

$(KERNEL_DIRECTORY):
	wget $(KERNEL_URL)
	tar xf $(KERNEL_ARCHIVE)


# Initramfs build targets
initramfs: initfs initfs/init initfs/bin/busybox
	cd initfs/ && find . | cpio -o --format=newc > ../initramfs

initfs/init: initfs init.sh
	cp init.sh initfs/init

$(BUSYBOX_DIRECTORY):
	wget $(BUSYBOX_URL)
	tar xf $(BUSYBOX_ARCHIVE)

initfs/bin/busybox: $(BUSYBOX_DIRECTORY)
	cp busybox.config $(BUSYBOX_DIRECTORY)/.config
	cd $(BUSYBOX_DIRECTORY) && make -j`nproc`
	cp $(BUSYBOX_DIRECTORY)/busybox initfs/bin/busybox
	bash symlink-busybox.sh

initfs:
	mkdir -p initfs/bin initfs/proc initfs/dev initfs/sys


# Utility targets
runvm: vmlinuz initramfs
	qemu-system-x86_64 -m 2048 -kernel vmlinuz -initrd initramfs

clean:
	rm -rf vmlinuz $(KERNEL_DIRECTORY) $(KERNEL_ARCHIVE) $(BUSYBOX_DIRECTORY) \
		$(BUSYBOX_ARCHIVE)
