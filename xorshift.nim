import unsigned, strutils
## A random number generator with 1024 bits of state.
## Very high performance

type
  TXorshift1024* {.final, pure, acyclic.} = object
    data*: array[16, int64]
    pos*: range[0..15]

proc next*(state: var TXorShift1024): uint64 =
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

proc seed*(arr: openarray[int8]): TXorShift1024 =
  for i, v in arr:
    result.data[i] = v

when isMainModule:
  var state = seed(@[42i8, 34i8, 54i8, 56i8, 22i8, 99i8])
  for d in state.data:
    echo(toHex(d, 50))
  for i in 1..20100:
    echo(next(state))


