start:
mov eax, 0x40000000
cpuid
cmp eax, 0x40000001
jne fail
cmp ebx, 0x564f4c43
jne fail
cmp edx, 0x534f5245
jne fail
cmp ecx, 0x3638582d
jne fail
mov eax, 67
out 0xe9, al
mov eax, 76
out 0xe9, al
mov eax, 79
out 0xe9, al
mov eax, 86
out 0xe9, al
mov eax, 69
out 0xe9, al
mov eax, 82
out 0xe9, al
mov eax, 79
out 0xe9, al
mov eax, 83
out 0xe9, al
mov eax, 45
out 0xe9, al
mov eax, 88
out 0xe9, al
mov eax, 56
out 0xe9, al
mov eax, 54
out 0xe9, al
mov eax, 32
out 0xe9, al
mov eax, 79
out 0xe9, al
mov eax, 75
out 0xe9, al
mov eax, 10
out 0xe9, al
hlt
fail:
mov eax, 88
out 0xe9, al
mov eax, 10
out 0xe9, al
hlt
