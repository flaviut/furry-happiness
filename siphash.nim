import bitutils, unsigned

## The siphash cryptographic hashing algorithm, implemented
## as described in 
##
##     Aumasson, Jean-Philippe, and Daniel J. Bernstein. "SipHash: a fast
##     short-input PRF." Progress in Cryptology-INDOCRYPT 2012 (2012):
##     489-508.

type
  SipHash* = array[4, uint64]

const 
  cRounds = 2
  dRounds = 4

proc partialRound(a, b: var uint64, rot1, rot2: int) {.inline.} =
  a = a + b
  b = rotl(b, rot1)
  b = b xor a
  a = rotl(b, rot2)

proc round(v: var array[4, uint64] ) {.inline.} =
  partialRound(v[0], v[1], 13, 32)
  partialRound(v[2], v[1], 17, 32)
  partialRound(v[2], v[3], 16, 0)
  partialRound(v[0], v[3], 21, 0)
  # Equivalent to 
  # v0 += v1
  # v1 ≪= 13
  # v1 ⊕= v0
  # v0 ≪= 32
  #
  # v2 += v1
  # v1 ≪= 17
  # v1 ⊕= v2
  # v2 ≪= 32
  # 
  # v2 += v3
  # v3 ≪= 16
  # v3 ⊕= v2
  #
  # v0 += v3
  # v3 ≪= 21
  # v3 ⊕= v0


proc initHash*(key: array[2, uint64]): SipHash =
  ## 1. Initialization
  result[0] = key[0] xor 0x736f6d6570736575'u64
  result[1] = key[1] xor 0x646f72616e646f6d'u64
  result[2] = key[0] xor 0x6c7967656e657261'u64
  result[3] = key[1] xor 0x7465646279746573'u64

proc mix*(hash: SipHash, data: uint64): SipHash =
  ## 2. Compression
  result = hash
  result[3] = result[3] xor data
  for i in 0..cRounds:
    round(result)
  result[0] = result[0] xor data

proc mixLast*(hash: SipHash, data: uint64, len: int): SipHash =
  ## 2. Last compression step
  hash.mix(data or rotl(len.uint64, 56))

proc finalize*(hash: SipHash): uint64 =
  var hash = hash
  hash[2] = hash[2] xor 0xFF'u64
  for i in 0..dRounds:
    round(hash)
  return hash[0] xor hash[1] xor hash[2] xor hash[3]


when isMainModule:
  initHash([0x0706050403020100'u64, 0x0f0e0d0c0b0a0908'u64])