include(CheckIncludeFile)

check_include_file("unistd.h" HAVE_UNISTD_H)
check_include_file("inttypes.h" HAVE_INTTYPES_H)
check_include_file("stdint.h" HAVE_STDINT_H)
check_include_file("alloca.h" HAVE_ALLOCA_H)

set(AMXXPC_PLATFORM_DEFINES "")
set(AMXXPC_PLATFORM_LIBS "")

if(HAVE_UNISTD_H)
  list(APPEND AMXXPC_PLATFORM_DEFINES HAVE_UNISTD_H)
endif()
if(HAVE_INTTYPES_H)
  list(APPEND AMXXPC_PLATFORM_DEFINES HAVE_INTTYPES_H)
endif()
if(HAVE_STDINT_H)
  list(APPEND AMXXPC_PLATFORM_DEFINES HAVE_STDINT_H)
endif()
if(HAVE_ALLOCA_H)
  list(APPEND AMXXPC_PLATFORM_DEFINES HAVE_ALLOCA_H)
endif()

if(UNIX)
  if(NOT APPLE)
    list(APPEND AMXXPC_PLATFORM_DEFINES LINUX)
  endif()
  list(APPEND AMXXPC_PLATFORM_DEFINES ENABLE_BINRELOC _GNU_SOURCE)
  list(APPEND AMXXPC_PLATFORM_LIBS m pthread)

  if(NOT APPLE)
    list(APPEND AMXXPC_PLATFORM_LIBS dl)
  endif()

  include(CheckCCompilerFlag)

  set(_AMXXPC_C_WARNING_FLAGS
    -Wall
    -Wno-unused-result
    -Wno-constant-conversion
    -Wno-int-to-pointer-cast
    -Wno-unused-but-set-variable
    -Wno-address-of-packed-member
    -Wno-overflow
    -Wno-parentheses
    -Wno-maybe-uninitialized
    -Wno-stringop-truncation
    -Wno-strict-aliasing
  )

  foreach(_flag IN LISTS _AMXXPC_C_WARNING_FLAGS)
    string(MAKE_C_IDENTIFIER "HAVE${_flag}" _var)
    check_c_compiler_flag(${_flag} ${_var})
    if(${_var})
      add_compile_options(${_flag})
    endif()
  endforeach()

  if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_compile_options(-g)
  endif()
endif()

if(WIN32)
  list(APPEND AMXXPC_PLATFORM_DEFINES _CRT_SECURE_NO_WARNINGS)
  if(MSVC)
    add_compile_options(/W3)
  endif()
endif()

set(CMAKE_C_STANDARD 99)
set(CMAKE_CXX_STANDARD 11)
