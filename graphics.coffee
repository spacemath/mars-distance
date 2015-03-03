$blab.noGitHubRibbon = true;

distanceCode = $ "#distance-code"
distanceCode.hide()
$("#distance-toggle").click ->
    distanceCode.toggle()
    $("html, body").animate({scrollTop: $(document).height()}, "slow")
    false
    
class Canvas
	
	constructor: (@image) ->
		
		@width = @image.width()
		@height = @image.height()
		
		@mx = d3.scale.linear()
			.domain([221, -221])
			.range([0, @width]) 
		
		@my = d3.scale.linear()
			.domain([-131, 131])
			.range([@height, 0])
		
		@overlay = d3.select "#overlay"
		@overlay.selectAll("svg").remove()
		@svg = @overlay.append "svg"
		
		@svg.attr("id", "plot")
			.attr('width', @width)
			.attr('height', @height)
		
		@surface = @svg.append('g')
			.attr('width', @width)
			.attr('height', @height)
			.attr('id', 'surface')
		
		@gridLine(-180, y, 180, y) for y in [-90..90] by 10
		@gridLine(x, -90, x, 90) for x in [-180..180] by 10
		
	gridLine: (x1, y1, x2, y2) ->
		@surface.append("line")
			.attr("x1", @mx(x1))
			.attr("y1", @my(y1))
			.attr("x2", @mx(x2))
			.attr("y2", @my(y2))
			.attr("class", "grid-line")

class Circle
	
	constructor: (@canvas, @x, @y, @r=10, @cb) ->
		
		@container = @canvas.surface
		
		@mx = @canvas.mx
		@my = @canvas.my
		
		x = @mx(@x)
		y = @my(@y)
		
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
		xx = if x>0 then Math.max(0, Math.min(@canvas.width, x)) else 0
		yy = if y>0 then Math.max(0, Math.min(@canvas.height, y)) else 0
		@obj.attr "transform", "translate(#{xx}, #{yy})"
		@x = @mx.invert(x)
		@y = @my.invert(y)
		cb()

mars = $ "#mars-image"
canvas = new Canvas mars
$blab.circle = (x, y, cb) -> new Circle(canvas, x, y, 10, (-> cb()))

