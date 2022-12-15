from secrets import token_hex
import binascii

# Test stores
f = open('tc_data_mem_save.csv', 'w')
# Store word every address
mem_bs = 3
for n in range(1024):
  addr = hex(0x80000000 + n * 4)[2:]
  data = token_hex(4)
  test_case = "{},{},{}\n".format(mem_bs, addr, data)
  f.write(test_case)
# LED register
addr = hex(0x00100014)[2:]
data = token_hex(4)
test_case = "{},{},{}\n".format(mem_bs, addr, data)
f.write(test_case)

# Store half-word every address
mem_bs = 2
for n in range(2048):
  addr = hex(0x80000000 + n * 2)[2:]
  data = '0000' + token_hex(2)
  test_case = "{},{},{}\n".format(mem_bs, addr, data)
  f.write(test_case)
# LED register
for n in range(2):
  addr = hex(0x00100014 + n * 2)[2:]
  data = '0000' + token_hex(2)
  test_case = "{},{},{}\n".format(mem_bs, addr, data)
  f.write(test_case)

# Test save byte aligned/misaligned
mem_bs = 1
for n in range(4096):
  addr = hex(0x80000000 + n)[2:]
  data = '000000' + token_hex(1)
  test_case = "{},{},{}\n".format(mem_bs, addr, data)
  f.write(test_case)
# LED register
for n in range(4):
  addr = hex(0x00100014 + n)[2:]
  data = '000000' + token_hex(1)
  test_case = "{},{},{}\n".format(mem_bs, addr, data)
  f.write(test_case)

f.close()

# Test loads
f = open('tc_data_mem_load.csv', 'w')
# Load word already thoroughly tested
# Test load half-word unsigned
mem_bs = 2
mem_se = 0
for n in range(2048):
  addr = hex(0x80000000 + n * 2)[2:]
  data = '0000' + token_hex(2)
  test_case = "{},{},{},{}\n".format(mem_bs, mem_se, addr, data)
  f.write(test_case)

# Test load half-word signed
mem_se = 1
for n in range(2048):
  addr = hex(0x80000000 + n * 2)[2:]
  data = token_hex(2)
  # Long winded conversion to check if MSB is 0 for sign extension
  if bin(int.from_bytes(binascii.unhexlify(data),
                        'big'))[2:].zfill(16)[0] == '0':
    data = '0000' + data
  else:
    data = 'FFFF' + data
  test_case = "{},{},{},{}\n".format(mem_bs, mem_se, addr, data)
  f.write(test_case)

# Test load byte unsigned
mem_bs = 1
mem_se = 0
for n in range(4096):
  addr = hex(0x80000000 + n)[2:]
  data = '000000' + token_hex(1)
  test_case = "{},{},{},{}\n".format(mem_bs, mem_se, addr, data)
  f.write(test_case)

# Test load byte signed aligned/misaligned
mem_se = 1
for n in range(4096):
  addr = hex(0x80000000 + n)[2:]
  data = token_hex(1)
  # Long winded conversion to check if MSB is 0 for sign extension
  if bin(int.from_bytes(binascii.unhexlify(data),
                        'big'))[2:].zfill(8)[0] == '0':
    data = '000000' + data
  else:
    data = 'FFFFFF' + data
  test_case = "{},{},{},{}\n".format(mem_bs, mem_se, addr, data)
  f.write(test_case)

f.close()
