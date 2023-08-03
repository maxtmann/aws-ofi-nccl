# -*- autoconf -*-
#
# Copyright (c) 2023      Amazon.com, Inc. or its affiliates. All rights reserved.
#
# See LICENSE.txt for license information
#

AC_DEFUN([CHECK_PKG_MEMCHECK], [  
  asan_enabled=0
  valgrind_enabled=0
  default_memcheck_redzone_size=16
  
  AC_ARG_ENABLE([memcheck],
              [AS_HELP_STRING([--enable-memcheck=[asan|valgrind]], [Enable memory access checks with ASAN or valgrind])],
              [AS_IF([test "${enable_memcheck}" != "no" -a "${enable_memcheck}" != "asan" -a "${enable_memcheck}" != "valgrind"],
                     [AC_MSG_ERROR(Invalid option --enable-memcheck=${enable_memcheck})])])

  AC_MSG_CHECKING([whether to enable ASAN])
  AS_IF([test "${enable_memcheck}" = "asan"],
        [CPPFLAGS="-fsanitize=address ${CPPFLAGS}"
         LDFLAGS="-fsanitize=address ${LDFLAGS}"
         AC_MSG_RESULT([yes])
         asan_enabled=1],
        [AC_MSG_RESULT([no])
         asan_enabled=0])

  CPPFLAGS_save="${CPPFLAGS}"

  AC_ARG_WITH([valgrind],
              [AS_HELP_STRING([--with-valgrind=DIR], [Option to set path to valgrind include directory in case valgrind is enabled])])

  AS_IF([test -n "${with_valgrind}" -a "${enable_memcheck}" != "valgrind"],
        [AC_MSG_ERROR([Option --with-valgrind=PATH not supported as valgrind is not enabled])])

  AS_IF([test -n "${with_valgrind}" -a "${enable_memcheck}" = "valgrind"],
        [AS_IF([test -f ${with_valgrind}/valgrind/valgrind.h],
               [CPPFLAGS="-I${with_valgrind} ${CPPFLAGS}"],
               [test -f ${with_valgrind}/include/valgrind/valgrind.h],
               [CPPFLAGS="-I${with_valgrind}/include ${CPPFLAGS}"],
               [AC_MSG_ERROR(valgrind.h not found in ${with_valgrind})])])

  AS_IF([test "${enable_memcheck}" = "valgrind"],
        [AC_CHECK_HEADERS([valgrind/valgrind.h],
        [valgrind_enabled=1],
        [AC_MSG_ERROR([valgrind.h not found])])])

  # Valgrind API changed significantly with the introduction of
  # version 3.2.0. Verify that memory checking macros introduced by
  # version 3.2.0 are available.
  AS_IF([test "${valgrind_enabled}" = "1"],
        [AC_MSG_CHECKING([for VALGRIND_MAKE_MEM_NOACCESS])
         AC_COMPILE_IFELSE([AC_LANG_PROGRAM(
                            [[
                              #include "valgrind/memcheck.h"
                            ]],
                            [[#if !defined(VALGRIND_MAKE_MEM_NOACCESS)
                              #error Failed not defined $define
                              #endif
                              int main(void) {
                                return 0;
                              }]])],
                           [AC_MSG_RESULT([yes])],
                           [AC_MSG_RESULT([no])
                            valgrind_enabled=0
                            CPPFLAGS="${CPPFLAGS_save}"
                            AC_MSG_ERROR([Need valgrind version 3.2.0 or later.])])])

  AC_MSG_CHECKING([whether to enable valgrind])
  AS_IF([test "${valgrind_enabled}" = "1"],
        [AC_MSG_RESULT([yes])],
        [AC_MSG_RESULT([no])])

  AC_MSG_CHECKING([Checking for MEMCHECK_REDZONE_SIZE])
  AC_ARG_VAR(MEMCHECK_REDZONE_SIZE,
  AS_HELP_STRING([Size of added redzones (in bytes). The default size is 16 bytes in case memory access checks are enabled and 0 otherwise. Is required to be a multiple of 8. @<:@default=16@:>@]))
  AS_IF([test "${asan_enabled}" = "0" -a "${valgrind_enabled}" = "0"],[default_memcheck_redzone_size=0])
  MEMCHECK_REDZONE_SIZE=${MEMCHECK_REDZONE_SIZE:=${default_memcheck_redzone_size}}
  AC_MSG_RESULT(${MEMCHECK_REDZONE_SIZE})
  AS_IF([test "$(( MEMCHECK_REDZONE_SIZE % 8 ))" != "0"],
        [AC_MSG_ERROR([MEMCHECK_REDZONE_SIZE=${MEMCHECK_REDZONE_SIZE} is not a multiple of 8])])
  
  AC_DEFINE_UNQUOTED([ENABLE_ASAN], [${asan_enabled}], [Defined to 1 if ASAN is enabled])
  AC_DEFINE_UNQUOTED([ENABLE_VALGRIND], [${valgrind_enabled}], [Defined to 1 if valgrind is enabled])
  AC_DEFINE_UNQUOTED([MEMCHECK_REDZONE_SIZE], [${MEMCHECK_REDZONE_SIZE}], [Defines size of added redzones (in bytes) in case ASAN or valgrind is enabled.])

  AS_UNSET([asan_enabled])
  AS_UNSET([valgrind_enabled])
  AS_UNSET([CPPFLAGS_save])
  AS_UNSET([default_memcheck_redzone_size])
])
