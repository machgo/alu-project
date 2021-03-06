#!/bin/bash

# print enhanced instruction infos from doc/opcode-table2.txt
awk -F"\t" '
{ 
for(i=2; i<18; i++){ 
split($i, code, " "); 
if($i !~ "??? ---" ){ 
printf("0x%x|%s|%s\n", (NR-1)*2^4+i-2,  $i, code[1]); 
}
} 
}
' doc/opcode-table2.txt > /tmp/tbl2.txt

# print table from named-commands.txt
awk 'NR>1{ printf("%s|", $1); for(i=3;i<=NF;i++) {printf("%s ", $i)} printf("\n"); }' named-commands.txt > /tmp/named-tbl.txt
awk -F"|" 'NR==FNR{a[$1]=$2;what=$1; awhat=a[what]; next} $3 ~ "TXS"{ line2[$3]=$0; } 
END {  
for(line in line2) { 
for(x in a) { 
#
{
#if(tolower(line) ~ tolower(x)){ p=6666221} else {p=123} 
#print "xmatch of x= " x "and line=" line "index: " index(line, x); 
} 
printf("x= %s line= %s a[x]= %s line2[line]= %s\n", x,line, a[x], line2[line]) 
} 
printf("line= %s what= %s a[what]= %s line2[line]= %s\n", line , what, a[what], line2[line]); 
}
} ' /tmp/named-tbl.txt /tmp/tbl2.txt  

# awk -F"|" 'NR==FNR{a[$1]=$2;next} { for(x in a){ if(x ~ / RTS/) printf("%s", a[$3])}; printf("  %s | %s | %s \n", $3, $0, $3) }' /tmp/named-tbl.txt /tmp/tbl2.txt  


# print laa instruction table file laa-commands.txt as a usable output for a c-struct array
awk -F"\t" 'BEGIN { }

function print_syntax(cmd, adr_mode){
if(adr_mode=="imm"){
return(sprintf("%s #oper \n", cmd))
}
if(adr_mode=="zp"){
return(sprintf("%s addr \n", cmd))
}
if(adr_mode=="zpx"){
return(sprintf("%s addr,X \n", cmd))
}
if(adr_mode=="abs"){
return(sprintf("%s ADDR \n", cmd))
}
if(adr_mode=="abx"){
return(sprintf("%s ADDR,X \n", cmd))
}
if(adr_mode=="aby"){
return(sprintf("%s ADDR,Y \n", cmd))
}
if(adr_mode=="izx"){
return(sprintf("%s addr,X\n", cmd))
}
if(adr_mode=="izy"){
return(sprintf("%s addr,Y \n", cmd))
}
if(adr_mode=="imp"){
return(sprintf("%s \n", cmd))
}
if(adr_mode=="rel"){
return(sprintf("%s addr\n", cmd))
}
}
function adrm(adr_mode){
if(adr_mode=="zpx "){
return(sprintf(" edata_zpindex(idx)"))
}
if(adr-mode=="zpy"){
return(sprintf("  edata_zpindex(idy)"))
}
if(adr_mode=="abx " || adr_mode=="abx"){
return(sprintf("  edata_abindex(idx)"))
}
if(adr_mode=="aby"){
return(sprintf("  edata_abindex(idy)"))
}
return(sprintf("  edata_%s()",adr_mode))
}
# function printing alu opcode name such as OR in ora
function alucall(adr_mode,i){
if(i=="ORA"){
return(sprintf("  char *reg = %s;\n %s", adrm(adr_mode), "alu(ALU_OP_OR,acc,reg,acc,flags);\n"))
}
if(i=="ADC"){
return(sprintf("  char *reg = %s;\n %s", adrm(adr_mode), "alu(ALU_OP_ADD_WITH_CARRY,acc,reg,acc,flags);\n"))
}
if(i=="SBC"){
return(sprintf("  char *reg = %s;\n %s", adrm(adr_mode), "alu(ALU_OP_SUB_WITH_BORROW,acc,reg,acc,flags);\n"))
}
if(i=="EOR"){
return(sprintf("  char *reg = %s;\n %s", adrm(adr_mode), "alu(ALU_OP_XOR,acc,reg,acc,flags);\n"))
}
 if(i=="CMP"){
return(sprintf("   char a[REG_WIDTH+1];\n  char *reg = %s;\n  alu(ALU_OP_SUB,acc,reg,a,flags);\n", adrm(adr_mode)))
}
if(i=="CPX"){
return(sprintf("   char a[REG_WIDTH+1];\n  char *reg = %s;\n  alu(ALU_OP_SUB,idx,reg,a,flags);\n", adrm(adr_mode)))
}
if(i=="CPY"){
return(sprintf("   char a[REG_WIDTH+1];\n  char *reg = %s;\n  alu(ALU_OP_SUB,idy,reg,a,flags);\n", adrm(adr_mode)))
}
if(i=="DEC"){
return(sprintf("   char *reg = %s;\n  alu(ALU_OP_SUB,reg,\"00000001\",dbr,flags);\nset_rw2write();\naccess_memory();", adrm(adr_mode)))
}
if(i=="INC"){
return(sprintf("   char *reg = %s;\n  alu(ALU_OP_ADD,reg,\"00000001\",dbr,flags);\nset_rw2write();\naccess_memory();", adrm(adr_mode)))
}
if(i=="ASL"){
if(adr_mode=="imp"){
return(sprintf("  alu(ALU_OP_ASL,acc,NULL,acc,flags);\n"))
}
return(sprintf("   char a[REG_WIDTH+1];\n  char *reg = %s;\n  alu(ALU_OP_ASL,reg,a,dbr,flags);\nset_rw2write();\naccess_memory();", adrm(adr_mode)))
}
if(i=="LSR"){
if(adr_mode=="imp"){
return(sprintf("  alu(ALU_OP_LSR,acc,NULL,acc,flags);\n"))
}
return(sprintf("   char a[REG_WIDTH+1];\n  char *reg = %s;\n  alu(ALU_OP_LSR,reg,a,dbr,flags);\nset_rw2write();\naccess_memory();", adrm(adr_mode)))
}
if(i=="ROL"){
if(adr_mode=="imp"){
return(sprintf("  alu(ALU_OP_ROL,acc,NULL,acc,flags);\n"))
}
return(sprintf("   char a[REG_WIDTH+1];\n  char *reg = %s;\n  alu(ALU_OP_ROL,reg,a,dbr,flags);\nset_rw2write();\naccess_memory();", adrm(adr_mode)))
}
if(i=="ROR"){
if(adr_mode=="imp"){
return(sprintf("  alu(ALU_OP_ROR,acc,NULL,acc,flags);\n"))
}
return(sprintf("   char a[REG_WIDTH+1];\n  char *reg = %s;\n  alu(ALU_OP_ROR,reg,a,dbr,flags);\nset_rw2write();\naccess_memory();", adrm(adr_mode)))
}
if(i=="INX"){
return(sprintf("   alu(ALU_OP_ADD,idx,\"00000001\",idx,flags);\n"))
}
if(i=="AND" || i=="ADD" ){
return(sprintf("  char *reg = %s;\n  alu(ALU_OP_%s,acc,reg,acc,flags);\nset_rw2write();\naccess_memory();", adrm(adr_mode), i))
}

}

NR==2 { split($0, rows, "\t"); }

NR>1 && $0 !~ /^#/{ 
for(i=2; i<14; i++){ 
split($i, code, "$"); 
if($i !~ /^ *$/ ){ 
fctname = "cpu_6502_" tolower($1) "_" tolower(rows[i]) ;
printf("\"%s\", 0x%s, %s, \"%s\", \"%s%s%s%s%s%s%s\"\n", $1, code[2], "cpu_6502_" tolower($1) "_" tolower(rows[i]), $14, $15=="*" ? "*" : "-", $16=="*" ? "*" : "-", $17=="*" ? "*" : "-",$18=="*" ? "*" : "-",$19=="*" ? "*" : "-",$20=="*" ? "*" : "-",$21=="*" ? "*" : "-" ); 
print "/*\n 6502 mu-function implementation\n name: " $1 "\n code: 0x" code[2] "\n address-mode: "tolower(rows[i])"\n function: " $14 "\n Syntax: " print_syntax($1,tolower(rows[i])) "\n flags: \n*/ \n" "void cpu_6502_" tolower($1) "_" tolower(rows[i]) "(){\n" alucall(tolower(rows[i]),$1) "\n}\n\n" > "/tmp/generated_6502-mu-code-template.c" 
print "/*\n 6502 mu-code function " fctname " declaration\n*/\n void " fctname "();\n" > "/tmp/generated_6502-mu-code-template.h" 


#printf("{ index: %s \"%s\", 0x%s, %s, \"%s\", \"%s\", \"%s%s%s%s%s%s%s\" },\n", i, $1, code[2], "6502_" tolower($1) "_" tolower(rows[i]) "(6502_register* value){}", $i, $14, $15=="*" ? "*" : "-", $16=="*" ? "*" : "-", $17=="*" ? "*" : "-",$18=="*" ? "*" : "-",$19=="*" ? "*" : "-",$20=="*" ? "*" : "-",$21=="*" ? "*" : "-" ); 
}
} 
}
' jmp-commands.txt move-commands.txt laa-commands.txt | \
sort -k2 > /tmp/tbl1.txt

# merging both files: /tmp/tbl1.txt /tmp/tbl2.txt
# awk -F"\"" 'NR==FNR{a[FNR]=$0;next} {printf("{ %s, \"%s\" }, \n", a[FNR], $2)}' /tmp/tbl1.txt /tmp/tbl2.txt

# print abstract table ordered by opcode from jmp-commands.txt move-commands.txt laa-commands.txt 
awk -F"\t" 'BEGIN { }
NR==2 { split($0, rows, "\t"); }
NR>1 && $0 !~ /^#/{ 
for(i=2; i<14; i++){ 
split($i, code, "$"); 
if($i !~ /^ *$/ ){ 
fctname = "cpu_6502_" tolower($1) "_" tolower(rows[i]) ;
flags = sprintf("%s%s%s%s%s%s%s", $15=="*" ? "*" : "-", $16=="*" ? "*" : "-", $17=="*" ? "*" : "-", $18=="*" ? "*" : "-", $19=="*" ? "*" : "-", $20=="*" ? "*" : "-", $21=="*" ? "*" : "-");
printf("%s | 0x%s | %s | %s | %s | %s \n", $1, code[2], fctname, $14, flags,tolower(rows[i]));
}
} 
}
' jmp-commands.txt move-commands.txt laa-commands.txt >/tmp/cmd-tbl.txt


# old stuff
# awk -F"\t" 'BEGIN { x = split("imp imm zp zpx zpy izx izy abs abx aby ind rel", adrmodes, " "); } 
# !/^#/ { 
# print $1 ; 
# for(adr in adrmodes) { 
# split($adr, code, "$"); 
# if($adr !~ /^ *$/ ){ 

# printf("linenumr: %s adr: %s $adr %s adrmodes[adr]: %s \n", NR, adr, $adr, adrmodes[adr]);

# # printf("{ \"%s\", 0x%s, %s, \"%s\", \"%s\", \"%s%s%s%s%s%s%s\" },\n", $1, code[2], "6502_" tolower($1) "_" tolower(adrmodes[adr]) "(6502_register* value){}", adrmodes[adr], $14, $15=="*" ? "*" : "-", $16=="*" ? "*" : "-", $17=="*" ? "*" : "-",$18=="*" ? "*" : "-",$19=="*" ? "*" : "-",$20=="*" ? "*" : "-",$21=="*" ? "*" : "-" ); 

# print "/*\n Name: " $1 "\n adrmode: " adrmodes[adr] "\n function: " $14 "\n*/\n" > "/tmp/generated-6502-mucode-template.c"; 
# print "void 6502_" tolower($1) "_" tolower(adrmodes[adr]) "(6502_register* value){\n\n}\n" >"/tmp/generated-6502-mucode-template.c";
# }
# } 
# }
# ' laa-commands.txt   |  \
# # sorting code field
# sort -k2


# this one worked (old)
#awk -F"\t" 'BEGIN { x = split("imp imm zp zpx zpy izx izy abs abx aby ind rel", adrmodes, " "); } NR>2{ for(adr in adrmodes) { if($adr !~ /^ *$/ ) printf("\"%s\", \"%s\", \"%s\" \"%s\"\n", $1, $adr, adrmodes[adr], $14 ); } }' laa-commands.txt 

						     
# for latex table
# awk -F"\t" '{printf("%s & %s & %s & %s & %s & %s & %s & %s & %s & %s & %s & %s & %s & %s & %s & %s & %s & %s & %s & %s & %s & %s\n",$1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22)}' laa-commands.txt 

# generating the functions going with each instruction
# awk -F"\t" '{printf("void 6502%s(%s){\n\n}\n", tolower($1) tolower($3) , 