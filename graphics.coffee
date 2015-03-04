$blab.noGitHubRibbon = true;

codeWidget = ->
	distanceCode = $ "#distance-code"
	distanceCode.hide()
	delay = 1000
	$("#distance-toggle").click ->
		if distanceCode.is(":visible")
			distanceCode.hide delay
		else
			distanceCode.show 0, ->
				$("html, body").animate({scrollTop: $(document).height()}, delay)
		false

codeWidget()
    
class Canvas
	
	mapSrc: "map.png"
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

canvasObjects = (canvas) ->
	
	setCoords = ->
	
		Lx = $blab.lander?.x ? 0
		Ly = $blab.lander?.y ? 0
		Ix = $blab.impact?.x ? 0
		Iy = $blab.impact?.y ? 0
	
		l = (s, x) -> $(s).html(Math.round(10*x) / 10 + "<sup>&deg;</sup>")
		l("#lander-lat", Ly)
		l("#lander-long", Lx)
		l("#impact-lat", Iy)
		l("#impact-long", Ix)
	
		d = $blab.distance?(Lx, Ly, Ix, Iy) ? 0
		$("#distance").text(Math.round(d) + " km")
	
	$blab.impact = new ImageCircle
			canvas: canvas
			image: "meteor.png"
			label: "Impact"
			x: -10.8
			y: 36
			r: 25
			cb: (-> setCoords())

	$blab.lander = new ImageCircle
			canvas: canvas
			image: "lander.png"
			label: "Lander"
			x: -129.6
			y: 5.4
			r: 25
			cb: (-> setCoords())


new Canvas((canvas) -> canvasObjects(canvas))

#$(document).on "setPos", (evt, data) ->
	#setCoords()
