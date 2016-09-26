#!/bin/bash

if [ $# != 0 ]; then
  cat <<EOF
This script:

- tested on a x86_64 Ubuntu 16.04 machine
- builds debug and release for the current platform
- also attempts to build release for ARMv7 (32 bit) and PowerPC (32 bit) Linux targets
- also attempts to build release for x86 (64 bit) for Windows (MinGW) target
- strips out symbols for release executables
- prints out executable segments sizes
- note: cargo builds are started in parallel
- note: project name is fetched from Cargo.toml file in current directory


Installation:
- requires rustup >= 0.6.3
- requires cross-compilation binutils packages (examples below work on Ubuntu 16.04)


Rustup targets installation:
    rustup target install armv7-unknown-linux-gnueabihf
    rustup target install powerpc-unknown-linux-gnu
    rustup target install x86_64-pc-windows-gnu


Rustup configuration file ~/.cargo/config must contain:

[target.armv7-unknown-linux-gnueabihf]
linker = "arm-linux-gnueabihf-gcc"

[target.powerpc-unknown-linux-gnu]
linker = "powerpc-linux-gnu-gcc"

[target.x86_64-pc-windows-gnu]
linker = "x86_64-w64-mingw32-gcc"


Ubuntu 16.04 host requirements for ARMv7 cross-compiling:
    sudo apt install gcc-arm-linux-gnueabihf

Ubuntu 16.04 host requirements for PowerPC (32 bit with Ubuntu 16.04) cross-compiling:
    sudo apt install gcc-5-powerpc-linux-gnu

Ubuntu 16.04 host requirements for PowerPC (32 bit with Ubuntu 12.04 or 14.04) cross-compiling:
    sudo apt install gcc-powerpc-linux-gnu

Ubuntu 16.04 host requirements for x86/64 MinGW (Windows) cross-compiling:
    sudo apt install gcc-mingw-w64-x86-64

Ubuntu/PPC 12.04 target requirements: upgrade libc6 and libnih from Ubuntu/PPC 14.04 (download from launchpad.net):
    dpkg -i libc6_2.18*ubuntu*powerpc.deb libc-dev-bin_2.18*ubuntu*powerpc.deb libc6-dev_2.18*ubuntu*powerpc.deb
    dpkg -i libnih1_1.0.3*ubuntu*powerpc.deb libnih-dbus1_1.0.3*ubuntu*powerpc.deb

Maemo 5 target requirements: need a separate directory (for example "/root/rust", see http://talk.maemo.org/showthread.php?t=97650 ) for use with LD_LIBRARY_PATH and libc6 2.6.18 and libgcc_s (download from rpmfind.net, from OpenSUSE 13.x/ARM), plus something like:
    ln -s /root/rust/ld-linux-armhf.so.3 /lib

SailfishOS 2.0 ARM target (Jolla phone) requirements: none, it just works

ArchLinuxARM 2016 target (ARMv7, like the Beagleboard) requirements: none, it just works

EOF
  exit 0
fi


if [ ! -f Cargo.toml ]; then
  echo no Cargo.toml file
  exit 1
fi
NAME=`grep name Cargo.toml | head -1 | cut -b9- | tr -d '"'`


# architecture "triplet" and prefix "triplet":

AARM=armv7-unknown-linux-gnueabihf
PARM=arm-linux-gnueabihf

APPC=powerpc-unknown-linux-gnu
PPPC=powerpc-linux-gnu

AMGW=x86_64-pc-windows-gnu
PMGW=x86_64-w64-mingw32


cargo build --quiet &
cargo build --quiet --release &
cargo build --quiet --release --target=$AARM &
cargo build --quiet --release --target=$APPC &
cargo build --quiet --release --target=$AMGW &
wait

# release builds: executable names
#
RNAT=target/release/$NAME
RARM=target/$AARM/release/$NAME
RPPC=target/$APPC/release/$NAME
RMGW=target/$AMGW/release/$NAME.exe

# stripping symbols from executables:
strip $RNAT
$PARM-strip $RARM
$PPPC-strip $RPPC
$PMGW-strip $RMGW

LST="target/debug/$NAME $RNAT $RARM $RPPC $RMGW"

for a in $LST
do
  if [ -x $a ]; then
    size $a
  fi
done

for a in $LST
do
  if [ -x $a ]; then
    ls -o $a
  fi
done

# ---
