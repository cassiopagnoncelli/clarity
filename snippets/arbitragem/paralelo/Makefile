# especifique o número de threads limite, ou use 0 para usar o máximo de
# threads possível.
NUMERO_DE_THREADS = 0

# imprimir tabela de adjacências se e somente se TBL_ADJ = 1.
TBL_ADJ = 1

# flags
CC     = @gcc
CFLAGS = -DTHREADS=$(NUMERO_DE_THREADS) -DIMPR_TBL=$(TBL_ADJ) -lm -fopenmp -g \
	-ggdb -Wall -Wextra -Wformat -Wdeprecated -Wdeprecated-declarations \
	-Wdiv-by-zero -Winline -Woverflow -Woverlength-strings -Wlogical-op \
	-Wpragmas -Wshadow -Wredundant-decls -Wstrict-aliasing \
	-Wstrict-overflow -Wundef -Wunknown-pragmas -Wswitch -Wswitch-default \
	-Wswitch-enum -Wcast-align -Wcast-qual -Wconversion

# regras que não geram executável de mesmo nome
.PHONY: clean

arbitragem: arbitragem.c

clean:
	@$(RM) -v arbitragem
