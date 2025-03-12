# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file LICENSE.rst.

#[=======================================================================[.rst:
FindSphinx
----------

Sphinx is a documentation generation tool
(https://www.sphinx-doc.org/en/master/index.html). Sphinx uses the Breathe
extension (https://breathe.readthedocs.io/en/latest/) to transform Doxygen
(https://www.doxygen.nl) code comments into a Sphinx-generated document. This
module looks for Sphinx.

.. code-block:: cmake

  find_package(Sphinx)

The following variables are defined by this module:

.. variable:: Sphinx_FOUND

  True if the required components were found.

Imported Targets
^^^^^^^^^^^^^^^^

The module defines ``IMPORTED`` targets for each Sphinx executable found.
These can be used as part of custom commands, etc. and should be preferred over
old-style (and now deprecated) variables like ``Sphinx_build_EXECUTABLE``. The
following import targets are defined if their corresponding executable could be
found. With the exception of sphinx-build, the component import targets will
only be defined if that component was requested:

* ``Sphinx::build`` (added if no components requested)
* ``Sphinx::apidoc``
* ``Sphinx::autogen``
* ``Sphinx::quickstart``

Functions
^^^^^^^^^

.. command:: sphinx_build

  This function is intended as a convenience for adding a target for generating
  documentation with Sphinx.

  .. code-block:: cmake

    sphinx_build(targetName
        [filesOrDirs...]
        [ALL]
        [USE_STAMP_FILE]
        [WORKING_DIRECTORY dir]
        [COMMENT comment]
        [CONFIG_FILE filename])


Deprecated Result Variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^

For compatibility with previous versions of CMake, the following variables
are also defined but they are deprecated and should no longer be used:

.. variable:: Sphinx_build_EXECUTABLE

  The path to the ``sphinx-build`` command. If projects need to refer to the
  ``sphinx-build`` executable directly, they should use the ``Sphinx::build``
  import target instead.

.. variable:: Sphinx_apidoc_EXECUTABLE

  The path to the ``sphinx-apidoc`` command. If projects need to refer to the
  ``sphinx-apidoc`` executable directly, they should use the ``Sphinx::apidoc``
  import target instead.

.. variable:: Sphinx_autogen_EXECUTABLE

  The path to the ``sphinx-autogen`` command. If projects need to refer to the
  ``sphinx-autogen`` executable directly, they should use the
  ``Sphinx::autogen`` import target instead.

.. variable:: Sphinx_quickstart_EXECUTABLE

  The path to the ``sphinx-quickstart`` command. If projects need to refer to
  the ``sphinx-quickstart`` executable directly, they should use the
  ``Sphinx::quickstart`` import target instead.

#]=======================================================================]

include(FindPackageHandleStandardArgs)

function(_Sphinx_get_version sphinx_version result_var sphinx_path)
	execute_process(
		COMMAND "${sphinx_path}" --version
		OUTPUT_VARIABLE full_sphinx_version
		OUTPUT_STRIP_TRAILING_WHITESPACE
		RESULT_VARIABLE version_result
	)

	string(REGEX MATCH "[0-9]+\.[0-9]+\.[0-9]+$" sem_sphinx_version "${full_sphinx_version}")

	set(${result_var} ${version_result} PARENT_SCOPE)
	set(${sphinx_version} ${sem_sphinx_version} PARENT_SCOPE)
endfunction()

function(_Sphinx_version_validator version_match sphinx_path)
	if(NOT DEFINED ${CMAKE_FIND_PACKAGE_NAME}_FIND_VERSION)
		set(${is_valid_version} TRUE PARENT_SCOPE)
	else()
		_Sphinx_get_version(candidate_version version_result "${sphinx_path}")

		find_package_check_version("${candidate_version}" valid_sphinx_version
			HANDLE_VERSION_RANGE
		)

		set(${version_match} "${valid_sphinx_version}" PARENT_SCOPE)
	endif()
endfunction()

#
# Find sphinx-<comp>...
#
macro(_Sphinx_find_sphinx_comp comp comp_doc)
	find_program(
		${CMAKE_FIND_PACKAGE_NAME}_${comp}_EXECUTABLE
		NAMES sphinx-${comp}
		DOC ${comp_doc}
		VALIDATOR _Sphinx_version_validator
	)
	mark_as_advanced(${CMAKE_FIND_PACKAGE_NAME}_${comp}_EXECUTABLE)

	if(${CMAKE_FIND_PACKAGE_NAME}_${comp}_EXECUTABLE)
		_Sphinx_get_version(${CMAKE_FIND_PACKAGE_NAME}_${comp}_VERSION _Sphinx_version_result "${${CMAKE_FIND_PACKAGE_NAME}_${comp}_EXECUTABLE}")

		if(_Sphinx_version_result)
			if(NOT ${CMAKE_FIND_PACKAGE_NAME}_FIND_QUIETLY)
				message(WARNING "sphinx-${comp} executable failed unexpectedly while determining version (exit status: ${_Sphinx_version_result}). Disabling sphinx-${comp}.")
			endif()
			set(${CMAKE_FIND_PACKAGE_NAME}_${comp}_EXECUTABLE "${${CMAKE_FIND_PACKAGE_NAME}_${comp}_EXECUTABLE}-FAILED_EXECUTION-NOTFOUND")
		else()
			# Create an imported target for sphinx-${comp}
			if(NOT TARGET Sphinx::${comp})
				add_executable(Sphinx::${comp} IMPORTED GLOBAL)
				set_target_properties(Sphinx::${comp} PROPERTIES
					IMPORTED_LOCATION "${${CMAKE_FIND_PACKAGE_NAME}_${comp}_EXECUTABLE}"
				)
			endif()
		endif()
	endif()
endmacro()

#
# Find all requested components of Sphinx. If no components are listed, default
# to ``sphinx-build``...
#
if(NOT ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
	set(${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS build)
endif()
foreach(_comp IN LISTS ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
    if(_comp STREQUAL "build")
        _Sphinx_find_sphinx_comp(
			build
			"sphinx-build generates documentation from files (https://www.sphinx-doc.org/en/master/man/sphinx-build.html)"
		)
    elseif(_comp STREQUAL "apidoc")
		_Sphinx_find_sphinx_comp(
			apidoc
			"sphinx-apidoc generates Sphinx sources to document a whole package in the style of other automatic API doc tools (https://www.sphinx-doc.org/en/master/man/sphinx-apidoc.html)"
		)
    elseif(_comp STREQUAL "autogen")
		_Sphinx_find_sphinx_comp(
			autogen
			"sphinx-autogen generates documentation from files (https://www.sphinx-doc.org/en/master/man/sphinx-autogen.html)"
		)
    elseif(_comp STREQUAL "quickstart")
		_Sphinx_find_sphinx_comp(
			quickstart
			"sphinx-quickstart is an interactive tool that generates a documentation directory and a Makefile for use with sphinx-build (https://www.sphinx-doc.org/en/master/man/sphinx-quickstart.html)"
		)
    else()
		if(NOT ${CMAKE_FIND_PACKAGE_NAME}_FIND_QUIETLY)
        	message(WARNING "${_comp} is not a valid Sphinx component")
		endif()
        set(${CMAKE_FIND_PACKAGE_NAME}_${_comp}_FOUND FALSE)
        continue()
    endif()

    if(TARGET Sphinx::${_comp})
        set(${CMAKE_FIND_PACKAGE_NAME}_${_comp}_FOUND TRUE)
    else()
        set(${CMAKE_FIND_PACKAGE_NAME}_${_comp}_FOUND FALSE)
    endif()
endforeach()
unset(_comp)

find_package_handle_standard_args(
	Sphinx
	HANDLE_VERSION_RANGE
	HANDLE_COMPONENTS
)

function(sphinx_build targetName)
	if(NOT TARGET Sphinx::build)
		message(FATAL_ERROR "sphinx-build was not found, needed by \
sphinx_build() for target ${targetName}")
	endif()

	set(_valueless_args ALL)
	set(_one_value_args SOURCE_DIR OUTPUT_DIR COMMENT)
	set(_multi_value_args OPTIONS SOURCES)
	cmake_parse_arguments(
		PARSE_ARGV 0
		_args
		"${_valueless_args}"
		"${_one_value_args}"
		"${_multi_value_args}"
	)

	unset(_all)
	if(${_args_ALL})
		set(_all ALL)
	endif()

	if(NOT _args_COMMENT)
		set(
			_args_COMMENT
			"Generate API documentation with Sphinx for ${targetName}"
		)
	endif()

	list(JOIN _args_OPTIONS " " _sphinx_options)
	string(STRIP "${_sphinx_options}" _sphinx_options)
	string(REGEX REPLACE "[ \t\r\n]+" ";" _sphinx_options "${_sphinx_options}")

	# Build up a list of files to list as SOURCES in the custom target so that
	# they are displayed in IDEs.
	unset(_sources)
	foreach(_item IN LISTS _args_SOURCES)
		cmake_path(
			ABSOLUTE_PATH _item
			NORMALIZE
			BASE_DIRECTORY "${_args_SOURCE_DIR}"
			OUTPUT_VARIABLE _abs_item
		)
		get_source_file_property(_isGenerated "${_abs_item}" GENERATED)
		if(_isGenerated OR
			(EXISTS "${_abs_item}" AND
			NOT IS_DIRECTORY "${_abs_item}" AND
			NOT IS_SYMLINK "${_abs_item}"))
			list(APPEND _sources "${_abs_item}")
		endif()
	endforeach()

	add_custom_target(
		${targetName} ${_all} VERBATIM
		COMMAND Sphinx::build ${_sphinx_options}
			${_args_SOURCE_DIR} ${_args_OUTPUT_DIR}
		COMMENT "${_args_COMMENT}"
		SOURCES "${_sources}"
	)
endfunction()
