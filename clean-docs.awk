#!/usr/bin/gawk --file
#
# An AWK filter to remove erroneous instances of "@index use" from the tool
# syntax after finduses is called. Based off the work of Joseph S. Riel in
# autodefs.elisp.
#
# Copyright (c) 2024 by Bryce A. Carson. See the LICENSE file for copying
# information.

BEGIN {
    docsflag = 0
    regex = "^@index use"
    subgroup = 1
}

($0 ~ /^@(begin|end) docs /) {
    docsflag = !docsflag
    print
    next
}

!docsflag {
    print
    next
}

# If the current line inside a documentation chunk does not match the regex,
# print it and continue with the next line.
!match($0, regex, arr) {
    print
    next
}

# Insert a @fatal error (due to the finduses filter) before the culprit line.
# {
#     print "@fatal finduses \"@index use\" detected within documentation chunk after finduses stage. "
#     print
# }

END {}
