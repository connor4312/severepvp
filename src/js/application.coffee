$(document).ready ->
	$canvas = $('#canvas')
	$video  = $('#video')

	ctx    = $canvas[0].getContext('2d')

	fps = 1000 / 30

	screen =
		width : $(window).width()
		height: $(window).height()

	$(window).on 'resize', do ->
		$canvas.attr
			width : screen.width
			height: screen.height
	###
	$video[0].play()
	do draw = ->
		if not @paused and not @ended
			ctx.drawImage $video[0], 0, 0, screen.width, screen.height
			setTimeout draw, fps
		else
			openMenu()
	###
	scene = new Phoria.Scene()
	scene.camera.position = {x:0.0, y:5.0, z:-15.0}
	scene.perspective.aspect = screen.width / screen.height
	scene.viewport.width = screen.width
	scene.viewport.height = screen.height

	renderer = new Phoria.CanvasRenderer(canvas);

	#openMenu = _.after 2, ->
	openMenu = ->
		c = Phoria.Util.generateUnitCube()
		cube = Phoria.Entity.create
			points: c.points,
			edges: c.edges,
			polygons: c.polygons
			style:
				shademode: "plain"

		for i in [0..5]
			cube.textures.push bitmaps[i]
			cube.polygons[i].texture = i

		scene.graph.push cube

		do fmAnimate = ->
			cube.rotateY(0.5*Phoria.RADIANS);

			scene.modelView()
			renderer.render(scene);

			setTimeout fmAnimate, fps

	loader = new Phoria.Preloader()
	bitmaps = []

	for i in [0..5]
		bitmaps.push new Image()
		loader.addImage bitmaps[i], 'img/panorama' + i + '.png'

	loader.onLoadCallback openMenu