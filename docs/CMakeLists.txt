# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file LICENSE.rst.

find_package(Doxygen REQUIRED)

set(DOXYGEN_CITE_BIB_FILES "${CMAKE_CURRENT_SOURCE_DIR}/refs.bib")
set(DOXYGEN_EXCLUDE_PATTERNS "*.cpp")
set(DOXYGEN_GENERATE_XML YES)
set(DOXYGEN_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/doxygen")
set(DOXYGEN_STRIP_FROM_PATH "${sphinx_riddle_SOURCE_DIR}")

doxygen_add_docs(
	sphinx_riddle_doxygen_docs
	"${sphinx_riddle_SOURCE_DIR}/sphinx"
	ALL
)

find_package(Sphinx REQUIRED)

sphinx_build(
	sphinx_riddle_sphinx_docs ALL
	OPTIONS
		"-b html"
		"-Dbreathe_projects.sphinx_riddle=${DOXYGEN_OUTPUT_DIRECTORY}/xml"
	SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}
	OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/sphinx
	SOURCES
		${CMAKE_CURRENT_SOURCE_DIR}/index.rst
)
add_dependencies(sphinx_riddle_sphinx_docs sphinx_riddle_doxygen_docs)
