import unsigned

type
  Random* = generic x
    x.next() is uint64
    x.nextU8() is uint8  # Used to avoid consuming unneeded randomness

proc next*[T](self: var T, n: Int): Int =
  ## Gets a random number in [0, n). This wastes entropy, so it should
  ## be used with caution in cases where randomness can be exhausted
  assert n > 0
  # Roughly based on http://stackoverflow.com/a/17554531/2299084
  let
    buckets = 0xFFFF_FFFF_FFFF_FFFF'u64 div uint(n)
    limit = buckets * uint(n)

  while true:
    result = int(self.next())
    if uint64(result) < limit: break

  result = int(uint64(result) div buckets)

when isMainModule:
  import xorshift
  import unittest
  var a1, a2, b1, b2 = 0
  for i in 200..400:
    block:
      var state = seed(@[i.int8, 24i8, 52i8, 56i8, 22i8, 99i8])
      var buckets: array[0..99999, int]
      for i in 1..20000000:
        inc buckets[state.next(100000)]
      a1 += buckets[0]
      a2 += buckets[99999]

    block:
      var state = seed(@[i.int8, 24i8, 52i8, 56i8, 22i8, 99i8])
      var buckets: array[0..99999, int]
      for i in 1..20000000:
        let b: int = (state.next mod 100000).int
        inc buckets[b]
      b1 += buckets[0]
      b2 += buckets[99999]
  echo a1, " ", a2
  echo b1, " ", b2
