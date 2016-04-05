
all: edison-linux/arch/x86/boot/bzImage edison-bcm43340/bcm4334x.ko

edison-linux/.git:
	git submodule update --init edison-linux
	cd edison-linux && git apply ../mfd_trace.h.patch
	cd edison-linux && git apply ../sst_trace.h.patch

edison-bcm43340/.git:
	git submodule update --init edison-bcm43340

edison-linux/.config: edison-linux/.git edison-default-kernel.config
	cp edison-default-kernel.config edison-linux/.config

edison-linux/include/generated/utsrelease.h: edison-linux/.config
	cd edison-linux && (yes "" | make oldconfig) && make prepare

edison-linux/arch/x86/boot/bzImage: edison-linux/.config edison-linux/include/generated/utsrelease.h
	cd edison-linux && make

edison-bcm43340/bcm4334x.ko: edison-bcm43340/.git edison-linux/arch/x86/boot/bzImage
	cd edison-bcm43340 && (KERNEL_SRC=../edison-linux make)

config: edison-linux/.config
	cd edison-linux && make config

xconfig: edison-linux/.config
	cd edison-linux && make xconfig

clean: edison-linux/.git edison-linux/.git
	cd edison-linux && make clean
	cd edison-bcm43340 && make clean
	[ -e collected ] && rm -R collected || true

collected/latest: edison-linux/arch/x86/boot/bzImage edison-bcm43340/bcm4334x.ko
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
