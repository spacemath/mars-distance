setCoords = (Lx, Ly, Ix, Iy) ->
    
    d = $blab.distance Lx, Ly, Ix, Iy
    
    l = (s, x) -> $(s).html(Math.round(10*x) / 10 + "<sup>&deg;</sup>")
    l("#lander-lat", Ly)
    l("#lander-long", Lx)
    l("#impact-lat", Iy)
    l("#impact-long", Ix)
    
    $("#distance").text(Math.round(d) + " km")

impact = $blab.impact -10.8, 36, (-> set())
lander = $blab.lander -129.6, 5.4, (-> set())

set = -> setCoords(lander.x, lander.y, impact.x, impact.y)
set()
