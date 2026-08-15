---@class OpcodeMetadata
---Names for instruction forms currently implemented by CC:X86.
local OpcodeMetadata = {
    [0x01] = "ADD r/m32,r32",
    [0x03] = "ADD r32,r/m32",
    [0x05] = "ADD EAX,imm32",
    [0x0D] = "OR EAX,imm32",
    [0x29] = "SUB r/m32,r32",
    [0x2B] = "SUB r32,r/m32",
    [0x2D] = "SUB EAX,imm32",
    [0x31] = "XOR r/m32,r32",
    [0x33] = "XOR r32,r/m32",
    [0x35] = "XOR EAX,imm32",
    [0x39] = "CMP r/m32,r32",
    [0x3B] = "CMP r32,r/m32",
    [0x68] = "PUSH imm32",
    [0x6A] = "PUSH imm8",
    [0x89] = "MOV r/m32,r32",
    [0x8B] = "MOV r32,r/m32",
    [0x8D] = "LEA r32,m",
    [0x90] = "NOP",
    [0xA1] = "MOV EAX,moffs32",
    [0xA3] = "MOV moffs32,EAX",
    [0xB8] = "MOV r32,imm32",
    [0xC2] = "RET imm16",
    [0xC3] = "RET",
    [0xC7] = "MOV r/m32,imm32",
    [0xCD] = "INT imm8",
    [0xE8] = "CALL rel32",
    [0xE9] = "JMP rel32",
    [0xEB] = "JMP rel8",
    [0xF4] = "HLT",
}

function OpcodeMetadata.name(opcode)
    if opcode >= 0x40 and opcode <= 0x47 then return "INC r32" end
    if opcode >= 0x48 and opcode <= 0x4F then return "DEC r32" end
    if opcode >= 0x50 and opcode <= 0x57 then return "PUSH r32" end
    if opcode >= 0x58 and opcode <= 0x5F then return "POP r32" end
    if opcode >= 0x70 and opcode <= 0x7F then return "Jcc rel8" end
    if opcode >= 0x80 and opcode <= 0x8F then return "Jcc rel32" end
    if opcode >= 0xB8 and opcode <= 0xBF then return "MOV r32,imm32" end
    return OpcodeMetadata[opcode] or "UNKNOWN"
end

return OpcodeMetadata
