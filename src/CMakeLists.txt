cmake_minimum_required(VERSION 3.10)

project(result_channel_library VERSION 1.0.0 LANGUAGES CXX)

add_library(result_channel SHARED "result_channel.cpp")

set(CMAKE_CXX_STANDARD 23)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CXX_EXTENSIONS OFF)

set_target_properties(result_channel PROPERTIES PUBLIC_HEADER result_channel.h OUTPUT_NAME "result_channel")

target_compile_definitions(result_channel PUBLIC DART_SHARED_LIB)

target_include_directories(result_channel PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

if(ANDROID)
    target_link_options(result_channel PRIVATE "-Wl,-z,max-page-size=16384")
endif ()
