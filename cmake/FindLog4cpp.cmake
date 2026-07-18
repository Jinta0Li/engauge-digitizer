find_path(Log4cpp_INCLUDE_DIR
  NAMES log4cpp/Category.hh
  HINTS "${Log4cpp_ROOT}" ENV LOG4CPP_HOME
  PATH_SUFFIXES include
)

find_library(Log4cpp_LIBRARY
  NAMES log4cpp
  HINTS "${Log4cpp_ROOT}" ENV LOG4CPP_HOME
  PATH_SUFFIXES lib lib64
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Log4cpp
  REQUIRED_VARS Log4cpp_LIBRARY Log4cpp_INCLUDE_DIR
)

if(Log4cpp_FOUND AND NOT TARGET Log4cpp::log4cpp)
  add_library(Log4cpp::log4cpp UNKNOWN IMPORTED)
  set_target_properties(Log4cpp::log4cpp PROPERTIES
    IMPORTED_LOCATION "${Log4cpp_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${Log4cpp_INCLUDE_DIR}"
  )
endif()

mark_as_advanced(Log4cpp_INCLUDE_DIR Log4cpp_LIBRARY)
