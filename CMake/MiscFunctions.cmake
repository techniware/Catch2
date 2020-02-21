#checks that the given hard-coded list contains all headers + sources in the given folder
function(CheckFileList LIST_VAR FOLDER)
  set(MESSAGE " should be added to the variable ${LIST_VAR}")
  set(MESSAGE "${MESSAGE} in ${CMAKE_CURRENT_LIST_FILE}\n")
  file(GLOB GLOBBED_LIST "${FOLDER}/*.cpp"
                         "${FOLDER}/*.hpp"
                         "${FOLDER}/*.h")
  list(REMOVE_ITEM GLOBBED_LIST ${${LIST_VAR}})
  foreach(EXTRA_ITEM ${GLOBBED_LIST})
    string(REPLACE "${CATCH_DIR}/" "" RELATIVE_FILE_NAME "${EXTRA_ITEM}")
    message(AUTHOR_WARNING "The file \"${RELATIVE_FILE_NAME}\"${MESSAGE}")
  endforeach()
endfunction()

function(CheckFileListRec LIST_VAR FOLDER)
  set(MESSAGE " should be added to the variable ${LIST_VAR}")
  set(MESSAGE "${MESSAGE} in ${CMAKE_CURRENT_LIST_FILE}\n")
  file(GLOB_RECURSE GLOBBED_LIST "${FOLDER}/*.cpp"
                                 "${FOLDER}/*.hpp"
                                 "${FOLDER}/*.h")
  list(REMOVE_ITEM GLOBBED_LIST ${${LIST_VAR}})
  foreach(EXTRA_ITEM ${GLOBBED_LIST})
    string(REPLACE "${CATCH_DIR}/" "" RELATIVE_FILE_NAME "${EXTRA_ITEM}")
    message(AUTHOR_WARNING "The file \"${RELATIVE_FILE_NAME}\"${MESSAGE}")
  endforeach()
endfunction()

include(CheckCXXCompilerFlag)
function(add_cxx_flag_if_supported_to_targets flagname targets)
    check_cxx_compiler_flag("${flagname}" HAVE_FLAG_${flagname})

    if (HAVE_FLAG_${flagname})
        foreach(target ${targets})
            target_compile_options(${target} PUBLIC ${flagname})
        endforeach()
    endif()
endfunction()

# Assumes that it is only called for development builds, where warnings
# and Werror is desired, so it also enables Werror.
function(add_warnings_to_targets targets)
    LIST(LENGTH targets TARGETS_LEN)
    # For now we just assume 2 possibilities: msvc and msvc-like compilers,
    # and other.
    if (MSVC)
        foreach(target ${targets})
            # Force MSVC to consider everything as encoded in utf-8
            target_compile_options( ${target} PRIVATE /utf-8 )
            # Enable Werror equivalent
            if (CATCH_ENABLE_WERROR)
                target_compile_options( ${target} PRIVATE /WX )
            endif()

            # MSVC is currently handled specially
            if ( CMAKE_CXX_COMPILER_ID MATCHES "MSVC" )
                STRING(REGEX REPLACE "/W[0-9]" "/W4" CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS}) # override default warning level
                target_compile_options( ${target} PRIVATE /w44265 /w44061 /w44062 /w45038 )
            endif()
        endforeach()

    endif()

    if (NOT MSVC)
        set(CHECKED_WARNING_FLAGS
          "-Wall"
          "-Wextra"
          "-Wpedantic"
          "-Wweak-vtables"
          "-Wunreachable-code"
          "-Wmissing-declarations"
          "-Wexit-time-destructors"
          "-Wglobal-constructors"
          "-Wmissing-noreturn"
          "-Wparentheses"
          "-Wextra-semi-stmt"
          "-Wunreachable-code"
          "-Wstrict-aliasing"
          "-Wreturn-std-move"
          "-Wmissing-braces"
        )
        foreach(warning ${CHECKED_WARNING_FLAGS})
            add_cxx_flag_if_supported_to_targets(${warning} "${targets}")
        endforeach()

        if (CATCH_ENABLE_WERROR)
            foreach(target ${targets})
                # Enable Werror equivalent
                target_compile_options( ${target} PRIVATE -Werror )
            endforeach()
        endif()
    endif()
endfunction()
