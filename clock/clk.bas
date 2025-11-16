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
'do we have a realtimeclock?
haveRtc =0 '0 = no

drawclockface
drawclock
SetTick 1000,tick
Do
 cmd$ = Inkey$
 If cmd$ <> "" Then
  Select Case Asc(cmd$)
   Case 151 'f7
    settime
    drawclockface
   Case 152 'f8
    setdate
    drawclockface
   Case 27  'esc
    Exit Do
  End Select
 EndIf
Loop
Sub tick
 drawclock
End Sub
CLS
SetTick 0,0
End
Sub drawclockface
 CLS
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
End Sub

Sub drawclock
 ti$=Time$
 s=Val(Mid$(ti$,7))
 m=Val(Mid$(ti$,4,2))+s/60
 h=Val(Left$(ti$,2))+m/60
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
End Sub
Sub draws
 Line xo,yo,x+xo,y+yo,1,0
 theta=-tau*t+tau/4
 x=rh*Cos(theta)
 y=-rh*Sin(theta)
 Line xo,yo,x+xo,y+yo,1,c
End Sub

Sub settime
 CLS
 Print "Time HH:MM"
 'hour
 Input "Enter hour (HH): ", th$
 If Len(th$) > 2 Then Exit Sub
 If isnum(th$) = 0 Then Exit Sub
 nh = Val(th$)
 If nh > 23 Then Exit Sub
 'min
 CLS
 Print "Time HH:MM"
 Input "Enter minutes (MM): ", tm$
 If Len(tm$) > 2 Then Exit Sub
 If isnum(tm$) = 0 Then Exit Sub
 nm = Val(tm$)
 If nm > 59 Then Exit Sub
 Time$ = Str$(nh,2,0,"0") + ":" + Str$(nm,2,0,"0") + ":00"
End Sub

Sub setdate
 CLS
 Print "Date YYYY/MM/DD"
 'year
 Input "Enter year (YYYY): ", dy$
 If Len(dy$) <> 4 Then Exit Sub
 If isnum(dy$) = 0 Then Exit Sub
 ny = Val(dy$)
 If ny < 1980 Then Exit Sub
 If ny > 2300 Then Exit Sub
 'month
 CLS
 Print "Date YYYY/MM/DD"
 Input "Enter month (MM): ", dm$
 If Len(dm$) > 2 Then Exit Sub
 If isnum(dm$) = 0 Then Exit Sub
 nm = Val(dm$)
 If nm > 12 Then Exit Sub
 'day
 CLS
 Print "Date YYYY/MM/DD"
 Input "Enter day (DD): ", dday$
 If Len(dday$) > 2 Then Exit Sub
 If isnum(dday$) = 0 Then Exit Sub
 nd = Val(dday$)
 If dayofmonth(nd,nm) = 0 Then Exit Sub
 Date$ = Str$(ny) + "/" + Str$(nm,2,0,"0") + "/" + Str$(nd,2,0,"0")
End Sub

Function dayofmonth(id As integer, im As integer)
  dayofmonth = 0
  If id > 31 Then Exit Function
  If im > 12 Then Exit Function
  If im = 2 And id > 28 Then Exit Function
  If im = 4 Or im = 6 Or im = 9 Or im = 11 Then
    If id > 30 Then Exit Function
  EndIf
  dayofmonth = 1
End Function

Function isnum(inchar$ As string)
  isnum = 1
  charlen = Len(inchar$)
  For i = 1 To charlen
    curchar$ = Mid$(inchar$, i, 1)
    If curchar$ < "0" Or curchar$ > "9" Then isnum = 0
  Next i
End Function
