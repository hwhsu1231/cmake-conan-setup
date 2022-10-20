# Unify the output directories, so that all the generated executables 
# and libraries will be placed into the same directories, respectively.
#
# For example:
#   ${CMAKE_BINARY_DIR}/Debug/bin
#   ${CMAKE_BIANRY_DIR}/Debug/lib
# or
#   ${CMAKE_BINARY_DIR}/Release/bin
#   ${CMAKE_BIANRY_DIR}/Release/lib
# 
if(NOT DEFINED is_multi_config)
  get_cmake_property(is_multi_config GENERATOR_IS_MULTI_CONFIG)
endif()
if(is_multi_config)
  # Using Multi-Config Generator.
  set(output_dir "${CMAKE_BINARY_DIR}/$<CONFIG>")
else(is_multi_config)
  # Using Single-Config Generator.
  set(output_dir "${CMAKE_BINARY_DIR}/${CMAKE_BUILD_TYPE}")
endif(is_multi_config)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${output_dir}/bin")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${output_dir}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${output_dir}/lib")
