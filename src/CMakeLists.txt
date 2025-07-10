cmake_minimum_required(VERSION 3.10)

project(result_channel_library VERSION 1.0.0 LANGUAGES CXX)

add_library(result_channel SHARED "result_channel.cpp")

set(CMAKE_CXX_STANDARD 23)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CXX_EXTENSIONS OFF)

set_target_properties(result_channel PROPERTIES PUBLIC_HEADER result_channel.h OUTPUT_NAME "result_channel")

target_compile_definitions(result_channel PUBLIC DART_SHARED_LIB)

target_include_directories(result_channel PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

if (ANDROID)
    target_link_options(result_channel PRIVATE "-Wl,-z,max-page-size=16384")
endif ()

set(PROJECT_TEMP_ROOT "") # Initialize to empty

if (WIN32)
    set(PROJECT_TEMP_ROOT "$ENV{TEMP}")
    if (NOT PROJECT_TEMP_ROOT)
        set(PROJECT_TEMP_ROOT "$ENV{TMP}")
    endif ()
else ()
    if(UNIX OR APPLE)
        set(PROJECT_TEMP_ROOT "$ENV{TMPDIR}")
        if (NOT PROJECT_TEMP_ROOT)
            set(PROJECT_TEMP_ROOT "$ENV{TMP}")
        endif ()
    else ()
        message(FATAL_ERROR "Unsupported operating system for automatic library detection.")
    endif ()
endif ()

if (PROJECT_TEMP_ROOT)
    set(PROJECT_TEMP_ROOT "${PROJECT_TEMP_ROOT}/result_channel")
else ()
    message(FATAL_ERROR "Could not determine system temporary directory.")
endif ()

file(MAKE_DIRECTORY "${PROJECT_TEMP_ROOT}")

configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/result_channel.h"
        "${PROJECT_TEMP_ROOT}/result_channel.h"
        COPYONLY
)
