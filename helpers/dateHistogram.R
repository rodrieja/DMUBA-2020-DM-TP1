dateHistogram <- function(values, bin = 1, x_label, y_label) {
  dateDF = data.frame(date = as.Date(values))
  bin <- bin # used for aggregating the data and aligning the labels
  
  p <- ggplot(dateDF, aes(date))
  p <- p + geom_histogram(binwidth = bin, colour="white")

  # The numeric data is treated as a date,
  # breaks are set to an interval equal to the binwidth,
  # and a set of labels is generated and adjusted in order to align with bars
  p <- p + scale_x_date(breaks = seq(min(dateDF$date), # change -20 term to taste
                                     max(dateDF$date), 
                                     bin),
                        labels = date_format("%Y-%m-%d"))
  
  # from here, format at ease
  p <- p + theme_bw() + xlab(x_label) + ylab(y_label) +
    theme(axis.text.x  = element_text(angle=45,
                                      hjust = 1,
                                      vjust = 1))
  p
}