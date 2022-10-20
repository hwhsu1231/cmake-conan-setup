################################################################################
# Cache Variables
# - CMAKE_CONFIGURATION_TYPES
# - CMAKE_CONAN_OUTPUT_FOLDER
# - CMAKE_CONAN_OUTPUT_QUIET
# - CMAKE_CONAN_ERROR_QUIET
################################################################################


get_cmake_property(is_multi_config GENERATOR_IS_MULTI_CONFIG)
if(is_multi_config)
  set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING
    "Specifies the available build types (configurations) on multi-config generators.")
endif()
set(CMAKE_CONAN_OUTPUT_FOLDER "${CMAKE_BINARY_DIR}/conan-dependencies" CACHE FILEPATH 
  "Specify the subfolder where 'conan install' generates files inside the build directory.")
set(CMAKE_CONAN_OUTPUT_QUIET false CACHE BOOL 
  "Disable the output message of running 'conan install' command if we set it to true.")
set(CMAKE_CONAN_ERROR_QUIET false CACHE BOOL 
  "Disable the error message of running 'conan install' command if we set it to true.")


################################################################################
# Step 1:
#   Include 'conan.cmake' and scan for conan recipe in the root source directory.
################################################################################


# Copy 'conan.cmake' file into the build directory.
# We can either prepare a copy in advanced alongside with 'conan-setup.cmake'
# or download the latest version from "https://github.com/conan-io/cmake-conan"
if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/conan.cmake")
  # Copy 'conan.cmake' locally
  if(NOT EXISTS "${CMAKE_BINARY_DIR}/conan.cmake")
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/conan.cmake"
      DESTINATION "${CMAKE_BINARY_DIR}")
  endif()
else()
  # Download 'conan.cmake' from "https://github.com/conan-io/cmake-conan"
  if(NOT EXISTS "${CMAKE_BINARY_DIR}/conan.cmake")
    message(STATUS "Downloading conan.cmake from https://github.com/conan-io/cmake-conan")
    file(DOWNLOAD 
      "https://raw.githubusercontent.com/conan-io/cmake-conan/master/conan.cmake"
      "${CMAKE_BINARY_DIR}/conan.cmake"
      TLS_VERIFY ON)
  endif()
endif()


# Scan for conan recipe in the root source directory.
# If the conan recipe ('conanfile.txt' or 'conanfile.py') doesn't exist in
# the root source directory, then the process will stop and return an error.
set(CONAN_RECIPE_FILE "")
foreach(ext txt;py)
  if(EXISTS "${CMAKE_SOURCE_DIR}/conanfile.${ext}")
    set(CONAN_RECIPE_FILE "${CMAKE_SOURCE_DIR}/conanfile.${ext}")
    break()
  endif()
endforeach()
if(CONAN_RECIPE_FILE STREQUAL "")
  message(FATAL_ERROR "Conan recipe doesn't exist in the root source directory...")
endif()


################################################################################
# Step 2: 
#   Create a new 'CMakeLists.txt', in which APIs of cmake-conan are used, by 
#   calling 'file(WRITE)'.
################################################################################


if(CMAKE_GENERATOR MATCHES "^Visual Studio")
  if(CMAKE_GENERATOR_TOOLSET MATCHES "host=x64")
    set(_toolset_arch "x64")
  elseif(CMAKE_GENERATOR_TOOLSET MATCHES "host=x86")
    set(_toolset_arch "x86")
  endif()
endif()


# Create a CMakeLists.txt file in the "conan" subfolder inside the
# build directory. In the generated CMakeLists.txt file, it will call
# the following two APIs of cmake-conan: 'conan_cmake_autodetect()' 
# and 'conan_cmake_install()'
file(WRITE "${CMAKE_CONAN_OUTPUT_FOLDER}/CMakeLists.txt" "\
cmake_minimum_required(VERSION 3.15)
project(conan-setup)
include(\"${CMAKE_BINARY_DIR}/conan.cmake\")
get_cmake_property(is_multi_config GENERATOR_IS_MULTI_CONFIG)
if(is_multi_config)
  # Using Multi-Config Generator.
  foreach(type ${CMAKE_CONFIGURATION_TYPES})
    conan_cmake_autodetect(settings BUILD_TYPE \$\{type\})
    conan_cmake_install(
      PATH_OR_REFERENCE \"${CONAN_RECIPE_FILE}\"
      INSTALL_FOLDER    \"${CMAKE_CONAN_OUTPUT_FOLDER}\"
      OUTPUT_FOLDER     \"${CMAKE_CONAN_OUTPUT_FOLDER}\"
      BUILD             missing
      REMOTE            conancenter
      CONF              tools.cmake.cmaketoolchain:generator=\"${CMAKE_GENERATOR}\"
      CONF              tools.cmake.cmaketoolchain:toolset_arch=${_toolset_arch}
      SETTINGS          \$\{settings\})
  endforeach()
else(is_multi_config)
  # Using Single-Config Generator.
  conan_cmake_autodetect(settings)
  conan_cmake_install(
    PATH_OR_REFERENCE \"${CONAN_RECIPE_FILE}\"
    INSTALL_FOLDER    \"${CMAKE_CONAN_OUTPUT_FOLDER}\"
    OUTPUT_FOLDER     \"${CMAKE_CONAN_OUTPUT_FOLDER}\"
    BUILD             missing
    REMOTE            conancenter
    CONF              tools.cmake.cmaketoolchain:generator=\"${CMAKE_GENERATOR}\"
    SETTINGS          \$\{settings\})
endif(is_multi_config)
")


################################################################################
# Step 3:
#   Configure the generated 'CMakeLists.txt' by calling 'execute_process(COMMAND
#   ${CMAKE_COMMAND})'.
################################################################################


# Remove the whole build directory before configuring the project
if(EXISTS "${CMAKE_CONAN_OUTPUT_FOLDER}/build")
  file(REMOVE_RECURSE "${CMAKE_CONAN_OUTPUT_FOLDER}/build")
endif()


# If we're using Multi-Config generator, we usually don't need to specify
# CMAKE_BUILD_TYPE variable.
set(ARGUMENTS_OPTION "-G ${CMAKE_GENERATOR}")
get_cmake_property(is_multi_config GENERATOR_IS_MULTI_CONFIG)
if(is_multi_config)
  # Using Multi-Config generator.
  if(CMAKE_GENERATOR MATCHES "^Visual Studio")
    # Using Visual Studio generator.
    list(APPEND ARGUMENTS_OPTION "-T ${CMAKE_GENERATOR_TOOLSET}")
    list(APPEND ARGUMENTS_OPTION "-A ${CMAKE_GENERATOR_PLATFORM}")
  elseif(CMAKE_GENERATOR MATCHES "Ninja Multi-Config")
    # Using Ninja Multi-Config generator.
    list(APPEND ARGUMENTS_OPTION "-D CMAKE_C_COMPILER=${CMAKE_C_COMPILER}")
    list(APPEND ARGUMENTS_OPTION "-D CMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}")
  endif()
else()
  # Using Single-Config generator.
  list(APPEND ARGUMENTS_OPTION "-D CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")
  list(APPEND ARGUMENTS_OPTION "-D CMAKE_C_COMPILER=${CMAKE_C_COMPILER}")
  list(APPEND ARGUMENTS_OPTION "-D CMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}")
endif()
# message("ARGUMENTS_OPTION = ${ARGUMENTS_OPTION}")


# By default, it will print the output and error messages of 'conan install' 
# command. If we specified 'CMAKE_CONAN_OUTPUT_QUIET' or 'CMAKE_CONAN_ERROR_QUIET' 
# variable to TRUE in the configure-time, then the message won't be printed.
if(CMAKE_CONAN_OUTPUT_QUIET)
  set(OUTPUT_OPTION "OUTPUT_QUIET")
endif()
if(CMAKE_CONAN_ERROR_QUIET)
  set(ERROR_OPTION "ERROR_QUIET")
endif()


# Execute 'cmake' command to configure the project
execute_process(COMMAND ${CMAKE_COMMAND}
  -S "${CMAKE_CONAN_OUTPUT_FOLDER}"
  -B "${CMAKE_CONAN_OUTPUT_FOLDER}/build"
  ${ARGUMENTS_OPTION}
  ${OUTPUT_OPTION}
  ${ERROR_OPTION}
  RESULT_VARIABLE result
)
if(result EQUAL 0)
else()
  message(FATAL_ERROR "Failed to configure the generated CMakeLists.txt...")
endif()


################################################################################
# Step 4:
#   Include 'conan_toolchain.cmake' generated by CMakeToolchain at the end of 
#   'conan-setup.cmake'
################################################################################


# If 'CMakeToolchain' generator is used, then we just need to include the generated 
# 'conan_toolchain.cmake' to specify the search paths for 'xxx-config.cmake' and
# 'Findxxx.cmake' generated by 'CMakeDeps' generator.
# Otherwise, we need to specify the "${CMAKE_CONAN_OUTPUT_FOLDER}" subfolder into 
# 'CMAKE_MODULE_PATH' and 'CMAKE_PREFIX_PATH' ourselves.
if(EXISTS "${CMAKE_CONAN_OUTPUT_FOLDER}/conan_toolchain.cmake")
  include("${CMAKE_CONAN_OUTPUT_FOLDER}/conan_toolchain.cmake")
else()
  list(APPEND CMAKE_MODULE_PATH "${CMAKE_CONAN_OUTPUT_FOLDER}")
  list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CONAN_OUTPUT_FOLDER}")
endif()
