import bitutils, unsigned

## An implmentation of the 32-bit MurmurHash algorithm. This is equvilent
## to the offical implmentation, but is factored into methods to be easy
## to use for hashing non-strings

type
  THash = uint32

const
  c1: uint32 = 0xCC9E2D51'u32
  c2: uint32 = 0x1B873593'u32

proc mixLast*(hash: THash, val: int32): THash =
  ## A bit faster than mix, and can be used for the last element because it
  ## doesn't mix the bits up as finalization does that anyways
  var k = val.uint32

  k *= c1
  k  = k.rotl(15)
  k *= c2

  result = hash
  result = result xor k

proc mix*(hash: THash, val: int32): THash =
  var k = val.uint32
  result = hash
  
  k *= c1
  k  = k.rotl(15)
  k *= c2
  
  result = result xor k
  result = result.rotl(13)
  result = result * 5'u32 + 0xE6546B64'u32

proc finalize*(hash: THash, len: Natural): THash =
  result = hash

  result = result xor THash(len)

  result  = result xor (result shr 16)
  result *= 0x85EBCA6B'u32
  result  = result xor (result shr 13)
  result *= 0xC2B2AE35'u32
  result  = result xor (result shr 16)

proc `!&`*(hash: THash, val: int32): THash =
  mix(hash, val)

proc `!$`*(hash: THash, len: Natural): THash =
  finalize(hash, len)

proc hash*(data: string, seed: THash): THash =
  result = seed
  let blocks = data.len div 4

  block body:
    for i in 0..(blocks-1):
      let
        adjIdx = i * 4
        nextBlock = (int32 ord(data[adjIdx])         ) or
                    (int32 ord(data[adjIdx+1]) shl 8 ) or
                    (int32 ord(data[adjIdx+2]) shl 16) or
                    (int32 ord(data[adjIdx+3]) shl 24)
      result = result.mix(nextBlock)
 
  block tail:
    var nextBlock: int32 = 0
    let
      extraBytes = data.len and 3  # Mod 4
      lastElem = blocks * 4
    if extraBytes >= 3: nextBlock = nextBlock xor (int32 ord(data[lastElem+2]) shl 16)
    if extraBytes >= 2: nextBlock = nextBlock xor (int32 ord(data[lastElem+1]) shl 8 )
    if extraBytes >= 1: nextBlock = nextBlock xor (int32 ord(data[lastElem])         )
    result = result.mixLast(nextBlock)

  result = result.finalize(data.len)

proc hash*[T: int64|uint32](data: T, seed: THash = 0): THash =
  result = seed
  result = result.mix(int32(data shr 32))
  result = result.mixLast(int32(data and T(0xFFFF_FFFF)))
  result = result.finalize(2)

proc hash*[T: int8|int16|int32|uint8|uint16|uint32](data: T, seed: THash = 0): THash =
  result = seed.mixLast(data)
  result = result.finalize(1)

proc hash*(data: char, seed: THash = 0): THash =
  result = seed.mixLast(ord(data))
  result = result.finalize(1)

proc hash*(data: float32, seed: THash): THash =
  hash(cast[int32](data), seed)

proc hash*(data: float64, seed: THash): THash =
  hash(cast[int64](data), seed)

when isMainModule:
  assert hash("The quick brown fox jumps over the lazy dog", 0).int == 776992547 # Tested on little-endian
