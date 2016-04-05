
all: edison-linux/arch/x86/boot/bzImage edison-bcm43340/bcm4334x.ko

edison-linux/.git:
	git submodule update --init edison-linux

edison-linux/drivers/tty/serial/mfd_trace.h: mfd_trace.h.patch
	cd edison-linux && git apply ../mfd_trace.h.patch

edison-linux/sound/soc/intel/sst/sst_trace.h: sst_trace.h.patch
	cd edison-linux && git apply ../sst_trace.h.patch

edison-linux-patches: edison-linux/drivers/tty/serial/mfd_trace.h edison-linux/sound/soc/intel/sst/sst_trace.h

edison-bcm43340/.git:
	git submodule update --init edison-bcm43340

edison-linux/.config: edison-linux/.git edison-default-kernel.config
	cp edison-default-kernel.config edison-linux/.config

edison-linux/include/generated/utsrelease.h: edison-linux/.config
	cd edison-linux && (yes "" | make oldconfig) && make prepare

edison-linux-config: edison-linux/include/generated/utsrelease.h

edison-linux/arch/x86/boot/bzImage: edison-linux-config edison-linux-patches
	cd edison-linux && make

edison-linux-kernel: edison-linux/arch/x86/boot/bzImage

edison-bcm43340/bcm4334x.ko: edison-bcm43340/.git edison-linux-kernel
	cd edison-bcm43340 && (KERNEL_SRC=../edison-linux make)

bcm4334x-module: edison-bcm43340/bcm4334x.ko

config: edison-linux/.config
	cd edison-linux && make config

xconfig: edison-linux/.config
	cd edison-linux && make xconfig

oldconfig: edison-linux/.config
	cd edison-linux && make oldconfig

prepare: edison-linux/.config
	cd edison-linux && make prepare

clean: edison-linux/.git edison-linux/.git
	cd edison-linux && make clean
	cd edison-bcm43340 && make clean
	[ -e collected ] && rm -R collected || true

collected/latest: edison-linux-kernel bcm4334x-module
	mkdir -p collected
	./collect.sh

collected: collected/latest

$(DFU)/edison-image-edison.ext4: collected/latest
	./dfu-image-install.sh "${DFU}"

$(DFU)/edison-image-edison.hddimg: collected/latest
	./dfu-image-install.sh "${DFU}"

install: $(DFU)/edison-image-edison.ext4 $(DFU)/edison-image-edison.hddimg

flashall: install
	cd "${DFU}" && ./flashall.sh

.PHONY: all
