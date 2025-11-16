'PicoClock based on
'A very simple analog clock with digital date and name of weekday
' found randomly online at
'https://thebackshed.com/forum/ViewTopic.php?FID=16&TID=15586
'
cls 
xo=MM.HRes-160:yo=MM.VRes-160:r=100
c=&h00aa00
tau=8*Atn(1)
x=0:y=0
circle xo,yo,r,3,1,&h00aa00
csl=r*0.09
for dd= o to 360 step +30
 x1=fix(sin(rad(dd)) * r)
 y1=fix(cos(rad(dd)) * r)
 x2=fix(sin(rad(dd)) * (r+csl))
 y2=fix(cos(rad(dd)) * (r+csl))
 line x1+xo,y1+yo,x2+xo,y2+yo,3,&h00aa00
next dd
ti$=Time$
s=Val(Mid$(ti$,7))
m=Val(Mid$(ti$,4,2))+s/60
h=Val(Left$(ti$,2))+m/60
drawclock
settick 1000,tick
do
 pause 62000
loop
sub tick
 drawclock
end sub
settick 0,0
end
Sub drawclock
 Text 0,0,Date$,l,7,2,c
 Text 210,0,Day$(now)+"   ",l,7,2,c
 t=s/60
 x=xs:y=ys
 c=&h00aa00
 rh=0.925*r
 draws
 c=&H00aa00
 xs=x:ys=y
 t=m/60
 x=xm:y=ym:rh=0.9*r
 draws
 xm=x:ym=y
 t=(h-12*(h>=12))/12
 x=xh:y=yh:rh=0.55*r
 draws
 xh=x:yh=y:rh=r-1
 s=s+1
 m=m+1/60
 h=h+1/3600
End Sub
Sub draws
 Line xo,yo,x+xo,y+yo,1,0
 theta=-tau*t+tau/4
 x=rh*Cos(theta)
 y=-rh*Sin(theta)
 Line xo,yo,x+xo,y+yo,1,c
End Sub
