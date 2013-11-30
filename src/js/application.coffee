$(document).ready ->
	$canvas = $('#canvas')
	$video  = $('#video')[0]

	ctx    = $canvas[0].getContext('2d')

	screen =
		width : $(window).width()
		height: $(window).height()

	$(window).on 'resize', do ->
		$canvas.width  screen.width
		$canvas.height screen.height

	video.play()
	do draw = ->
		if not @paused and not @ended
			ctx.drawImage video, 0, 0, screen.width, screen.height
			setTimeout draw, 1000 / 30