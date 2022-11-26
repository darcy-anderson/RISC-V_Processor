from secrets import token_hex
import binascii

# Test saves
f = open('tc_data_mem_save.csv', 'w')
# Save word at every address
mem_en = 7
for n in range(1024):
  addr = hex(0x80000000 + n * 4)[2:]
  data = token_hex(4)
  if n == 512:
    mem_en = 'F'  # Confirm that MSB doesn't affect save word
  test_case = "{},{},{}\n".format(mem_en, addr, data)
  f.write(test_case)

# Test save word misaligned 1 byte
for n in range(100):
  addr = hex(0x80000001 + n * 4)[2:]
  data = token_hex(4)
  test_case = "{},{},{}\n".format(mem_en, addr, data)
  f.write(test_case)

# Test save word misaligned 2 byte
for n in range(100):
  addr = hex(0x80000002 + n * 4)[2:]
  data = token_hex(4)
  test_case = "{},{},{}\n".format(mem_en, addr, data)
  f.write(test_case)

# Test save word misaligned 3 byte
for n in range(100):
  addr = hex(0x80000003 + n * 4)[2:]
  data = token_hex(4)
  test_case = "{},{},{}\n".format(mem_en, addr, data)
  f.write(test_case)

# Test save half-word aligned
mem_en = 'E'
for n in range(100):
  addr = hex(0x80000000 + n * 4)[2:]
  data = '0000' + token_hex(2)
  test_case = "{},{},{}\n".format(mem_en, addr, data)
  f.write(test_case)

# Test save half-word misaligned 1 byte
for n in range(100):
  addr = hex(0x80000001 + n * 4)[2:]
  data = '0000' + token_hex(2)
  test_case = "{},{},{}\n".format(mem_en, addr, data)
  f.write(test_case)

# Test save half-word misaligned 2 byte
mem_en = 6
for n in range(100):
  addr = hex(0x80000002 + n * 4)[2:]
  data = '0000' + token_hex(2)
  test_case = "{},{},{}\n".format(mem_en, addr, data)
  f.write(test_case)

# Test save half-word misaligned 3 byte
for n in range(100):
  addr = hex(0x80000003 + n * 4)[2:]
  data = '0000' + token_hex(2)
  test_case = "{},{},{}\n".format(mem_en, addr, data)
  f.write(test_case)

# Test save byte aligned/misaligned
mem_en = 'D'
for n in range(100):
  addr = hex(0x80000000 + n)[2:]
  data = '000000' + token_hex(1)
  test_case = "{},{},{}\n".format(mem_en, addr, data)
  f.write(test_case)

# Test max address wrap-around
mem_en = 'F'
addr = hex(0x80000ffd)[2:]
data = token_hex(4)
test_case = "{},{},{}\n".format(mem_en, addr, data)
f.write(test_case)
addr = hex(0x80000ffe)[2:]
data = token_hex(4)
test_case = "{},{},{}\n".format(mem_en, addr, data)
f.write(test_case)
addr = hex(0x80000fff)[2:]
data = token_hex(4)
test_case = "{},{},{}\n".format(mem_en, addr, data)
f.write(test_case)

f.close()

# Test loads
f = open('tc_data_mem_load.csv', 'w')
# Load word already thoroughly tested
# Test load half-word unsigned aligned
mem_en = 6
for n in range(100):
  addr = hex(0x80000810 + n * 4)[2:]
  data = '0000' + token_hex(2)
  test_case = "{},{},{}\n".format(mem_en, addr, data)
  f.write(test_case)

# Test load half-word unsigned misaligned 1 byte
for n in range(100):
  addr = hex(0x80000811 + n * 4)[2:]
  data = '0000' + token_hex(2)
  test_case = "{},{},{}\n".format(mem_en, addr, data)
  f.write(test_case)

# Test load half-word unsigned misaligned 2 byte
for n in range(100):
  addr = hex(0x80000812 + n * 4)[2:]
  data = '0000' + token_hex(2)
  test_case = "{},{},{}\n".format(mem_en, addr, data)
  f.write(test_case)

# Test load half-word unsigned misaligned 3 byte
for n in range(100):
  addr = hex(0x80000813 + n * 4)[2:]
  data = '0000' + token_hex(2)
  test_case = "{},{},{}\n".format(mem_en, addr, data)
  f.write(test_case)

# Test load half-word signed aligned
mem_en = 'E'
for n in range(100):
  addr = hex(0x80000810 + n * 4)[2:]
  data = token_hex(2)
  # Long winded conversion to check if MSB is 0 for sign extension
  if bin(int.from_bytes(binascii.unhexlify(data),
                        'big'))[2:].zfill(16)[0] == '0':
    data = '0000' + data
  else:
    data = 'FFFF' + data
  test_case = "{},{},{}\n".format(mem_en, addr, data)
  f.write(test_case)

# Test load byte unsigned aligned/misaligned
mem_en = 5
for n in range(100):
  addr = hex(0x80000810 + n)[2:]
  data = '000000' + token_hex(1)
  test_case = "{},{},{}\n".format(mem_en, addr, data)
  f.write(test_case)

# Test load byte signed aligned/misaligned
mem_en = 'D'
for n in range(100):
  addr = hex(0x80000810 + n)[2:]
  data = token_hex(1)
  # Long winded conversion to check if MSB is 0 for sign extension
  if bin(int.from_bytes(binascii.unhexlify(data),
                        'big'))[2:].zfill(8)[0] == '0':
    data = '000000' + data
  else:
    data = 'FFFFFF' + data
  test_case = "{},{},{}\n".format(mem_en, addr, data)
  f.write(test_case)

f.close()
