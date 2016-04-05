KERNEL=edison-linux/arch/x86/boot/bzImage
BCM4334X=edison-bcm43340/bcm4334x.ko
VERSION=`echo -n $(cat "edison-linux/include/generated/utsrelease.h" 2>/dev/null | awk '{print $3}' | perl -p -e 's/^"(.*)"$/$1/')`

.gitmodules:
	git submodule init

edison-linux: .gitmodules
	git submodule update

edison-bcm43340: .gitmodules
	git submodule update

edison-linux/.config: edison-linux edison-default-kernel.config
	cp edison-default-kernel.config edison-linux/.config

$(KERNEL): edison-linux/.config
	cd edison-linux && make

$(BCM4334X): $(KERNEL)
	cd edison-bcm43340 && make

all: $(KERNEL) $(BCM4334X)

config: edison-linux
	cd edison-linux && make config

xconfig: edison-linux
	cd edison-linux && make xconfig

clean:
	cd edison-linux && make clean
	cd edison-bcm43340 && make clean

collected/$VERSION:
	./collect.sh

install: collected/$VERSION $(DFU)/edison-image-edison.ext4  $(DFU)/edison-image-edison.hddimg
	./dfu-image-install.sh $(DFU)

.PHONY: all
