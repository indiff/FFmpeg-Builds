# For more information, see 
# https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html,
# https://cmake.org/cmake/help/book/mastering-cmake/chapter/Cross%20Compiling%20With%20CMake.html, and
# https://tttapa.github.io/Pages/Raspberry-Pi/C++-Development-RPiOS/index.html.

include(CMakeDependentOption)

# System information
set(CMAKE_SYSTEM_NAME "Linux")
set(CMAKE_SYSTEM_PROCESSOR "x86_64")
set(CROSS_GNU_TRIPLE "x86_64-centos7-linux-gnu"
    CACHE STRING "The GNU triple of the toolchain to use")
set(CMAKE_LIBRARY_ARCHITECTURE "x86_64-linux-gnu")

# Compiler flags
set(CMAKE_C_FLAGS_INIT       "")
set(CMAKE_CXX_FLAGS_INIT     "")
set(CMAKE_Fortran_FLAGS_INIT "")

set(triple x86_64-centos7-linux-gnu)

set(CMAKE_C_COMPILER ${triple}-gcc)
set(CMAKE_CXX_COMPILER ${triple}-g++)
set(CMAKE_RANLIB ${triple}-gcc-ranlib)
set(CMAKE_AR ${triple}-gcc-ar)

# Search path configuration
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
# set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Packaging
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "amd64")

# Toolchain and sysroot
set(TOOLCHAIN_DIR "/opt/x-tools/${CROSS_GNU_TRIPLE}")
set(CMAKE_SYSROOT "${TOOLCHAIN_DIR}/${CROSS_GNU_TRIPLE}/sysroot")
list(APPEND CMAKE_BUILD_RPATH "${TOOLCHAIN_DIR}/${CROSS_GNU_TRIPLE}/lib64")

# set(CMAKE_SYSROOT /opt/ct-ng/${triple}/sysroot)
set(CMAKE_FIND_ROOT_PATH ${TOOLCHAIN_DIR} ${TOOLCHAIN_DIR}/${CROSS_GNU_TRIPLE}/sysroot /opt/ffbuild)

# Compiler binaries
set(CMAKE_C_COMPILER "${TOOLCHAIN_DIR}/bin/${CROSS_GNU_TRIPLE}-gcc"
    CACHE FILEPATH "C compiler")
set(CMAKE_CXX_COMPILER "${TOOLCHAIN_DIR}/bin/${CROSS_GNU_TRIPLE}-g++"
    CACHE FILEPATH "C++ compiler")
set(CMAKE_Fortran_COMPILER "${TOOLCHAIN_DIR}/bin/${CROSS_GNU_TRIPLE}-gfortran"
    CACHE FILEPATH "Fortran compiler")
