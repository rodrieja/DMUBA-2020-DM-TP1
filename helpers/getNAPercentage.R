# Devuelve % de NA por columnas de un dataFrame

getNAPercentage <- function(dataFrame) {
  nRow = nrow(dataFrame)
  finalDF = data.frame()
  
  for (colName in names(dataFrame)) {
    percentage = 0
    nas = sum(is.na(dataFrame[colName]))
    
    if (nas > 0) {
      percentage = nas / nRow * 100
    }
    
    auxDF = data.frame(attribute = colName, percentage = percentage)
    
    finalDF = rbind(finalDF, auxDF)
  }
  
  finalDF
}
