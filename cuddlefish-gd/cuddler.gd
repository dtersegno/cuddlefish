extends PanelContainer

@onready var UL = $GridContainer/UL
@onready var U = $GridContainer/U
@onready var UR = $GridContainer/UR
@onready var L = $GridContainer/L
@onready var C = $GridContainer/C
@onready var R = $GridContainer/R
@onready var DL = $GridContainer/DL
@onready var D = $GridContainer/D
@onready var DR = $GridContainer/DR

#to describe which direction its pointing.
enum DIRECTION {RIGHT, UP, LEFT, DOWN}
var direction := DIRECTION.RIGHT
var edge_blocks = []
		#$GridContainer/R,
		#$GridContainer/UR,
		#$GridContainer/U,
		#$GridContainer/UL,
		#$GridContainer/L,
		#$GridContainer/DL,
		#$GridContainer/D,
		#$GridContainer/DR
	#]

#spin button and behavior
@onready var button = $Button
@onready var spin_sound = $Sound/Spin
signal spinning
signal button_clicked

#preloaded scene for copying self
var cuddler_scene = preload("res://cuddler.tscn")

#squares labeled 0 thru 7 from right and xclockwise.
# [0,5] means a line goes from Right square (0) to Lower Left square (5)

#just a list.
var default_colors = [
	'DARK_ORCHID',
	'DARK_ORANGE',
	'CORNFLOWER_BLUE',
	'CHARTREUSE'
]

#give me the local square indices of a given color
var color_to_index = {
	'DARK_ORCHID':[0,5],
	'DARK_ORANGE':[1,6],
	'CORNFLOWER_BLUE':[2,4],
	'CHARTREUSE':[3,7]
}

#give me the color of square i
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
	edge_blocks = [
		$GridContainer/R,
		$GridContainer/UR,
		$GridContainer/U,
		$GridContainer/UL,
		$GridContainer/L,
		$GridContainer/DL,
		$GridContainer/D,
		$GridContainer/DR
	]
	#set_edge_block_colors(cuddle_colors)
	update_colors()

func local_to_global(local_square_no:int) -> int:
	return (local_square_no - direction*2)%8
	
func global_to_local(global_square_no:int) -> int:
	return (global_square_no + direction*2)%8

func get_color_of_square(square_no:int, local:bool):
	if local:
		return cuddle_colors[square_no]
	else:
		return get_color_of_square
	
func get_squares_of_color(color:Color, local:bool):
	return color_to_index[color]

func _on_button_pressed() -> void:
	await rotate_90()
	self.emit_signal("button_clicked")

# prevents pushing the button
func disable_button() -> void:
	var bton = get_child(-1)
	bton.disabled = true

#changes cuddle_colors list and actual colors of blocks
func update_colors() -> void:
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
	lighten_block_colors(0.2)
#

func rotate_90() -> void:
	var visual_square = cuddler_scene.instantiate()
	#visual_square.set_script('res://cuddler.gd')
	
	visual_square.initialize()
	visual_square.cuddle_colors = self.cuddle_colors.duplicate()
	visual_square.color_to_index = self.color_to_index.duplicate()
	visual_square.edge_blocks = self.edge_blocks.duplicate()
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
	
#animation for transient squares
func spin(creator_node):
	#print(get_size())
	await get_tree().process_frame  # wait one frame to ensure size is settled
	self.size = creator_node.size
	self.pivot_offset = self.size / 2
	#self.pivot_offset = get_size()
	var spin_tween = create_tween()
	var spin_time = .12
	#var spin_time = 3
	spin_tween.tween_property(self,"rotation", -PI/2, spin_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	spin_tween.tween_callback(self.queue_free)
	#spin_tween.tween_callback(creator_node.show)
	await spin_tween.finished
	#update_colors()
	return spin_tween.finished



func lighten_block_colors(lightening):
	for block in edge_blocks:
		block.color = block.color.lightened(lightening)
#
#func set_edge_block_colors(colors):
	#for index in range(len(edge_blocks)):
		#edge_blocks[index].color = colors[index]
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func flash_square(square_no, flash_time = 1):
	var this_edge_block = edge_blocks[square_no]
	var flash_tween = create_tween()
	var square_color = self.get_color_of_square(square_no, true).lightened(0.2)
	
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
