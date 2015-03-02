mars = $ '#mars-image'

width = mars.width()
height = mars.height()

mx = d3.scale.linear()
    .domain([-221, 221])
    .range([0, width]) 

my = d3.scale.linear()
    .domain([-131, 131])
    .range([height, 0])

element = d3.select '#overlay'
element.selectAll("svg").remove()
obj = element.append "svg"

obj.attr("id", "plot")
	.attr('width', width)
	.attr('height', height)
	
surface = obj.append('g')
	.attr('width', width)
	.attr('height', height)
	.attr('id', 'space')

gridLine = (x1, y1, x2, y2) ->
	surface.append("line")
		.attr("x1", mx(x1))
		.attr("y1", my(y1))
		.attr("x2", mx(x2))
		.attr("y2", my(y2))
		.attr("class", "grid-line")

hGridLine = (y) -> gridLine -180, y, 180, y
vGridLine = (x) -> gridLine x, -90, x, 90

hGridLine y for y in [-90..90] by 10
vGridLine x for x in [-180..180] by 10

class Circle
	
	constructor: (@x, @y, @r=10) ->
		
		x = mx(@x)
		y = my(@y)
		
		@obj = surface.append("circle")
			.attr("transform", "translate(#{x}, #{y})")
			.attr("r", @r)
			.attr("class", "circle")
				
		@obj.call(
		    d3.behavior
		    .drag()
		    .on("drag", => @move(d3.event.x, d3.event.y))
		)
	
	move: (x, y) ->
	    xx = if x>0 then Math.max(0, Math.min(width, x)) else 0
	    yy = if y>0 then Math.max(0, Math.min(height, y)) else 0
	    @obj.attr "transform", "translate(#{xx}, #{yy})"
		
lander = new Circle(0, 0)
impact = new Circle(90, 60)

