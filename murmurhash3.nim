import bitutils, unsigned

## An implementation of the 32-bit MurmurHash algorithm. This is equivalent
## to the official implementation, but is factored into methods to be easy
## to use for hashing non-strings

type
  IntermediateHash = uint32

const
  c1: uint32 = 0xCC9E2D51'u32
  c2: uint32 = 0x1B873593'u32

proc initHash(key: int32): IntermediateHash =
  result = IntermediateHash(key)

proc mix(hash: IntermediateHash, val: int32): IntermediateHash =
  var k = val.uint32
  result = hash
  
  k *= c1
  k  = k.rotl(15)
  k *= c2
  
  result = result xor k
  result = result.rotl(13)
  result = result * 5'u32 + 0xE6546B64'u32

proc mixLast(hash: IntermediateHash, val: int32, len: int): IntermediateHash =
  ## A bit faster than mix, and should be used to
  ## mix in the last element
  var k = val.uint32

  k *= c1
  k  = k.rotl(15)
  k *= c2

  result = hash
  result = result xor k

  result = result xor len.IntermediateHash

proc finalize(hash: IntermediateHash): IntermediateHash =
  result = hash

  result  = result xor (result shr 16)
  result *= 0x85EBCA6B'u32
  result  = result xor (result shr 13)
  result *= 0xC2B2AE35'u32
  result  = result xor (result shr 16)

proc hash*(data: string, seed: int32): IntermediateHash =
  result = initHash(seed)
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
    result = result.mixLast(nextBlock, data.len)

  result = result.finalize()

proc hash*[T: int64|uint32](data: T, seed: int32): IntermediateHash =
  result = initHash(seed)
  result = result.mix(int32(data shr 32))
  result = result.mixLast(int32(data and T(0xFFFF_FFFF)), 1)
  result = result.finalize()

proc hash*[T: int8|int16|int32|uint8|uint16|uint32](data: T, seed: int32): IntermediateHash =
  result = initHash(seed)
  result = result.mixLast(data, 1)
  result = result.finalize()

proc hash*(data: char, seed: int32): IntermediateHash =
  result = initHash(seed)
  result = result.mixLast(ord(data), 1)
  result = result.finalize()

proc hash*(data: float32, seed: int32): IntermediateHash =
  hash(cast[int32](data), seed)

proc hash*(data: float64, seed: int32): IntermediateHash =
  hash(cast[int64](data), seed)

when isMainModule:
  assert hash("The quick brown fox jumps over the lazy dog", 0).int == 776992547 # Tested on little-endian
