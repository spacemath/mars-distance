class Canvas
	
	mapSrc: "../resources/images/mars-map.png"
	xMax: 180
	yMax: 90
	gridStep: 10
	mapMargin: 41
	
	constructor: (@callback) ->
		@mapImage = new Image
		@mapImage.src = @mapSrc
		@mapImage.onload = =>
			@width = @mapImage.width
			@height = @mapImage.height
			@create()
			@callback this
		
	create: ->
		
		@overlay = d3.select "#map"
		@overlay.selectAll("svg").remove()
		@svg = @overlay.append("svg")
			.attr('width', @width)
			.attr('height', @height)
			
		@surface = @svg.append("g")
			.attr("width", @width)
			.attr("height", @height)
		
		@mx = d3.scale.linear()
			.domain([@xMax + @mapMargin, -(@xMax + @mapMargin)])
			.range([0, @width]) 
		
		@my = d3.scale.linear()
			.domain([-(@yMax + @mapMargin), @yMax + @mapMargin])
			.range([@height, 0])
			
		@map()
		
		$("#map-preloader").remove()
		
	invertX: (x) -> @limit @mx.invert(x), @xMax
	
	invertY: (y) ->  @limit @my.invert(y), @yMax
		
	limit: (z, m) ->
		return m if z>m
		return -m if z<-m
		z
	
	map: ->
		@surface.append("svg:image")
			.attr("xlink:href", @mapSrc)
			.attr("width", @width)
			.attr("height", @height)
		@legend()
		@gridLine(-@xMax, y, @xMax, y) for y in [-@yMax..@yMax] by @gridStep
		@gridLine(x, -@yMax, x, @yMax) for x in [-@xMax..@xMax] by @gridStep
	
	legend: ->
		$("#map-legend").append("<span style='color:red'>Red=+3000 meters</span>, <span style='color:blue'>Blue=-4000 meters</span>")
		
	gridLine: (x1, y1, x2, y2) ->
		@surface.append("line")
			.attr("x1", @mx(x1))
			.attr("y1", @my(y1))
			.attr("x2", @mx(x2))
			.attr("y2", @my(y2))
			.attr("class", "grid-line")


class d3Object
	
	constructor: (@canvas, @x, @y, @draggable, @cb) ->
		
		@container = @canvas.surface
		
		@mx = @canvas.mx
		@my = @canvas.my
		
		@append @x, @y
		
		@setDraggable() if @draggable
		
	append: (x, y) ->
		#Override in subclass
	
	setDraggable: ->
		@obj.call(
			d3.behavior
			.drag()
			.on("drag", => 
				@move(d3.event.x, d3.event.y)
			)
		)
	
	move: (x, y) -> @pos @canvas.invertX(x), @canvas.invertY(y)
	
	pos: (@x, @y) ->
		@transform @mx(@x), @my(@y)
		@cb()
		#$.event.trigger "setPos", {obj: this}
	
	transform: (x, y) -> @obj.attr "transform", "translate(#{x}, #{y})"


class ImageCircle extends d3Object
	
	constructor: (@spec) ->
		
		{@canvas, @image, @label, @x, @y, @r, @draggable, @cb} = @spec
		
		@width = 1.8*@r
		@height = @width
		super @canvas, @x, @y, @draggable, @cb

	append: (x, y) ->
		@obj = @container.append('g')
			.attr("width", @width)
			.attr("height", @height)
			.attr("class", "circle-image"+(if @draggable then " draggable" else ""))
		
		@obj.append("circle").attr("r", @r)
		
		@image = @obj.append("svg:image")
			.attr("xlink:href", @image)
			.attr("transform", "translate(#{-@width/2}, #{-@height/2})")
			.attr("width", @width)
			.attr("height", @height)
				
		@obj.append("text")
		    .attr("x", 0)
		    .attr("y", @height)
			.attr("dy", "-.3em")
		    .text(@label)
		
		@pos x, y


class LanderAndImpact

	constructor: (@canvas, @setCoordsCallback) ->
		
		# Default objects before construction.
		# This is needed so that setCoords can be called before both objects constructed.
		@lander = x: 0, y: 0
		@impact = x: 0, y: 0
		
		@impact = new ImageCircle
			canvas: @canvas
			image: "../resources/images/meteor.png"
			label: "Impact"
			x: -10.8
			y: 36
			r: 25
			draggable: true
			cb: (=> @setCoords())

		@lander = new ImageCircle
			canvas: @canvas
			image: "../resources/images/lander.png"
			label: "Lander"
			# +3North and -135 East. 
			x: -135
			y: 3
			r: 25
			draggable: false
			cb: (=> @setCoords())

	setCoords: ->
		
		Lx = @lander.x
		Ly = @lander.y
		Ix = @impact.x
		Iy = @impact.y

		l = (s, x) -> $(s).html(Math.round(10*x)/10 + "<sup>&deg;</sup>")
		l("#lander-lat", Ly)
		l("#lander-long", Lx)
		l("#impact-lat", Iy)
		l("#impact-long", Ix)
		
		# TODO: d should be prop?  Coords doc interface should be separate obj/class?
		@distance = $blab.distance?(Lx, Ly, Ix, Iy) ? 0
		$("#distance").text(Math.round(@distance) + " km")
		
		@setCoordsCallback?(this)

# Exports
$blab.Canvas = Canvas
$blab.LanderAndImpact = LanderAndImpact

# Event handling - not used.
$(document).on "setPos", (evt, data) ->
