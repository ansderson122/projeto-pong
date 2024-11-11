
# Projeto Pong 

Este projeto implementa uma versão básica do jogo Pong em Assembly para a arquitetura RISC-V, utilizando o simulador Logisim Evolution. Durante o desenvolvimento, construímos um circuito usando componentes do Logisim Evolution, incluindo um processador RISC-V, memórias, barramento SoC, dispositivos de entrada/saída, e uma tela RGB. Explicaremos em detalhes cada um desses componentes nas próximas seções. Este projeto foi realizado como parte da disciplina de Arquitetura de Computadores de Alto Desempenho da UFCA.

O projeto pode ser dividido em duas partes: a parte física e a parte de software. A parte física foi desenvolvida no Logisim Evolution e corresponde aos circuitos utilizados. Já a parte de software foi implementada em Assembly para RISC-V, abrangendo desde a lógica do jogo até o sistema de interação com os componentes físicos, permitindo que o jogo seja desenhado e exibido na tela RGB.

## Parte física 

O Logisim Evolution possui diversos circuitos já implementados. Dentre eles, utilizamos um `processador RISC-V`, `memórias`, `barramento SoC`, `dispositivos de entrada/saída`, e uma `tela RGB`. Detalharemos melhor cada um desses componentes nesta seção.

### Prcessador RISC-V
O núcleo do projeto, responsável por executar o código em Assembly e controlar as operações do jogo Pong. O processador é configurado para gerenciar as movimentações e colisões da bola e das raquetes, e interagir com outros componentes do circuito.

### Memória

A memória armazenam tanto o código Assembly (instruções do jogo) quanto os dados necessários durante a execução, como a posição da bola. Dividimos as memórias entre memória de instruções (para o código do jogo) e memória de video (para o armazenamento o possição da bola e seu vetor direção).

### Barramento SoC
O Barramento SoC funciona como um sistema de comunicação entre o processador e os demais componentes, como memórias e dispositivos de entrada/saída. Cada dispositivo possui um endereço em hexadecimal. Abaixo está uma tabela com todos os endereços utilizados:

#### Tabela 1
| Endereço inicial | Endereço final | Nome do comoponente|
|------------------|----------------|--------------------|
| 0x0              | 0x3ff          | Memoria_de_intrucao|
| 0x400            | 0x417          | Saida_x            |
| 0x418            | 0x42f          | Saida_y            |
| 0x430            | 0x447          | Reset              |
| 0x448            | 0x45f          | Escrita            |
| 0x460            | 0x477          | Cor                |
| 0x478            | 0x877          | Memoria_de_video   |
| 0x878            | 0x88f          | Controle           |

### Dispositivos de entrada/saída
Os dispositivos de entrada/saída recebem dados das interações do usuário e enviam informações ao processador, além de receberem dados do processador para envio à tela RGB, onde serão exibidos.

Os dispositivos Saída_x, Saída_y, Reset, Escrita, Cor e Controle, listados na Tabela 1, são dispositivos de entrada/saída:

- Saída_x e Saída_y: Definem as coordenadas X e Y para indicar onde o pixel será desenhado na tela.

- Reset: Limpa a tela, apagando todo o conteúdo atual.

- Escrita: Habilita a escrita na tela; a escrita ocorre somente durante o pulso de clock, caso o bit de escrita esteja ativado.

- Cor: Define a cor do pixel que será desenhado na tela.  

### Tela RGB
A tela RGB exibe o jogo Pong em tempo real, renderizando a bola e as raquetes com base nos dados dos dispositivos de entrada/saída. A tela utilizada tem uma resolução de 32x64 pixels e 8 bits para representar cores. A tela não se conecta diretamente ao barramento SoC; para desenhar um pixel, o processador precisa interagir primeiro com os dispositivos de entrada/saída.

A tela recebe as coordenadas X e Y, um bit para habilitar a escrita, um bit de reset, 8 bits para definir a cor, além dos sinais de clock e enable.

## Parte de Software
O software foi desenvolvido em Assembly para RISC-V e pode ser dividido nas seguintes partes: inicialização, movimentação do jogador, movimento da bola e movimento da IA.

Para melhorar o desempenho, reservamos alguns registradores para funções específicas que não são reutilizadas para outras finalidades durante a execução do código. A alocação desses registradores está apresentada na tabela abaixo:

|Registrador|	Função|
|-----------|---------|
|`tp`         |	Armazena o endereço do controle|
|`t6`         |	Armazena a cor branca|
|`t3`         |	Armazena a posição Y do jogador|
|`t4`         |	Armazena a posição Y da IA|
|`t5`         |   ------|

O endereço do Controle foi armazenado em tp, pois é um valor muito grande para ser carregado diretamente em um registrador.

### Inicialização

A primeira etapa é definir parâmetros essenciais para o funcionamento do jogo Pong. Em Assembly RISC-V, o comando .equ (equivalente) permite associar constantes a endereços de memória ou valores, facilitando o entendimento e a manutenção do código. Cada um desses parâmetros é utilizado para configurar a posição e o comportamento de elementos na tela, como a bola e as raquetes dos jogadores. Abaixo está o codigo para desses parâmetros:


   <style>
        .code-block {
            border: 1px solid #ddd;
            padding: 10px;
            overflow-x: auto;
            font-family: monospace;
            color: #fff;
        }
        .text{color:#f4f4f4; }
        .comment { color: #6a737d; }
        .directive { color: #d73a49; }
        .number { color: #005cc5; }
    </style>

<pre class="code-block">
<code>
<span class="directive">.equ</span> <span class="text">saida_x</span> <span class="number">0x400</span>
<span class="directive">.equ</span> <span class="text">saida_y</span> <span class="number">0x418</span>
<span class="directive">.equ</span> <span class="text">resetTela</span> <span class="number">0x430</span>
<span class="directive">.equ</span> <span class="text">escritaTela</span> <span class="number">0x448</span>
<span class="directive">.equ</span> <span class="text">corTela</span> <span class="number">0x460</span>
<span class="directive">.equ</span> <span class="text">memoria_de_video</span> <span class="number">0x478</span>
<span class="directive">.equ</span> <span class="text">velocidadePlayer</span> <span class="number">1</span>

<span class="directive">.equ</span> <span class="text">posicao_bola</span> <span class="number">0x478</span> <span class="comment"># endereço da posição da bola</span>
<span class="directive">.equ</span> <span class="text">vetor_direcao</span> <span class="number">0x480</span>

<span class="directive">.equ</span> <span class="text">tamanho_tela_y</span> <span class="number">32</span>
<span class="directive">.equ</span> <span class="text">tamanho_tela_x</span> <span class="number">64</span>
<span class="directive">.equ</span> <span class="text">altura_players</span> <span class="number">5</span> <span class="comment"># altura de -5 a +5</span>
<span class="directive">.equ</span> <span class="text">largura_players</span> <span class="number">1</span>
<span class="directive">.equ</span> <span class="text">centro_players</span> <span class="number">17</span>
<span class="directive">.equ</span> <span class="text">distacia_bordaX_tela_player</span> <span class="number">5</span>
</code>
</pre>
Parâmetros de Saída e Controle:
- .equ saida_x 0x400 e .equ saida_y 0x418: Esses são os endereços na memória usados para definir as coordenadas x e y de saída dos pixels na tela.
- .equ resetTela 0x430: Define o endereço usado para resetar (limpar) a tela.
- .equ escritaTela 0x448: Controla o estado de escrita na tela. Se ativado, permite que novos pixels sejam desenhados durante um pulso de clock.
- .equ corTela 0x460: Define o endereço de memória que armazena a cor do pixel a ser desenhado.
- .equ memoria_de_video 0x478: Representa o endereço inicial da memória de vídeo, onde os dados de exibição são armazenados.

Parâmetros do Jogo:
- .equ velocidadePlayer 1: Define a velocidade de movimento da raquete do jogador.
- .equ posicao_bola 0x478: Endereço de memória que armazena a posição da bola. O eixo x começa no endereço 0x478 e o eixo y vai até 0x47c.
- .equ vetor_direcao 0x480: Define o vetor de direção da bola, indicando o sentido de movimento no eixo x e y.

Parâmetros da Tela:
- .equ tamanho_tela_y 32 e .equ tamanho_tela_x 64: Configuram o tamanho da tela em pixels no eixo vertical (y) e horizontal (x).

Parâmetros dos Jogadores:
- .equ altura_players 5: Define a altura da raquete dos jogadores, que vai de -5 a +5 a partir do centro da raquete.
- .equ largura_players 1: Define a largura da raquete dos jogadores.
- .equ centro_players 17: Define a posição inicial central das raquetes.
- .equ distacia_bordaX_tela_player 5: Especifica a distância entre a borda da tela e a raquete do jogador, mantendo-a a uma distância segura para melhorar a jogabilidade.

#### Desenho da raquete

<pre class="code-block">
<code>
<span class="directive">li</span> <span class="number">a1</span>,<span class="number">0</span>
<span class="directive">li</span> <span class="number">t0</span>,<span class="number">largura_players</span>
<span class="directive">addi</span> <span class="number">t0</span>,<span class="number">t0</span>,<span class="number">distacia_bordaX_tela_player</span>
<span class="directive">li</span> <span class="number">s8</span>,<span class="number">distacia_bordaX_tela_player</span> <span class="comment"># posição x do jogador</span>
<span class="directive">li</span> <span class="number">a6</span>,<span class="number">altura_players</span>

<span class="text">begin_for_i:</span>
<span class="directive">bge</span> <span class="number">s8</span>,<span class="number">t0</span>,<span class="text">end_for_i</span>	
<span class="directive">addi</span> <span class="number">t1</span>,<span class="number">t3</span>,<span class="number">altura_players</span>
<span class="directive">sub</span> <span class="number">s9</span>,<span class="number">t3</span>,<span class="number">a6</span> <span class="comment"></span>

<span class="text">begin_for_j:</span>
<span class="directive">bge</span> <span class="number">s9</span>,<span class="number">t1</span>,<span class="text">end_for_j</span>
<span class="directive">sw</span> <span class="number">s8</span>, <span class="number">saida_x</span>(<span class="number">zero</span>) <span class="comment"># = 0x400 + 0</span>
<span class="directive">sw</span> <span class="number">s9</span>, <span class="number">saida_y</span>(<span class="number">zero</span>)
<span class="directive">sw</span> <span class="number">s7</span>, <span class="number">escritaTela</span>(<span class="number">zero</span>) <span class="comment"></span>
<span class="directive">addi</span> <span class="number">s9</span>,<span class="number">s9</span>,<span class="number">1</span>
<span class="directive">j</span> <span class="text">begin_for_j</span>
<span class="text">end_for_j:</span>
<span class="directive">addi</span> <span class="number">s8</span>,<span class="number">s8</span>,<span class="number">1</span>
<span class="directive">j</span> <span class="text">begin_for_i</span>
<span class="text">end_for_i:</span>
<span class="directive">bge</span> <span class="number">a1</span>,<span class="number">s7</span>,<span class="text">inicializacao_bola</span>
<span class="directive">addi</span> <span class="number">a1</span>,<span class="number">a1</span>,<span class="number">1</span>
<span class="directive">li</span> <span class="number">s8</span>, <span class="number">distacia_bordaX_tela_player</span>
<span class="directive">li</span> <span class="number">t0</span>, <span class="number">tamanho_tela_x</span>
<span class="directive">sub</span> <span class="number">s8</span>,<span class="number">t0</span>,<span class="number">s8</span> <span class="comment"># distacia_bordaX_tela_player - tamanho_tela_x</span>
<span class="directive">li</span> <span class="number">t0</span>,<span class="number">largura_players</span>
<span class="directive">add</span> <span class="number">t0</span>,<span class="number">t0</span>,<span class="number">s8</span>
<span class="directive">j</span> <span class="text">begin_for_i</span>
</code>
</pre>

#### Desenho da bola

<pre class="code-block">
<code>
<span class="text">inicializacao_bola:</span>
<span class="directive">li</span> <span class="number">a1</span>, <span class="number">16</span> <span class="comment"># posição inicial y da bola</span>
<span class="directive">li</span> <span class="number">a2</span>, <span class="number">32</span> <span class="comment"># posição inicial x da bola</span>

<span class="directive">sw</span> <span class="number">a2</span>,<span class="number">posicao_bola</span>(<span class="number">zero</span>)
<span class="directive">li</span> <span class="number">a3</span>,<span class="number">4</span>
<span class="directive">sw</span> <span class="number">a1</span>,<span class="number">posicao_bola</span>(<span class="number">a3</span>)

<span class="directive">sw</span> <span class="number">a2</span>, <span class="number">saida_x</span>(<span class="number">zero</span>)
<span class="directive">sw</span> <span class="number">a1</span>, <span class="number">saida_y</span>(<span class="number">zero</span>)
<span class="directive">li</span> <span class="number">s7</span>,<span class="number">1</span>
<span class="directive">sw</span> <span class="number">s7</span>, <span class="number">escritaTela</span>(<span class="number">zero</span>)

<span class="directive">sw</span> <span class="number">s7</span>,<span class="number">vetor_direcao</span>(<span class="number">zero</span>)
<span class="directive">sw</span> <span class="number">s7</span>,<span class="number">vetor_direcao</span>(<span class="number">a3</span>)
</code>
</pre>

### Movimentação do jogador

<pre class="code-block">
<code>
<span class="text">pressButton:</span> 
<span class="directive">li</span> <span class="number">s7</span>,<span class="number">1</span>
<span class="directive">lw</span> <span class="number">a0</span>, <span class="number">0</span>(<span class="number">tp</span>)
<span class="directive">sw</span> <span class="number">s7</span>,<span class="number">0</span>(<span class="number">tp</span>)
<span class="directive">beq</span> <span class="number">a0</span>, <span class="number">zero</span>, <span class="text">fim_pressButton</span>
<span class="directive">addi</span> <span class="number">a0</span>,<span class="number">a0</span>, <span class="number">-1</span>
<span class="directive">beq</span> <span class="number">a0</span>, <span class="number">zero</span>, <span class="text">moveParaBaixo</span>
<span class="directive">addi</span> <span class="number">a0</span>,<span class="number">a0</span>, <span class="number">-1</span>
<span class="directive">beq</span> <span class="number">a0</span>, <span class="number">zero</span>, <span class="text">moveParaCima</span>
<span class="text">fim_pressButton:</span>
<span class="directive">jr</span> <span class="number">ra</span> 

<span class="text">moveParaCima:</span>
<span class="directive">sw</span> <span class="number">s7</span>,<span class="number">0</span>(<span class="number">tp</span>)
<span class="directive">li</span> <span class="number">a3</span>, <span class="number">distacia_bordaX_tela_player</span>
<span class="directive">li</span> <span class="number">a1</span>,<span class="number">altura_players</span>
<span class="directive">sub</span> <span class="number">a4</span>,<span class="number">t3</span>, <span class="number">a1</span>
<span class="directive">add</span> <span class="number">a1</span>,<span class="number">t3</span>, <span class="number">a1</span>
<span class="directive">bge</span> <span class="number">zero</span>,<span class="number">a4</span>,<span class="text">fim_pressButton</span>
<span class="directive">li</span> <span class="number">a5</span>, <span class="number">1</span>

<span class="text">moveParaCima_i:</span>
<span class="directive">beq</span> <span class="number">a5</span>,<span class="number">zero</span>, <span class="text">moveParaCima_i_fim</span>
<span class="directive">sw</span> <span class="number">t6</span>, <span class="number">corTela</span>(<span class="number">zero</span>)
<span class="directive">sw</span> <span class="number">a3</span>, <span class="number">saida_x</span>(<span class="number">zero</span>)
<span class="directive">sw</span> <span class="number">a4</span>, <span class="number">saida_y</span>(<span class="number">zero</span>)
<span class="directive">sw</span> <span class="number">s7</span>, <span class="number">escritaTela</span>(<span class="number">zero</span>)
<span class="directive">addi</span> <span class="number">a5</span>,<span class="number">a5</span>,<span class="number">-1</span>
<span class="directive">sw</span> <span class="number">zero</span>, <span class="number">corTela</span>(<span class="number">zero</span>)
<span class="directive">sw</span> <span class="number">a3</span>, <span class="number">saida_x</span>(<span class="number">zero</span>)
<span class="directive">sw</span> <span class="number">a1</span>, <span class="number">saida_y</span>(<span class="number">zero</span>)
<span class="directive">sw</span> <span class="number">s7</span>, <span class="number">escritaTela</span>(<span class="number">zero</span>)
<span class="directive">addi</span> <span class="number">a3</span>,<span class="number">a3</span>,<span class="number">1</span>
<span class="directive">j</span> <span class="text">moveParaCima_i</span>
<span class="text">moveParaCima_i_fim:</span>
<span class="directive">addi</span> <span class="number">t3</span>,<span class="number">t3</span>,<span class="number">-1</span>
<span class="directive">addi</span> <span class="number">a1</span>,<span class="number">a1</span>,<span class="number">-1</span>
<span class="directive">sw</span> <span class="number">zero</span>, <span class="number">saida_x</span>(<span class="number">zero</span>)
<span class="directive">sw</span> <span class="number">zero</span>, <span class="number">saida_y</span>(<span class="number">zero</span>)
<span class="directive">jr</span> <span class="number">ra</span>

<span class="text">moveParaBaixo:</span>
<span class="directive">sw</span> <span class="number">s7</span>,<span class="number">0</span>(<span class="number">tp</span>)
<span class="directive">li</span> <span class="number">a3</span>, <span class="number">distacia_bordaX_tela_player</span>
<span class="directive">li</span> <span class="number">a1</span>,<span class="number">altura_players</span>
<span class="directive">add</span> <span class="number">a4</span>,<span class="number">t3</span>, <span class="number">a1</span>
<span class="directive">sub</span> <span class="number">a1</span>,<span class="number">t3</span>, <span class="number">a1</span>
<span class="directive">li</span> <span class="number">a5</span>, <span class="number">tamanho_tela_y</span>
<span class="directive">addi</span> <span class="number">a5</span>,<span class="number">a5</span>,<span class="number">-1</span>
<span class="directive">bge</span> <span class="number">a4</span>,<span class="number">a5</span>,<span class="text">fim_pressButton</span>
<span class="directive">li</span> <span class="number">a5</span>, <span class="number">1</span>

<span class="text">moveParaBaixo_i:</span>
<span class="directive">beq</span> <span class="number">a5</span>,<span class="number">zero</span>, <span class="text">moveParaBaixo_i_fim</span>
<span class="directive">sw</span> <span class="number">t6</span>, <span class="number">corTela</span>(<span class="number">zero</span>)
<span class="directive">sw</span> <span class="number">a3</span>, <span class="number">saida_x</span>(<span class="number">zero</span>)
<span class="directive">sw</span> <span class="number">a4</span>, <span class="number">saida_y</span>(<span class="number">zero</span>)
<span class="directive">sw</span> <span class="number">s7</span>, <span class="number">escritaTela</span>(<span class="number">zero</span>)
<span class="directive">addi</span> <span class="number">a5</span>,<span class="number">a5</span>,<span class="number">-1</span>
<span class="directive">sw</span> <span class="number">zero</span>, <span class="number">corTela</span>(<span class="number">zero</span>)
<span class="directive">sw</span> <span class="number">a3</span>, <span class="number">saida_x</span>(<span class="number">zero</span>)
<span class="directive">sw</span> <span class="number">a1</span>, <span class="number">saida_y</span>(<span class="number">zero</span>)
<span class="directive">sw</span> <span class="number">s7</span>, <span class="number">escritaTela</span>(<span class="number">zero</span>)
<span class="directive">addi</span> <span class="number">a3</span>,<span class="number">a3</span>,<span class="number">1</span>
<span class="directive">j</span> <span class="text">moveParaBaixo_i</span>
<span class="text">moveParaBaixo_i_fim:</span>
<span class="directive">addi</span> <span class="number">t3</span>,<span class="number">t3</span>,<span class="number">1</span>
<span class="directive">sw</span> <span class="number">zero</span>, <span class="number">saida_x</span>(<span class="number">zero</span>)
<span class="directive">sw</span> <span class="number">zero</span>, <span class="number">saida_y</span>(<span class="number">zero</span>)
<span class="directive">jr</span> <span class="number">ra</span>
</code>
</pre>




