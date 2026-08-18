local args={...}
local input=args[1]
local output=args[2]
if not input or not output then
 print("usage: asm <source.asm> <output.bin>")
 return
end
local regs={eax=0,ecx=1,edx=2,ebx=3,esp=4,ebp=5,esi=6,edi=7}
local function number(value)
 value=value:gsub("%s+","")
 if value:sub(1,2):lower()=="0x" then return tonumber(value:sub(3),16) end
 if value:sub(1,1)=="-" then return tonumber(value,10) end
 return tonumber(value,10)
end
local function reg(value)
 return regs[value:lower()]
end
local function parse(line)
 line=line:match("^%s*(.-)%s*$")
 return line
end
local function emit32(out,value)
 value=value%4294967296
 out[#out+1]=value%256
 out[#out+1]=math.floor(value/256)%256
 out[#out+1]=math.floor(value/65536)%256
 out[#out+1]=math.floor(value/16777216)%256
end
local source={}
local labels={}
local pc=0
local h=fs.open(input,"r")
if not h then error("cannot open "..input) end
while true do
 local line=h.readLine()
 if not line then break end
 line=parse(line)
 local label=line:match("^([%a_][%w_]*):$")
 if label then labels[label]=pc else source[#source+1]=line end
 if not label and line~="" then
  local op=line:match("^(%S+)")
  op=op:lower()
  if op=="db" then
   local values=line:sub(3):gmatch("[^,]+")
   for _ in values do pc=pc+1 end
  elseif op=="nop" or op=="ret" or op=="hlt" or op=="cpuid" then
   pc=pc+(op=="cpuid" and 2 or 1)
  elseif op=="int" then
   pc=pc+2
  elseif op=="push" or op=="mov" or op=="add" or op=="sub" or op=="cmp" then
   if op=="push" then pc=pc+5
   elseif op=="mov" then pc=pc+5
   else pc=pc+6 end
  elseif op=="xor" then pc=pc+2
  elseif op=="out" then pc=pc+2
  elseif op=="jmp" or op=="call" then pc=pc+5
  elseif op=="je" or op=="jne" then pc=pc+6
  else error("unsupported instruction: "..op) end
 end
end
h.close()
local out={}
local function fail(line,message) error(input..":"..line..": "..message) end
local function split_operands(text)
 local a,b=text:match("^%s*([^,]+),%s*(.-)%s*$")
 return a,b
end
pc=0
for line_no,line in ipairs(source) do
 if line~="" then
  local op,rest=line:match("^(%S+)%s*(.-)$")
  op=op:lower()
  if op=="db" then
   for value in rest:gmatch("[^,]+") do
    local n=number(value)
    if not n then fail(line_no,"bad db value") end
    out[#out+1]=n%256
    pc=pc+1
   end
  elseif op=="nop" then out[#out+1]=0x90;pc=pc+1
  elseif op=="hlt" then out[#out+1]=0xF4;pc=pc+1
  elseif op=="ret" then out[#out+1]=0xC3;pc=pc+1
  elseif op=="cpuid" then out[#out+1]=0x0F;out[#out+1]=0xA2;pc=pc+2
  elseif op=="int" then
   local n=number(rest)
   if not n then fail(line_no,"bad interrupt") end
   out[#out+1]=0xCD;out[#out+1]=n%256;pc=pc+2
  elseif op=="push" then
   local n=number(rest)
   if not n then fail(line_no,"push requires an immediate") end
   out[#out+1]=0x68;emit32(out,n);pc=pc+5
  elseif op=="mov" then
   local a,b=split_operands(rest)
   local r=reg(a)
   local n=number(b or "")
   if not r or n==nil then fail(line_no,"only mov reg,imm is supported") end
   out[#out+1]=0xB8+r;emit32(out,n);pc=pc+5
  elseif op=="xor" then
   local a,b=split_operands(rest)
   local ra,rb=reg(a),reg(b)
   if ra==nil or rb==nil then fail(line_no,"xor requires registers") end
   out[#out+1]=0x31;out[#out+1]=0xC0+rb*8+ra;pc=pc+2
  elseif op=="add" or op=="sub" or op=="cmp" then
   local a,b=split_operands(rest)
   local r=reg(a)
   local n=number(b or "")
   if r==nil or n==nil then fail(line_no,op.." requires reg,imm") end
   local group=op=="add" and 0 or op=="sub" and 5 or 7
   out[#out+1]=0x81;out[#out+1]=0xC0+group*8+r;emit32(out,n);pc=pc+6
  elseif op=="out" then
   local a,b=split_operands(rest)
   if (a or ""):lower()=="0xe9" and (b or ""):lower()=="al" then out[#out+1]=0xE6;out[#out+1]=0xE9;pc=pc+2 else fail(line_no,"only out 0xe9,al is supported") end
  elseif op=="jmp" or op=="call" then
   local target=labels[rest]
   if target==nil then fail(line_no,"unknown label") end
   local next_pc=pc+5
   out[#out+1]=op=="jmp" and 0xE9 or 0xE8
   emit32(out,target-next_pc)
   pc=next_pc
  elseif op=="je" or op=="jne" then
   local target=labels[rest]
   if target==nil then fail(line_no,"unknown label") end
   local next_pc=pc+6
   out[#out+1]=0x0F;out[#out+1]=op=="je" and 0x84 or 0x85
   emit32(out,target-next_pc)
   pc=next_pc
  end
 end
end
local f=fs.open(output,"wb")
if not f then error("cannot create "..output) end
for i=1,#out,256 do
 local chunk={}
 for j=i,math.min(i+255,#out) do chunk[#chunk+1]=string.char(out[j]) end
 f.write(table.concat(chunk))
end
f.close()
print(string.format("assembled %d bytes -> %s",#out,output))
