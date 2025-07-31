###################################################
# Build Soapy SDR support module for HydraSDR Devices
###################################################

cmake_minimum_required(VERSION 3.10)

# Project version - UPDATE THIS FOR RELEASES
set(SOAPYHYDRASDR_VERSION "1.0.0")

project(SoapyHydraSDR VERSION ${SOAPYHYDRASDR_VERSION} LANGUAGES CXX)

message(STATUS "Building SoapyHydraSDR version: ${SOAPYHYDRASDR_VERSION}")

# Set default build type to Release if not specified
if(NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE Release)
endif()

# Platform-specific settings
if(WIN32)
	# Use static runtime on Windows for better compatibility
	set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
	
	# Set proper Windows subsystem
	if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
		set(CMAKE_WIN32_EXECUTABLE OFF)
	endif()
endif()

# Find required dependencies
find_package(SoapySDR "0.4.0" NO_MODULE REQUIRED)
if(NOT SoapySDR_FOUND)
	message(FATAL_ERROR "Soapy SDR development files not found...")
endif()
message(STATUS "Found SoapySDR: ${SoapySDR_VERSION}")

# Ensure SoapySDR module directory is set
if(NOT SOAPY_SDR_MODULE_DIR)
	# Extract SoapySDR ABI version from full version
	if(SoapySDR_VERSION)
		string(REGEX MATCH "^([0-9]+\\.[0-9]+)" SoapySDR_ABI_VERSION "${SoapySDR_VERSION}")
		message(STATUS "Extracted SoapySDR ABI version: ${SoapySDR_ABI_VERSION}")
	endif()
	
	if(NOT SoapySDR_ABI_VERSION)
		set(SoapySDR_ABI_VERSION "0.8")  # Fallback version
		message(STATUS "Using fallback SoapySDR ABI version: ${SoapySDR_ABI_VERSION}")
	endif()
	
	# Try to detect SoapySDR module directory using pkg-config
	find_package(PkgConfig QUIET)
	if(PKG_CONFIG_FOUND)
		pkg_check_modules(SOAPYSDR_PC QUIET SoapySDR)
		if(SOAPYSDR_PC_FOUND)
			execute_process(
				COMMAND ${PKG_CONFIG_EXECUTABLE} --variable=moduledir SoapySDR
				OUTPUT_VARIABLE SOAPY_SDR_MODULE_DIR
				OUTPUT_STRIP_TRAILING_WHITESPACE
				ERROR_QUIET
			)
		endif()
	endif()
	
	# Fallback to common locations if still not found
	if(NOT SOAPY_SDR_MODULE_DIR)
		if(WIN32)
			set(SOAPY_SDR_MODULE_DIR "lib/SoapySDR/modules${SoapySDR_ABI_VERSION}")
		elseif(APPLE)
			set(SOAPY_SDR_MODULE_DIR "/usr/local/lib/SoapySDR/modules${SoapySDR_ABI_VERSION}")
		else()
			# Linux - try common locations
			foreach(POSSIBLE_DIR 
				"/usr/lib/x86_64-linux-gnu/SoapySDR/modules${SoapySDR_ABI_VERSION}"
				"/usr/lib/SoapySDR/modules${SoapySDR_ABI_VERSION}"
				"/usr/local/lib/SoapySDR/modules${SoapySDR_ABI_VERSION}")
				if(EXISTS "${POSSIBLE_DIR}")
					set(SOAPY_SDR_MODULE_DIR "${POSSIBLE_DIR}")
					break()
				endif()
			endforeach()
			
			# Final fallback
			if(NOT SOAPY_SDR_MODULE_DIR)
				set(SOAPY_SDR_MODULE_DIR "/usr/lib/x86_64-linux-gnu/SoapySDR/modules0.8")
			endif()
		endif()
		message(STATUS "SoapySDR module directory not auto-detected, using fallback: ${SOAPY_SDR_MODULE_DIR}")
	else()
		message(STATUS "Detected SoapySDR module directory: ${SOAPY_SDR_MODULE_DIR}")
	endif()
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

# Try to find system-installed LibHYDRASDR first
find_package(LibHYDRASDR REQUIRED)

if(NOT LibHYDRASDR_FOUND)
	message(STATUS "System LibHYDRASDR not found, will use locally built version")
	
	# Set paths for locally built LibHYDRASDR
	# Check both source dir (CI builds here) and binary dir (local builds)
	set(POSSIBLE_INSTALL_DIRS 
		"${CMAKE_CURRENT_SOURCE_DIR}/rfone_host_build/install"
		"${CMAKE_CURRENT_BINARY_DIR}/rfone_host_build/install"
		"${CMAKE_CURRENT_SOURCE_DIR}/../rfone_host_build/install"
	)
	
	foreach(INSTALL_DIR ${POSSIBLE_INSTALL_DIRS})
		if(WIN32)
			set(TEST_LIB "${INSTALL_DIR}/lib/hydrasdr.lib")
			set(TEST_HEADER "${INSTALL_DIR}/include/libhydrasdr/hydrasdr.h")
		elseif(APPLE)
			set(TEST_LIB "${INSTALL_DIR}/lib/libhydrasdr.dylib")
			set(TEST_HEADER "${INSTALL_DIR}/include/libhydrasdr/hydrasdr.h")
		else() # Linux
			set(TEST_LIB "${INSTALL_DIR}/lib/libhydrasdr.so")
			set(TEST_HEADER "${INSTALL_DIR}/include/libhydrasdr/hydrasdr.h")
		endif()
		
		# Also check alternative header location
		set(ALT_HEADER "${INSTALL_DIR}/include/hydrasdr.h")
		
		if(EXISTS "${TEST_LIB}" AND (EXISTS "${TEST_HEADER}" OR EXISTS "${ALT_HEADER}"))
			set(LibHYDRASDR_INCLUDE_DIRS "${INSTALL_DIR}/include")
			set(LibHYDRASDR_LIBRARIES "${TEST_LIB}")
			message(STATUS "Found locally built LibHydraSDR at: ${INSTALL_DIR}")
			break()
		endif()
	endforeach()
	
	# Verify we found the library
	if(NOT LibHYDRASDR_LIBRARIES OR NOT LibHYDRASDR_INCLUDE_DIRS)
		message(FATAL_ERROR "Could not find locally built LibHydraSDR. Please ensure it is built first.
		
Searched in these locations:
${POSSIBLE_INSTALL_DIRS}

Expected files:
- Library: ${TEST_LIB}
- Header: ${TEST_HEADER} or ${ALT_HEADER}")
	endif()
endif()

message(STATUS "LibHYDRASDR include dirs: ${LibHYDRASDR_INCLUDE_DIRS}")
message(STATUS "LibHYDRASDR libraries: ${LibHYDRASDR_LIBRARIES}")

# Include directories - handle both direct include and subdirectory cases
if(LibHYDRASDR_INCLUDE_DIRS)
	# If headers are found in libhydrasdr subdirectory, we need to include the parent directory
	# so that #include <libhydrasdr/hydrasdr.h> works
	if("${LibHYDRASDR_INCLUDE_DIRS}" MATCHES "libhydrasdr$")
		# Headers are in libhydrasdr subdirectory, include the parent
		get_filename_component(PARENT_INCLUDE_DIR "${LibHYDRASDR_INCLUDE_DIRS}" DIRECTORY)
		include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${PARENT_INCLUDE_DIR})
		message(STATUS "Including parent directory for libhydrasdr headers: ${PARENT_INCLUDE_DIR}")
	else()
		# Headers are in main include directory
		include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${LibHYDRASDR_INCLUDE_DIRS})
		message(STATUS "Including directory: ${LibHYDRASDR_INCLUDE_DIRS}")
	endif()
else()
	message(FATAL_ERROR "LibHYDRASDR include directories not found")
endif()

# Enable C++11 features
if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU" OR "${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
	# C++11 is a required language feature for this project
	include(CheckCXXCompilerFlag)
	CHECK_CXX_COMPILER_FLAG("-std=c++11" HAS_STD_CXX11)
	if(HAS_STD_CXX11)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
	else(HAS_STD_CXX11)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
	endif()
	
	# Thread support enabled (not the same as -lpthread)
	list(APPEND HYDRASDR_LIBS -pthread)
	
	# Compiler warnings (Linux Kernel style preferences)
	add_compile_options(-Wall -Wextra -Wno-unused-parameter)
	
	# Additional useful warnings
	add_compile_options(-Wformat=2 -Wformat-security -Wformat-nonliteral)
	add_compile_options(-Wcast-qual -Wcast-align)
	add_compile_options(-Wpointer-arith -Wredundant-decls)
endif()

if(APPLE)
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wc++11-extensions")
endif(APPLE)

if(WIN32 AND MSVC)
	# Windows-specific compiler settings
	add_compile_options(/W4 /WX-)  # High warning level, but don't treat warnings as errors
	add_definitions(-D_CRT_SECURE_NO_WARNINGS)
	add_definitions(-D_WINSOCK_DEPRECATED_NO_WARNINGS)
	
	# Disable specific MSVC warnings that are too noisy
	add_compile_options(/wd4127)  # conditional expression is constant
	add_compile_options(/wd4996)  # deprecated functions
endif()

# Platform-specific libraries
if(APPLE)
	find_library(COREFOUNDATION_LIBRARY CoreFoundation)
	list(APPEND HYDRASDR_LIBS ${COREFOUNDATION_LIBRARY})
endif()

list(APPEND HYDRASDR_LIBS ${LibHYDRASDR_LIBRARIES})

# Verify paths exist and provide detailed information
if(LibHYDRASDR_LIBRARIES)
	message(STATUS "LibHydraSDR library for linking: ${LibHYDRASDR_LIBRARIES}")
	if(IS_ABSOLUTE "${LibHYDRASDR_LIBRARIES}")
		message(STATUS "  ✓ Library path is absolute")
	else()
		message(STATUS "  ✗ Library path is relative - this may cause linking issues")
	endif()
	
	if(EXISTS "${LibHYDRASDR_LIBRARIES}")
		message(STATUS "  ✓ Library file exists")
	else()
		message(FATAL_ERROR "  ✗ Library file does NOT exist: ${LibHYDRASDR_LIBRARIES}")
	endif()
endif()

# Verify include directory exists
if(LibHYDRASDR_INCLUDE_DIRS)
	if(EXISTS "${LibHYDRASDR_INCLUDE_DIRS}")
		message(STATUS "  ✓ Include directory exists")
		
		# Check for header files
		if(EXISTS "${LibHYDRASDR_INCLUDE_DIRS}/libhydrasdr/hydrasdr.h")
			message(STATUS "  ✓ Found hydrasdr.h in libhydrasdr subdirectory")
		elseif(EXISTS "${LibHYDRASDR_INCLUDE_DIRS}/hydrasdr.h")
			message(STATUS "  ✓ Found hydrasdr.h in root include directory")
		else()
			message(FATAL_ERROR "  ✗ Could not find hydrasdr.h in include directory: ${LibHYDRASDR_INCLUDE_DIRS}")
		endif()
	else()
		message(FATAL_ERROR "  ✗ Include directory does NOT exist: ${LibHYDRASDR_INCLUDE_DIRS}")
	endif()
endif()

# Create the SoapySDR module
SOAPY_SDR_MODULE_UTIL(
	TARGET SoapyHydraSDR
	SOURCES
		SoapyHydraSDR.hpp
		Registration.cpp
		Settings.cpp
		Streaming.cpp
	LIBRARIES
		${HYDRASDR_LIBS}
)

# Set target properties
set_target_properties(SoapyHydraSDR PROPERTIES
	CXX_STANDARD 11
	CXX_STANDARD_REQUIRED ON
	VERSION ${SOAPYHYDRASDR_VERSION}
	SOVERSION ${PROJECT_VERSION_MAJOR}
)

# Fix macOS compatibility version issue
if(APPLE)
	set_target_properties(SoapyHydraSDR PROPERTIES
		MACOSX_RPATH ON
		INSTALL_RPATH_USE_LINK_PATH ON
		# Remove problematic version properties for SoapySDR modules
		VERSION ""
		SOVERSION ""
	)
endif()

# Add version compile definition
target_compile_definitions(SoapyHydraSDR PRIVATE 
	SOAPYHYDRASDR_VERSION="${SOAPYHYDRASDR_VERSION}"
)

# Ensure proper include paths for the target
if(LibHYDRASDR_INCLUDE_DIRS)
	# If headers are found in libhydrasdr subdirectory, we need to include the parent directory
	if("${LibHYDRASDR_INCLUDE_DIRS}" MATCHES "libhydrasdr$")
		# Headers are in libhydrasdr subdirectory, include the parent
		get_filename_component(PARENT_INCLUDE_DIR "${LibHYDRASDR_INCLUDE_DIRS}" DIRECTORY)
		target_include_directories(SoapyHydraSDR PRIVATE ${PARENT_INCLUDE_DIR})
		message(STATUS "Adding parent include directory to target: ${PARENT_INCLUDE_DIR}")
	else()
		# Headers are in main include directory
		target_include_directories(SoapyHydraSDR PRIVATE ${LibHYDRASDR_INCLUDE_DIRS})
		message(STATUS "Adding include directory to target: ${LibHYDRASDR_INCLUDE_DIRS}")
	endif()
endif()

# Installation rules
install(TARGETS SoapyHydraSDR
	LIBRARY DESTINATION ${SOAPY_SDR_MODULE_DIR}
	ARCHIVE DESTINATION ${SOAPY_SDR_MODULE_DIR}  
	RUNTIME DESTINATION ${SOAPY_SDR_MODULE_DIR}
)

# Verify module directory before installation
if(NOT SOAPY_SDR_MODULE_DIR)
	message(FATAL_ERROR "SoapySDR module directory not found. Cannot install module.")
endif()

message(STATUS "Will install SoapySDR module to: ${SOAPY_SDR_MODULE_DIR}")

# On Windows, also install required DLLs
if(WIN32)
	# Use the same path calculation approach for consistency
	get_filename_component(PROJECT_ROOT_DIR "${CMAKE_CURRENT_BINARY_DIR}" DIRECTORY)
	set(RFONE_BUILD_DIR "${PROJECT_ROOT_DIR}/rfone_host_build/install")
	
	if(EXISTS "${RFONE_BUILD_DIR}/bin/hydrasdr.dll")
		install(FILES "${RFONE_BUILD_DIR}/bin/hydrasdr.dll"
			DESTINATION ${SOAPY_SDR_MODULE_DIR})
		message(STATUS "Will install hydrasdr.dll from: ${RFONE_BUILD_DIR}/bin/")
	endif()
	
	# Install other required Windows DLLs if they exist
	file(GLOB WINDOWS_DLLS "${RFONE_BUILD_DIR}/bin/*.dll")
	if(WINDOWS_DLLS)
		install(FILES ${WINDOWS_DLLS} DESTINATION ${SOAPY_SDR_MODULE_DIR})
		message(STATUS "Will install additional DLLs: ${WINDOWS_DLLS}")
	endif()
endif()

# Print build information
message(STATUS "")
message(STATUS "Build Configuration Summary:")
message(STATUS "  Project Version: ${SOAPYHYDRASDR_VERSION}")
message(STATUS "  Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  Compiler: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "  Install Prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "  SoapySDR Version: ${SoapySDR_VERSION}")
message(STATUS "  SoapySDR ABI Version: ${SoapySDR_ABI_VERSION}")
message(STATUS "  SoapySDR Module Dir: ${SOAPY_SDR_MODULE_DIR}")
if(LibHYDRASDR_FOUND)
	message(STATUS "  LibHYDRASDR Found: YES")
else()
	message(STATUS "  LibHYDRASDR Found: NO")
endif()
message(STATUS "  LibHYDRASDR Include: ${LibHYDRASDR_INCLUDE_DIRS}")
message(STATUS "  LibHYDRASDR Libraries: ${LibHYDRASDR_LIBRARIES}")

# Debug: Show what will actually be used for compilation
if(LibHYDRASDR_INCLUDE_DIRS)
	if("${LibHYDRASDR_INCLUDE_DIRS}" MATCHES "libhydrasdr$")
		get_filename_component(ACTUAL_INCLUDE_DIR "${LibHYDRASDR_INCLUDE_DIRS}" DIRECTORY)
		message(STATUS "  Actual Include Dir for Compilation: ${ACTUAL_INCLUDE_DIR}")
	else()
		message(STATUS "  Actual Include Dir for Compilation: ${LibHYDRASDR_INCLUDE_DIRS}")
	endif()
endif()

if(WIN32)
	message(STATUS "  MSVC Runtime: ${CMAKE_MSVC_RUNTIME_LIBRARY}")
endif()
message(STATUS "")
