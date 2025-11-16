'PicoClock based on
'A very simple analog clock
' found randomly online at
'https://thebackshed.com/forum/ViewTopic.php?FID=16&TID=15586
'
CLS black                               'Clear tft display
xo=MM.HRes-160:yo=MM.VRes-120:r=100     'Draw circle in middle of the screen
tau=8*Atn(1)
x=0:y=0
Circle xo,yo,r,3,1,&hff0000             'The border of the circle is RED
ti$=Time$                               'Get the current time
s=Val(Mid$(ti$,7))                      'Make s,m,h
m=Val(Mid$(ti$,4,2))+s/60
h=Val(Left$(ti$,2))+m/60
drawclock                               'Draw the clock
settick 1000,tick                       'Generate interrupt once per second
do
 pause 62000
loop
sub tick
 drawclock                             'Draw the clock
end sub
settick 0,0
end
Sub drawclock
 t=s/60
 x=xs:y=ys
 c=&hffff
 rh=0.925*r
 draws
 c=&Hffffff
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