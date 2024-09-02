.data

	#bom de colocar os dados abaixo como 128 e 64. Dai o bitmap display fica legal como 512x512, pixels 1x1

	widht: .word 512
	height: .word 512
	memoria: .word 0x10040000
	
	#é na memoria $heap (o heap vai de 10040000 ate deus sabe onde)

	talvez_coord_x: .word 0
	talvez_coord_y: .word 0
	coord_x: .word 0
	coord_y:.word 0
	
	tam_bola_x: .word 4
	tam_bola_y: .word 4
	
	cor_aleatoria: .word 1
	cor_bola: .word 0xFFFFFF
	cor_fundo: .word 0x0
	cor_obstaculo: .word 0x808080
	efeito_5d: .word 1
	
	velo_x: .word 0
	velo_y: .word 0
	velocidade_maxima: .word 5 	#em qualquer direcao, ideal 5
	energia_maxima: .word 0		#se 0, sera o dobro da velo max
	
	delay: .word 10 		#em milissegundos
	se_som: .word 1
	
	qtd_obstaculos: .word 20
	tam_max_obstaculos: .word 30
	
	jogador_4_pontas: .word 0,0,0,0
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
			
		velocidade_aleatoria:
			
			li $v0, 42
			la $t2, velocidade_maxima
			lw $t2,0($t2)
			mul $t1,$t2,2
			addi $t1,$t1,1
			add $a1,$t1,$zero
			syscall
		
			sub $a0,$a0,$t2
			la $t2,velo_x
			sw $a0,0($t2)			#velocidade aleatoria em X (NÃO DEIXAR AS DUAS SER 0)
			add $t7,$a0,$zero
		
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
			add $t7,$t7,$a0
			
			beqz $t7,velocidade_aleatoria
		
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
		#add $s1,$gp,$t1		#caminhar em GP para o indice horizontal, pelo tamanho da word, guardar em s1
		addi $s1,$t1,0x10040000
		
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
		
	desenhar_obstaculos:
	
		li $t0,0			#em t0 vai ser o contador de quantos obstaculos ja foram impressos
		lw $t1,qtd_obstaculos		#em t1 vai ser a quantidade maxima desses objetos
		
		li $t2,0
		li $t7,0			#os dois temporarios
		
		bge $t0,$t1,fim_loop_obstaculos
		
		loop_obstaculos:
		
			li $v0, 42
			lw $a1,tam_max_obstaculos
			syscall
			addi $a0,$a0,1
			move $t5,$a0		#t5 vai ser o tam x desse obstaculo especifico
			
			lw $t2,tam_bola_x
			bge $t5,$t2,tam_obst_x_ok
			li $t5,4		#O OBSTACULO NAO PODE SER MENOR QUE O JOGADOR POIS SE NAO AS VEZES O JOGADOR PODE SER PERFURADO
			
			tam_obst_x_ok:
			
			li $v0, 42
			lw $a1,tam_max_obstaculos
			syscall
			addi $a0,$a0,1
			move $t6,$a0		#t6 vai ser o tam y desse obstaculo especifico
			
			lw $t2,tam_bola_y
			bge $t6,$t2,tam_obst_y_ok
			li $t6,4
			
			tam_obst_y_ok:
			
			lw $t3,widht
			lw $t4,height
			sub $t4,$t4,$t6
			sub $t3,$t3,$t5
			
			move $a1,$t3
			li $v0,42
			syscall
			move $t3,$a0		#t3 agora é a coord x do primeiro pixel desse obstaculo
			
			move $a1,$t4
			li $v0,42
			syscall
			move $t4,$a0		#t4 agora é a coord y do primeiro pixel desse obstaculo

			li $s0,0			#s0 vai ser o primeiro pixel desse obstaculo
			li $t8,0			#eu vou usar t8 para caminhar em x, precisa ser transformado em word
			li $t9,0			#eu vou usar t9 para caminhar em y
		
			#------------ operações
		
			mul $t2,$t3,4
			#add $s1,$gp,$t1		#caminhar em GP para o indice horizontal, pelo tamanho da word, guardar em s0
			addi $s0,$t2,0x10040000
		
			lw $t2, widht			#usar t2 pra segurar a altura para calcular a largura e quantas linhas andou
			sub $t7,$t4,1			#diminuir 1 porque o indice 1 em y concluiu 0 linhas
			mul $t2,$t7,$t2
			mul $t2,$t2,4			#considerar o tamanho das words
			add $s0,$s0,$t2			#caminhar isso na memoria no indice y, isso tudo apenas para ter S0 COMO PRIMEIRO PIXEL
		
			loop_desenho_obstaculo_x:
			
				mul $t2,$t8,4
				add $s7,$s0,$t2
				lw $t2, cor_obstaculo
				sw $t2,0($s7)		#anda uma iteração em X, e guarda a cor no primeiro pixel, isso vai ser o s7 pois e importante
			
				li $t9,0
				loop_desenho_obstaculo_y:

					lw $t2,widht
					mul $t7,$t9,4
					mul $t7,$t7,$t2
				
					add $t7,$s7,$t7
					lw $t2,cor_obstaculo
					sw $t2,0($t7)
				
					addi $t9,$t9,1
					blt $t9,$t6,loop_desenho_obstaculo_y
			
				addi $t8,$t8,1		#verifica o loop, pra andar todos os pixels ate o tamanho horizontal
				blt $t8,$t5,loop_desenho_obstaculo_x
			
			addi $t0,$t0,1
			blt $t0,$t1,loop_obstaculos
		
		fim_loop_obstaculos:
		
		jr $ra
		
	atualizar:				#PRECISO PARAR DE USAR O T1 PARA O DADO MAIS IMPORTANTE: NOVA COORD

		#---------------------- X
	
		lw $t1,velo_x
		lw $t3,coord_x		
		add $t1,$t1,$t3			#essa é a nova coordenada de X, somando a coordenada anterior a velocidade atual
		
		lw $t4,widht
		lw $t2,tam_bola_x		#agora eu tenho o indice maximo que a bola pode nascer, para comparar
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
		
			#la $t2,talvez_coord_x
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
						addi $t3,$t3,1		#o que e essa linha de codigo? ela estava adicionando 1 a t3, mudei p -1
		
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

			#la $t2,talvez_coord_y
			la $t2,coord_y
			sw $t1,0($t2)
		
		jr $ra
		
	quicar:
	
		#aqui eu preciso calcular as 4 ponta e guardar esses 4 endereços
		#se algum desses 4 endereços for branco, quicou
		
		#lw $t5,talvez_coord_x
		#lw $t6,talvez_coord_y
		li $s2,0
		lw $t5,coord_x
		lw $t6,coord_y
		
		mul $t2,$t5,4
		addi $s2,$t2,0x10040000
		lw $t2,widht
		sub $t1,$t6,1			#diminuir 1 porque o indice 1 em y concluiu 0 linhas
		mul $t1,$t1,$t2
		mul $t1,$t1,4			#considerar o tamanho das words
		add $s2,$s2,$t1			#caminhar isso na memoria no indice y, isso tudo apenas para ter S2 COMO PRIMEIRO PIXEL
		
		la $t2,jogador_4_pontas
		sw $s2,0($t2)			#salvando a ponta xy
		
		lw $t3,tam_bola_x
			sub $t3,$t3,1		#TESTAR PRA VER SE ASSIM DA, POIS O PRIMEIRO PIXEL JA FOI NE?
		mul $t3,$t3,4
		add $t0,$s2,$t3
		sw $t0,4($t2)			#salvando a ponta x4y
		
		lw $t4,tam_bola_y
		sub $t4,$t4,1
		lw $t2,widht
		mul $t4,$t4,$t2
		mul $t4,$t4,4
		add $t0,$s2,$t4
		la $t2,jogador_4_pontas
		sw $t0,8($t2)			#salvando ponta xy4
		
		add $t0,$s2,$t3
		add $t0,$t0,$t4
		sw $t0,12($t2)			#salvando ponta x4y4
		
										#li $v0,32
										#li $a0,3000				
										#syscall
		
		la $t2,jogador_4_pontas
		lw $t7,cor_obstaculo
		li $t8,0
		
		lw $t3,tam_bola_y
		lw $t4,widht
		mul $t4,$t4,$t3
		mul $t4,$t4,4
		
		lw $t3,tam_bola_x
		mul $t3,$t3,4
		
		#aqui eu posso usar o s2? a partir daqui eu vou agora fazer as comparacoes dos pixels ao redor
		
		li $t5,0
		li $t6,0
		li $t8,0
		
			lw $s2,0($t2)
		
		sub $t0,$s2,$t3			#isso aqui e a esquerda de xy
		lw $t1,0($t0)
		seq $t8,$t1,$t7
		or $t5,$t5,$t8
		
		sub $t0,$s2,$t4			#isso aqui e em cima de xy
		lw $t1,0($t0)
		seq $t8,$t1,$t7
		or $t6,$t6,$t8
		
			lw $s2,4($t2)
		
		add $t0,$s2,$t3			#isso aqui e a direita de x4y
		lw $t1,0($t0)
		seq $t8,$t1,$t7
		or $t5,$t5,$t8
		
		sub $t0,$s2,$t4			#isso aqui e em cima de x4y
		lw $t1,0($t0)
		seq $t8,$t1,$t7
		or $t6,$t6,$t8
		
			lw $s2,8($t2)

		add $t0,$s2,$t4			#isso aqui e embaixo de xy4
		lw $t1,0($t0)
		seq $t8,$t1,$t7
		or $t6,$t6,$t8
		
		sub $t0,$s2,$t3			#isso aqui e a esquerda de xy4
		lw $t1,0($t0)
		seq $t8,$t1,$t7
		or $t5,$t5,$t8
		
			lw $s2,12($t2)

		add $t0,$s2,$t3			#isso aqui e a direita de x4y4
		lw $t1,0($t0)
		seq $t8,$t1,$t7
		or $t5,$t5,$t8
		
		add $t0,$s2,$t4			#isso aqui e embaixo de x4y4
		lw $t1,0($t0)
		seq $t8,$t1,$t7
		or $t6,$t6,$t8	
		
		#lw $t1,0($t2)
		#lw $t0,($t1)			#certo isso? NAO, E DEMOREI PRA PERCEBER INVES DE LA+LW NA VDD E LW+LW GRRRR!!!
			#bne $t0,$t7,nao_xy
			#mul $t8,$t8,2
		
			#nao_xy:
		#lw $t1,4($t2)
		#lw $t0,0($t1)
			#bne $t0,$t7,nao_x4y
			#mul $t8,$t8,3
		
			#nao_x4y:
		#lw $t1,8($t2)
		#lw $t0,0($t1)
			#bne $t0,$t7,nao_xy4
			#mul $t8,$t8,5
		
			#nao_xy4:
		#lw $t1,12($t2)
		#lw $t0,0($t1)
			#bne $t0,$t7,nao_x4y4		#AQUI E POSSIVEL CRIAR VARIAS LOGICAS PARA VELOCIDADE DEPENDENDO DO ANGULO DA QUICADA
			#mul $t8,$t8,7
		
			#nao_x4y4:
			#bne $t8,1,quicou
		
		or $t8,$t5,$t6
		beq $t8,1,quicou
		
		nao_quicou:
		
			#la $t2,coord_x			#ESSAS 6 LINHAS SAO PARA CASO USAR O 'TALVEZ_COORD'
			#lw $t1,talvez_coord_x
			#sw $t1,($t2)
		
			#la $t2,coord_y
			#lw $t1,talvez_coord_y
			#sw $t1,($t2)
		
			jr $ra
		
		quicou:
		
				lw $t2,se_som
				bne $t2,1,fim_som_quicar
				som_quicar:
				li $v0,31
				li $a0, 55	
				li $a1, 1000
				li $a2, 32
				li $a3, 126
				syscall
				fim_som_quicar:
				
				#beq $t8,6,ignorar_quicada_horiz
				#beq $t8,35,ignorar_quicada_horiz
				
			bne $t5,1,fim_paredes
			
			la $t2,velo_x
			lw $t1,($t2)
			mul $t1,$t1,-1			#inverter a direção do movimento, mesma velocidade para o lado contrário, ja que quicou
			sw $t1,($t2)
			
			la $t2,coord_x
			lw $t3,($t2)
			add $t3,$t3,$t1			#desfazer o movimento onde quicou (AS 4 NAO E NECESSARIA SE USAR 'TALVEZ_COORD')
			sw $t3,($t2)
			fim_paredes:
			
				#ignorar_quicada_horiz:
			
				#beq $t8,15,ignorar_quicada_horiz
				#beq $t8,14,ignorar_quicada_horiz
				
			bne $t6,1,fim_superficies
			
			la $t2,velo_y
			lw $t1,($t2)
			mul $t1,$t1,-1
			sw $t1,($t2)
			
			la $t2,coord_y
			lw $t4,($t2)
			add $t4,$t4,$t1		#desfazer o movimento onde quicou (AS 4 NAO E NECESSARIA SE USAR 'TALVEZ_COORD')
			sw $t4,($t2)
			fim_superficies:
				#ignorar_quicada_verti:
			
		jr $ra

	# -----------------------------------------------------------------------------------------
	
	main:			#OTIMIZAR IMPRESSAO.. TESTAR..
	
		jal spawn
		jal desenhar_obstaculos
		
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
			
				jal atualizar
				jal quicar
			
			la $t0,cor_fundo
			lw $t0,0($t0)
			
				lw $t2,efeito_5d
				beq $t2,1,sem_apagar
			
			#jal atualizar
			
			jal desenhar_bola
				sem_apagar:
			
			j loop_principal
