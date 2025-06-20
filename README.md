# Trabalho Sistemas digitais FPU

Lucas Bianchessi
Matricula: 23104249

2+3+1+0+4+2+4+9+0 = 25
X = (8+1) =9
Y = (31-9)=22

reset esta com negedge para o sistema ser reiniciado em LOW

Abaixo a descricao dafuncionalidade de cada estado:

## INIT

Recebe op_A_in e op_B_in e o particiona da seguinte forma: [31] = sinal, [30:22] = expoente e [21:0] = mantissa(todos os indices são inclusivos). Importante ressaltar que o registrador ultilizado para a mantissa e dois bits maior que o de entrada, sendo um dos bits adiocionados para receber o 1 extra que vem com o padrao da IEEE e o outro para facilitar em casos de overflow. Tambem quando alguma das mantissas e o expoente for zero o numero e considerado zero e o outro e enviado como resultado.

A parte mais relevante para o calculo deste estado e que ele indentifica o menor expoente e muda o estado de acordo, caso o expoente for igual ele envia direto para o estado SUM

## SHIFT_UP_

Um shift para direita, foi chamado de SHIFT_UP porque ele aumenta o expoente ate ficar igual ao expoente maior. Tambem antes de cada shift e verificado o bit menos significativo, caso for 1 status_out recebe a indicacao de INEXACT e UNDERFLOW(0011).

## SUM

A partir de um xor com ambos os sinais e separado em uma soma ou uma subtracao das mantissas. Em caso de soma se verifica o ultimo bit (colocado extra com este proposito) caso aceso incrementa um no expoente e se faz um shift para a direita pois a atribuicao assume que o bit final esta no segundo bit (da esquerda para a direita) este bit entao e ignorado como de acordo com padrao da IEEE, caso o shift realizado remova um bit aceso o sinal de UNDErFLOW e aceso da mesma maneira que foi sitada acima.
No caso de uma subtracao, subtrai-se o menor numero do maior e salva o sinal do maior e entao troca para o estado FIND_ONE, caso for igual sinaliza que o resultado e zero e troca o estado para o INIT.

## FIND_ONE

Fica em loop realizando shifts para a direita(e subtrai o expoente) ate encontrar um 1 no segundo bit mais significativo entao discarta os dois mais significativos e atribui o resto para a mantissa_out.
# FPU
