cmake_minimum_required(VERSION 3.10)

project(result_channel_library VERSION 1.0.0 LANGUAGES CXX)

add_library(result_channel SHARED "result_channel.cpp")

set_target_properties(result_channel PROPERTIES PUBLIC_HEADER include/result_channel.h OUTPUT_NAME "result_channel")

target_include_directories(result_channel PUBLIC include)

target_compile_definitions(result_channel PUBLIC DART_SHARED_LIB)

if (ANDROID)
    target_link_options(result_channel PRIVATE "-Wl,-z,max-page-size=16384")
endif ()
