#set directory to this file location

#import the package
library(signature.tools.lib)

#set sample names
sample_names <- c("sample1","sample2")

#set the file names. 
SNV_tab_files <- c("../../tests/testthat/test_hrdetect_1/test_hrdetect_1.snv.simple.txt",
                   "../../tests/testthat/test_hrdetect_2/test_hrdetect_2.snv.simple.txt")

#name the vectors entries with the sample names
names(SNV_tab_files) <- sample_names

#load SNV data and convert to SNV mutational catalogues
SNVcat_list <- list()
for (i in 1:length(SNV_tab_files)){
  tmpSNVtab <- read.table(SNV_tab_files[i],sep = "\t",header = TRUE,check.names = FALSE,stringsAsFactors = FALSE)
  #convert to SNV catalogue, see ?tabToSNVcatalogue or ?vcfToSNVcatalogue for details
  res <- tabToSNVcatalogue(subs = tmpSNVtab,genome.v = "hg19")
  colnames(res$catalogue) <- sample_names[i]
  SNVcat_list[[i]] <- res$catalogue
}
#bind the catalogues in one table
SNV_catalogues <- do.call(cbind,SNVcat_list)

#the catalogues can be plotted as follows
plotSubsSignatures(signature_data_matrix = SNV_catalogues,plot_sum = TRUE,output_file = "SNV_catalogues.pdf")

#fit the organ-specific breast cancer signatures using the bootstrap signature fit approach
sigsToUse <- getOrganSignatures("Breast",typemut = "subs")
subs_fit_res <- SignatureFit_withBootstrap_Analysis(outdir = "signatureFit/",
                                                    cat = SNV_catalogues,
                                                    signature_data_matrix = sigsToUse,
                                                    type_of_mutations = "subs",
                                                    nboot = 100,nparallel = 4)

#The signature exposures can be found here and correspond to the median of the boostrapped runs followed by false positive filters. See ?SignatureFit_withBootstrap_Analysis for details
snv_exp <- subs_fit_res$E_median_filtered

#Convert the organ-spoecific signature exposures into reference siganture exposures
snv_exp <- convertExposuresFromOrganToRefSigs(expMatrix = snv_exp,typemut = "subs")

#write the results
writeTable(snv_exp,"RefSigSubsExposures.tsv")

