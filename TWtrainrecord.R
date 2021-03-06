#call packages 
library(RCurl)
# date and station setting
TaiwanTime <- as.POSIXlt (Sys.time(),tz ="Asia/Taipei")
TaiwanDate <- substr(TaiwanTime,1,10)
date <- gsub(pattern = "\\-","\\/",TaiwanDate)

station <-1228
url <-character()
urlfunction<- function(date,station){
        temp<- paste("twtraffic.tra.gov.tw/twrail/mobile/StationSearchResult.aspx?searchdate=",date,"&fromstation=",station,sep="")
        url <<- temp
} 
urlfunction(date,station)

rowdata <- getURL(url = url,encoding = "UTF-8")
rowdata2 <- strsplit(rowdata,split = "script")

Train <- paste(rowdata2[[1]][10],rowdata2[[1]][12])

## clearn  Train Data
Train2 <- gsub(pattern = "TRSearchResult\\.push\\(\\'","",Train)
Train3 <- gsub(pattern = "\\'\\)","",Train2)
Train4 <- gsub(pattern = ">","",Train3)
Train5 <- gsub(pattern = "<\\/","",Train4)

Traindataclean <- strsplit(Train5,split = ";")
Traindatamatix <- matrix(Traindataclean[[1]],ncol=6, byrow=T)
# change from matrix to dataframe
Traindataframe <- as.data.frame(Traindatamatix)
# change the V3 to time frame
Traindataframe$V3 <- strptime(Traindataframe$V3,"%H:%M",tz = "Asia/Taipei")
#delete the future time
Traindataframe2 <-Traindataframe[Traindataframe$V3 < Sys.time(),]

#collect data
#Finaldata <- data.frame()
#call dataframe record.csv
Finaldata <- read.table("record1228.CSV",header = T, sep = ",")#,encoding = "UTF-8"
Finaldata2<-as.data.frame(Finaldata)
Finaldata2$Time<- as.POSIXct(Finaldata2$Time,tz = "Asia/Taipei")

# conbine new data in
names(Traindataframe2)<-names(Finaldata2)
Finaldata3 <- rbind(Finaldata2,Traindataframe2)
#Name, Up is 0, Dowm is 1
colnames(Finaldata3) <- c("Type","Number","Time","Destination","Up/Down","delaytime")

write.table(Finaldata3, file = "record1228.CSV", sep = ",")

