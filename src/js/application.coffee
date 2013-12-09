$(document).ready ->

	# Start Configure -----------------------------------------------------

	ratio = 1920 / 1080

	backgroundDetail = 100
	backgroundBlur = 4

	fps = 
		video: 1000 / 30
		background: 1000 / 30

	logo = 
		width: 561
		height: 137

	# End Configure -------------------------------------------------------

	# Start Global Setups -------------------------------------------------

	$canvas = $('#canvas')
	$video  = $('#video')

	ctx    = $canvas[0].getContext('2d')

	screen = {}

	$('.button').each (index) -> $(@).css('left', (index * 20) + '%')

	do setsizes = ->
		o_screen =
			width : $(window).width()
			height: $(window).height()

		if o_screen.height * ratio > o_screen.width
			screen =
				width : o_screen.width
				height: o_screen.width / ratio
		else
			screen =
				width : o_screen.height * ratio
				height: o_screen.height

		$canvas.attr
			width : screen.width
			height: screen.height

		$('#frame').css
			width: screen.width * 0.8
			height: screen.height * 0.8
			left: (o_screen.width - screen.width * 0.8) * 0.5
			top: (o_screen.height - screen.height * 0.8) * 0.5

	$(window).on 'resize', _.throttle(setsizes, 50)


	# End Global Setups ---------------------------------------------------

	# Start Video Stage ---------------------------------------------------
	
	setTimeout(
		->
			$video[0].play()
			do draw = ->
				if not $video[0].paused and not $video[0].ended
					ctx.drawImage $video[0], 0, 0, screen.width, screen.height
					setTimeout draw, fps.video
				else
					Renderer.start()
		, 1000
	)
	
	# End Vide Stoage -----------------------------------------------------
	
	# Start 3D Background -------------------------------------------------

	#openMenu = _.after 2, ->
	class Background
		constructor: ->
			#@pat = ctx.createPattern resources.bg, 'repeat'
			@off = 0
			@img =
				src: resources.bg
				width: 330
				height: 320

		fmAnimate: ->
			
			ctx.fillStyle = @pat;

			w = 0
			while w < screen.width
				h = @off

				while h < screen.height
					ctx.drawImage @img.src, w, h
					h += @img.height

				w += @img.width

			@off -= 1
			if -@off >= @bgh then @off = 0

	# End 3D Background ---------------------------------------------------

	# Start Render Tie-in -------------------------------------------------

	class RendererO
		constructor: ->
			@starter = _.after 2, ->
				@bg = new Background
				@render()

				setTimeout(
					->
						$('.button').each (index) ->
							setTimeout(
								=>
									$(@).addClass('active')
								, Math.round(Math.random() * 400)
							)
					, 300
				)

			@fadep = 0
			@stage = 0

			@motds = [
				'Vote Now!'
			]
			@motdIndex = Math.floor(Math.random() * @motds.length)
			@motdscale =
				up: false
				scale: 24
				min: 22,
				max: 26

			@buttons = []

		start: =>
			@starter()

		reset: ->
			ctx.globalAlpha = 1

		logoAndMotd: ->

			ctx.drawImage resources.logo, screen.width * 0.5 - logo.width * 0.5, 50

			textPos =
				x: screen.width * 0.5 + logo.width * 0.5 - 60
				y: 50 + logo.height - 60
				width: 200

			ctx.font = Math.round(@motdscale.scale) + 'px Minecraft'
			ctx.fillStyle = '#666600'
			ctx.textBaseline = 'top'

			ctx.save();
			ctx.translate textPos.x, textPos.y
			ctx.rotate -Math.PI * 0.25
			ctx.textAlign = 'center'

			ctx.fillStyle = '#666600'
			ctx.fillText @motds[@motdIndex], 3, 3, textPos.width
			ctx.fillStyle = '#ffff00'
			ctx.fillText @motds[@motdIndex], 0, 0, textPos.width

			ctx.restore();

			if @motdscale.up
				@motdscale.scale += 0.5
				if @motdscale.scale >= @motdscale.max
					@motdscale.up = false
			else
				@motdscale.scale -= 0.5
				if @motdscale.scale <= @motdscale.min
					@motdscale.up = true

		credits: ->
			ctx.font = '16px Minecraft'
			ctx.fillStyle = '#444444'
			ctx.textBaseline = 'bottom'

			ctx.textAlign = 'left'
			ctx.fillText '(c) 2013 SeverePVP: Release 1.0', 5, screen.height - 5

			ctx.textAlign = 'right'
			ctx.fillText 'Coded by Vector Media', screen.width - 5, screen.height - 5

		render: =>

			if @stage is 1 or @stage is 2
				@bg.fmAnimate()
				@logoAndMotd()
				@credits()

			if @stage is 0
				if @fadep < 1
					ctx.globalAlpha = @fadep
					ctx.fillStyle = 'black'
					ctx.fillRect 0, 0, screen.width, screen.height
					@fadep += 0.2
				else @stage++
			
			if @stage is 1

				if @fadep > 0
					ctx.globalAlpha = @fadep
					ctx.fillStyle = 'black'
					ctx.fillRect 0, 0, screen.width, screen.height
					@fadep -= 0.03
				else @stage++

			@reset()
			setTimeout @render, fps.background

	Renderer = new RendererO

	# End Render Tie-in ---------------------------------------------------

	# Start Preloaders ----------------------------------------------------

	resources =
		bg: 'img/bg.png'
		logo: 'img/logo.png'
	loader = _.after _.keys(resources).length, Renderer.start

	for key, url of resources
		im = new Image()
		resources[key] = im
		im.onload = loader
		im.src = url

	# End Preloaders ------------------------------------------------------

	frame = 0
	maxframes = $('iframe').length - 1

	showFrame = (id = 0) ->
		frame = parseInt(id)
		$('#frame > iframe').css('display', 'none')
		$('#frame' + id).css('display', 'block')

	updateArrows = ->
		$('#larr, #rarr').css 'display', 'block'
		$('#larr').css('display', 'none') if frame is 1
		$('#rarr').css('display', 'none') if frame is maxframes

	$('a.frame').on 'click', (e) ->
		e.preventDefault()
		$('#fcontainer').addClass('active')

		id = $(@).attr('data-id') ? 0

		showFrame id
		updateArrows()

		if $(@).attr('href')
			$('#votebox').css 'visibility', 'hidden'
			$('#frame' + id).attr 'src', $(@).attr('href')

		return false

	$('#frame').on 'click', (e) ->
		e.stopPropagation()

	$('#voteclick').on 'click', (e) ->
		$('#votebox').css 'visibility', 'visible'

	$('#fcontainer, .close').on 'click', ->
		$('#fcontainer').removeClass('active')

	$('#larr').on 'click', ->
		showFrame frame - 1
		updateArrows()

	$('#rarr').on 'click', ->
		showFrame frame + 1
		updateArrows()