import re

asm_file = open('test1.asm', 'r')
hex_file = open('hex.dat', 'w')

opcodes = {
    'and':'10' , 'or':'11' , 'xor':'12' , 'add':'13' , 'inc':'14' , 'mul':'15' , 'div':'16' , 'mod':'17',
    'nand':'18' , 'nor':'19' , 'not':'1a' , 'sub':'1b' , 'dec':'1c' , 'exp':'1e' , 'slt':'1f',
    'ld':'21' , 'st':'22' , 'li':'23',
    'jmp':'31' , 'beq':'32',
    'mov':'41'
}
registers = {
    '%r0':'00','%r1':'01','%r2':'02','%r3':'03','%r4':'04','%r5':'05','%r6':'06','%r7':'07','%r8':'08','%r9':'09'
}



# INITIALIZE
part_of_code = 0
labels = {}
mem_adr = 0

# PARSE , read line by line
for line in asm_file:
    hexcode = ''

    # strip away whitespaces and newlines
    line = line.strip()

    # ignore comments and empty lines
    if line == '': continue
    if line[0:2] == '//': continue
    if '//' in line: line = line[:line.index('//')].strip()

    # .data section or .code section ?
    if line == '.data':
        part_of_code = 1
        continue
    elif line == '.code':
        part_of_code = 2
        continue

    print(mem_adr,'-',end='') # debug

    # data segment
    if part_of_code==1:
        labels[line[0:line.index(':')]] = [ hex(mem_adr)[2:] , [i for i in line[line.index(':')+1:].split(' ') if i != ''] ]
        #mem_adr += 4 * len(labels[line[0:line.index(':')]][1])

    # code segment
    if part_of_code==2:
        l = [ i for i in re.split(' |,', line) if i != '' ]

        # check for labels
        for i in range(min(len(l),4)):
            if l[i] in labels:
                l[i] = labels[l[i]][0]


        # add opcode
        hexcode += opcodes[l[0]]
     
        # type of instruction ?
        if hexcode[0] == '1':
            # arithmetic op :     + - * / %
            if len(l)==4:
                hexcode = hexcode + registers[l[1]] + registers[l[2]] + registers[l[3]]     # op.rr.rr.rr
            elif len(l)==3:
                hexcode = hexcode + registers[l[1]] + registers[l[2]] + '00'     # op.rr.rr.rr   (not, inc, dec)
        elif hexcode[0] == '2':
            # data control :    load, store, and load_imm
            hexcode = hexcode + registers[l[1]] + hex(int(l[2]))[2:].zfill(4)       # op.rr.iiii
        elif hexcode[0:2] == '31':
            # jump
            hexcode = hexcode + hex(int(l[1]))[2:].zfill(6)        # jp.iiiiii
        elif hexcode[0:2] == '32':
            # beq
            hexcode = hexcode + hex(int(l[1]))[2:].zfill(2) + registers[l[2]] + registers[l[3]]        # bq.ii.rr.rr
        elif hexcode[0] == '4':
            # mov
            hexcode = hexcode + registers[l[1]] + '00' + registers[l[2]]      # mv.r2.--.r1
        
        hex_file.write(hexcode+'\n')
        mem_adr += 4

    # debug
    print(part_of_code,'-', line,'-',hexcode)
print('labels: ', labels)

asm_file.close()
hex_file.close()