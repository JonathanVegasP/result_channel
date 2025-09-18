cmake_minimum_required(VERSION 3.10)

project(result_channel_library VERSION 1.0.0 LANGUAGES C)

add_library(result_channel SHARED "result_channel.c")

set_target_properties(result_channel PROPERTIES PUBLIC_HEADER include/result_channel.h OUTPUT_NAME "result_channel")

target_include_directories(result_channel PUBLIC include)

find_library(log-lib log)

target_link_libraries(your_library_name
        ${log-lib}
)

target_compile_definitions(result_channel PUBLIC DART_SHARED_LIB)

if (ANDROID)
    target_link_options(result_channel PRIVATE "-Wl,-z,max-page-size=16384")
endif ()
