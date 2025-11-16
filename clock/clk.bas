'PicoClock based on
'A very simple analog clock with digital date and name of weekday
' found randomly online at
'https://thebackshed.com/forum/ViewTopic.php?FID=16&TID=15586
'
backlight 50                            'Backlight on 50%
cls                                     'Clear tft display
xo=MM.HRes-160:yo=MM.VRes-120:r=100     'Circle is positioned in the middle of
                                       'the sceen with a diameter of 200 pixels
tau=8*Atn(1)
x=0:y=0
circle xo,yo,r,3,1,&hff0000             'Colour of the circle is red
csl=r*0.09
for dd= o to 360 step +30               'Draw every 30 degrees a small line
 x1=fix(sin(rad(dd)) * r)
 y1=fix(cos(rad(dd)) * r)
 x2=fix(sin(rad(dd)) * (r+csl))
 y2=fix(cos(rad(dd)) * (r+csl))
 line x1+xo,y1+yo,x2+xo,y2+yo,3,&hff0000
next dd
ti$=Time$                               'Get the current time
s=Val(Mid$(ti$,7))                      'Convert s,m en h in degrees on circle
m=Val(Mid$(ti$,4,2))+s/60
h=Val(Left$(ti$,2))+m/60
drawclock                               'Draw the clock
settick 1000,tick                       'Once per second draw the clock
do
 pause 62000
loop
sub tick
 drawclock                             'Draw the clock
end sub
settick 0,0
end
Sub drawclock
 Text 0,0,Date$,l,7,2                  'Place date
 Text 210,0,Day$(now)+"   ",l,7,2      'Place day of week
 t=s/60
 x=xs:y=ys
 c=&hffff
 rh=0.925*r
 draws                                 'Draw the second hand in Cyan
 c=&Hffffff
 xs=x:ys=y
 t=m/60
 x=xm:y=ym:rh=0.9*r
 draws                                 'Draw minute hand in white
 xm=x:ym=y
 t=(h-12*(h>=12))/12
 x=xh:y=yh:rh=0.55*r
 draws                                 'Draw hour hand in white
 xh=x:yh=y:rh=r-1
 s=s+1                                 'Increment the time per second  
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
