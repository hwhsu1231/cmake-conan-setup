get_filename_component(target_name "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
message("==== TARGET: ${target_name}")

add_executable(${target_name} main.cpp)

target_link_libraries(${target_name}
  PRIVATE
    fmt::fmt
)
