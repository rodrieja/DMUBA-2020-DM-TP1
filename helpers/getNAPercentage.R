getNAPercentage <- function(dataFrame) {
  nRow = nrow(dataFrame)
  finalDF = data.frame()
  
  for (colName in names(dataFrame)) {
    percentage = 0
    nas = table(is.na(dataFrame[colName]))
    
    if (isTRUE(nas["TRUE"] > 0)) {
      percentage = nas["TRUE"] / nRow * 100
    }
    
    auxDF = data.frame(attribute=colName, percentage=percentage)
    
    finalDF = rbind(finalDF, auxDF)
  }
  
  finalDF
}
