# defina 1, para imprimir tabela de adjacências do grafo; 0, caso contrário.
TBL_ADJ = 1

# flags
CC     = @gcc
CFLAGS = -DIMPR_TBL=$(TBL_ADJ) -lm -g -ggdb -Wall -Wextra -Wformat \
	-Wdeprecated -Wdeprecated-declarations -Wdiv-by-zero -Winline \
	-Woverflow -Woverlength-strings -Wlogical-op -Wpragmas -Wshadow \
	-Wredundant-decls -Wstrict-aliasing -Wstrict-overflow -Wundef \
	-Wunknown-pragmas -Wswitch -Wswitch-default -Wswitch-enum \
	-Wcast-align -Wcast-qual -Wconversion

# regras que não geram executável de mesmo nome
.PHONY: clean

arbitragem: arbitragem.c

clean:
	@$(RM) -v arbitragem
