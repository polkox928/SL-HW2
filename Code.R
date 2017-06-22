
# Read the data -----------------------------------------------------------

# Read the song's labels
labels = read.table("data/Labels.txt")
colnames(labels) = c('Labels')

# Package to read the audio files
install.packages("wrassp")
library(wrassp)


function extract.features(filename) {
  raw_file <- read.AsspDataObj(filename)
  
}