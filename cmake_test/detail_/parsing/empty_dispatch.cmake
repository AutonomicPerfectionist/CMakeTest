include_guard()

## @fn _ct_empty_dispatch(line)
#  @brief Handles dispatching if the current line is a blank line.
#
#  While parsing the input file we don't want to waste our time with blank
#  lines. This function will examine the current line we are parsing and return
#  control to the main driver if the line we are currently looking at is a blank
#  line.
#
#  @note This function is a macro as it is inteded to be used as a logical
#        factorization inside parse_dispatch and we don't want parse_dispatch
#        to have to act on the results of this function.
#
#  @param[in] line The line whose emptyness is in question.
macro(_ct_empty_dispatch _ed_line)
    if("${_ed_line}" STREQUAL "")
        return()
    endif()

    # Needs to be after the empty check or CMake will throw an error
    string(REGEX MATCH "^\\s*$" _ed_blank "${_ed_line}")
    if(NOT "${_ed_blank}" STREQUAL "")
        return()
    endif()
endmacro()