$(document).ready ->
	$canvas = $('#canvas')
	$video  = $('#video')

	ctx    = $canvas[0].getContext('2d')

	screen =
		width : $(window).width()
		height: $(window).height()

	$(window).on 'resize', do ->
		$canvas.attr
			width : screen.width
			height: screen.height

	$video[0].play()
	do draw = ->
		if not @paused and not @ended
			debugger;
			ctx.drawImage $video[0], 0, 0, screen.width, screen.height
		setTimeout draw, 1000 / 30