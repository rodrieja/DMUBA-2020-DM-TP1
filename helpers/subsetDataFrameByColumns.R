subsetDataFrameByColumns <- function(dataFrame, columns) {
  attributes = names(dataFrame)[names(dataFrame) %in% columns]
  
  dataFrame[attributes]
}