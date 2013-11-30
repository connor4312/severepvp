$(document).ready ->

	# Configure -----------------------------------------------------------

	ratio = 1920 / 1080

	backgroundDetail = 100
	backgroundBlur = 4

	fps = 
		video: 1000 / 30
		background: 1000 / 15

	# End Configure -------------------------------------------------------

	$canvas = $('#canvas')
	$video  = $('#video')

	ctx    = $canvas[0].getContext('2d')

	d3canvassize = 
		width : Math.round(backgroundDetail * ratio)
		height: Math.round(backgroundDetail)

	screen = {}

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

	$(window).on 'resize', setsizes

	###
	$video[0].play()
	do draw = ->
		if not @paused and not @ended
			ctx.drawImage $video[0], 0, 0, screen.width, screen.height
			setTimeout draw, fps.video
		else
			openMenu()
	###

	makeAuxCanvas = ->

		elem = $('<canvas />')
		$('#hidebox').append elem

		return elem
	
	

	scene = new Phoria.Scene()
	scene.camera.position = { x: 1, y: 1, z: 1 }
	scene.camera.lookat = { x: 0, y: 0, z: 0 }
	scene.perspective.near = 0.05
	scene.perspective.far = 5
	scene.perspective.aspect = d3canvassize.width / d3canvassize.height
	scene.viewport.width = d3canvassize.width
	scene.viewport.height = d3canvassize.height

	

	#openMenu = _.after 2, ->
	openMenu = ->
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

			planes[i].textures.push bitmaps[i]
			planes[i].polygons[0].texture = 0

			scene.graph.push planes[i]
		
		rotdeg = 0

		($d3canvas = makeAuxCanvas()).attr
			width: d3canvassize.width
			height: d3canvassize.height

		d3canvas = $d3canvas[0]
		d3canvasctx = d3canvas.getContext '2d'

		renderer = new Phoria.CanvasRenderer d3canvas

		do fmAnimate = ->
			
			rotdeg += 0.02

			scene.camera.lookat.x = Math.cos(rotdeg) * 0.1
			scene.camera.lookat.y = Math.sin(rotdeg) * 0.1
			#scene.camera.position.x = Math.cos(rotdeg) * 10
			#scene.camera.position.y = Math.sin(rotdeg) * 10

			scene.modelView()
			renderer.render(scene);

			stackBlurCanvasRGB d3canvasctx, 0, 0, d3canvassize.width, d3canvassize.height, backgroundBlur
			ctx.drawImage d3canvas, 0, 0, screen.width, screen.height

			setTimeout fmAnimate, fps.background

	loader = new Phoria.Preloader()
	bitmaps = []

	for i in [0..2]
		bitmaps.push new Image()
		loader.addImage bitmaps[i], 'img/tex' + i + '.png'

	loader.onLoadCallback openMenu