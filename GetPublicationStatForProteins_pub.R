#read manifest - get all proteins
library(readxl)
ProtData <- readxl::read_excel("./OlinkData.xlsx")
ProtDataCols <- names(ProtData)
ProtNamesRaw<-  ProtDataCols[6:178] # Removing meta-data columns
#grep("\\.\\.\\.",ProtNamesRaw,value = T,invert = T)
ProtNames <- ProtNamesRaw[-grep("\\.\\.\\.",ProtNamesRaw)[1:6]] # column-names that contain "..." are doublets (using multiple panels one protein might appear more than once).There are 6 doublets and hardcoded in to keep only one of them
ProtNames <- gsub("\\.\\.\\..*","",ProtNames) #removing "...*" from the doublets left 


#create link
#pmc - full text search - 8M articles
#https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pmc&term=%22enteric+glial+cells%22+il6&retmode=xml
#pubmed - only search in abstracst - 34M articles
# https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=%22enteric+glial+cells%22+il6&retmode=xml
require(XML)
require(xml2)
PMCbase <- 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pmc&term=%22enteric+glial+cells%22+%22'
Pubmedbase <- 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=%22enteric+glial+cells%22+%22'
XML_ending <- '%22&retmode=xml'
testProt <- "IL6"
PMClink <- paste0(PMCbase,testProt,XML_ending)
Pubmedlink <- paste0(Pubmedbase,testProt,XML_ending)

PMCxml <- read_xml(PMClink)
Pubmedxml <- read_xml(Pubmedlink)

#PMCdata <- xmlParse(PMCxml)
xml_text(xml_find_all(PMCxml, ".//Count"))
xml_text(xml_find_all(Pubmedxml, ".//Count"))

#BaseLink <- 'https://pubmed-ncbi-nlm-nih-gov.db.ub.oru.se/?term=%22enteric+glial+cells%22+'
xml_structure(PMCxml)
xml_find_all(PMCxml,"cou")

LitSearchRes <- c()
for (prot in ProtNames){
  print(prot)
  prot <- gsub(" ","%20",prot)
  print(prot)
  PMClink <- paste0(PMCbase,prot,XML_ending)
  Pubmedlink <- paste0(Pubmedbase,prot,XML_ending)
  PMCxml <- read_xml(PMClink)
  Pubmedxml <- read_xml(Pubmedlink)
  PMCcount <- xml_text(xml_find_all(PMCxml, ".//Count"))
  Pubmedcount <- xml_text(xml_find_all(Pubmedxml, ".//Count"))
  LitSearchRes <- rbind(LitSearchRes,c(prot,Pubmedcount,PMCcount))
}
  
colnames(LitSearchRes) <- c("Protein","AbstractSearch","FullTextSearch","FullSearchEntericGliaCells","FullSearchProtein")
LitSearchRes <- as.data.frame(LitSearchRes)
LitSearchRes[,2:5] <- apply(LitSearchRes[,2:5],2,as.numeric)

writexl::write_xlsx(LitSearchRes,path = "./LitSearch.xlsx")

#download overview page

#extract