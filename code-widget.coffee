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