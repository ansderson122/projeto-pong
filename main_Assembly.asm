_start:
.equ saida_x 0x400            # Endereço para a saída X
.equ saida_y 0x418            # Endereço para a saída Y
.equ resetTela 0x430          # Endereço para resetar a tela
.equ escritaTela 0x448        # Endereço para habilitar a escrita na tela
.equ corTela 0x460            # Endereço para definir a cor do pixel
.equ memoria_de_video 0x478   # Endereço da memória de vídeo
.equ controle 0x878           # Endereço do controle
    
.equ posicao_bola 0x478       # Endereço inicial da posição da bola
.equ vetor_direcao 0x480      # Vetor de direção da bola
        
.equ tamanho_tela_y 32        # Altura da tela
.equ tamanho_tela_x 64        # Largura da tela
        
.equ velocidadePlayer 1       # Velocidade do jogador
.equ altura_players 5         # Altura das raquetes (-5 a +5 a partir do centro)
.equ largura_players 1        # Largura das raquetes
.equ centro_players 17        # Posição inicial central das raquetes
.equ distancia_bordaX_tela_player 5 # Distância entre a raquete e a borda lateral
 
# Reset da tela
li a0, 1                   # Carrega o valor 1 em a0 (ativo o reset)
sw a0, resetTela(zero)     # Escreve no endereço de reset para limpar a tela

# Configuração do endereço do controle
li a0, 0x8                 # Carrega o valor base (8) em hexadecimal
slli a0, a0, 8             # Desloca o valor 8 bits à esquerda (equivalente a multiplicar por 256)
addi tp, a0, 0x78          # Soma o valor deslocado com 0x78 para definir o endereço do controle em tp

# Definição da cor branca
li s8, 0xff                # Carrega o valor máximo (255) para o componente vermelho
slli s8, s8, 16            # Desloca 16 bits à esquerda para posicionar no componente vermelho (RGB)
li s9, 0xff                # Carrega o valor máximo (255) para o componente verde
slli s9, s9, 8             # Desloca 8 bits à esquerda para posicionar no componente verde (RGB)
li s10, 0xff               # Carrega o valor máximo (255) para o componente azul
add s8, s8, s9             # Combina vermelho e verde no registrador s8
add t6, s8, s10            # Adiciona o azul para formar a cor branca completa (RGB = 255,255,255)
sw t6, corTela(zero)       # Escreve a cor branca no dispositivo de entrada/saída (corTela)

# Configuração inicial das posições
li t3, centro_players      # Define a posição inicial Y do jogador como o centro da tela
li t4, centro_players      # Define a posição inicial Y da IA como o centro da tela


li a1,0
li t0,lagura_players
addi t0,t0,distacia_bordaX_tela_player
li s8,distacia_bordaX_tela_player # i = 0
li a6,altura_players


begin_for_i:
bge s8,t0,end_for_i	
addi t1,t3,altura_players
sub s9,t3,a6 # j = 0, a altura do player e de 11 pixels 

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
li s8, distacia_bordaX_tela_player
li t0, tamanho_tela_x
sub s8,t0,s8 # distacia_bordaX_tela_player - tamanho_tela_x
li t0,lagura_players
add t0,t0,s8
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
jal ra, IA

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
li a3, distacia_bordaX_tela_player
li a1,altura_players
sub a4,t3, a1
add a1,t3, a1
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
li a3, distacia_bordaX_tela_player
li a1,altura_players
add a4,t3, a1
sub a1,t3, a1
li a5, tamanho_tela_y
addi a5,a5,-1
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
li a1, 1
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
bge zero,a3,alteracao_vertical 
bge a3,a6,alteracao_vertical
j test_x

alteracao_vertical:
mul a5,a5,s2
sw a5,vetor_direcao(a1)
j fim_movimento_bola

test_x:
bge zero,a2,reincia_bola
bge a2,a7,reincia_bola
j altera_fim

reincia_bola:
sub a2,a2,a4
sub a3,a3,a5

mul a4,a4,s2
sw a4,vetor_direcao(zero)

sw zero, corTela(zero)
sw a2, saida_x(zero) 
sw a3, saida_y(zero)
sw s7, escritaTela(zero)
li a2,32
li a3,16
sw a2,posicao_bola(zero)
sw a3,posicao_bola(a1)
j fim_movimento_bola

altera_fim:

#-- verificar colisões entre a bola e os PLAYERS e altera 
#-- a direção da bola
li a6, distacia_bordaX_tela_player
li a7, tamanho_tela_x 
sub a7,a7,a6

beq a2, a6, verifica_y_player
beq a2, a7, verifica_y_IA
j verifica_fim

verifica_y_player:
add s2,a6,t3
sub s3,t3,a6
j verifica_altera_x

verifica_y_IA:
add s2,a6,t4
sub s3,t4,a6
j verifica_altera_x

verifica_altera_x:
slt s4,s2,a3
slt s5,a3,s3
or s5,s5,s4
beqz s5,altera_direcao_x
j verifica_fim

altera_direcao_x:
li s2,-1
mul a4,a4,s2
sw a4,vetor_direcao(zero)

verifica_fim:
fim_movimento_bola:
addi t5,t5,1
jr ra 


IA:
li a1, 4
lw a2,posicao_bola(zero)
lw a3,posicao_bola(a1) # possiçao y da bola 
li a4, tamanho_tela_x 
li a5,20
sub a4,a4,a5
addi a4,a4,10

slt a4,a2,a4
bne a4,zero,AI_fim


slt a2,a3,t4
beq a2,zero,IA_subir
bne a2,zero,IA_descer

AI_fim:
jr ra 
IA_descer:
li a3, distacia_bordaX_tela_player
li a4, tamanho_tela_x
sub a3,a4,a3 # distacia_bordaX_tela_player - tamanho_tela_x
li a1,altura_players
sub a4,t4, a1
add a1,t4, a1
bge zero,a4,AI_fim
addi t4,t4,-1
j IA_desenha


IA_subir:
li a3, distacia_bordaX_tela_player
li a4, tamanho_tela_x
sub a3,a4,a3 # distacia_bordaX_tela_player - tamanho_tela_x
li a1,altura_players
add a4,t4, a1
sub a1,t4, a1
li a5, tamanho_tela_y
addi a5,a5,-1
bge a4,a5,AI_fim
addi t4,t4,1
j IA_desenha


IA_desenha:
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
sw zero, saida_x(zero)
sw zero, saida_y(zero)
jr ra


fim:
j fim












