
# paste (and cut) results to one file for different size images
paste mem-512.out <(cut -f2,3,4,5 mem-1024.out) >mem.out

