' Converted to Pico MMBasic by Kevin Moore 07/12/2021
' Based on Python project https://github.com/dr-mod/pico-solar-system
' which uses the planetry equations of motion from http://stjarnhimlen.se/comp/tutorial.html
' I have limited the year between 1901 and 2100 as the equations may not work beyond these.
' 
' modified from its original form to work on the picocalc
' changes only include new screen size of 320x320 and replacement of touch interface with keyboard.
'
' Keys:
' +            = Brightness up
' -            = Brightness down
' ,<           = increase date by a week at a time then a month...
' .>           = decrease date by a week at a time then a month...
' <-Back       = reset back to todays date, also re-initialise LCD display
' ESC          = Exit program
'
' turn off default typing
Option DEFAULT NONE
' force explicit typing
Option EXPLICIT
' turn off blinking LED while running
SetPin GP25, DOUT
' Screen = 320*320
Const width = 320
Const height = 320
Const onerad = 57.2957795131
Const update = 100
Colour RGB(WHITE), RGB(BLACK) ' Set the default colours
Font 1, 3 ' Set the default font
Dim m$(11) = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec")
Dim planet_name$(9) = ("","Mercury","Venus","Earth","Mars","Jupiter","Saturn","Uranus","Neptune","Moon")
Dim STRING dy
Dim INTEGER x, y, orbit, year, month, day, hour, min, today = 0, bright = 28
Dim INTEGER dayoff = 0, cuday, cumonth, cuyear, updatescr = update
Dim INTEGER last_pos(1,9)
Dim INTEGER rtcl=1 ' do we have a hardware real time clock
Dim FLOAT planets_dict(1,9)
Dim FLOAT xeclip, yeclip, zeclip, long2, lat2, r, Earthx, Earthy
Dim FLOAT feta, coordinatex, coordinatey, seconds, lastsec=60.0, frac_s=0.0

' set screen backlight to mid value
Backlight bright
' Solar system centre
y = height / 2
x = y

Do
  day = Eval(Left$(Date$, 2))

' only update planets daily or when changing or when fast scrolling
  If day <> today Or dayoff >= 2 Then
' re-initialise display once a day at midnight, when date changes
    If dayoff <=1 Then GUI RESET LCDPANEL
    If dayoff <=4 Then CLS
    year = Eval(Right$(Date$, 4))
    month = Eval(Mid$(Date$, 4, 2))
    today = day
    hour = Eval(Left$(Time$, 2))
    min = Eval(Mid$(Time$, 4, 2))

' call main calculations of planet positions
    coordinates(year, month, day, hour, min) ' results returned in planets_dict array

' draw Sun
    If dayoff <=4 Then Circle x, y, 10, 0, 1,, RGB(YELLOW)

    For orbit = 1 To 9
' planet and orbit sizeing only for a 340*240 screen
' draw orbit rings
      r = 13 * orbit + 8
' change orbit spacing for inner planets
      If orbit <=3 Then r=r-7+(orbit*2) : If orbit >=2 Then r=r-3
' for speed, don't draw orbits if fast scrolling the date, no orbit for Moon
      If dayoff <= 2 And orbit <= 8 Then Circle x, y, r, 1, 1, RGB(60,60,60), -1 : last_pos(0,orbit)=0 : last_pos(1 ,orbit)=0
' draw planets
' Moon Special is geocentric, all others are Heliocentric
      If orbit = 9 Then
' Don't draw Moon if fast scrolling
        If dayoff <= 2 Then
          feta = Atan2(planets_dict(1,orbit), planets_dict(0,orbit))+1.570796327
          r= 10 ' Moon orbit round Earth (keep it close)
          coordinatex = r * Sin(feta) + Earthx
          coordinatey = r * Cos(feta) + Earthy
          Call planet_name$(orbit) ,(coordinatex, coordinatey, last_pos(0,orbit), last_pos(1,orbit))
          last_pos(0,orbit) = coordinatex
          last_pos(1,orbit) = coordinatey
        EndIf
      Else
        feta = Atan2(planets_dict(0,orbit), planets_dict(1,orbit))
        coordinatex = r * Sin(feta) + x
        coordinatey = height - (r * Cos(feta) + y)
        Call planet_name$(orbit) ,(coordinatex, coordinatey, last_pos(0,orbit), last_pos(1,orbit))
        last_pos(0,orbit) = coordinatex
        last_pos(1,orbit) = coordinatey
      EndIf
      If orbit = 3 Then Earthx=coordinatex : Earthy=coordinatey ' save Earth coordinates for Moon calcs.
    Next orbit

' display current date don't disply day of week if fast scrolling date
    If dayoff <= 2 Then
      dy$=Day$(Date$)
      If dy$="Wednesday" Then dy$="Wednesdy"
      Text 192, 22, dy$, "LB", 3, 1, RGB(ORANGE)
    EndIf
    Text 222, 28, Left$(Date$, 3)+m$(Eval(Mid$(Date$, 4, 2))-1), "LT", 3, 1, RGB(ORANGE)
    Text 252, 58, Right$(Date$,4), "LT", 3, 1, RGB(ORANGE)
  EndIf

' display current time and Pluto unless fast scrolling date
  If dayoff <= 2 Then
    seconds = Eval(Right$(Time$, 2))
    If lastsec > seconds Then Text 204, 212, Left$(Time$, 5), "LT", 7, 4, RGB(CYAN) : seconds=0 ' update time
    If seconds <> lastsec Then
      frac_s=0
      lastsec = seconds
    Else
      frac_s = frac_s+updatescr
    EndIf
    Pluto(seconds+(frac_s/1000))
  EndIf

  Pause updatescr ' wait before doing next screen update
  cmd$ = Inkey$
  If cmd$ <> "" Then
' save todays date for returning later
    If dayoff = 0 Then cuday = day : cumonth = month : cuyear = year
    If Asc(cmd$) = 61 or Asc(cmd$) = 43 Then ' [+]
        bright = bright + 5
        If bright >95 Then bright=100
		Backlight bright
    ElseIf Asc(cmd$) = 45 or Asc(cmd$) = 95 Then '[-]
        bright = bright - 5
        If bright <5 Then bright=0
		Backlight bright
    ElseIf Asc(cmd$) = 46 or Asc(cmd$) = 62 Then ' [>]
        If dayoff <97 Then day = day+7 Else month = month+1
        If day >28 Then day=1 : month = month+1
        If month >12 Then month=1 : year = year+1
        If year > 2100 Then year = 2100
		updatescr=0
		lastsec=60
		dayoff = dayoff+3
		Date$ = Str$(day)+"/"+Str$(month)+"/"+Str$(year)
    ElseIf Asc(cmd$) = 44 or Asc(cmd$) = 60 Then ' [<]
        If dayoff <97 Then day = day-7 Else month = month-1
        If day <1 Then day=28 : month = month-1
        If month <1 Then month=12 : year = year-1
        If year <1901 Then year=1901
		updatescr=0
		lastsec=60
		dayoff = dayoff+3
		Date$ = Str$(day)+"/"+Str$(month)+"/"+Str$(year)
    ElseIf Asc(cmd$) = 8 Then '[<-Back]
      updatescr = update
      dayoff = 0
      lastsec=60
      today=0
      If rtcl = 1 Then
        RTC GETTIME
      Else
        Date$ = Str$(cuday)+"/"+Str$(cumonth)+"/"+Str$(cuyear)
      EndIf
    EndIf
  ElseIf dayoff >2 Then
    dayoff = 2
  ElseIf dayoff =2 Then
    dayoff = 1
    updatescr = update  ' delay between screen updates & checking for push switches
  EndIf
Loop

Sub Pluto( secs As FLOAT )
Const  R = 4
Const  BOUNCE = -0.98
Static Float  plu_x = 290.0, plu_y = y
Static Float  xpos = plu_x, ypos=plu_y
Static Float  vel_x = -3.0
Static Integer  y_height = 124, y_min = 83
Static Integer  x_min = width-82 + R, x_max = width - R
Static Float amplitude, x_fun, sway, height, sec2

   If secs < 0.01 Then
     sec2=0
     vel_x = Rnd*3+4
     If Rnd > 0.5 Then vel_x = -(vel_x)
' update 59sec and 0 sec markers every minute.
     Text 236, 83, "0", "LB", 7, 1, RGB(156,166,183)
     Text 226, 210, "59", "LB", 7, 1, RGB(156,166,183)
   EndIf
' update the 30sec marker every 4 seconds while less than 35 seconds
   If secs >= sec2 And secs <= 35 Then sec2 = secs+2 : Text 308, 150, "30", "LB", 7, 1, RGB(156,166,183)

   amplitude = (60-secs)/60
   x_fun = secs - Fix( secs )
   sway = 1 - ((((x_fun/0.5)-1)^2) * (-1) + 1)
   height = y_height * amplitude
   plu_y = (height * sway) + y_height - height + y_min

   plu_x = plu_x + vel_x
   If plu_x >= x_max Then
       vel_x = vel_x * BOUNCE
       plu_x = x_max
   ElseIf plu_x <= x_min Then
       vel_x = vel_x * BOUNCE
       plu_x = x_min
   EndIf

   Box xpos-4, ypos-4, 9, 9, 0,, RGB(0,0,0)  ' blank Pluto
   Circle plu_x, plu_y, R, 0, 1,, RGB(156,166,183)  'Pluto
   xpos = plu_x
   ypos = plu_y

End Sub

Sub Mercury(xs As INTEGER, ys As INTEGER, xpos As INTEGER, ypos As INTEGER)
   Box xpos-2, ypos-2, 5, 5, 0,, RGB(0,0,0)  ' blank Mercury
   Circle xs, ys, 2, 0, 1,, RGB(213,178,138)  'Mercury
End Sub

Sub Venus(xs As INTEGER, ys As INTEGER, xpos As INTEGER, ypos As INTEGER)
   Box xpos-4, ypos-4, 9, 9, 0,, RGB(0,0,0)  ' blank Venus
   Circle xs, ys, 4, 0, 1,, RGB(179,102,22)  'Venus
End Sub

Sub Earth(xs As INTEGER, ys As INTEGER, xpos As INTEGER, ypos As INTEGER)
   Box xpos-6, ypos-6, 13, 13, 0,, RGB(0,0,0)  ' blank Earth
   Circle xs, ys, 6, 0, 1,, RGB(126,152,203)  'Earth
' don't draw planet details if fast scrolling
   If dayoff <=2 Then
     Line xs-1,ys-6, xs+1,ys-6, 1, RGB(WHITE)
     Line xs-3,ys+5, xs+3,ys+5, 1, RGB(WHITE)
     Line xs-1,ys+6, xs+1,ys+6, 1, RGB(WHITE)
     Circle xs+1,ys+1, 3, 2, 1.5, RGB(230,230,250), -1
     Circle xs-2, ys-1, 4, 0, 0.6,, RGB(30,255,20)
   EndIf
End Sub

Sub Mars(xs As INTEGER, ys As INTEGER, xpos As INTEGER, ypos As INTEGER)
   Box xpos-3, ypos-3, 7, 7, 0,, RGB(0,0,0)    ' blank Mars
   Circle xs, ys, 3, 0, 1,, RGB(234,169,111)    'Mars
End Sub

Sub Jupiter(xs As INTEGER, ys As INTEGER, xpos As INTEGER, ypos As INTEGER)
' don't draw planet details if fast scrolling
   Box xpos-7, ypos-7, 15, 15, 0,, RGB(0,0,0)  ' blank Jupiter
   Circle xs, ys, 7, 0, 1,, RGB(185,191,153)  'Jupiter
   If dayoff <=2 Then
     Line xs-5,ys-5,xs+5,ys-5, 1, RGB(182,134,86)
     Line xs-7,ys-3,xs+7,ys-3, 2, RGB(182,134,86)
     Line xs-7,ys+1,xs+7,ys+1, 2, RGB(202,150,100)
     Line xs-5,ys+5,xs+5,ys+5, 1, RGB(202,150,100)
     Circle xs+2,ys+2, 2, 0, 1.75,, RGB(230,144,91)
   EndIf
End Sub

Sub Saturn(xs As INTEGER, ys As INTEGER, xpos As INTEGER, ypos As INTEGER)
   Box xpos-7, ypos-7, 15, 15, 0,, RGB(0,0,0) ' blank Saturn
   Line xpos-14, ypos, xpos+14, ypos, 2, RGB(0,0,0)
   Circle xs, ys, 6, 0, 1,, RGB(222,182,113) 'Saturn
   Line xs-14, ys, xs+14, ys, 2, RGB(141,124,104)
End Sub

Sub Uranus(xs As INTEGER, ys As INTEGER, xpos As INTEGER, ypos As INTEGER)
   Box xpos-5, ypos-5, 11, 11, 0,, RGB(0,0,0)   ' blank Uranus
   Circle xs, ys, 5, 0, 1,, RGB(173,217,244)   'Uranus
End Sub

Sub Neptune(xs As INTEGER, ys As INTEGER, xpos As INTEGER, ypos As INTEGER)
   Box xpos-5, ypos-5, 11, 11, 0,, RGB(0,0,0)    ' blank Neptune
   Circle xs, ys, 5, 0, 1,, RGB(116,142,193)    'Neptune
End Sub

Sub Moon( xs As INTEGER, ys As INTEGER, xpos As INTEGER, ypos As INTEGER)
    Box xpos-2, ypos-2, 5, 5, 0,, RGB(0,0,0)    ' blank Moon
    Circle xs, ys, 2, 0, 1,, RGB(250,250,250)    'Moon
End Sub

'Function Modulus(angle As FLOAT) As FLOAT
'    Modulus = angle - Int(angle/360.0)*360.0
'End Function

Sub from_sun(m As FLOAT, e As FLOAT, a As FLOAT, ns As FLOAT, w As FLOAT, ic As FLOAT)
Local FLOAT m2, e0, e02, e1, x, y, r, vs, vc, nc

    m2 = Rad(m)
    e0 = (m + onerad * e * Sin(m2) * (1 + e * Cos(m2))) Mod 360
    e02 = Rad(e0)
    e1 = Rad((e0 - (e0 - onerad * e * Sin(e02) - m) / (1 - e * Cos(e02))) Mod 360)
    x = a * (Cos(e1) - e)
    y = a * (Sqr(1 - e * e)) * Sin(e1)
' return value r
    r = Sqr(x * x + y * y)
    vs = Rad((Deg(Atan2(y, x)) Mod 360) + w)
    vc = Cos(vs)
    vs = Sin(vs)
    ns = Rad(ns)
    nc = Cos(ns)
    ns = Sin(ns)
    zeclip = r * vs * Sin(Rad(ic))
    ic = Cos(Rad(ic))
' return values xeclip, yeclip, long2, lat2
    xeclip = r * (nc * vc - ns * vs * ic)
    yeclip = r * (ns * vc + nc * vs * ic)
    long2 = (Deg(Atan2(yeclip, xeclip))) Mod 360
    lat2 = Deg(Atan2(zeclip, Sqr(xeclip * xeclip + yeclip * yeclip)))
End Sub

' results returned in array planets_dict
Sub coordinates(year%, month%, day%, hour%, minute%)
Local INTEGER jdn
Local FLOAT jd, d, w, e, m2, m, e_capt, x, y, r, v, lon, x2, y2
Local FLOAT n_mo, i_mo, w_mo, a_mo, e_mo, m_mo
Local FLOAT n_er, i_er, w_er, a_er, e_er, m_er
Local FLOAT n_af, i_af, w_af, a_af, e_af, m_af
Local FLOAT n_ar, i_ar, w_ar, a_ar, e_ar, m_ar
Local FLOAT n_di, i_di, w_di, a_di, e_di, m_di
Local FLOAT n_kr, i_kr, w_kr, a_kr, e_kr, m_kr
Local FLOAT n_ou, i_ou, w_ou, a_ou, e_ou, m_ou
Local FLOAT n_po, i_po, w_po, a_po, e_po, m_po
Local FLOAT di_diat1, di_diat2, di_diat3, di_diat4, di_diat5, di_diat6, di_diat7
Local FLOAT kr_diat1, kr_diat2, kr_diat3, kr_diat4, kr_diat5, kr_diat6, kr_diat7
Local FLOAT ou_diat1, ou_diat2, ou_diat3
Local FLOAT diataraxes_long_di, diataraxes_long_kr, diataraxes_lat_kr, diataraxes_long_ou
Local FLOAT long2_di, coslat2_di, r_di, long2_kr, coslat2_kr, r_kr
Local FLOAT long2_ou, coslat2_ou, r_ou

    jdn = ((367*year%-(7*(year%+((month%+9)\12))\4))+(275*month%\9)+(day%+1721013.5))
    jd = (jdn + hour% / 24. + minute% / 1440.)
    d = jd - 2451543.5

    w = 282.9404 + 4.70935E-5 * d
    e = (0.016709 - (1.151E-9 * d))
    m2 = (356.047 + 0.9856002585 * d) Mod 360

    m = Rad( m2 )
    e_capt = Rad(m2 + onerad * e * Sin(m) * (1 + e * Cos(m)))
    x = Cos(e_capt) - e
    y = Sin(e_capt) * Sqr(1 - e * e)

    r = Sqr(x * x + y * y)

    v = Deg(Atan2(y, x))
    lon = Rad((v + w) Mod 360)
    x2 = r * Cos(lon)
    y2 = r * Sin(lon)

' Earth coords
    planets_dict(0,3) = -1 * x2
    planets_dict(1,3) = -1 * y2

    n_mo = 125.1228 - 0.0529538083 * d    '  (Long asc. node)
    i_mo = 5.1454                         '  (Inclination)
    w_mo = 318.0634 + 0.1643573223 * d    '  (Arg. of perigee)
    a_mo = 60.2666                        '  (Mean distance)
    e_mo = 0.054881                       '  (Eccentricity)
    m_mo = (115.3654 + 13.0649929509 * d) Mod 360 '  (Mean anomaly)

    n_er = 48.3313 + 3.24587E-5 * d
    i_er = 7.0047 + 5.00E-8 * d
    w_er = 29.1241 + 1.01444E-5 * d
    a_er = 0.387098
    e_er = 0.205635 + 5.59E-10 * d
    m_er = (168.6562 + 4.0923344368 * d) Mod 360

    n_af = 76.6799 + 2.46590E-5 * d
    i_af = 3.3946 + 2.75E-8 * d
    w_af = 54.8910 + 1.38374E-5 * d
    a_af = 0.723330
    e_af = 0.006773 - 1.30E-9 * d
    m_af = (48.0052 + 1.6021302244 * d) Mod 360

    n_ar = 49.5574 + 2.11081E-5 * d
    i_ar = 1.8497 - 1.78E-8 * d
    w_ar = 286.5016 + 2.92961E-5 * d
    a_ar = 1.523688
    e_ar = 0.093405 + 2.51E-9 * d
    m_ar = (18.6021 + 0.5240207766 * d) Mod 360

    n_di = 100.4542 + 2.76854E-5 * d
    i_di = 1.3030 - 1.557E-7 * d
    w_di = 273.8777 + 1.6450E-5 * d
    a_di = 5.20256
    e_di = 0.048498 + 4.469E-9 * d
    m_di = (19.8950 + 0.0830853001 * d) Mod 360

    n_kr = 113.6634 + 2.38980E-5 * d
    i_kr = 2.4886 - 1.081E-7 * d
    w_kr = 339.3939 + 2.97661E-5 * d
    a_kr = 9.55475
    e_kr = 0.055546 - 9.499E-9 * d
    m_kr = (316.9670 + 0.0334442282 * d) Mod 360

    n_ou = 74.0005 + 1.3978E-5 * d
    i_ou = 0.7733 + 1.9E-8 * d
    w_ou = 96.6612 + 3.0565E-5 * d
    a_ou = 19.18171 - 1.55E-8 * d
    e_ou = 0.047318 + 7.45E-9 * d
    m_ou = (142.5905 + 0.011725806 * d) Mod 360

    n_po = 131.7806 + 3.0173E-5 * d
    i_po = 1.7700 - 2.55E-7 * d
    w_po = 272.8461 - 6.027E-6 * d
    a_po = 30.05826 + 3.313E-8 * d
    e_po = 0.008606 + 2.15E-9 * d
    m_po = (260.2471 + 0.005995147 * d) Mod 360

    from_sun(m_mo, e_mo, a_mo, n_mo, w_mo, i_mo)
    planets_dict(0,9) = xeclip
    planets_dict(1,9) = yeclip

' return values in xeclip, yeclip, long2, lat2, r
    from_sun(m_er, e_er, a_er, n_er, w_er, i_er)
    planets_dict(0,1) = xeclip
    planets_dict(1,1) = yeclip

    from_sun(m_af, e_af, a_af, n_af, w_af, i_af)
    planets_dict(0,2) = xeclip
    planets_dict(1,2) = yeclip

    from_sun(m_ar, e_ar, a_ar, n_ar, w_ar, i_ar)
    planets_dict(0,4) = xeclip
    planets_dict(1,4) = yeclip

' return values in xeclip, yeclip, long2, lat2, r
    from_sun(m_di, e_di, a_di, n_di, w_di, i_di)
    long2_di = long2
    coslat2_di = Cos(Rad(lat2))
    r_di = r

    from_sun(m_kr, e_kr, a_kr, n_kr, w_kr, i_kr)
    long2_kr = long2
    coslat2_kr = lat2
    r_kr = r

    from_sun(m_ou, e_ou, a_ou, n_ou, w_ou, i_ou)
    long2_ou = long2
    coslat2_ou = Cos(Rad(lat2))
    r_ou = r

    from_sun(m_po, e_po, a_po, n_po, w_po, i_po)
    planets_dict(0,8) = xeclip
    planets_dict(1,8) = yeclip

    m_di = m_di Mod 360
    m_kr = m_kr Mod 360
    m_ou = m_ou Mod 360

    di_diat1 = -0.332 * Sin(Rad(2 * m_di - 5 * m_kr - 67.6))
    di_diat2 = -0.056 * Sin(Rad(2 * m_di - 2 * m_kr + 21))
    di_diat3 = 0.042 * Sin(Rad(3 * m_di - 5 * m_kr + 21))
    di_diat4 = -0.036 * Sin(Rad(m_di - 2 * m_kr))
    di_diat5 = 0.022 * Cos(Rad(m_di - m_kr))
    di_diat6 = 0.023 * Sin(Rad(2 * m_di - 3 * m_kr + 52))
    di_diat7 = -0.016 * Sin(Rad(m_di - 5 * m_kr - 69))

    kr_diat1 = 0.812 * Sin(Rad(2 * m_di - 5 * m_kr - 67.6))
    kr_diat2 = -0.229 * Cos(Rad(2 * m_di - 4 * m_kr - 2))
    kr_diat3 = 0.119 * Sin(Rad(m_di - 2 * m_kr - 3))
    kr_diat4 = 0.046 * Sin(Rad(2 * m_di - 6 * m_kr - 69))
    kr_diat5 = 0.014 * Sin(Rad(m_di - 3 * m_kr + 32))

    kr_diat6 = -0.02 * Cos(Rad(2 * m_di - 4 * m_kr - 2))
    kr_diat7 = 0.018 * Sin(Rad(2 * m_di - 6 * m_kr - 49))

    ou_diat1 = 0.04 * Sin(Rad(m_kr - 2 * m_ou + 6))
    ou_diat2 = 0.035 * Sin(Rad(m_kr - 3 * m_ou + 33))
    ou_diat3 = -0.015 * Sin(Rad(m_di - m_ou + 20))

    diataraxes_long_di = (di_diat1 + di_diat2 + di_diat3 + di_diat4 + di_diat5 + di_diat6 + di_diat7)
    diataraxes_long_kr = (kr_diat1 + kr_diat2 + kr_diat3 + kr_diat4 + kr_diat5)
    diataraxes_lat_kr = (kr_diat6 + kr_diat7)
    diataraxes_long_ou = (ou_diat1 + ou_diat2 + ou_diat3)

    long2_di = Rad(long2_di + diataraxes_long_di)
    long2_kr = Rad(long2_kr + diataraxes_long_kr)
    coslat2_kr  = Cos(Rad(coslat2_kr + diataraxes_lat_kr))
    long2_ou = Rad(long2_ou + diataraxes_long_ou)

    planets_dict(0,5) = r_di * Cos(long2_di) * coslat2_di
    planets_dict(1,5) = r_di * Sin(long2_di) * coslat2_di
    planets_dict(0,6) = r_kr * Cos(long2_kr) * coslat2_kr
    planets_dict(1,6) = r_kr * Sin(long2_kr) * coslat2_kr
    planets_dict(0,7) = r_ou * Cos(long2_ou) * coslat2_ou
    planets_dict(1,7) = r_ou * Sin(long2_ou) * coslat2_ou

End Sub
