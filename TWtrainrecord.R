library(RCurl)
# date and station setting
date <- gsub(pattern = "\\-","\\/",Sys.Date())
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
Traindataframe2 <-Traindataframe[Traindataframe$V3 > Sys.time(),]
#collect data
Finalupdata <- data.frame()
Finalupdata <- rbind(Finalupdata,Traindataframe2)
#Name, Up is 0, Dowm is 0
colnames(Finalupdata) <- c("Type","Number","Time","Destination","Up/Down","delaytime")

Finaldata