# CMEE 2021 HPC exercises R code challenge G pro forma

rm(list=ls()) # nothing written elsewhere should be needed to make this work

# please edit these data to show your information.
name <- "Natasha Ramsden"
preferred_name <- "Tash"
email <- "ter21@ic.ac.uk"
username <- "ter21"

# don't worry about comments for this challenge - the number of characters used will be counted starting from here
t=function(s,d,l){w=s[1]+l*cos(d);v=s[2]+l*sin(d);segments(s[1],s[2],w,v);return(c(w,v))};f=function(s,d,l,r){if(l>.001){x=t(s,d,l);y=f(x,d+pi/4*r,l*.38,r);z=f(x,d,l*.87,r*-1)}};plot.new();f(c(.5,0),pi/2,.13,1)