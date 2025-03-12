# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file LICENSE.rst.

cmake_minimum_required (VERSION 3.20)

project ("sphinx_riddle")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

add_subdirectory ("sphinx")
add_subdirectory("docs")
