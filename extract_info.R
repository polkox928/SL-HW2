#install.packages("signal")
library(wrassp)
suppressPackageStartupMessages(require(signal, quietly = TRUE))
set.seed(42)
labels = read.table("data/Labels.txt")

extract.info = function(filename) {
  raw.file = read.AsspDataObj(filename, begin = 0, end = 30 * 22050, samples = TRUE)
  
  
  # Setup for specgram
  Fs        = attributes(raw.file)$sampleRate  # Sampling rate
  winsize   = 2048                        # Time-windowing in number of samples
  hopsize   = 512                         # Windows overlap
  nfft      = 2048
  noverlap  = winsize - hopsize
  
  spectrogram = specgram(x = raw.file$audio, 
                         n = nfft, 
                         Fs = Fs, 
                         window = winsize,
                         overlap = noverlap)
  ## Power spectrum
  # Frequency bands selection
  number.of.bands = 2^3
  low.band = 100
  eps = .Machine$double.eps    # Machine precision to avoid under/overflow
  
  # Number of seconds of the analyzed window
  num.timesegm = ncol(spectrogram$S)    # number of overlapping time segments
  corrtime = 15    # number of seconds to consider
  
  # Energy of bands
  fco = round(c(0, low.band*(Fs/2/low.band)^((0:(number.of.bands-1))/(number.of.bands-1)))/Fs*nfft)
  energy = matrix(0, number.of.bands, num.timesegm)
  for (time.segment in 1:num.timesegm){
    for (i in 1:number.of.bands){
      lower.bound = 1 + fco[i]
      upper.bound = min( c( 1+ fco[i+1], nrow(spectrogram$S) ) )
      energy[i, time.segment] = sum( abs( spectrogram$S[lower.bound:upper.bound, time.segment])^2)
    }
  }
  energy[energy < eps] = eps
  energy = 10*log10(energy)
  
  feat.vec = c(energy)
  
  return(feat.vec)
}


design.matrix = matrix(data = NA, nrow = 150, ncol = length(extract.info("data/f1.au")))

for (idx in 1:150){
  filename = paste("data/f", idx, ".au", sep = "")
  feat.vec = extract.info(filename)
  design.matrix[idx, ] = feat.vec
}

data = cbind(design.matrix, labels)
colnames(data)[10305] = "labels"
# write.csv(x = data, file = 'data-matrix.csv')

