#### cuddler 2 rot



extends PanelContainer


@onready var spin_sound = $Sound/Spin
signal spinning

var cuddler_scene = preload("res://cuddler.tscn")

#squares labeled 0 thru 7 from right and xclockwise.
# [0,5] means a line goes from Right square (0) to Lower Left square (5)
var default_colors = [
	'DARK_ORCHID',
	'DARK_ORANGE',
	'CORNFLOWER_BLUE',
	'CHARTREUSE'
]
var color_to_index = {
	'DARK_ORCHID':[0,5],
	'DARK_ORANGE':[1,6],
	'CORNFLOWER_BLUE':[2,4],
	'CHARTREUSE':[3,7]
}
var cuddle_colors = [
	Color('DARK_ORCHID'),
	Color('DARK_ORANGE'),
	Color('CORNFLOWER_BLUE'),
	Color('CHARTREUSE'),
	Color('CORNFLOWER_BLUE'),
	Color('DARK_ORCHID'),
	Color('DARK_ORANGE'),
	Color('CHARTREUSE'),
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.initialize()
	button.pressed.connect(self._on_button_pressed)

func initialize():
	button = $Button
	update_colors()

func _on_button_pressed():
	rotate_90()
	return null

# prevents pushing the button until rotation animation is complete
func disable_button():
	button.disabled = true
	return null

#changes cuddle_colors list and actual colors of blocks
func update_colors():
	#print('Updating colors on cube:')
	#color_to_index: which squares have color color_to_index[name]?
	for color_name in color_to_index:
		for index in color_to_index[color_name]:
			#change the list of colors
			cuddle_colors[index] = Color(color_name)
			#change the actual square color
			#print('edge blocks:')
			#print(edge_blocks)
			#print('cuddle colors:')
			#print(cuddle_colors)
			edge_blocks[index].color = cuddle_colors[index]
	lighten_block_colors()
	return null

func rotate_90():
	var visual_square = cuddler_scene.instantiate()
	#visual_square.set_script('res://cuddler.gd')
	
	visual_square.initialize()
	visual_square.cuddle_colors = self.cuddle_colors.duplicate(true)
	visual_square.color_to_index = self.color_to_index.duplicate(true)
	visual_square.edge_blocks = self.edge_blocks.duplicate(true)
	visual_square.disable_button()
	visual_square.update_colors()
	
	#place the visual square over myself
	visual_square.global_position = self.global_position
	get_tree().root.add_child(visual_square)
	#self.add_child(visual_square)
	
	# "hide" the real square
	#print('hiding square')
	self.modulate.a = 0
	
	#rotate colors on the real square's color tracker.
	for color_name in color_to_index:
		var index_pair = color_to_index[color_name]
		index_pair[0] = (index_pair[0] + 2)%8
		index_pair[1] = (index_pair[1] + 2)%8
		color_to_index[color_name] = index_pair
	
	#change the real square's colors
	update_colors()
	
	#emit a sound
	var spin_sound_pitch_width = 0.1
	spin_sound.pitch_scale = 2. + (randf()-0.5)*spin_sound_pitch_width
	spin_sound.play()
	
	#wait for the spinning square to finish
	await visual_square.spin(self)
	
	#"show" self
	
	#print('showing square')
	self.modulate.a = 1
	visual_square.queue_free()
	
	#visual_square.queue_free()
	button.release_focus()

	return null
	
#animation for transient squares
func spin(creator_node):
	#print(get_size())
	await get_tree().process_frame  # wait one frame to ensure size is settled
	self.size = creator_node.size
	self.pivot_offset = self.size / 2
	#self.pivot_offset = get_size()
	var spin_tween = create_tween()
	var spin_time = 0.12
	#var spin_time = 3
	spin_tween.tween_property(self,"rotation", -PI/2, spin_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	spin_tween.tween_callback(self.queue_free)
	#spin_tween.tween_callback(creator_node.show)
	await spin_tween.finished
	#update_colors()
	return spin_tween.finished



#func rotate_45():
	#var first_block_color = edge_blocks[0].color
	#for block_index in range(len(edge_blocks) - 1):
		#var this_block = edge_blocks[block_index]
		#var next_block = edge_blocks[block_index + 1]
		#this_block.color = next_block.color
	#edge_blocks[-1].color = first_block_color
	#return null
#
#
#func rotate_90():
	#var first_block_color = edge_blocks[0].color
	#var second_block_color = edge_blocks[1].color
	#for block_index in range(len(edge_blocks) - 2):
		#var this_block = edge_blocks[block_index]
		#var next_block = edge_blocks[block_index + 2]
		#this_block.color = next_block.color
	#edge_blocks[-2].color = first_block_color
	#edge_blocks[-1].color = second_block_color
	#return null

func lighten_block_colors():
	for block in edge_blocks:
		block.color = block.color.lightened(0.2)

func set_edge_block_colors(colors):
	for index in range(len(edge_blocks)):
		edge_blocks[index].color = colors[index]
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func flash_square(square_no, flash_time = 1):
	var this_edge_block = edge_blocks[square_no]
	var flash_tween = create_tween()
	var square_color = this_edge_block.color
	
	flash_tween.tween_property(
		this_edge_block,
		"color",
		Color(1,1,1,1),
		flash_time/10.
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_ELASTIC)
	flash_tween.tween_property(
		this_edge_block,
		"color",
		square_color,
		flash_time*2/3.
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	#be sure to update the colors because the square_color variable
	#may no longer represent the color --- since it may have changed
	#due to a rotation.
	await flash_tween.finished
	update_colors()
	return null
