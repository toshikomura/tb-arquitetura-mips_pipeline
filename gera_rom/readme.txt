
- programe no assembly do mips o arquivo prog.asm
- execute o script gera_rom.sh atraves do comando (no diretorio corrente): 
		
		./generate_rom.py prog.asm 

O script gera o arquivo rom32.vhd que deve ser movido para o diretorio contendo
o arquivo vhdl do caminho de dados do mips, mips_pipeline.vhd, e compilado com
o ghdl.


Este diretorio contem:

	compl_num - executavel que converte um numero inteiro para binario.
                    Usado principalmente para gerar numeros negativos em
                    complemento de 2.
	compl_num.c - arquivo fonte do executavel anterior
	generate_line_rom.sh - converte uma instrucao para binario
	generate_rom.py - executa o script anterior para todas as linhas do
                          arquivo assembly fonte e monta o restante do arquivo
                          rom32.vhd
	prog.asm - sugestao de arquivo fonte em assembly. Esse arquivo deve
                   passado como argumento para o script anterior para gerar
                   o rom32.vhd.
	readme.txt - este arquivo
	rom_bottom.txt - parte constante abaixo do arquivo rom32.vhd
	rom_middle.txt - parte onde sao colocadas as instrucoes convertidas
                         para binario.
	rom_up.txt - parte constante acima do arquivo rom32.vhd
