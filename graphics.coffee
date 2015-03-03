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
		
		@append @x, @y
		
		@obj.call(
			d3.behavior
			.drag()
			.on("drag", => 
				@move(d3.event.x, d3.event.y)
			)
		)
		
	append: (x, y) ->
		#Override in subclass
		
	move: (x, y) -> @pos @canvas.invertX(x), @canvas.invertY(y)
	
	pos: (@x, @y) ->
		@transform @mx(@x), @my(@y)
		@cb()
		#$.event.trigger "setPos", {obj: this}
	
	transform: (x, y) -> @obj.attr "transform", "translate(#{x}, #{y})"


class Circle extends d3Object
	
	constructor: (@canvas, @x, @y, @r=10, @cb) ->
		super @canvas, @x, @y, @cb
		
	append: (x, y) ->
		@obj = @container.append("circle")
			.attr("r", @r)
			.attr("class", "circle")
		@pos x, y


class ConcentricCircles extends d3Object

	constructor: (@canvas, @x, @y, @r=10, @cb) ->
		super @canvas, @x, @y, @cb
		
	append: (x, y) ->
		@obj = @container.append('g')
			.attr('width', 2*@r)
			.attr('height', 2*@r)
		@obj.append("circle").attr("r", r).attr("class", "circle") for r in [@r, 0.6*@r, 0.2*@r]
		@pos x, y


class Image extends d3Object
	
	constructor: (@canvas, @image, @x, @y, @width, @height, @cb) ->
		super @canvas, @x, @y, @cb

	append: (x, y) ->
		@obj = @container.append("svg:image")
			.attr("xlink:href", @image)
			.attr("width", @width)
			.attr("height", @height)
			.attr("class", "d3-image")
		@pos x, y
			
	transform: (x, y) ->
		@obj.attr "transform", "translate(#{x - @width / 2}, #{y - @height / 2})"


class ImageCircle extends d3Object
	
	constructor: (@spec) ->
		
		{@canvas, @image, @label, @x, @y, @r, @cb} = @spec
		
		@width = 1.8*@r
		@height = @width
		super @canvas, @x, @y, @cb

	append: (x, y) ->
		@obj = @container.append('g')
			.attr("width", @width)
			.attr("height", @height)
			.attr("class", "circle-image")
		
		@obj.append("circle").attr("r", @r)
		
		@image = @obj.append("svg:image")
			.attr("xlink:href", @image)
			.attr("transform", "translate(#{-@width / 2}, #{- @height / 2})")
			.attr("width", @width)
			.attr("height", @height)
				
		@obj.append("text")
		    .attr("x", 0)
		    .attr("y", @height)
			.attr("dy", "-.3em")
		    .text(@label)
		
		@pos x, y


mars = $ "#mars-image"
canvas = new Canvas mars

setCoords = ->
	
	Lx = $blab.lander?.x ? 0
	Ly = $blab.lander?.y ? 0
	Ix = $blab.impact?.x ? 0
	Iy = $blab.impact?.y ? 0
	
	d = $blab.distance?(Lx, Ly, Ix, Iy) ? 0
	
	l = (s, x) -> $(s).html(Math.round(10*x) / 10 + "<sup>&deg;</sup>")
	l("#lander-lat", Ly)
	l("#lander-long", Lx)
	l("#impact-lat", Iy)
	l("#impact-long", Ix)

	$("#distance").text(Math.round(d) + " km")

$blab.impact = new ImageCircle
		canvas: canvas
		image: "meteor.png"
		label: "Impact"
		x: -129.6
		y: 5.4
		r: 25
		cb: (-> setCoords())

$blab.lander = new ImageCircle
		canvas: canvas
		image: "lander.png"
		label: "Lander"
		x: -10.8
		y: 36
		r: 25
		cb: (-> setCoords())

#$(document).on "setPos", (evt, data) ->
	#setCoords()
