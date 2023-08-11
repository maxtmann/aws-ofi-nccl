# -*- autoconf -*-
#
# Copyright (c) 2023      Amazon.com, Inc. or its affiliates. All rights reserved.
#
# See LICENSE.txt for license information
#

AC_DEFUN([CHECK_ENABLE_UBSAN], [
  AC_MSG_CHECKING([whether to enable UBSAN (Undefined Behaviour Sanitizer)])
  AC_ARG_ENABLE([ubsan],
                [AS_HELP_STRING([--enable-ubsan], [Enable undefined behaviour checks with UBSAN])])

  AS_IF([test "${enable_ubsan}" = "yes"],
        [CPPFLAGS="-fsanitize=undefined ${CPPFLAGS}"
         LDFLAGS="-fsanitize=undefined ${LDFLAGS}"
         AC_MSG_RESULT([yes])],
        [AC_MSG_RESULT([no])])
])
