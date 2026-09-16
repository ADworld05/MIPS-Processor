# Memory word 0 contains 21.
# The add immediately uses the value loaded into $t0, so the pipeline must stall.
lw  $t0, 0($zero)
add $t1, $t0, $t0
