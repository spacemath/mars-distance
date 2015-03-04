# Degrees to radians.
deg2rad = (a) -> a*pi/180

# Define sin/cos to use degrees.
sinRad = sin
cosRad = cos
sin = (a) -> sinRad(deg2rad(a))
cos = (a) -> cosRad(deg2rad(a))

# Distance between two points on Mars.
# (x1, y1) = long/lat of first point.
# (x2, y2) = long/lat of second point.
distance = (x1, y1, x2, y2) ->
    D = 3390
    D * acos( sin(y1)*sin(y2) + 
        cos(y1)*cos(y2)*cos(x1-x2) )

# Export distance function.
$blab.distance = distance
