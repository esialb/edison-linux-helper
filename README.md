# edison-linux-helper

*handy wrapper repo for building edison kernels*

Simple wrapper repo with submodules for [edison-linux](https://github.com/01org/edison-linux/) and [edison-bcm43340](https://github.com/01org/edison-bcm43340/).
Suitable for building new kernels for an Intel Edison, with wifi and bluetooth support.
Can collect built kernel and modules into a directory for scp over to a running Edison, or update the kernel and modules on a DFU installation image.

Applies two small patches to edison-linux (see [mfd_trace.h.patch](mfd_trace.h.patch) and [sst_trace.h.patch](sst_trace.h.patch)) that fix trivial compilation issues.
Presumably the Yocto tools add additional internal include paths not specified in the edison-linux kernel sources themselves when compiling a kernel.

Includes two kernel configurations:

1.  [Kernel config](edison-default-kernel.config) from stock edison images
2.  [Kernel config](edison-recommended-kernel.config) with many more options and modules, so Edison makes a useful headless server


## TL;DR

Configuring and building a kernel:

```bash
git clone https://github.com/esialb/edison-linux-helper.git
cd edison-linux-helper/
make xconfig
make
```

Updating a DFU installation image:

```bash
DFU=../edison-image-latest/ sudo make install
```

Updating a running Edison:

```bash
make collected
cd collected/latest/
scp -r * root@192.168.2.15:/
ssh root@192.168.2.15 reboot
```
