import unittest, xorshift, strutils, math, rand

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

