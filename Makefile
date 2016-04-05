all: edison-linux/arch/x86/boot/bzImage edison-bcm43340/bcm4334x.ko

edison-linux/.git:
	git submodule init
	git submodule update

edison-bcm43340/.git:
	git submodule init
	git submodule update

edison-linux/.config: edison-linux/.git edison-default-kernel.config
	cp edison-default-kernel.config edison-linux/.config

edison-linux/arch/x86/boot/bzImage: edison-linux/.config
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

.version: edison-linux/arch/x86/boot/bzImage
	echo -n $(cat "edison-linux/include/generated/utsrelease.h" 2>/dev/null | awk '{print $3}' | perl -p -e 's/^"(.*)"$/$1/') > .version

collected/latest: edison-linux/arch/x86/boot/bzImage edison-bcm43340/bcm4334x.ko .version
	mkdir -p collected
	./collect.sh
	ln -sf collected/$(cat .version) collected/latest

collect: collected/latest

${DFU}/.edison-helper-install: collected/latest $(DFU)/edison-image-edison.ext4  $(DFU)/edison-image-edison.hddimg
	./dfu-image-install.sh "${DFU}"
	touch ${DFU}/.edison-helper-install

install: ${DFU}/.edison-helper-install

flashall: ${DFU}/.edison-helper-install
	cd "${DFU}" && ./flashall.sh

.PHONY: all
