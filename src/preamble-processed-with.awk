BEGIN {
    RS="\\.\n"
    FS="[:;]\n"
    ORS="\n"
}

$1 ~ /LaTeX/ {
    for (i = 2; i <= NF; i++) {
        print($i)
    }
    if (FNR != NR)
        print("")
    next
}

$1 ~ /new command/{
    print("")
    for (i = 2; i <= NF; i++) {
        print("\\newcommand"$i)
    }
    print("")
    next
}

$1 ~ /use package/{
    for (i = 2; i <= NF; i++) {
        if (match($i, /^#/))
            continue

        if (!match($i, /(\w+)(\[[^\]]+\])?(?:{(\n+|.+)})?/, package)) {
            print("%% Attempted to match a usepackage delcaration, but could not match!")
            continue
        }

        gsub(/ /, "", package[2])
        printf("\\usepackage%s{%s}\n", package[2], package[1])

        if (match($i, /\w+(\[[^\]]+\])?{(\n+|.+)}/, expressions))
        printf("%s\n", expressions[2])

    }
    print("")
    next
}
