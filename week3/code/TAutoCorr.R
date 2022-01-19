rm(list=ls())
require(ggplot2)
load("../data/KeyWestAnnualMeanTemperature.RData")
plot<-ggplot(data=ats,mapping = aes(x=Year,y=Temp))+geom_point()
ggsave("../results/Auto_Cor_Florida_Temp.png",plot,,width = 5.03, height = 3.08, units = "in")
yeartempall<-ats$Temp
yeartemp_n<-ats$Temp[1:99]
yeartemp_n1<-ats$Temp[2:100]
yearpair<-data.frame(yeartemp_n,yeartemp_n1)
cor<-cor(yearpair$yeartemp_n,yearpair$yeartemp_n1)
corlist<-rep(NA,99999)
for(i in 1:100000){
  shuffle<-sample(yeartempall,99,replace=FALSE)
  corlist[i]<-cor(yeartemp_n,shuffle)
}
count<-0
for(i in 1:length(corlist)){
  if(corlist[i]>cor){
    count<-count+1
  }
}
fraction<-count/length(corlist)
cordata<-data.frame(corlist)
g<- ggplot(cordata,aes(x=corlist))+
  geom_histogram(position = "identity",fill="lightcoral",color="black")+
  xlab("correlation coefficient")+
  ylab("Count")+
  geom_vline(xintercept = cor,linetype="twodash",color="blue")+
  annotate(geom = "text",fontface="bold",color="blue",
           x=0.3,y=9000,
           label="observed value = 0.326",size = 3)
ggsave("../results/Auto_cor_Florida_histogram.png",g,width = 5.03, height = 3.08, units = "in")
