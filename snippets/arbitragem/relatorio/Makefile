LU_MASTERS = relatorio

# Regras que não geram arquivos de mesmo nome
.PHONY: default clean

default: pdf

clean ::
	@$(RM) -v $(addsuffix .dvi,$(LU_MASTERS)) \
		  $(addsuffix .dvi.mk,$(LU_MASTERS)) \
		  $(addsuffix .dvi_FAILED,$(LU_MASTERS)) \
		  $(addsuffix .dvi_NEED_REBUILD,$(LU_MASTERS)) \
		  $(addsuffix .pdf,$(LU_MASTERS)) \
		  $(addsuffix .pdf.mk,$(LU_MASTERS)) \
		  $(addsuffix .pdf_FAILED,$(LU_MASTERS)) \
		  $(addsuffix .pdf_NEED_REBUILD,$(LU_MASTERS)) \
		  $(addsuffix .ps,$(LU_MASTERS)) \
		  $(addsuffix .djvu,$(LU_MASTERS)) \
		  $(addsuffix .aux,$(LU_MASTERS)) \
		  $(addsuffix .aux.orig,$(LU_MASTERS)) \
		  $(addsuffix .bbl,$(LU_MASTERS)) \
		  $(addsuffix .blg,$(LU_MASTERS)) \
		  $(addsuffix .toc,$(LU_MASTERS)) \
		  $(addsuffix .ent,$(LU_MASTERS)) \
		  $(addsuffix .log,$(LU_MASTERS))

# Ferramenta para compilar documentos LaTeX
include LaTeX.mk

# Regra pra gerar o documento em formato djvu
# (djvu não é uma regra padrão do Makefile.)
djvu: pdf
        @if test $$(which pdf2djvu) != ""; then pdf2djvu -q $(LU_MASTERS).pdf \
        --output=$(LU_MASTERS).djvu; fi
