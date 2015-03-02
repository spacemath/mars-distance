mars = $ '#mars-image'

width = mars.width()
height = mars.height()

mx = d3.scale.linear()
    .domain([221, -221])
    .range([0, width]) 

my = d3.scale.linear()
    .domain([-131, 131])
    .range([height, 0])

canvas = d3.select '#overlay'
canvas.selectAll("svg").remove()
svg = canvas.append "svg"

svg.attr("id", "plot")
	.attr('width', width)
	.attr('height', height)
	
surface = svg.append('g')
	.attr('width', width)
	.attr('height', height)
	.attr('id', 'surface')

gridLine = (x1, y1, x2, y2) ->
	surface.append("line")
		.attr("x1", mx(x1))
		.attr("y1", my(y1))
		.attr("x2", mx(x2))
		.attr("y2", my(y2))
		.attr("class", "grid-line")

gridLine(-180, y, 180, y) for y in [-90..90] by 10
gridLine(x, -90, x, 90) for x in [-180..180] by 10

calcDistance = (Lx, Ly, Ix, Iy) ->
	
	pi = Math.PI
	sin = (a) -> Math.sin(a*pi / 180)
	cos = (a) -> Math.cos(a*pi / 180)
	D = 3390
	d = D * Math.acos(sin(Ly)*sin(Iy) + cos(Ly)*cos(Iy)*cos(Ix-Lx))
	
	l = (s, x) -> $(s).html(Math.round(10*x) / 10 + "<sup>&deg;</sup>")
	l("#lander-lat", Ly)
	l("#lander-long", Lx)
	l("#impact-lat", Iy)
	l("#impact-long", Ix)
	$("#distance").text(Math.round(d) + " km")

class Circle
	
	constructor: (@container, @x, @y, @r=10, @cb) ->
		
		x = mx(@x)
		y = my(@y)
		
		@obj = @container.append("circle")
			.attr("transform", "translate(#{x}, #{y})")
			.attr("r", @r)
			.attr("class", "circle")
				
		@obj.call(
			d3.behavior
			.drag()
			.on("drag", => @move(d3.event.x, d3.event.y, @cb))
		)
	
	move: (x, y, cb) ->
		xx = if x>0 then Math.max(0, Math.min(width, x)) else 0
		yy = if y>0 then Math.max(0, Math.min(height, y)) else 0
		@obj.attr "transform", "translate(#{xx}, #{yy})"
		@x = mx.invert(x)
		@y = my.invert(y)
		cb()
		
cb = -> calcDistance(lander.x, lander.y, impact.x, impact.y)
lander = new Circle(surface, -129.6, 5.4, 10, (-> cb()))
impact = new Circle(surface, -10.8, 36, 10, (-> cb()))
cb()


