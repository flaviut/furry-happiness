import bitutils, unsigned

## The siphash cryptographic hashing algorithm, implemented
## as described in 
##
##     Aumasson, Jean-Philippe, and Daniel J. Bernstein. "SipHash: a fast
##     short-input PRF." Progress in Cryptology-INDOCRYPT 2012 (2012):
##     489-508.

type
  SipHash* = array[4, uint64]
  SipSeed = array[2, uint64]

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
  # Equivalent to the following from the paper: 
  # v0 += v1   v2 += v3
  # v1 ≪= 13   v3 ≪= 16
  # v1 ⊕= v0   v3 ⊕= v2
  # v0 ≪= 32  
  #
  # v2 += v1   v0 += v3
  # v1 ≪= 17   v3 ≪= 21
  # v1 ⊕= v2   v3 ⊕= v0
  # v2 ≪= 32


proc initHash*(key: SipSeed): SipHash =
  ## 1. Initialization
  result[0] = key[0].uint64 xor 0x736f6d6570736575'u64
  result[1] = key[1].uint64 xor 0x646f72616e646f6d'u64
  result[2] = key[0].uint64 xor 0x6c7967656e657261'u64
  result[3] = key[1].uint64 xor 0x7465646279746573'u64

proc mix*(hash: SipHash, data: uint64): SipHash =
  ## 2. Compression
  result = hash
  result[3] = result[3] xor data
  for i in 0..cRounds:
    round(result)
  result[0] = result[0] xor data

proc mixLast*(hash: SipHash, data: uint64, len: int): SipHash =
  ## 2. Last compression step
  hash.mix(data or (len.uint64 shl 56))

proc finalize*(hash: SipHash): uint64 =
  var hash = hash
  hash[2] = hash[2] xor 0xFF'u64
  for i in 0..dRounds:
    round(hash)
  return hash[0] xor hash[1] xor hash[2] xor hash[3]


proc hash*(val: String, seed: SipSeed): uint64 =
  var res = initHash(seed)

  let
    remainingBytes = val.len and 7
    includeLen = remainingBytes != 7
    divedVals = (val.len div 8) 
    bodyVals = divedVals - (if includeLen: 1 else: 0)

  for i in 0..bodyVals:
    let nextVal = (val[i*8  ].uint64       ) or
                  (val[i*8+1].uint64 shl  8) or
                  (val[i*8+2].uint64 shl 16) or
                  (val[i*8+3].uint64 shl 24) or
                  (val[i*8+4].uint64 shl 32) or
                  (val[i*8+5].uint64 shl 40) or
                  (val[i*8+6].uint64 shl 48) or
                  (val[i*8+7].uint64 shl 56)
    if includeLen:
      res = res.mix(nextVal)
    else:
      res = res.mixLast(nextVal, 0)

  if includeLen:
    var nextVal = 0'u64
    if remainingBytes > 0: nextVal = (val[divedVals*8  ].uint64       ) or nextVal
    if remainingBytes > 1: nextVal = (val[divedVals*8+1].uint64 shl  8) or nextVal
    if remainingBytes > 2: nextVal = (val[divedVals*8+2].uint64 shl 16) or nextVal
    if remainingBytes > 3: nextVal = (val[divedVals*8+3].uint64 shl 24) or nextVal
    if remainingBytes > 4: nextVal = (val[divedVals*8+4].uint64 shl 32) or nextVal
    if remainingBytes > 5: nextVal = (val[divedVals*8+5].uint64 shl 40) or nextVal
    if remainingBytes > 6: nextVal = (val[divedVals*8+6].uint64 shl 48) or nextVal
    
    res = res.mixLast(nextVal, val.len)

  return finalize(res)

when isMainModule:
  var seed = [0xdeadbeefcafebabe'u64, 0x8badf00d1badb002'u64]
  import strutils
  echo(hash("Short test message", seed).BiggestInt.toHex(16))

