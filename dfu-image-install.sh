#!/bin/bash

TOFLASH="$1"

if [ -z "${TOFLASH}" ]; then
  echo "./dfu-image-install.sh /path/to/edison/image/toFlash"
  exit 1
fi

RELEASE="$(eh_kernel_release_version)"

FSROOT_IMAGE="${TOFLASH}/edison-image-edison.ext4"
FSBOOT_IMAGE="${TOFLASH}/edison-image-edison.hddimg"

FSROOT_MOUNT="${FSROOT_IMAGE}.mnt"
FSBOOT_MOUNT="${FSBOOT_IMAGE}.mnt"

MODULES="${FSROOT_MOUNT}/lib/modules/${RELEASE}"

BZIMAGE="$(eh_collected_dir)/boot/vmlinuz"

echo "mounting filesystem images"

mkdir -p "${FSROOT_MOUNT}"
mkdir -p "${FSBOOT_MOUNT}"

mount -o loop "${FSROOT_IMAGE}" "${FSROOT_MOUNT}" || exit 1
mount -o loop "${FSBOOT_IMAGE}" "${FSBOOT_MOUNT}" || exit 1

echo "copying kernel modules"

[ -e "${MODULES}" ] && rm -Rf "${MODULES}"

MODCOUNT=0
for KO in `find $(eh_collected_dir)/* -name '*.ko'`; do
  D=$(dirname "${KO}")
  mkdir -p "${MODULES}/kernel/${D}"
  cp "${KO}" "${MODULES}/kernel/${D}"
  echo -n .
  MODCOUNT=$((${MODCOUNT} + 1))
done
echo
echo "${MODCOUNT} modules copied"

echo "computing module dependencies"
cp modules.* "${MODULES}"
depmod -a -b "${FSROOT_MOUNT}" -F System.map "${RELEASE}"

echo "copying kernel image"

[ -e "${FSROOT_MOUNT}/boot/bzImage-${RELEASE}" ] && rm -Rf "${FSROOT_MOUNT}/boot/bzImage-${RELEASE}"
cp "${BZIMAGE}" "${FSROOT_MOUNT}/boot/bzImage-${RELEASE}"

[ -e "${FSROOT_MOUNT}/boot/bzImage" ] && rm -Rf "${FSROOT_MOUNT}/boot/bzImage"
ln -sf "bzImage-${RELEASE}" "${FSROOT_MOUNT}/boot/bzImage"

[ -e "${FSBOOT_MOUNT}/vmlinuz" ] && rm -Rf "${FSBOOT_MOUNT}/vmlinuz"
cp "${BZIMAGE}" "${FSBOOT_MOUNT}/vmlinuz"

echo "unmounting filesystem images"

while ! umount "${FSBOOT_MOUNT}" > /dev/null 2>&1; do sleep 1; done
while ! umount "${FSROOT_MOUNT}" > /dev/null 2>&1; do sleep 1; done

rmdir "${FSBOOT_MOUNT}"
rmdir "${FSROOT_MOUNT}"
