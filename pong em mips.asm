.data

	#bom de colocar os dados abaixo como 128 e 64. Dai o bitmap display como 512x256 e pixels 4 e 4

	widht: .word 128
	height: .word 64
	
	#é na memoria $gp (o gp vai de 10008000 ate 10010000, isso sao 0x8000 bytes (32768), como o word tem 4 bytes, sao 2^13, ou 128x64)

	coord_x: .word 0
	coord_y:.word 0
	
	#antiga_coord_x: .word 0
	#antiga_coord_y:.word 0
	
	tam_bola_x: .word 4
	tam_bola_y: .word 4
	
	cor_aleatoria: .word 0
	cor_bola: .word 0xFFFFFF
	cor_fundo: .word 0x0
	efeito_5d: .word 0
	
	velo_x: .word 0
	velo_y: .word 0
	velocidade_maxima: .word 5 	#em qualquer direcao
	energia_maxima: .word 0		#se 0, sera o dobro da velo max
	
	delay: .word 10 		#em milissegundos
	se_som: .word 1
.text

	j main
	
	#t0 a cor
	#t1 registrador instantaneo
	#t2 endereços instantâneos, load ou store
	
	#t3, 4, 5, 6
	
	#s1 vai ser o endereço do primeiro pixel da bola na memoria
	#s5 vai ser onde a bola está no X,  t5 normalmente para isso tbm
	#s6 vai ser onde a bola está no Y, t6 normalmente para isso tbm

	spawn:				#função normal, que é chamada na primeira iteração. Só usa temporários: 2, 5, 6.
			move $t2,$zero
			move $t5,$zero
			move $t6,$zero
	
		li $v0, 42
		la $t2, velocidade_maxima
		lw $t2,0($t2)
		mul $t1,$t2,2
		addi $t1,$t1,1
		add $a1,$t1,$zero
		syscall
		
		sub $a0,$a0,$t2
		la $t2,velo_x
		sw $a0,0($t2)			#velocidade aleatoria em X
		
		li $v0, 42
		la $t2, velocidade_maxima
		lw $t2,0($t2)
		mul $t1,$t2,2
		addi $t1,$t1,1
		add $a1,$t1,$zero
		syscall
		
		sub $a0,$a0,$t2
		la $t2,velo_y
		sw $a0,0($t2)			#velocidade aleatoria em Y
		
			lw $t2,energia_maxima
			bne $t2,0,organizar_coords
			
			lw $t2,velocidade_maxima
			mul $t2,$t2,2
			sw $t2,energia_maxima
		
			organizar_coords:
		
		la $t2,height
		lw $t2,0($t2)
		la $t6,tam_bola_y
		lw $t6,0($t6)
		sub $t6,$t2,$t6			#em t6 vai ter o maximo onde pode spawnar no eixo y
						#SABER SE VAI ATE 256 OU 255
		la $t2,widht
		lw $t2,0($t2)
		la $t5,tam_bola_x
		lw $t5,0($t5)
		sub $t5,$t2,$t5			#em t5 vai ter o maximo onde pode spawnar no eixo x
	
		move $a1,$t6
   		li $v0, 42 
   		syscall
   	
   		la $t2,coord_y			#VERIFICAR SE TA CERTO, O ALEATORIO CRU VAI DE 0 A 255
   		sw $a0,0($t2)			#salvando em coord_y o numero aleatorio horizontal pra spawnar
   		
   		move $a1,$t5
   		li $v0, 42 
   		syscall
   	
   		la $t2,coord_x
   		sw $a0,0($t2)			#salvando em coord_x o numero aleatorio vertical pra spawnar
   		
			move $t2,$zero
			move $t5,$zero
			move $t6,$zero

		jr $ra

	desenhar_bola:			#função de impressão, chamada várias vezes. T 3, 4, 6, 7 são do loop. T5 cor. 
					#ESSA FUNCAO DEVERIA SER PINTAR E APAGAR, A COR E S5 S6 DEVEM SER FEITOS FORA
		#------------ definir variaveis
	
		la $t5, tam_bola_x
		lw $t5, 0($t5)			#eu vou usar t6 pra ser o contador do loop externo (limite de caminhar)
		la $t6, tam_bola_y
		lw $t6, 0($t6)			#eu vou usar t7 pra ser o contador do loop interno (limite de caminhar)
		
		li $t3,0			#eu vou usar t3 para caminhar em x, precisa ser transformado em word
		li $t4,0			#eu vou usar t4 para caminhar em y
		
		#------------ operações
		
		mul $t1,$s5,4
		add $s1,$gp,$t1			#caminhar em GP para o indice horizontal, pelo tamanho da word, guardar em s1
			
		la $t2, widht
		lw $t2, 0($t2)			#usar t2 pra segurar a altura para calcular a largura e quantas linhas andou
			
		sub $t1,$s6,1			#diminuir 1 porque o indice 1 em y concluiu 0 linhas
		mul $t1,$t1,$t2
		mul $t1,$t1,4			#considerar o tamanho das words
		add $s1,$s1,$t1			#caminhar isso em GP no indice x, isso tudo apenas para ter S1 COMO PRIMEIRO PIXEL
		
		loop_desenho_x:
			
			mul $t1,$t3,4
			add $t7,$s1,$t1
			sw $t0,0($t7)		#anda uma iteração em X, e guarda a cor no primeiro pixel
			
			li $t4,0
			loop_desenho_y:
			
				la $t2,widht
				lw $t2,0($t2)
			
				mul $t1,$t4,4
				mul $t1,$t1,$t2
				
				add $t2,$t7,$t1
				sw $t0,0($t2)
				
				addi $t4,$t4,1
				blt $t4,$t6,loop_desenho_y
			
			addi $t3,$t3,1		#verifica o loop, pra andar todos os pixels ate o tamanho horizontal
			blt $t3,$t5,loop_desenho_x
			
		jr $ra
		
	atualizar:				#PRECISO PARAR DE USAR O T1 PARA O DADO MAIS IMPORTANTE: NOVA COORD
	
		#---------------------- X
	
		la $t2,velo_x
		lw $t1,0($t2)
		la $t2,coord_x
		lw $t3,0($t2)			
		add $t1,$t1,$t3			#essa é a nova coordenada de X, somando a coordenada anterior a velocidade atual
		
		la $t2, widht
		lw $t4, 0($t2)
		la $t2, tam_bola_x
		lw $t2, 0($t2)			#agora eu tenho o indice maximo que a bola pode nascer, para comparar
		sub $t3,$t4,$t2			#PRECISA DIMINUIR '1' AQUI??
		
		bgt $t1,$t3,bater_horiz		#aqui verifico se bateu na parede, caso nao e necessario ignorar as linhas abaixo
		blt $t1,$zero,bater_horiz
		j salvar_x
		
		bater_horiz:
	
				lw $t2,se_som
				bne $t2,1,fim_som_horiz
				som_horiz:
				li $v0,31
				li $a0, 62
				li $a1, 1000
				li $a2, 32
				li $a3, 126
				syscall
				fim_som_horiz:
		
			la $t2,velo_x
			lw $t3,0($t2)
			mul $t3,$t3,-1		#inverter a direção do movimento, mesma velocidade para o lado contrário
			add $t1,$t1,$t3		#desfazer o movimento anterior
			
			li $v0,42
			li $a1,3
			syscall
			sub $a0,$a0,1
			add $t3,$t3,$a0

				lw $t5, energia_maxima
				bgt $t3,$t5,nao_mudar_velo_x_horiz
				mul $t5,$t5,-1
				blt $t3,$t5,nao_mudar_velo_x_horiz
				lw $t5,velo_y
				add $t5,$t3,$t5
				beq $t5,$zero,nao_mudar_velo_x_horiz

			sw $t3,0($t2)		#ganhar ou perder uma unidade de movimento aleatoriamente em X e atualizar nova velocidade
				nao_mudar_velo_x_horiz:
			
			la $t2,velo_y
			lw $t3,0($t2)
			li $v0,42
			li $a1,3
			syscall
			sub $a0,$a0,1
			add $t3,$t3,$a0		
	
				lw $t5, energia_maxima
				bgt $t3,$t5,nao_mudar_velo_y_horiz
				mul $t5,$t5,-1
				blt $t3,$t5,nao_mudar_velo_y_horiz
				lw $t5,velo_x
				add $t5,$t3,$t5
				beq $t5,$zero,nao_mudar_velo_y_horiz

			sw $t3,0($t2)		#ganhar ou perder uma unidade de movimento aleatoriamente em Y e atualizar nova velocidade
				nao_mudar_velo_y_horiz:
		
		salvar_x:
		
			la $t2,coord_x
			sw $t1,0($t2)
			
		#---------------------- Y
				
		la $t2,velo_y
		lw $t1,0($t2)
		la $t2,coord_y
		lw $t3,0($t2)			
		add $t1,$t1,$t3			#essa é a nova coordenada de Y, somando a coordenada anterior a velocidade atual
		
		la $t2, height
		lw $t4, 0($t2)
		la $t2, tam_bola_y
		lw $t2, 0($t2)			#agora eu tenho o indice maximo que a bola pode nascer, para comparar
		sub $t3,$t4,$t2			#PRECISA DIMINUIR '1' AQUI?? PQ PARECE QUE O LIMITE DA HITBOX E 1 PIXEL ANTES
						addi $t3,$t3,1
		
		bgt $t1,$t3,bater_verti		#aqui verifico se bateu na parede, caso nao e necessario ignorar as linhas abaixo
		blt $t1,$zero,bater_verti
		j salvar_y
		
		bater_verti:
		
				lw $t2,se_som
				bne $t2,1,fim_som_verti
				som_verti:
				li $v0,31
				li $a0, 58
				li $a1, 1000
				li $a2, 32
				li $a3, 126
				syscall
				fim_som_verti:
		
			la $t2,velo_y
			lw $t3,0($t2)
			mul $t3,$t3,-1		#inverter a direção do movimento, mesma velocidade para o lado contrário
			add $t1,$t1,$t3		#desfazer o movimento anterior
			
			li $v0,42
			li $a1,3
			syscall
			sub $a0,$a0,1
			add $t3,$t3,$a0
			
				lw $t5, energia_maxima
				bgt $t3,$t5,nao_mudar_velo_y_verti
				mul $t5,$t5,-1
				blt $t3,$t5,nao_mudar_velo_y_verti
				lw $t5,velo_x
				add $t5,$t3,$t5
				beq $t5,$zero,nao_mudar_velo_y_verti

			sw $t3,0($t2)		#ganhar ou perder uma unidade de movimento aleatoriamente em Y e atualizar nova velocidade
				nao_mudar_velo_y_verti:
			
			la $t2,velo_x
			lw $t3,0($t2)
			li $v0,42
			li $a1,3
			syscall
			sub $a0,$a0,1
			add $t3,$t3,$a0
			
				lw $t5, energia_maxima
				bgt $t3,$t5,nao_mudar_velo_x_verti
				mul $t5,$t5,-1
				blt $t3,$t5,nao_mudar_velo_x_verti
				lw $t5,velo_y
				add $t5,$t3,$t5
				beq $t5,$zero,nao_mudar_velo_x_verti

			sw $t3,0($t2)		#ganhar ou perder uma unidade de movimento aleatoriamente em X e atualizar nova velocidade
				nao_mudar_velo_x_verti:

		salvar_y:

			la $t2,coord_y
			sw $t1,0($t2)
		
			jr $ra

	# -----------------------------------------------------------------------------------------
	
	main:			#OTIMIZAR IMPRESSAO.. TESTAR..
	
		jal spawn
		
		loop_principal:
		
			la $s5,coord_x			
			lw $s5,0($s5)			#s5 vai ser atualizado
			la $s6,coord_y
			lw $s6,0($s6)			#s6 vai ser atualizado
			
			la $t0,cor_bola
			lw $t0,0($t0)
			
				lw $t2,cor_aleatoria
				bne $t2,1,fim_random
				se_random:
				
					li $v0,42
					move $a1,$t0
					syscall
					move $t0,$a0
				
				fim_random:
			
			jal desenhar_bola
			
				li $v0,32
				lw $a0,delay				
				syscall
			
				#jal atualizar
			
			la $t0,cor_fundo
			lw $t0,0($t0)
			
				lw $t2,efeito_5d
				beq $t2,1,sem_apagar
			
			jal atualizar
			
			jal desenhar_bola
				sem_apagar:
			
			j loop_principal
