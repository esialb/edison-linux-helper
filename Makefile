KERNEL_IMAGE=edison-linux/arch/x86/boot/bzImage
BCM4334X_MODULE=edison-bcm43340/bcm4334x.ko

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

$(KERNEL_IMAGE): edison-linux/include/generated/utsrelease.h
	cd edison-linux && make

$(BCM4334X_MODULE): edison-bcm43340/.git $(KERNEL_IMAGE)
	cd edison-bcm43340 && (KERNEL_SRC=../edison-linux make)

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

collected/latest: $(KERNEL_IMAGE) $(BCM4334X_MODULE)
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
