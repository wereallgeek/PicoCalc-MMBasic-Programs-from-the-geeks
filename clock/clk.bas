'PicoClock based on
'A very simple analog clock with digital date and name of weekday
' found randomly online at
'https://thebackshed.com/forum/ViewTopic.php?FID=16&TID=15586
'
CLS
xo=MM.HRES-160:yo=MM.VRES-160:r=100
'configure colours here.
hrsc=&h00aa00
minc=&h00aa00
secc=&h00aa00
txtc=&h00aa00
clkc=&h00aa00

tau=8*Atn(1)
x=0:y=0
Circle xo,yo,r,3,1,clkc
csl=r*0.09
For dd= o To 360 Step +30
 x1=Fix(Sin(Rad(dd)) * r)
 y1=Fix(Cos(Rad(dd)) * r)
 x2=Fix(Sin(Rad(dd)) * (r+csl))
 y2=Fix(Cos(Rad(dd)) * (r+csl))
 Line x1+xo,y1+yo,x2+xo,y2+yo,3,clkc
Next dd
ti$=Time$
s=Val(Mid$(ti$,7))
m=Val(Mid$(ti$,4,2))+s/60
h=Val(Left$(ti$,2))+m/60
drawclock
SetTick 1000,tick
Do
 Pause 62000
Loop
Sub tick
 drawclock
End Sub
SetTick 0,0
End
Sub drawclock
 Text 0,0,Date$,l,7,2,txtc
 Text 210,0,Day$(now)+"   ",l,7,2,txtc
 t=s/60
 x=xs:y=ys
 c=secc
 rh=0.925*r
 draws
 c=minc
 xs=x:ys=y
 t=m/60
 x=xm:y=ym:rh=0.9*r
 draws
 xm=x:ym=y
 t=(h-12*(h>=12))/12
 x=xh:y=yh:rh=0.55*r
 c=hrsc
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
End
