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
	
	$video[0].play()
	do draw = ->
		if not @paused and not @ended
			ctx.drawImage $video[0], 0, 0, screen.width, screen.height
			setTimeout draw, fps
		else
			openMenu()
	
	scene = new Phoria.Scene()
	scene.camera.position = { x: 1, y: 1, z: 1 }
	scene.camera.lookat = { x: 0, y: 0, z: 0 }
	scene.perspective.near = 0.05
	scene.perspective.far = 5
	scene.perspective.aspect = screen.width / screen.height
	scene.viewport.width = screen.width
	scene.viewport.height = screen.height

	renderer = new Phoria.CanvasRenderer(canvas);

	openMenu = _.after 2, ->
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

		do fmAnimate = ->

			rotdeg += 0.01

			scene.camera.lookat.x = Math.cos(rotdeg) * 0.1
			scene.camera.lookat.y = Math.sin(rotdeg) * 0.1
			#scene.camera.position.x = Math.cos(rotdeg) * 10
			#scene.camera.position.y = Math.sin(rotdeg) * 10

			scene.modelView()
			renderer.render(scene);

			setTimeout fmAnimate, fps

	loader = new Phoria.Preloader()
	bitmaps = []

	for i in [0..2]
		bitmaps.push new Image()
		loader.addImage bitmaps[i], 'img/tex' + i + '.png'

	loader.onLoadCallback openMenu