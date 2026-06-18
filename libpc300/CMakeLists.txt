set(LIBPC300_SOURCES
  sc1.c
  sc2.c
  sc3.c
  sc4.c
  sc5.c
  sc6.c
  sc7.c
  scvars.c
  scmemfil.c
  scstate.c
  sclist.c
  sci18n.c
  libpawnc.c
  memfile.c
  sp_symhash.c
)

if(UNIX)
  list(APPEND LIBPC300_SOURCES prefix.c)
endif()

if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
  set_source_files_properties(sc1.c PROPERTIES COMPILE_OPTIONS
    "-Wno-maybe-uninitialized;-Wno-stringop-truncation;-Wno-overflow")
  set_source_files_properties(sc2.c PROPERTIES COMPILE_OPTIONS
    "-Wno-strict-aliasing")
  set_source_files_properties(sc3.c PROPERTIES COMPILE_OPTIONS
    "-Wno-maybe-uninitialized")
  set_source_files_properties(sc7.c PROPERTIES COMPILE_OPTIONS
    "-Wno-int-to-pointer-cast")
endif()

set(LIBPC300_DEFINES
  NO_MAIN
  PAWNC_DLL
  ${AMXXPC_PLATFORM_DEFINES}
)

# Static library (for linking into amxxpc)
if(AMXXPC_STATIC)
  add_library(libpc300_static STATIC ${LIBPC300_SOURCES})
  target_compile_definitions(libpc300_static PRIVATE ${LIBPC300_DEFINES})
  target_include_directories(libpc300_static PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
  target_link_libraries(libpc300_static PRIVATE ${AMXXPC_PLATFORM_LIBS})
  set_target_properties(libpc300_static PROPERTIES
    OUTPUT_NAME pc300
    POSITION_INDEPENDENT_CODE ON
  )
endif()

# Shared library (amxxpc32.so / amxxpc32.dll / amxxpc32.dylib)
if(AMXXPC_BUILD_SHARED)
  add_library(amxxpc32 SHARED ${LIBPC300_SOURCES})
  target_compile_definitions(amxxpc32 PRIVATE ${LIBPC300_DEFINES})
  target_include_directories(amxxpc32 PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
  target_link_libraries(amxxpc32 PRIVATE ${AMXXPC_PLATFORM_LIBS})

  if(WIN32)
    set_target_properties(amxxpc32 PROPERTIES
      DEFINE_SYMBOL "PAWNC_DLL"
    )
  endif()

  if(UNIX AND NOT APPLE)
    add_custom_command(TARGET amxxpc32 POST_BUILD
      COMMAND strip -K Compile32 -K pc_printf -K pc_compile -K pc_addconstant -K pc_addtag -K pc_enablewarning $<TARGET_FILE:amxxpc32>
      COMMENT "Stripping amxxpc32 shared library"
    )
  endif()
endif()
