if (!require(BiocManager)) install.packages('BiocManager', repos='https://www.stats.bris.ac.uk/R/')

if (!require(DirichletMultinomial)) BiocManager::install("DirichletMultinomial")

if (!require(optparse)) install.packages('optparse', repos='https://www.stats.bris.ac.uk/R/')

if (!require(tidyverse)) install.packages('tidyverse', repos='https://www.stats.bris.ac.uk/R/')

if (!require(devtools)) install.packages("devtools", repos='https://www.stats.bris.ac.uk/R/')

library(devtools)
install_github("RHReynolds/RNAseqProcessing")

if (!requireNamespace("Biostrings", quietly = TRUE)) BiocManager::install("Biostrings")

if (!requireNamespace("tximport", quietly = TRUE)) BiocManager::install("tximport")

if (!requireNamespace("DESeq2", quietly = TRUE)) BiocManager::install("DESeq2")
