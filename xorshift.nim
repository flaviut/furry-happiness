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

proc size*: int = 128

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

proc seed*(arr: openarray[uint8]): Xorshift1024 =
  if arr.len != 128:
    raise newException(EInvalidValue, "Seed is not 128 bytes long, but must be 128 bytes")
  for i in 0..15:
    result.data[i] = ((arr[i*8  ].uint64 shr 56'u64) or
                      (arr[i*8+1].uint64 shr 48'u64) or
                      (arr[i*8+2].uint64 shr 40'u64) or
                      (arr[i*8+3].uint64 shr 32'u64) or
                      (arr[i*8+4].uint64 shr 24'u64) or
                      (arr[i*8+5].uint64 shr 16'u64) or
                      (arr[i*8+6].uint64 shr  8'u64) or
                      (arr[i*8+7].uint64           )).int64
  result.pos = 0