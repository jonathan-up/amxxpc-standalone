cmake_minimum_required(VERSION 3.15)
project(amxxpc VERSION 1.10.0 LANGUAGES C CXX)

option(AMXXPC_STATIC "Static link libpc300 into amxxpc (single binary)" ON)
option(AMXXPC_BUILD_SHARED "Also build amxxpc32 shared library" OFF)

include(cmake/PlatformSetup.cmake)
find_package(ZLIB REQUIRED)

add_subdirectory(libpc300)
add_subdirectory(amxxpc)
