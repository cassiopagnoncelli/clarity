# Maximise 
# 
# apply(
#   apply(
#   [
#     1 + f_1 R_11          1 + f_n R_n1
#     1 + f_1 R_12    ...   1 + f_n R_n1
#     1 + f_1 R_13          1 + f_n R_nm
#        ...                 ...
#     1 + f_1 R_1m          1 + f_n R_nm
#   ], 1, cumprod),
# 2, cumsum)
#
# with regards to f = <f_1, f_2, ..., f_n>, subject to 0 <= sum(f) <= 1.
# 
# The result is the optimal fraction of wealth to allocate into each asset
# on every new trade.
#

# Multi-asset position sizing.
kelly_criteria <- function() {}