#!/bin/sh

#
# Where do you want to install gcc?
# WARNING: selected path will be suffixed with
#          gcc version, like installdir-gcc-x.x.x!
#
export GCC_INSTALL_DIRECTORY=/usr/local


#
# Set temporary paths
#
export path_to_build=$PWD/tmp/build
export path_to_source=$PWD/tmp/src
export path_to_install=$PWD/tmp/install
mkdir -p $path_to_build
mkdir -p $path_to_source
mkdir -p $path_to_install


#
# Select packages
#
GMP_VERSION="6.1.2"
MPFR_VERSION="3.1.5"
MPC_VERSION="1.0.3"
ISL_VERSION="0.17.1"
GCC_VERSION="6.2.0"

PARALLEL_JOBS=8

GMP_SELECT=y
MPFR_SELECT=y
MPC_SELECT=y
ISL_SELECT=y
GCC_SELECT=y


#
# Download packages
#
if [ $GMP_SELECT = y ] && [ ! -f $path_to_source/gmp-$GMP_VERSION.tar.bz2 ]; then
  echo "Download gmp-$GMP_VERSION"
  cd $path_to_source; curl -OL https://gmplib.org/download/gmp-$GMP_VERSION/gmp-$GMP_VERSION.tar.bz2
fi
if [ $MPFR_SELECT = y ] && [ ! -f $path_to_source/mpfr-$MPFR_VERSION.tar.bz2 ]; then
  echo "Download mpfr-$MPFR_VERSION"
  cd $path_to_source; curl -OL https://ftp.gnu.org/gnu/mpfr/mpfr-$MPFR_VERSION.tar.bz2
fi
if [ $MPC_SELECT = y ] && [ ! -f $path_to_source/mpc-$MPC_VERSION.tar.gz ]; then
  echo "Download mpc-$MPC_VERSION"
  cd $path_to_source; curl -OL https://ftp.gnu.org/gnu/mpc/mpc-$MPC_VERSION.tar.gz
fi
if [ $ISL_SELECT = y ] && [ ! -f $path_to_source/isl-$ISL_VERSION.tar.bz2 ]; then
  echo "Download isl-$ISL_VERSION"
  cd $path_to_source; curl -OL http://isl.gforge.inria.fr/isl-$ISL_VERSION.tar.bz2
fi
if [ $GCC_SELECT = y ] && [ ! -f $path_to_source/gcc-$GCC_VERSION.tar.bz2 ]; then
  echo "Download gcc-$GCC_VERSION"
  cd $path_to_source; curl -OL https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.bz2
fi
echo "Download complete!"


#
# Build packages
#
# get required bins and a fresh start
xcode-select --install
rm -rf $path_to_install/*

#
# GMP
#
if [ $GMP_SELECT = y ]; then
rm -rf $path_to_build/gmp-$GMP_VERSION
tar xjf $path_to_source/gmp-$GMP_VERSION.tar.bz2 -C $path_to_build
cd $path_to_build/gmp-$GMP_VERSION
mkdir build && cd build
../configure --prefix=$path_to_install --enable-cxx  --enable-static --disable-shared
make -j $PARALLEL_JOBS
make install
fi

#
# MPFR
#
if [ $MPFR_SELECT = y ]; then
rm -rf $path_to_build/mpfr-$MPFR_VERSION
tar xjf $path_to_source/mpfr-$MPFR_VERSION.tar.bz2 -C $path_to_build
cd $path_to_build/mpfr-$MPFR_VERSION
mkdir build && cd build
../configure --prefix=$path_to_install --with-gmp=$path_to_install --enable-static --disable-shared
make -j $PARALLEL_JOBS
make install
fi

#
# MPC
#
if [ $MPC_SELECT = y ]; then
rm -rf $path_to_build/mpc-$MPC_VERSION
tar xzf $path_to_source/mpc-$MPC_VERSION.tar.gz -C $path_to_build
cd $path_to_build/mpc-$MPC_VERSION
mkdir build && cd build
../configure --prefix=$path_to_install --with-gmp=$path_to_install --with-mpfr=$path_to_install --enable-static --disable-shared
make -j $PARALLEL_JOBS
make install
fi

#
# ISL
#
if [ $ISL_SELECT = y ]; then
rm -rf $path_to_build/isl-$ISL_VERSION
tar xjf $path_to_source/isl-$ISL_VERSION.tar.bz2 -C $path_to_build
cd $path_to_build/isl-$ISL_VERSION
mkdir build && cd build
../configure --prefix=$path_to_install --with-gmp-prefix=$path_to_install --enable-static --disable-shared
make -j $PARALLEL_JOBS
make install
fi

#
# GCC
#
if [ $GCC_SELECT = y ]; then
rm -rf $path_to_build/gcc-$GCC_VERSION
tar xjf $path_to_source/gcc-$GCC_VERSION.tar.bz2 -C $path_to_build
cd $path_to_build/gcc-$GCC_VERSION
mkdir build && cd build
../configure --prefix=$GCC_INSTALL_DIRECTORY/gcc-$GCC_VERSION --enable-checking=release --with-gmp=$path_to_install --with-mpfr=$path_to_install --with-mpc=$path_to_install --enable-languages=c,c++ --with-isl=$path_to_install --program-suffix=-$GCC_VERSION
make -j $PARALLEL_JOBS
echo "Enter password to complete installation to $GCC_INSTALL_DIRECTORY/gcc-$GCC_VERSION"
sudo make install
echo "gcc installed to $GCC_INSTALL_DIRECTORY/gcc-$GCC_VERSION"
fi


