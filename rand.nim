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
  
import unittest, xorshift, strutils
var state = seed([578247, 39337, 675246, 1567546723, 2390230, 5435346, 3476457, 960482304, 85948609, 659406839,
                  86349034, 4356934, 65454365, 564356, 3458910, 0294])
#for i in 0 .. 10000:
#  discard state.next()
#var buckets: array[0..999, int]
#for i in 1..200000000:
#  inc buckets[state.next(1000)]
#
#
#var
#  chiSquare = 0.0
#  mean = 200_000
#for i, elem in buckets:
#  let part = ((elem-mean)*(elem-mean))/mean
#  chiSquare += part
#assert chiSquare < 1143.9169
#echo chiSquare.int

while true:
  var nextInt = state.next
  discard stdout.writeBuffer(addr nextInt, sizeof(nextInt))
