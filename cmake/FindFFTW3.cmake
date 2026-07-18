find_path(FFTW3_INCLUDE_DIR
  NAMES fftw3.h
  HINTS "${FFTW3_ROOT}" ENV FFTW_HOME
  PATH_SUFFIXES include
)

find_library(FFTW3_LIBRARY
  NAMES fftw3 libfftw3-3
  HINTS "${FFTW3_ROOT}" ENV FFTW_HOME
  PATH_SUFFIXES lib lib64
)

if(WIN32)
  find_file(FFTW3_RUNTIME_LIBRARY
    NAMES libfftw3-3.dll fftw3.dll
    HINTS "${FFTW3_ROOT}" ENV FFTW_HOME
    PATH_SUFFIXES bin lib
  )
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(FFTW3
  REQUIRED_VARS FFTW3_LIBRARY FFTW3_INCLUDE_DIR
)

if(FFTW3_FOUND AND NOT TARGET FFTW3::fftw3)
  add_library(FFTW3::fftw3 UNKNOWN IMPORTED)
  set_target_properties(FFTW3::fftw3 PROPERTIES
    IMPORTED_LOCATION "${FFTW3_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${FFTW3_INCLUDE_DIR}"
  )
endif()

mark_as_advanced(FFTW3_INCLUDE_DIR FFTW3_LIBRARY FFTW3_RUNTIME_LIBRARY)
