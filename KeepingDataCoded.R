library(tidyr)
#Data Directory
setwd(dir = "../Projet/data_project/")

#Load data

#Total death attribuable to environement
TotalDeathEnvironment=read.table("Total.csv", sep = ";", header = TRUE)
#keep only Total for each country (and his WHO region also)
TotalNumber= subset(TotalDeathEnvironment, TotalDeathEnvironment$ENVCAUSE..code.=="ENVCAUSE000", select=c("REGION..code.", "COUNTRY..code.", "TOTENV_5..numeric."))

#ambiant & household air pollution: Mortality attributable to joint effects of household and ambient air pollution
AirPollution=read.table("Air.csv", sep=";", header = TRUE)
#keep only Total for both sexes
AirNumber=subset(AirPollution, AirPollution$SEX..code.=="BTSX" & AirPollution$ENVCAUSE..code.=="ENVCAUSE000", select = c("COUNTRY..code.", "SDGAIRBOD..numeric."))

#Merge data
Total.Air=merge(TotalNumber, AirNumber, by="COUNTRY..code.", all=TRUE)

#Chemicals: Mortality rate attribuating to unentationel poisoning (per 100 000 hab.)
Chemicals=read.table("Chemicals.csv", sep=";", header = TRUE)
#keep only Total for both sexes
ChemicalsNumber=subset(Chemicals, Chemicals$SEX..code.=="BTSX")

#2015
ChemicalsNumber2015=subset(ChemicalsNumber, ChemicalsNumber$YEAR..code.=="2015", select = c("COUNTRY..code.", "SDGPOISON..numeric."))
#2016
ChemicalsNumber2016=subset(ChemicalsNumber, ChemicalsNumber$YEAR..code.=="2016", select = c("COUNTRY..code.", "SDGPOISON..numeric."))

#union2015.16=merge(ChemicalsNumber2015, ChemicalsNumber2016, by=c("COUNTRY..code."), all = FALSE )

#merge data from 2016 and 2015
#chemicals2015.16=merge(ChemicalsNumber2016, ChemicalsNumber2015 , by=c("COUNTRY..code.", "SDGPOISON..numeric.") , all = TRUE)

#Merge data
Total.Air.Chemicals=merge(Total.Air, ChemicalsNumber2016, by="COUNTRY..code.", all = TRUE)

#Water Pollution: Mortality rate to unsafe water, sanitation and hygiene. 
WaterPollution=read.table("Waterpollution.csv", sep=";", header = TRUE)
#keep only mortality
WaterNumber=subset(WaterPollution, WaterPollution$SDGWSHBOD..numeric. != "", select = c("COUNTRY..code.", "SDGWSHBOD..numeric."))

#Merge data
Total.Air.Chemicals.Water=merge(Total.Air.Chemicals, WaterNumber, by="COUNTRY..code.", all = TRUE)

#UV exposure: Mortality attribuable to UV exposure
UV=read.table("UV.csv", sep=";", header = TRUE)
#keep only mortality
UVNumber=subset(UV, select = c("COUNTRY..code.","UV_4..numeric."))

#merged data
Total.Air.Chemicals.Water.UV=merge(Total.Air.Chemicals.Water, UVNumber, by="COUNTRY..code.", all=TRUE)

## Add Country and Region code
CodeCorr=read.table("Country.csv", sep=";", header = TRUE, fill = TRUE )
CountryCode=subset(CodeCorr, select = c("X...Code", "DisplayValue", "WHO_REGION","World.Bank.income.group"))

Total.Air.Chemicals.Water.UV=merge(Total.Air.Chemicals.Water.UV, CountryCode, by.x = "COUNTRY..code.", by.y = "X...Code", all = TRUE)


colnames(Total.Air.Chemicals.Water.UV)=c("country_code", "region_code", "PourcentDeathAttribuableEnv", "Per100000AirPol", "Per100000Chemi", "Per100000Water", "Per100000UV", "country_name", "region_name", "WorldBankincome" )

write.csv(Total.Air.Chemicals.Water.UV, 'data.csv')

#new array for matrix

AirPollution<- subset(Total.Air.Chemicals.Water.UV, select = c("Per100000AirPol", "country_name","region_code" ))
AirPollution=AirPollution %>% drop_na(Per100000AirPol)
AirPollution$Name<- "AirPollution"
colnames(AirPollution)<- c("Value", "country_name","continent", "Name")

WaterPollution <- subset(Total.Air.Chemicals.Water.UV, select = c("Per100000Water", "country_name", "region_code" ))
WaterPollution=WaterPollution %>% drop_na(Per100000Water)
WaterPollution$Name<- "WaterPollution"
colnames(WaterPollution)<- c("Value", "country_name","continent", "Name")

ChemiPollution <- subset(Total.Air.Chemicals.Water.UV, select = c("Per100000Chemi", "country_name", "region_code" ))
ChemiPollution=ChemiPollution %>% drop_na(Per100000Chemi)
ChemiPollution$Name<- "ChemicalPollution"
colnames(ChemiPollution)<- c("Value", "country_name","continent", "Name")

UVExposition <- subset(Total.Air.Chemicals.Water.UV, select = c("Per100000UV", "country_name", "region_code" ))
UVExposition=UVExposition %>% drop_na(Per100000UV)
UVExposition$Name <- "UVExposition"
colnames(UVExposition)<- c("Value", "country_name","continent", "Name" )

MatrixArray=rbind(UVExposition,ChemiPollution,WaterPollution,AirPollution)
MatrixArray=MatrixArray %>% drop_na(country_name)
write.csv(MatrixArray, 'data_matrix.csv')


