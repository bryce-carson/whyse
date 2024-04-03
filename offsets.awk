$1 ~ "(code|docs)" {
    print("Chunk " $3)
    chunk = !chunk
}
{ if (chunk) print $0 }
