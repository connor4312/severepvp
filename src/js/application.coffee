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

	button =
		width: 289
		height: 123

	mainColor = '#1cafd4'

	buttonList = [
		{
			text: 'Forum'
			func: -> window.location = 'http://severepvp.net/community/'
		}
		{
			text: 'Vote'
			func: ->
		}
		{
			text: 'Shop'
			func: -> window.location = 'http://severepvp.buycraft.net/'
		}
		{
			text: 'Staff'
			func: ->
		}
		{
			text: 'Bans'
			func: -> window.location = 'http://severepvp.net/banmanagement/'
		}
	]

	# End Configure -------------------------------------------------------

	# Start Global Setups -------------------------------------------------

	$canvas = $('#canvas')
	$video  = $('#video')

	ctx    = $canvas[0].getContext('2d')

	screen = {}
	buttonsizes = {}

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
		
		buttonsizes = 
			width : Math.min(1000, screen.width * 0.8)
			height: Math.min(1000, screen.width * 0.8) * 0.1

		$canvas.attr
			width : screen.width
			height: screen.height

	$(window).on 'resize', _.throttle(setsizes, 50)


	# End Global Setups ---------------------------------------------------

	# Start Video Stage ---------------------------------------------------
	
	$video[0].play()
	do draw = ->
		if not $video[0].paused and not $video[0].ended
			ctx.drawImage $video[0], 0, 0, screen.width, screen.height
			setTimeout draw, fps.video
		else
			Renderer.start()
	
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

	# Start Button --------------------------------------------------------
	
	class Button
		constructor: (text, eve) ->
			@text = text
			@hovering = false
			@eve = eve
			@deg = Math.random() * Math.PI
			Renderer.buttons.push @

		calcRect: (index = 0, len = 1) ->
			factor = Math.min((screen.width * 0.8) / (len * (button.width + -30)), 1)
			spacing = -30 * factor

			return {
				factor: factor
				width: button.width * factor
				height: button.height * factor
				spacing: spacing
				y: (screen.height - button.height * factor) * 0.5
				x: (screen.width - (len * (button.width * factor + spacing))) * 0.5 + index * (button.width * factor + spacing)
				text_x: button.width * 0.5 * factor
				text_y: button.height * 1.9 * factor
			}

		render: (index, len) ->
			
			ctx.font = '24px Orbitron'
			ctx.textBaseline = 'middle'
			ctx.textAlign = 'center'

			debugger;
			i = @calcRect index, len

			ctx.drawImage resources.basePlate, i.x, i.y + 120 * i.factor, i.width, i.height
			ctx.drawImage resources['ico' + @text], i.x + (button.width - 128) * 0.5 * i.factor, i.y + Math.cos(@deg) * 20 * i.factor, 128 * i.factor, 128 * i.factor
			
			@deg += 0.05

			if @hovering
				styles = ['#666600', '#ffff00']
			else
				styles = ['#000000', '#ffffff']

			ctx.fillStyle = styles[0]
			ctx.fillText @text, i.x + i.text_x + 2, i.y + i.text_y + 2
			ctx.fillStyle = styles[1]
			ctx.fillText @text, i.x + i.text_x, i.y + i.text_y

	# End Button ----------------------------------------------------------

	# Start Render Tie-in -------------------------------------------------

	class RendererO
		constructor: ->
			@starter = _.after 2, ->
				@bg = new Background

				for b in buttonList
					new Button(b.text, b.func)

				@render()
				menuTriggers()

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

		renderButtons: =>
			l = @buttons.length
			for b, index in @buttons
				b.render(index, l)


		render: =>

			if @stage is 1 or @stage is 2
				@bg.fmAnimate()
				@renderButtons()
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
		basePlate: 'img/baseplate.png'
		logo: 'img/logo.png'
		icoBans: 'img/ico-bans.png'
		icoForum: 'img/ico-forum.png'
		icoShop: 'img/ico-shop.png'
		icoStaff: 'img/ico-staff.png'
		icoVote: 'img/ico-vote.png'

	loader = _.after _.keys(resources).length, Renderer.start

	for key, url of resources
		im = new Image()
		resources[key] = im
		im.onload = loader
		im.src = url

	# End Preloaders ------------------------------------------------------

	# Document Triggers ---------------------------------------------------

	menuTriggers = ->

		getMousePos = (canvas, evt) ->
			rect = $canvas[0].getBoundingClientRect()
			return {
				x: evt.clientX - rect.left,
				y: evt.clientY - rect.top
			}


		$canvas.on 'mousemove', _.throttle(
			(evt) ->
				mousePos = getMousePos canvas, evt
				tick = false
				for b, index in Renderer.buttons
					i = b.calcRect(index, Renderer.buttons.length)
					if mousePos.x > i.x and mousePos.y > i.y and mousePos.x < i.x + i.width and mousePos.y < i.y + i.height * 2
						b.hovering = true
						$canvas.css 'cursor', 'pointer'
						tick = true
					else
						b.hovering = false

				if tick is true
					$canvas.css 'cursor', 'pointer'
				else 
					$canvas.css 'cursor', 'auto'

			, fps.background * 0.5
		)

		$canvas.on 'click', ->
			for b, index in Renderer.buttons
				if b.hovering is true then b.eve()