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

import unittest, xorshift, strutils, math

proc chiSquare(fun: proc(): int, bucketCount, experiments: int):
  tuple[chiSquare : float, buckets : seq[int]] =

  var chiSquareVal = 0.0
  var buckets = newSeq[int](bucketCount)
  let mean = experiments / bucketCount

  for i in 0..experiments:
    buckets[int(fun())] += 1

  for i, elem in buckets:
    chiSquareVal += pow(float(elem) - mean, 2.0) / mean

  return (chiSquareVal, buckets)


var state = seed([58247, 39337, 675246, 1567546723, 2390230, 5435346, 3476457, 960482304, 85948609, 659406839,
                  86349034, 4356934, 65454365, 564356, 3458910, 0294])

for i in 0 .. 10000:
  discard state.next()

const
  modulus = 1000
  experiments = 200000000

proc getRand(): int = state.next(modulus)
echo chiSquare(getRand, modulus, experiments)
