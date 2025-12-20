# - Try to find LibHYDRASDR
# Once done this will define
#
#  LibHYDRASDR_FOUND - System has libhydrasdr
#  LibHYDRASDR_INCLUDE_DIRS - The libhydrasdr include directories
#  LibHYDRASDR_LIBRARIES - The libraries needed to use libhydrasdr
#  LibHYDRASDR_CFLAGS_OTHER - Compiler switches required for using libhydrasdr
#  LibHYDRASDR_VERSION - The libhydrasdr version

find_package(PkgConfig)
pkg_check_modules(PC_LibHYDRASDR hydrasdr)

# Try alternative pkg-config names if first attempt fails
if(NOT PC_LibHYDRASDR_FOUND)
    pkg_check_modules(PC_LibHYDRASDR libhydrasdr)
endif()

set(LibHYDRASDR_CFLAGS_OTHER ${PC_LibHYDRASDR_CFLAGS_OTHER})

# Define possible project-specific installation paths
set(PROJECT_INSTALL_PATHS
    "${CMAKE_CURRENT_SOURCE_DIR}/rfone_host_build/install/include"
    "${CMAKE_CURRENT_SOURCE_DIR}/../rfone_host_build/install/include"
    "${CMAKE_CURRENT_BINARY_DIR}/rfone_host_build/install/include"
    "${CMAKE_CURRENT_BINARY_DIR}/../rfone_host_build/install/include"
)

set(PROJECT_LIB_PATHS
    "${CMAKE_CURRENT_SOURCE_DIR}/rfone_host_build/install/lib"
    "${CMAKE_CURRENT_SOURCE_DIR}/rfone_host_build/install/lib64"
    "${CMAKE_CURRENT_SOURCE_DIR}/../rfone_host_build/install/lib"
    "${CMAKE_CURRENT_SOURCE_DIR}/../rfone_host_build/install/lib64"
    "${CMAKE_CURRENT_BINARY_DIR}/rfone_host_build/install/lib"
    "${CMAKE_CURRENT_BINARY_DIR}/rfone_host_build/install/lib64"
    "${CMAKE_CURRENT_BINARY_DIR}/../rfone_host_build/install/lib"
    "${CMAKE_CURRENT_BINARY_DIR}/../rfone_host_build/install/lib64"
)

# Windows-specific paths (vcpkg)
if(WIN32)
    list(APPEND PROJECT_INSTALL_PATHS
        "${CMAKE_CURRENT_SOURCE_DIR}/rfone_host_build/install/include"
        "${LIBHYDRASDR_ROOT}/include"
    )
    list(APPEND PROJECT_LIB_PATHS
        "${CMAKE_CURRENT_SOURCE_DIR}/rfone_host_build/install/bin"
        "${LIBHYDRASDR_ROOT}/lib"
        "${LIBHYDRASDR_ROOT}/bin"
    )
endif()

find_path(
    LibHYDRASDR_INCLUDE_DIRS
    NAMES hydrasdr.h libhydrasdr/hydrasdr.h
    HINTS $ENV{LibHYDRASDR_DIR}/include
        ${PC_LibHYDRASDR_INCLUDEDIR}
    PATHS 
        # Project-specific paths (for CI builds)
        ${PROJECT_INSTALL_PATHS}
        # Standard system paths
        /usr/local/include
        /usr/include
        /opt/local/include
    PATH_SUFFIXES libhydrasdr
)

find_library(
    LibHYDRASDR_LIBRARIES
    NAMES hydrasdr libhydrasdr
    HINTS $ENV{LibHYDRASDR_DIR}/lib
        ${PC_LibHYDRASDR_LIBDIR}
    PATHS
        # Project-specific paths (for CI builds)
        ${PROJECT_LIB_PATHS}
        # Standard system paths
        /usr/local/lib
        /usr/lib
        /usr/lib/x86_64-linux-gnu
        /usr/lib64
        /opt/local/lib
)

set(LibHYDRASDR_VERSION ${PC_LibHYDRASDR_VERSION})

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set LibHYDRASDR_FOUND to TRUE
# if all listed variables are TRUE
# Note that `FOUND_VAR LibHYDRASDR_FOUND` is needed for cmake 3.2 and older.
find_package_handle_standard_args(LibHYDRASDR
                                  FOUND_VAR LibHYDRASDR_FOUND
                                  REQUIRED_VARS LibHYDRASDR_LIBRARIES LibHYDRASDR_INCLUDE_DIRS
                                  VERSION_VAR LibHYDRASDR_VERSION)

mark_as_advanced(LibHYDRASDR_LIBRARIES LibHYDRASDR_INCLUDE_DIRS)

# Debug output when found
if(LibHYDRASDR_FOUND)
    message(STATUS "LibHydraSDR found:")
    message(STATUS "  Version: ${LibHYDRASDR_VERSION}")
    message(STATUS "  Libraries: ${LibHYDRASDR_LIBRARIES}")
    message(STATUS "  Include dirs: ${LibHYDRASDR_INCLUDE_DIRS}")
    message(STATUS "  CFlags: ${LibHYDRASDR_CFLAGS_OTHER}")
else()
    message(STATUS "LibHydraSDR NOT found. Searched in:")
    message(STATUS "  Project paths: ${PROJECT_INSTALL_PATHS}")
    message(STATUS "  System paths: /usr/local/include, /usr/include")
    message(STATUS "  Library paths: ${PROJECT_LIB_PATHS}")
    message(STATUS "  System lib paths: /usr/local/lib, /usr/lib, /usr/lib64, /usr/lib/x86_64-linux-gnu")
endif()
