# This module is NOT working until the following issue is solved because 
# the 'IMPORTED_LOCATION_<CONFIG>' property of imported targets generated 
# by 'CMakeDeps' is EMPTY for now.
# 
# https://github.com/conan-io/conan/issues/12077
#
function(deploy_target tgt)

  if(WIN32)
    # Use '$<TARGET_RUNTIME_DLLS:tgt>' to copy dependent DLL files
    add_custom_command(TARGET ${tgt} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy
              "$<TARGET_RUNTIME_DLLS:${tgt}>"
              "$<TARGET_FILE_DIR:${tgt}>"
      COMMAND_EXPAND_LISTS)

    # Use 'windeployqt' executable to deploy the Qt-based target
    if(TARGET Qt::windeployqt)
      add_custom_command(TARGET ${tgt} POST_BUILD
        COMMAND Qt::windeployqt
                "$<TARGET_FILE:${tgt}>"
                --dir "$<TARGET_FILE_DIR:${tgt}>"
                --no-libraries
                --no-translations
                --no-compiler-runtime
                --no-opengl-sw
                --no-system-d3d-compiler)
    endif()
  endif()

endfunction()
