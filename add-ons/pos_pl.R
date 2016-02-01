positionsPL <- function() {
  apply(open_positions, 1, function(op) {
    allSeries[epoch, op$instrument_id] / allSeries[op$epoch, op$instrument_id] - 1
  })
}

positionEvolution <- function(i) {
  allSeries[open_positions$epoch[i]:epoch, open_positions[i]$instrument_id] /
    allSeries[open_positions$epoch[i], open_positions[i]$instrument_id] - 1
}