folder<-"/home/jbrenton/Regina_file_deposit"
files<-list.files(folder)

files<-files[grep("fastq.gz", files)]
# filenames<-sub("(^.*)/.*", "\\1", files)

sample_names<-c()
for (i in 1:length(files)) {
  index<-which(!is.na(str_match(files[i], meta$CaseNo)))
  sample_names[i]<-unique(meta$CaseNo[index])
}
new_files<-file.path(folder, paste0(sample_names, ".fastq.gz"))

file.copy(from = files, to = new_files)

meta[meta$CaseNo %in% sample_names, ]