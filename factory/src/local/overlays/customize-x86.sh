#!/bin/sh

PATH="/usr/sbin:/usr/bin:/sbin:/bin:"
rootfs="$(pwd)/build_core2duo_4.16.0-rc4/rfs"
overlaydir="$(pwd)/src/local/overlays"
kernel="4.16.0-rc4-zii"

printf "#################################################\n"
printf "#### rootfs customization script running now ####\n"
printf "#################################################\n\n"

printf "Purging extraneous files and directories...\n"
find $rootfs -type d -name .svn  | xargs rm -rf 2>/dev/null
egrep '^[a-zA-Z0-9]' $overlaydir/extraneous.lst | while read entry; do
     rm -rf $rootfs/$entry
done

printf "Fixing permissions...\n"
chmod 0700 $rootfs/root $rootfs/root/.ssh
chmod 0700 $rootfs/etc/openssh
chmod 0400 $rootfs/root/.ssh/authorized_keys
chmod 0400 $rootfs/root/.ssh/config
chmod 0400 $rootfs/root/.ssh/root.key.private
chmod 0400 $rootfs/etc/shadow
chmod 0400 $rootfs/etc/openssh/*

printf "Populating version information...\n"
version="$(svnversion)"
printf "$version\n" >$rootfs/etc/version
printf "VERSION=$version\n" >>$rootfs/etc/os-release
printf "VERSION_ID=$version\n" | cut -d: -f1 >>$rootfs/etc/os-release

printf "Generating module dependencies...\n"
pushd src/local/kernel/linux-$kernel/
depmod -ae -F System.map -b $rootfs $kernel+
popd
