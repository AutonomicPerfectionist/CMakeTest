include_guard()

#[[[
# This function will find all *.cmake files in the specified directory as well as recursively through all subdirectories.
# It will then configure the boilerplate template to include() each cmake file and register each configured boilerplate
# with CTest. The configured templates will be executed seperately via CTest during the Test phase, and each *.cmake
# file found in the specified directory is assumed to contain CMakeTest tests.
#
# :param _ad_dir: The directory to search for *.cmake files. Subdirectories will be recursively searched.
# :type _ad_dir: path
#
#]]
function(ct_add_dir _ad_dir)
    get_filename_component(_ad_abs_test_dir "${_ad_dir}" REALPATH)
    file(GLOB_RECURSE _ad_files LIST_DIRECTORIES FALSE FOLLOW_SYMLINKS "${_ad_abs_test_dir}/*.cmake") #Recurse over target dir to find all cmake files

    foreach(_ad_test_file ${_ad_files})
        file(RELATIVE_PATH _ad_rel_path "${_ad_abs_test_dir}" "${_ad_test_file}") #Find rel path so we don't end up with insanely long paths under test folders

        configure_file("${_CT_TEMPLATES_DIR}/lists.txt" "${CMAKE_CURRENT_BINARY_DIR}/tests/${_ad_rel_path}/src/CMakeLists.txt" @ONLY) #Fill in boilerplate, copy to build dir
        add_test(
        NAME
            ${_ad_rel_path}
        COMMAND
            "${CMAKE_CTEST_COMMAND}"
                --build-and-test "${CMAKE_CURRENT_BINARY_DIR}/tests/${_ad_rel_path}/src"
                                 "${CMAKE_CURRENT_BINARY_DIR}/tests/${_ad_rel_path}"
                --build-generator "${CMAKE_GENERATOR}"
                --test-command "${CMAKE_CTEST_COMMAND}"
        ) #Register boilerplate with CTest
    endforeach()
endfunction()
