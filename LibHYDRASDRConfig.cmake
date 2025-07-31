# - Try to find LibHYDRASDR
# Once done this will define
#
#  LibHYDRASDR - System has libhydrasdr
#  LibHYDRASDR - The libhydrasdr include directories
#  LibHYDRASDR - The libraries needed to use libhydrasdr
#  LibHYDRASDR - Compiler switches required for using libhydrasdr
#  LibHYDRASDR - The librtlsdr version
#

find_package(PkgConfig)
pkg_check_modules(PC_LibHYDRASDR libhydrasdr)
set(LibHYDRASDR ${PC_LibHYDRASDR_CFLAGS_OTHER})

find_path(
    LibHYDRASDR_INCLUDE_DIRS
    NAMES libhydrasdr/hydrasdr.h
    HINTS $ENV{LibHYDRASDR_DIR}/include
        ${PC_LibHYDRASDR_INCLUDEDIR}
    PATHS /usr/local/include
          /usr/include
)

find_library(
    LibHYDRASDR_LIBRARIES
    NAMES hydrasdr
    HINTS $ENV{LibHYDRASDR_DIR}/lib
        ${PC_LibHYDRASDR_LIBDIR}
    PATHS /usr/local/lib
          /usr/lib
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
