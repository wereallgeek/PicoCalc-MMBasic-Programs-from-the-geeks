'PicoClock based on
'A very simple analog clock with digital date and name of weekday
' found randomly online at
'https://thebackshed.com/forum/ViewTopic.php?FID=16&TID=15586
'
' added calendar
' added timer alarm
'
mode$="clock"
f1pos = 95
f2pos = 145
f3pos = 195
f4pos = 255
f5pos = 305

'timer alarm
countdown = 0
snoozed = 1

'calendar cell size
Const CELL_Y = 41
Const CELL_X = 45
Const SIZE_Y = 39
Const SIZE_X = 42
CLS
xo=MM.HRES-160:yo=MM.VRES-160:r=100
'configure colours here.
'analog clock
hrsc=&h00aa00
minc=&h00aa00
secc=&h00aa00
txtc=&h00aa00
clkc=&h00aa00
'digital clock and calendar
digiclkc   = &h00aa00
caltitlec  = &h00aa00
caldayc    = &h00aa00
caldaynumc = &H8410
otherdayc  = &H8410
todayc     = &h00aa00

menuc=&h00aa00
fkeyc=&h00aa00
fkhic=&h00dd00

batc=&h1e991e

knowndate = thisdate()

'do we have a realtimeclock?
haveRtc =0 '0 = no

drawclockface
drawclock
SetTick 1000,tick
Do
 cmd$ = Inkey$
 If cmd$ <> "" Then
  Select Case Asc(cmd$)
  drawCurrentCalendar
   Case 145 '[F1]
    mode$="clock"
    drawCurrentScreen
   Case 146 '[F2]
    mode$="calendar"
    knowndate = thisdate()
    drawCurrentScreen
   Case 128 'up'
    If mode$="calendar" Then
      CalYear = CalYear + 1
      DrawCalendar CalMonth, CalYear, CalDay
    EndIf
   Case 129 'down'
    If mode$="calendar" Then
      CalYear = CalYear - 1
      DrawCalendar CalMonth, CalYear, CalDay
    EndIf
   Case 130 'left'
    If mode$="calendar" Then
      If CalMonth > 1 Then
        CalMonth = CalMonth - 1
      Else
        CalMonth = 12
      EndIf
      DrawCalendar CalMonth, CalYear, CalDay
    EndIf
   Case 131 'right'
    If mode$="calendar" Then
      If CalMonth < 12 Then
        CalMonth = CalMonth + 1
      Else
        CalMonth = 1
      EndIf
      DrawCalendar CalMonth, CalYear, CalDay
    EndIf
   Case 148 '[f4]
    newtimer
    drawCurrentScreen
   Case 151 'f7
    settime
    drawCurrentScreen
   Case 152 'f8
    setdate
    drawCurrentScreen
   Case 27  'esc
    Exit Do
  End Select
 EndIf
 If cmd$ <> "" And snoozed = 0 And countdown = 0 Then
  snooze
 EndIf
 If knowndate <> thisdate() And mode$="calendar" Then
  knowndate = thisdate()
  drawCurrentScreen
 EndIf
Loop
Sub tick
 handleTimerAlarm
 drawclock
End Sub
CLS
SetTick 0,0
End

Sub drawCurrentScreen
 If mode$="clock" Then
  drawclockface
 ElseIf mode$="calendar" Then
  drawCurrentCalendar
 EndIf
End Sub

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
 drawfooter
End Sub

Sub drawclock
 If mode$="clock" Then
  ti$=Time$
  s=Val(Mid$(ti$,7))
  m=Val(Mid$(ti$,4,2))+s/60
  h=Val(Left$(ti$,2))+m/60
  Text 0,0,Date$,l,7,2,txtc
  Text 180,0,Day$(now)+"   ",l,7,2,txtc
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
 ElseIf mode$="calendar" Then
  Colour digiclkc
  Font 1
  Print @(255, 11) Time$
 EndIf
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

Sub drawCurrentCalendar
 ' Get current date components (as numbers)
 CalDay = Val(Mid$(Date$, 1, 2))
 CalMonth = Val(Mid$(Date$, 4, 2))
 CalYear = Val(Mid$(Date$, 7, 4))

 ' Draw the calendar
 DrawCalendar CalMonth, CalYear, CalDay
End Sub

Sub DrawCalendar(Month, Year, Today)
 ' Draws a calendar for the specified Month and Year
 Local MonthName$, DaysInMonth, FirstDayOfWeek, Day, X, Y, Row, Col, DaysOfWeek$(7), MonthNames$(12)

 CLS
 Colour caltitlec

 ' Month Names
 MonthNames$(1) = "January" : MonthNames$(2) = "February" : MonthNames$(3) = "March"
 MonthNames$(4) = "April" : MonthNames$(5) = "May" : MonthNames$(6) = "June"
 MonthNames$(7) = "July" : MonthNames$(8) = "August" : MonthNames$(9) = "September"
 MonthNames$(10) = "October" : MonthNames$(11) = "November" : MonthNames$(12) = "December"
 MonthName$ = MonthNames$(Month)

 ' Display Month and Year Header (Font 3 is fine)
 Font 3
 Print @(10, 10) MonthName$; " "; Year

 ' Display Day of Week Headers (Font 1 is fine)
 Font 1
 DaysOfWeek$(0) = "Sun" : DaysOfWeek$(1) = "Mon" : DaysOfWeek$(2) = "Tue"
 DaysOfWeek$(3) = "Wed" : DaysOfWeek$(4) = "Thu" : DaysOfWeek$(5) = "Fri" : DaysOfWeek$(6) = "Sat"

 For Col = 0 To 6
   X = Col * CELL_X + 5
   Y = 35
   Colour caldayc
   Print @(X, Y) DaysOfWeek$(Col)
 Next

 ' --- Calculate the number of days in the month ---
 DaysInMonth = 31
 If Month = 4 Or Month = 6 Or Month = 9 Or Month = 11 Then DaysInMonth = 30
 If Month = 2 Then
   If (Year Mod 4 = 0 And Year Mod 100 <> 0) Or (Year Mod 400 = 0) Then
     DaysInMonth = 29
   Else
     DaysInMonth = 28
   End If
 End If

 ' --- Calculate the Day of the Week for the 1st of the month using a function ---
 FirstDayOfWeek = GetDayOfWeek(1, Month, Year) ' 0=Sun, 6=Sat

 ' Draw the days
 ' Changed font from Font 2 to Font 1 (smallest) to prevent wrapping for 2-digit numbers
 Font 1
 Row = 0
 Col = FirstDayOfWeek

 For Day = 1 To DaysInMonth
   X = (Col * CELL_X) + 10
   Y = 60 + (Row * CELL_Y)
   'square pos
   sx = x - 8
   sy = y - 8

   ' Highlight today's date
   If Day = Today And Month = Val(Mid$(Date$, 4, 2)) And Year = Val(Mid$(Date$, 7, 4)) Then
     Box sx, sy, SIZE_X, SIZE_Y, 5, todayc
   Else
     Box sx, sy, SIZE_X, SIZE_Y, 3, otherdayc
   End If

   Colour caldaynumc
   Print @(X, Y) Day

   Col = Col + 1
   If Col > 6 Then
     Col = 0
     Row = Row + 1
   End If
 Next Day
 drawfooter
End Sub

Function GetDayOfWeek(TargetD, TargetM, TargetY)
 ' Calculates the day of the week using Zeller's Congruence variation
 ' Returns 0 = Sunday, 6 = Saturday
 Local h, q_val, m_val, y_val, j_val, k_val

 q_val = TargetD
 m_val = TargetM
 y_val = TargetY

 If m_val < 3 Then
   m_val = m_val + 12
   y_val = y_val - 1
 End If

 j_val = Int(y_val / 100)
 k_val = y_val Mod 100

 h = (q_val + Int(13 * (m_val + 1) / 5) + k_val + Int(k_val / 4) + Int(j_val / 4) - 2 * j_val) Mod 7

 If h = 0 Then GetDayOfWeek = 6 Else GetDayOfWeek = h - 1

End Function

Function thisdate()
  thisdate = Val(Left$(Date$,2))
End Function

Sub handleTimerAlarm
  If snoozed = 1 Then Exit Sub
  If countdown > 0 Then countdown = countdown - 1
  If countdown > 0 Then timeleft
  If countdown = 0 Then soundalarm
End Sub

Sub newtimer
  If countdown > 0 Or snoozed = 0 Then
   snooze
   Exit Sub
  EndIf
  CLS
  Font (2)
  Input "countdown (sec): ", count$
  If isnum(count$) = 0 Then Exit Sub
  countdown = Val(count$)
  snoozed = 0
End Sub

Sub snooze
  countdown = 0
  snoozed = 1
  Print @(15,304) "      "
  drawfooter
End Sub

Sub timeleft
  Font (7)
  Colour fkeyc
  If countdown > 0 Or snoozed = 0 Then
   Print @(15,304) "      "
   countmin = Int(countdown / 60)
   countsec = countdown Mod 60
   Print @(15,304) Str$(countmin,3,0,"0")+":"+Str$(countsec,2,0,"0")
  EndIf
End Sub

Sub showalarm
  Font (7)
  Colour fkeyc
  If Val(Right$(Time$,2)) Mod 2 = 0 Then
    Print @(15,304) "======"
  Else
    Print @(15,304) "!!!!!!"
  EndIf
End Sub

Sub soundalarm
  showalarm
  If Val(Right$(Time$,2)) Mod 3 = 0 Then
    Play tone 200,600,900
  ElseIf Val(Right$(Time$,2)) Mod 2 = 0 Then
    Play tone 500,300,900
  EndIf
End Sub

Function batlevel$()
  buildstring$ = "+"
  If MM.Info(charging) = 0 Then buildstring$ = " "
  buildstring$ = buildstring$ + Str$(MM.Info(battery))
  batlevel$ = buildstring$ + "%"
End Function

Sub drawfooter
  'batt top right isnt quite footer
  headtext$ = batlevel$()
  batpos = 320 - (Len(headtext$) * 7)
  Font (7)
  Colour batc
  Print @(batpos,0) headtext$
  'actual footer
  f1colour = fkeyc
  f2colour = fkeyc
  f3colour = fkeyc
  f4colour = fkeyc
  f5colour = fkeyc

  If mode$="clock" Then
   f1colour = fkhic
  ElseIf mode$="calendar" Then
   f2colour = fkhic
  EndIf
  If countdown > 0 Then f4colour = fkhic
  Line 1,300,319,300,1,menuc
  Font (7)
  Colour f1colour
  Print @(f1pos,304)"CLOCK"
  Colour f2colour
  Print @(f2pos,304)" CAL"
  Colour f3colour
  Print @(f3pos,304)""
  Colour f4colour
  Print @(f4pos,304)" TIMER"
  Colour f5colour
  Print @(f5pos,304)""
End Sub
