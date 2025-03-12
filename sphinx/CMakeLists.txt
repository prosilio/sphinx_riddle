# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file LICENSE.rst.

add_library(sphinx "sphinx.cpp" "sphinx.h")

target_include_directories(sphinx PUBLIC .)
