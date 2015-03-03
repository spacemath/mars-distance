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
		
	invertX: (x) -> @limit @mx.invert(x), 180
		
	invertY: (y) ->  @limit @my.invert(y), 90
		
	limit: (z, m) ->
		return m if z>m
		return -m if z<-m
		z
		
	gridLine: (x1, y1, x2, y2) ->
		@surface.append("line")
			.attr("x1", @mx(x1))
			.attr("y1", @my(y1))
			.attr("x2", @mx(x2))
			.attr("y2", @my(y2))
			.attr("class", "grid-line")


class d3Object
	
	constructor: (@canvas, @x, @y, @cb) ->
		
		@container = @canvas.surface
		
		@mx = @canvas.mx
		@my = @canvas.my
		
		@append @mx(@x), @my(@y)
		
		@obj.call(
			d3.behavior
			.drag()
			.on("drag", => 
				@move(d3.event.x, d3.event.y)
				@cb()
			)
		)
		
	append: (x, y) ->
		#Override in subclass
			
	transform: (x, y) ->
		@obj.attr "transform", "translate(#{x}, #{y})"
		
	move: (x, y) ->
		@x = @canvas.invertX(x)
		@y = @canvas.invertY(y)
		@transform @mx(@x), @my(@y)
	
class Circle extends d3Object
	
	constructor: (@canvas, @x, @y, @r=10, @cb) ->
		super @canvas, @x, @y, @cb
		
	append: (x, y) ->
		@obj = @container.append("circle")
			.attr("r", @r)
			.attr("class", "circle")
		@transform x, y


class Impact extends d3Object

	constructor: (@canvas, @x, @y, @r=10, @cb) ->
		super @canvas, @x, @y, @cb
		
	append: (x, y) ->
		@obj = @container.append('g')
			.attr('width', 2*@r)
			.attr('height', 2*@r)
		@obj.append("circle").attr("r", r).attr("class", "circle") for r in [@r, 0.6*@r, 0.2*@r]
		@transform x, y


class Image extends d3Object
	
	constructor: (@canvas, @x, @y, @width, @height, @cb) ->
		super @canvas, @x, @y, @cb

	append: (x, y) ->
		@obj = @container.append("svg:image")
			.attr("xlink:href", "lander.png")
			.attr("width", @width)
			.attr("height", @height)
			.attr("class", "d3-image")
		@transform x, y
			
	transform: (x, y) ->
		@obj.attr "transform", "translate(#{x - @width / 2}, #{y - @height / 2})"


mars = $ "#mars-image"
canvas = new Canvas mars
$blab.image = (x, y, cb) -> new Image(canvas, x, y, 80, 80, (-> cb()))
$blab.circle = (x, y, cb) -> new Circle(canvas, x, y, 10, (-> cb()))
$blab.impact = (x, y, cb) -> new Impact(canvas, x, y, 15, (-> cb()))
