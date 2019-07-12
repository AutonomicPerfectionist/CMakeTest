include_guard()
include(cmake_test/detail_/parsing/comment_dispatch)
include(cmake_test/detail_/parsing/empty_dispatch)
include(cmake_test/detail_/parsing/parse_assert)
include(cmake_test/detail_/write_and_run_contents)
include(cmake_test/detail_/test_section/test_section)
include(cmake_test/detail_/utilities/input_check)

function(_ct_parse_dispatch _pd_contents _pd_index _pd_prefix _pd_identifier)
    cmake_policy(SET CMP0007 NEW) #List won't ignore empty elements
    list(GET ${_pd_contents} ${${_pd_index}} _pd_line)

    # line can be empty
    _ct_nonempty_string(_pd_prefix)
    _ct_nonempty_string(_pd_identifier)

    _ct_empty_dispatch("${_pd_line}") # Handle empty/blank lines
    _ct_comment_dispatch("${_pd_line}") # Handle comments

    #See if it starts a block or is an assertion
    string(TOLOWER "${_pd_line}" _pd_lc_line)

    _ct_lc_find(_pd_is_test "ct_add_test" "${_pd_lc_line}")
    _ct_lc_find(_pd_is_etest "ct_end_test" "${_pd_lc_line}")

    _ct_lc_find(_pd_is_section "ct_add_section" "${_pd_lc_line}")
    _ct_lc_find(_pd_is_esection "ct_end_section" "${_pd_lc_line}")

    # All asserts start with "ct_assert"
    _ct_lc_find(_pd_is_assert "ct_assert" "${_pd_lc_line}")

    #Grab whatever's between the ()'s for add_test, add_section, and assert
    if(_pd_is_test OR _pd_is_section)
        string(REGEX MATCH "\\(\\s*\"(.*)\"\\s*\\)" _pd_match "${_pd_line}")
        set(_pd_args "${CMAKE_MATCH_1}")
    endif()

    # Get the handle the TestState identifier points to
    set(_pd_handle "${${_pd_identifier}}")

    if(_pd_is_test) #Start of new test
        _ct_test_section(CTOR ${_pd_identifier} "${_pd_args}")
        _ct_return(${_pd_identifier})
    elseif(_pd_is_etest) #End of a test
        _ct_write_and_run_contents("${_pd_prefix}" "${_pd_handle}")
        set(${_pd_identifier} "")
        _ct_return(${_pd_identifier})
    elseif(_pd_is_section) #Start of a section
        _ct_test_section(ADD_SECTION ${_pd_handle} ${_pd_identifier} "${_pd_args}")
        _ct_return(${_pd_identifier})
    elseif(_pd_is_esection) #End of a section
        _ct_write_and_run_contents("${_pd_prefix}" "${_pd_handle}")
        _ct_test_section(END_SECTION ${_pd_handle} ${_pd_identifier})
        _ct_return(${_pd_identifier})
    elseif(_pd_is_assert) #Assert for this section
        _ct_parse_assert(${_pd_handle} _pd_line)
    else()
        if(NOT "${_pd_handle}" STREQUAL "") #Just a line of code in test
            #STRING(REGEX REPLACE ";" "\\\\\\\\;" _pd_line "${_pd_line}")
            _ct_test_section(ADD_CONTENT ${_pd_handle} _pd_line)
        else()
            return() #Code outside test section
        endif()
    endif()
endfunction()
