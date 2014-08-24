import unsigned, strutils
## A random number generator with 1024 bits of state.
## Very high performance, suitable for places where
## a very large seed space is necessary
##
## Not a CPRNG, but output is still very good

type
  Xorshift1024* {.final.} = object
    data*: array[16, int64]
    pos*: range[0..15]

proc next*(state: var Xorshift1024): uint64 =
  var s0 = state.data[state.pos]
  # Increment the position counter, modulo 15 to wrap around
  state.pos = (state.pos + 1) and 15
  var s1 = state.data[state.pos]
  s1 = s1 xor (s1 shl 31)
  s1 = s1 xor (s1 shr 11)
  s0 = s0 xor (s0 shr 30)
  let nextv = s0 xor s1
  state.data[state.pos] = nextv
  return uint64(nextv) * 1181783497276652981u64

proc seed*(arr: array[16, int64]): Xorshift1024 =
  result.data = arr
  result.pos = 0