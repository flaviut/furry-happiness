import unsigned, math, bitutils

type
  Random* = generic x
    next(var x) is uint64

proc next*[T](self: var T, n: int): int =
  ## Gets a random number in [0, n). This wastes entropy, so it should
  ## be used with caution in cases where randomness can be exhausted
  assert n > 0
  let n = uint(n)

  let threshold = (0u - n) mod n

  while true:
    let res = self.next()
    if res > threshold:
      result = (res and high(int)) mod n
      assert result < n
      assert result >= 0
      break
