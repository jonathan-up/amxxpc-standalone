set(AMXXPC_SOURCES
  amxxpc.cpp
  amx_mini.cpp
  Binary.cpp
)

add_executable(amxxpc ${AMXXPC_SOURCES})

target_compile_definitions(amxxpc PRIVATE
  AMX_ANSIONLY
  ${AMXXPC_PLATFORM_DEFINES}
)

target_include_directories(amxxpc PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}
)

if(MSVC)
  set_target_properties(amxxpc PROPERTIES
    LINK_FLAGS "/SUBSYSTEM:CONSOLE"
  )
  target_compile_options(amxxpc PRIVATE /EHsc)
else()
  target_compile_options(amxxpc PRIVATE -fexceptions)
endif()

if(AMXXPC_STATIC)
  target_compile_definitions(amxxpc PRIVATE AMXXPC_STATIC)
  target_link_libraries(amxxpc PRIVATE libpc300_static ZLIB::ZLIB ${AMXXPC_PLATFORM_LIBS})
else()
  target_link_libraries(amxxpc PRIVATE ZLIB::ZLIB ${AMXXPC_PLATFORM_LIBS})
endif()
