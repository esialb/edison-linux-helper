#!/bin/bash

. functions.sh

RELEASE=$(eh_kernel_release_version)

FSROOT="$(eh_collected_dir)"

MODULES="${FSROOT}/lib/modules/${RELEASE}"

BZIMAGE="$(eh_kernel_src)/arch/x86/boot/bzImage"

echo "copying kernel modules"

[ -e "${MODULES}" ] && rm -Rf "${MODULES}"

MODCOUNT=0
for KO in `find $(eh_kernel_src)/* -name '*.ko'`; do
  D=$(dirname "${KO}")
  mkdir -p "${MODULES}/kernel/${D}"
  cp "${KO}" "${MODULES}/kernel/${D}"
  echo -n .
  MODCOUNT=$((${MODCOUNT} + 1))
done
for KO in $(eh_bcm43340_src)/bcm4334x.ko; do
  mkdir -p "${MODULES}/extra"
  cp "${KO}" "${MODULES}/extra"
  echo -n .
  MODCOUNT=$((${MODCOUNT} + 1))
done
echo
echo "${MODCOUNT} modules copied"

echo "computing module dependencies"
cp edison-linux/modules.* "${MODULES}"
depmod -a -b "${FSROOT}" -F edison-linux/System.map "${RELEASE}"

echo "copying kernel image"

mkdir -p "${FSROOT}/lib/kernel"
mkdir -p "${FSROOT}/boot"
[ -e "${FSROOT}/boot/bzImage-${RELEASE}" ] && rm -Rf "${FSROOT}/boot/bzImage-${RELEASE}"
cp "${BZIMAGE}" "${FSROOT}/lib/kernel/bzImage-${RELEASE}"
cp "${BZIMAGE}" "${FSROOT}/boot/vmlinuz"

ln -sf "${FSROOT}" "collected/latest"
