
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






