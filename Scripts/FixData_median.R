FixData_median<-function(df,subs)
{
  ##df: dataset to fix
  ##subs: flle with substitutions
  
  # Replace spaces with underscore character in the column ExonicFunc.refGene
  df$ExonicFunc.refGene<-gsub(" ","_",df$ExonicFunc.refGene,fixed=TRUE)

  # Create new variable Type by combining Func.refGene and ExonicFunc.refgene, Replace NA values and adjust column names
  df$Type<-paste(df$Func.refGene,df$ExonicFunc.refGene,sep=".")
  
  # Replace the string "\\x3b" with "\x3b" in the "Type" column 
  df$Type<-gsub("\\x3b","\x3b",df$Type,fixed=TRUE)
  
  # Replace "-" with NA in the MutPred_score column and convert it to numeric
  df$MutPred_score[which(df$MutPred_score=="-")]<-NA
  df$MutPred_score<-as.numeric(df$MutPred_score)

  # Adjust column names 
  colnames(df)[which(colnames(df)=="GERP.._RS")]<-"GERP++_RS"
  colnames(df)[which(colnames(df)=="GERP.._RS_rankscore")]<-"GERP++_RS_rankscore"
  colnames(df)[which(colnames(df)=="M.CAP_pred")]<-"M-CAP_pred"
  colnames(df)[which(colnames(df)=="M.CAP_score")]<-"M-CAP_score"
  colnames(df)[which(colnames(df)=="fathmm.MKL_coding_pred")]<-"fathmm-MKL_coding_pred"
  colnames(df)[which(colnames(df)=="fathmm.MKL_coding_score")]<-"fathmm-MKL_coding_score"
  colnames(df)[which(colnames(df)=="Eigen.PC.raw")]<-"Eigen-PC-raw"
  colnames(df)[which(colnames(df)=="Eigen.raw")]<-"Eigen-raw"
  
  # create dichotomize variables (binary variables)
  df_1<-df %>% 
    mutate(CLNDN_dicotomize=ifelse((CLNDN=="not_provided" | is.na(CLNDN)),0,1)) %>%
    mutate(CLNREVSTAT=ifelse(is.na(CLNREVSTAT),0,CLNREVSTAT))
  
  ##### List of scores to fix for their NA values 
  scores<-c("AF","phyloP100way_vertebrate","phyloP20way_mammalian",
            "phastCons100way_vertebrate","phastCons20way_mammalian",
            "SiPhy_29way_logOdds","GERP++_RS",
            "integrated_confidence_value","integrated_fitCons_score",
            "LRT_score","M-CAP_score","MetaLR_score","MutPred_score",
            "GenoCanyon_score","MutationTaster_score","SIFT_score",
            "fathmm-MKL_coding_score","FATHMM_score","MetaSVM_score",
            "MutationAssessor_score","PROVEAN_score")
  
  # Loop through each unique Type in the dataset
  for (t in unique(df_1$Type))
  {
    k<-which(subs$Type==t)
    if(length(k)>0){
      # If substitutions are found for the type, replace NA values in the scores with those from subs
	for (el in scores)
	{
	  df_1[which(is.na(df_1[,el]) & df_1$Type==t),el]<-subs[k,el]
	}
    }else{
      # If no substitutions are found, set the scores to "NA"
	df_1[which(is.na(df_1[,el]) & df_1$Type==t),el] = NA
    }
  }
  # Return modified dataframe
  return(df_1)
}
