extends PanelContainer

#@onready var UL = $GridContainer/UL
#@onready var U = $GridContainer/U
#@onready var UR = $GridContainer/UR
#@onready var L = $GridContainer/L
#@onready var C = $GridContainer/C
#@onready var R = $GridContainer/R
#@onready var DL = $GridContainer/DL
#@onready var D = $GridContainer/D
#@onready var DR = $GridContainer/DR

var edge_blocks = []

@onready var button = $Button

@onready var spin_sound = $Sound/Spin

var bw_colors =  [
	Color(0,0,0),
	Color(1,1,1),
	Color(0,0,0),
	Color(1,1,1),
	Color(0,0,0),
	Color(1,1,1),
	Color(0,0,0),
	Color(1,1,1)
]

#squares labeled 0 thru 7 from right and xclockwise.
# [0,5] means a line goes from Right square (0) to Lower Left square (5)
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
	lighten_block_colors()
	#set_edge_block_colors(cuddle_colors)
	update_colors()

func _on_button_pressed():
	rotate_90()
	#lighten_block_colors()

func disable_button():
	var bton = get_child(-1)
	bton.disabled = true
	return null

func update_colors():
	for color_name in color_to_index:
		for index in color_to_index[color_name]:
			#change the list of colors
			cuddle_colors[index] = Color(color_name)
			#change the actual square color
			edge_blocks[index].color = cuddle_colors[index]
	lighten_block_colors()
	return null

func rotate_45():
	# update the color_to_index dictionary
	for color_name in color_to_index:
		var index_pair = color_to_index[color_name]
		index_pair[0] = (index_pair[0] + 1)%8
		index_pair[1] = (index_pair[1] + 1)%8
		color_to_index[color_name] = index_pair
	update_colors()
	return null

func rotate_90():
	#duplicate self to spin for visual
	var visual_square = self.duplicate()
	visual_square.cuddle_colors = self.cuddle_colors
	visual_square.color_to_index = self.color_to_index
	visual_square.initialize()
	visual_square.disable_button()
	get_tree().root.add_child(visual_square)
	
	#place the visual square over myself
	visual_square.global_position = self.global_position
	# "hide" self
	self.modulate.a = 0
	#rotate colors
	for color_name in color_to_index:
		var index_pair = color_to_index[color_name]
		index_pair[0] = (index_pair[0] + 2)%8
		index_pair[1] = (index_pair[1] + 2)%8
		color_to_index[color_name] = index_pair
	update_colors()
	
	#emit a sound
	var spin_sound_pitch_width = 0.1
	spin_sound.pitch_scale = 2. + (randf()-0.5)*spin_sound_pitch_width
	spin_sound.play()
	
	#wait for the spinning square to finish
	await visual_square.spin(self)
	#"show" self
	self.modulate.a = 1
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
	var spin_time = .15
	spin_tween.tween_property(self,"rotation", -PI/2, spin_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	spin_tween.tween_callback(self.queue_free)
	#spin_tween.tween_callback(creator_node.show)
	await spin_tween.finished
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
