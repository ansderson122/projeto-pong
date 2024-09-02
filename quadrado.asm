_start:
.equ saida_x 0x400
.equ saida_y 0x418
.equ resetTela 0x430
.equ escritaTela 0x448
.equ corTela 0x460
.equ memoria_de_video 0x478
.equ controle 0x878 # esse endereço é muito grande
.equ velocidadePlayer 1 

.equ posicao_bola 0x478 # aqui é o endereço de menoria vetor posição da bola
# que inica em 0x478 para X e vai paar 0x47c
.equ vetor_direcao 0x480 

li a0, 0x8
slli a0,a0,8
addi tp,a0,0x78 # tp vai ser usado para o endereço do controle 

li a1,0
li s7, 1
sw s7,resetTela(zero)

# definido a cor 
li s8, 0xff # vermenho
slli s8,s8,16
li s9, 0xff # verde
slli s9,s9,8
li s10, 0xff # azul
add s8,s8,s9
add t6,s8,s10      #O t6 vai ser o branco 
sw t6 , corTela(zero)
# fim da cor
li t3, 17  # para a possição y do player
li t4,17   # para a possição y IA

li a1,0
li t0,6
li s8,5 # i = 0

begin_for_i:
bge s8,t0,end_for_i	
li t1,22
li s9,11 # j = 0, a altura do player e de 11 pixels 

begin_for_j:
bge s9,t1,end_for_j
sw s8, saida_x(zero) # = 0x400 + 0 
sw s9, saida_y(zero)
sw s7, escritaTela(zero) # h
addi s9,s9,1
j begin_for_j
end_for_j:
addi s8,s8,1
j begin_for_i
end_for_i:
bge a1,s7,inicializacao_bola
addi a1,a1,1
li s8, 58
li t0, 59
j begin_for_i


# ------------- desenha a bola 
inicializacao_bola:
li a1, 16
li a2, 32

sw a2,posicao_bola(zero)
li a3,4
sw a1,posicao_bola(a3)

sw a2, saida_x(zero) 
sw a1, saida_y(zero)
li s7,1
sw s7, escritaTela(zero)

sw s7,vetor_direcao(zero)
sw s7,vetor_direcao(a3)
li t5, 0 # t5 esta reservado para reduzir a velocidade da  bola 


loopPrincipal:
jal ra, pressButton
jal ra, movimento_bola

j loopPrincipal



# ------------------------ inicio do movimento do player
pressButton: 
li s7,1
lw a0, 0(tp)
sw s7,0(tp)
beq a0, zero, fim_pressButton
addi a0,a0, -1
beq a0, zero ,  moveParaBaixo
addi a0,a0, -1
beq a0, zero , moveParaCima
fim_pressButton:
jr ra 
moveParaCima:
sw s7,0(tp)
li a3, 5
addi a4,t3, -6
addi a1,t3, 6
bge zero,a4,fim_pressButton 
li a5, 1
moveParaCima_i:
beq a5,zero, moveParaCima_i_fim
sw t6, corTela(zero)
sw a3, saida_x(zero)
sw a4, saida_y(zero)
sw s7, escritaTela(zero)
addi a5,a5,-1
sw zero, corTela(zero)
sw a3, saida_x(zero)
sw a1, saida_y(zero)
sw s7, escritaTela(zero)
addi a3,a3,1
j moveParaCima_i
moveParaCima_i_fim:
addi t3,t3,-1
addi a1,a1,-1
sw zero, saida_x(zero)
sw zero, saida_y(zero)
jr ra
moveParaBaixo:
sw s7,0(tp)
li a3, 5
addi a4,t3, 6
addi a1,t3, -6
li a5, 31
bge a4,a5,fim_pressButton
li a5, 1
moveParaBaixo_i:
beq a5,zero, moveParaBaixo_i_fim
sw t6, corTela(zero)
sw a3, saida_x(zero)
sw a4, saida_y(zero)
sw s7, escritaTela(zero)
addi a5,a5,-1
sw zero, corTela(zero)
sw a3, saida_x(zero)
sw a1, saida_y(zero)
sw s7, escritaTela(zero)
addi a3,a3,1
j moveParaBaixo_i
moveParaBaixo_i_fim:
addi t3,t3,1
sw zero, saida_x(zero)
sw zero, saida_y(zero)
jr ra
#---------------------- fim do movimento player


movimento_bola:
li a1, 10
bge a1, t5,fim_movimento_bola
li t5, 0
li a1,4
li s7,1

lw a2,posicao_bola(zero)
lw a3,posicao_bola(a1)

lw a4,vetor_direcao(zero)
lw a5,vetor_direcao(a1)

sw zero, corTela(zero)
sw a2, saida_x(zero) 
sw a3, saida_y(zero)
sw s7, escritaTela(zero)

add a2,a2,a4
add a3,a3,a5

sw a2,posicao_bola(zero)
sw a3,posicao_bola(a1)

sw a2, saida_x(zero) 
sw a3, saida_y(zero)
sw t6, corTela(zero)
sw s7, escritaTela(zero)

#-- o a2 e a3 tem a futura possição da bola com a direção atua em (a4 ,a5)
add a2,a2,a4
add a3,a3,a5

#-- verificar colisões entre a bola e as paredes e altera 
#-- a direção da bola
li a6,32
li a7,64
li s2, -1
bge zero,a3,altera_Y
bge a3,a6,altera_Y
j test_x
altera_Y:
mul a5,a5,s2
sw a5,vetor_direcao(a1)
test_x:
bge zero,a2,altera_x
bge a2,a7,altera_x
j altera_fim
altera_x:
mul a4,a4,s2
sw a4,vetor_direcao(zero)
altera_fim:

#-- verificar colisões entre a bola e os PLAYERS e altera 
#-- a direção da bola
li a6, 5
li a7, 58

beq a2, a6, verifica_y_player
beq a2, a7, verifica_y_IA
j verifica_fim

verifica_y_player:
add s2,a6,t3
sub s3,a6,t3
bge s2,a3, verifica_altera_x
bge s3,a3, verifica_altera_x
j verifica_fim

verifica_y_IA:
add s2,a6,t4
sub s3,a6,t4
bge s2,a3, verifica_altera_x
bge s3,a3, verifica_altera_x
j verifica_fim

verifica_altera_x:
li s2,-1
mul a4,a4,s2
sw a4,vetor_direcao(zero)
verifica_fim:

fim_movimento_bola:
addi t5,t5,1
jr ra 





fim:
j fim












