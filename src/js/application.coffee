$(document).ready ->

	# Start Configure -----------------------------------------------------

	ratio = 1920 / 1080

	backgroundDetail = 100
	backgroundBlur = 4

	fps = 
		video: 1000 / 30
		background: 1000 / 15

	logo = 
		width: 561
		height: 137

	button =
		width: 1000
		height: 100


	# End Configure -------------------------------------------------------

	# Start Global Setups -------------------------------------------------

	$canvas = $('#canvas')
	$video  = $('#video')

	ctx    = $canvas[0].getContext('2d')

	d3canvassize = 
		width : Math.round(backgroundDetail * ratio)
		height: Math.round(backgroundDetail)

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

	$(window).on 'resize', setsizes

	makeAuxCanvas = ->
		elem = $('<canvas />')
		$('#hidebox').append elem

		return elem

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

			@makeScene()

			s = 1

			sets = [
				{
					points: [{x: s, y: 0, z: 0}, {x: 0, y: 0, z: 0}, {x: 0, y: s, z: 0}, {x: s, y: s, z: 0}],
					edges: [{a: 0, b: 1}, {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 4}]
					polygons: [{vertices: [3..0]}]
				}
				{
					points: [{x: 0, y: 0, z: 0}, {x: 0, y: 0, z: s}, {x: s, y: 0, z: s}, {x: s, y: 0, z: 0}],
					edges: [{a: 0, b: 1}, {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 4}]
					polygons: [{vertices: [0..3]}]
				}
				{
					points: [{x: 0, y: s, z: 0}, {x: 0, y: s, z: s}, {x: 0, y: 0, z: s}, {x: 0, y: 0, z: 0}],
					edges: [{a: 0, b: 1}, {a: 1, b: 2}, {a: 2, b: 3}, {a: 3, b: 4}]
					polygons: [{vertices: [0..3]}]
				}
			]

			planes = []

			for item, i in sets
				planes[i] = Phoria.Entity.create
					points: item.points
					edges: item.edges
					polygons: item.polygons
					style:
						shademode: "plain"

				planes[i].textures.push resources['tex' + i]
				planes[i].polygons[0].texture = 0

				@scene.graph.push planes[i]
			
			@rotdeg = 0

			($d3canvas = makeAuxCanvas()).attr
				width: d3canvassize.width
				height: d3canvassize.height

			@d3canvas = $d3canvas[0]
			@d3canvasctx = @d3canvas.getContext '2d'

			@d3renderer = new Phoria.CanvasRenderer @d3canvas

		makeScene: ->
			@scene = new Phoria.Scene()
			@scene.camera.position = { x: 1, y: 1, z: 1 }
			@scene.camera.lookat = { x: 0, y: 0, z: 0 }
			@scene.perspective.near = 0.05
			@scene.perspective.far = 5
			@scene.perspective.aspect = d3canvassize.width / d3canvassize.height
			@scene.viewport.width = d3canvassize.width
			@scene.viewport.height = d3canvassize.height

		fmAnimate: ->
			
			@rotdeg += 0.02

			@scene.camera.lookat.x = Math.cos(@rotdeg) * 0.1
			@scene.camera.lookat.y = Math.sin(@rotdeg) * 0.1

			@scene.modelView()
			@d3renderer.render(@scene);

			stackBlurCanvasRGB @d3canvasctx, 0, 0, d3canvassize.width, d3canvassize.height, backgroundBlur
			ctx.drawImage @d3canvas, 0, 0, screen.width, screen.height

	# End 3D Background ---------------------------------------------------

	# Start Button --------------------------------------------------------
	
	class Button
		constructor: (text) ->
			@text = text
			@hovering = false
			Renderer.buttons.push @

		calcRect: (index = 0) ->
			factor = Math.min(screen.width * 0.75, 600) / 1000

			return {
				width: button.width * factor
				height: button.height * factor
				spacing: 10
				y: 130 + logo.height + (((button.height * factor) + 10) * index)
				x: (screen.width - button.width * factor) * 0.5
				text_x: screen.width * 0.5
				text_y: (button.height * factor) * 0.5
			}

	# End Button ----------------------------------------------------------

	# Start Render Tie-in -------------------------------------------------

	class RendererO
		constructor: ->
			@starter = _.after 2, ->
				@bg = new Background
				new Button('Button 1')
				new Button('Button 2')
				new Button('Button 3')
				@render()

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
			ctx.font = '24px Minecraft'
			ctx.fillStyle = '#ffffff'
			ctx.textBaseline = 'bottom'

			ctx.textAlign = 'left'
			ctx.fillText '(C) SeverePVP: Release 1.0', 5, screen.height - 5

			ctx.textAlign = 'right'
			ctx.fillText 'Coded by Vector Media', screen.width - 5, screen.height - 5

		renderButtons: =>
			factor = Math.min(screen.width * 0.75, 600) / 1000
			
			ctx.font = Math.round(button.height * factor * 0.33) + 'px Minecraft'
			ctx.textBaseline = 'middle'
			ctx.textAlign = 'center'

			for b, index in @buttons

				i = b.calcRect(index)

				if b.hovering is true
					ctx.drawImage resources.buttonActive, i.x, i.y, i.width, i.height
				else
					ctx.drawImage resources.buttonInactive, i.x, i.y, i.width, i.height
				
				ctx.fillStyle = '#000000'
				ctx.fillText b.text, i.text_x + 2, i.y + i.text_y + 2
				ctx.fillStyle = '#ffffff'
				ctx.fillText b.text, i.text_x, i.y + i.text_y


		render: =>

			if @stage is 1 or @stage is 2
				@bg.fmAnimate()
				@logoAndMotd()
				@renderButtons()
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

	loader = new Phoria.Preloader()

	resources =
		tex0: 'img/tex0.png'
		tex1: 'img/tex1.png'
		tex2: 'img/tex2.png'
		buttonInactive: 'img/button-inactive.png'
		buttonActive  : 'img/button-active.png'
		logo: 'img/logo.png'

	for key, url of resources
		im = new Image()
		resources[key] = im
		loader.addImage im, url

	loader.onLoadCallback Renderer.start

	# End Preloaders ------------------------------------------------------

	# Document Triggers ---------------------------------------------------

	getMousePos = (canvas, evt) ->
		rect = $canvas[0].getBoundingClientRect()
		return {
			x: evt.clientX - rect.left,
			y: evt.clientY - rect.top
		}


	$canvas[0].addEventListener 'mousemove', _.throttle(
		(evt) ->
			mousePos = getMousePos canvas, evt

			for b, index in Renderer.buttons
				i = b.calcRect(index)
				if mousePos.x > i.x and mousePos.y > i.y and mousePos.x < i.x + i.width and mousePos.y < i.y + i.height
					b.hovering = true
				else
					b.hovering = false
		, fps.background * 0.5
	)
