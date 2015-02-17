import unsigned, math, bitutils

type
  Random* = generic x
    next(var x) is uint64

proc next*[T](self: var T, n: int): int =
  ## Gets a random number in [0, n). This wastes entropy, so it should
  ## be used with caution in cases where randomness can be exhausted
  assert n > 0
  
  if (n and (n-1)) == 0: # Will return true if n is a power of 2
    # Mask is calculated as n-1. We know n is a bitstring where a single bit is
    # set, so
    #   0010 0000
    # - 0000 0001
    # = 0001 1111
    return (self.next() and (n - 1).uint64).int

  let
    excess = high(int) mod n  # n > 0
    limit = high(int) - excess
  
  while true:
    let res = self.next().int shr 1  # Discard the sign
    if res < limit:
      result = res mod n
      assert result < n
      assert result >= 0
      break
