import unsigned

{.push checks: off.}

proc ones*[T: TInteger](): T =
  ## Returns an integer of the given size with all bits as one
  ##
  ## .. code-block:: Nimrod
  ##  assert(ones[int64]() == 0xFFFFFFFFFFFFFFFF'i64)
  ##  assert(ones[uint16]() == 0xFFFF'u16)
  T(0xFFFFFFFFFFFFFFFF'u64)

proc rotl*[T: TInteger](i: T, distance: BiggestInt): T =
  ## Rotates the integer ``i`` left ``distance`` times. This is an unsigned
  ## operation, the sign bit is rotated like any other bit.
  ## .. code-block:: Nimrod
  ##   assert (0b0000_1000 rotl 4) == 0b0100_0000
  ##   assert (-0b000_0000 rotl 2) == 0b0000_0010i8
  ##   assert (0b1000_0000u8 rotl 2) == 0b0000_0010u8
  ##   assert (432 rotl -2) == (432 rotr 2)
  return (i shl T(distance)) or (i shr T((sizeof(T)*8)-distance))

proc rotr*[T: TInteger](i: T, distance: BiggestInt): T =
  ## Rotates the integer ``i`` right ``distance`` times. This is an unsigned
  ## operation, the sign bit is rotated like any other bit.
  ## .. code-block:: Nimrod
  ##   assert (0b0010_0000 rotr 4) == 0b0000_0010
  ##   assert (-0b000_0000i8 rotr 2) == 0b0010_0000i8
  ##   assert (0b0000_0010u8 rotr 2) == 0b1000_0000u8
  ##   assert (781652 rotr -2) == (781652 rotl 2)
  return (i shr T(distance)) or (i shl T((sizeof(T)*8)-distance))

proc revBits*[T: TInteger](i: T): T =
  ## Reverses the order of the bits in the integer, such that the least
  ## significant bit becomes the most significant and so on
  ## .. code-block:: Nimrod
  ##   assert(revBits(0b1001_0010i8) == 0b0100_1001i8)
  result = i
  when sizeof(T) >= 1:
    result = ((result and cast[T](0x5555555555555555'i64)) shl 1) or
             ((result and cast[T](0xAAAAAAAAAAAAAAAA'i64)) shr 1)
    echo result
    result = ((result and cast[T](0x3333333333333333'i64)) shl 2) or
             ((result and cast[T](0xCCCCCCCCCCCCCCCC'i64)) shr 2)
    echo result
    result = ((result and cast[T](0x0F0F0F0F0F0F0F0F'i64)) shl 4) or
             ((result and cast[T](0xF0F0F0F0F0F0F0F0'i64)) shr 4)
    echo result
  when sizeof(T) >= 2:
    result = ((result and cast[T](0x00FF00FF00FF00FF'i64)) shl 8) or
             ((result and cast[T](0xFF00FF00FF00FF00'i64)) shr 8)
    echo result
  when sizeof(T) >= 4:
    result = ((result and cast[T](0x0000FFFF0000FFFF'i64)) shl 16) or
             ((result and cast[T](0xFFFF0000FFFF0000'i64)) shr 16)
    echo result
  when sizeof(T) == 8:
    result = ((result and cast[T](0x0000FFFF0000FFFF'i64)) shl 32) or
             ((result and cast[T](0xFFFF0000FFFF0000'i64)) shr 32)
    echo result

# checks really need to be off here
# ensures that the discriminator is ignored
{.push checks: off.}
type
  EndianTest = object
    case kind: bool
      of true:
        a: uint32
      of false:
        b: array[4, uint8]

proc isBigEndianMachine*: bool =
  let test = EndianTest(kind : true, a : 0x01020304)
  return test.b[0] == 1

proc isLittleEndianMachine*: bool =
  let test = EndianTest(kind : true, a : 0x01020304)
  return test.b[0] == 4
{.pop.}

{.pop.}

when isMainModule:
  # signed ones integers
  assert(ones[int8]() == 0xFF'i8)
  assert(ones[int16]() == 0xFFFF'i16)
  assert(ones[int32]() == 0xFFFFFFFF'i32)
  assert(ones[int64]() == 0xFFFFFFFFFFFFFFFF'i64)
  # unsigned ones integers
  assert(ones[uint8]() == 0xFF'u8)
  assert(ones[uint16]() == 0xFFFF'u16)
  assert(ones[uint32]() == 0xFFFFFFFF'u32)
  assert(ones[uint64]() == 0xFFFFFFFFFFFFFFFF'u64)
  # bit reversals
  assert(revBits(0x0000000000000000'i64) == 0x0000000000000000'i64)
  assert(revBits(0x00000000'i32) == 0x00000000'i32)
  assert(revBits(0x0000'i16) == 0x0000'i16)
  assert(revBits(0x00'i8) == 0x00'i8)
  echo revBits(0x1000000000000000'i64)
  assert(revBits(0x1000000000000000'i64) == 0x0000000000000001'i64)
  assert(revBits(0x10000000'i32) == 0x00000001'i32)
  assert(revBits(0x1000'i16) == 0x0001'i16)
  assert(revBits(0x10'i8) == 0x01'i8)