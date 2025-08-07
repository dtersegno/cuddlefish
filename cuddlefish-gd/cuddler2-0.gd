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


# Direction enum to describe which direction the cuddler is pointing.
#default is RIGHT: square 0 is in the cuddler direction from center.
#useful for converting local square numbers to global
#square numbers for the game to check color adjacency.

enum DIRECTION {RIGHT, UP, LEFT, DOWN}
var direction := DIRECTION.RIGHT

#unfortunately named --- these are the colored squares around the perimeter
#of the cuddler.
#Don't get these confused with the main puzzle's "edge blocks",
#which frame the array of cuddlers.
#this list fills on initialization, after ready()
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

#spin button and behavior.
#clicking the button makes the square spin
@onready var button = $Button
@onready var spin_sound = $Sound/Spin
signal spinning
signal button_clicked

#preloaded scene for copying self.
#will be unused in final game --- cuddler 2 will itself rotate rather
#than create a visual instance of itself.
var cuddler_scene = preload("res://cuddler2-0.tscn")

#squares labeled 0 thru 7 from right and xclockwise.
# [0,5] means a line goes from Right square (0) to Lower Left square (5)


#give me the local square indices of a given color.
#change this when coloring different cuddlers
var color_to_index = {
	'purple':[0,5],
	'orange':[1,6],
	'blue':[2,4],
	'green':[3,7]
}

#give me the color of local square i
var cuddle_colors = [
	Color('white'),
	Color('white'),
	Color('white'),
	Color('white'),
	Color('white'),
	Color('white'),
	Color('white'),
	Color('white'),
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.size = Vector2(126,126)
	self.pivot_offset = (self.size / 2)# - Vector2(2,2)
	#store colored squares in a list
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

func local_to_global(local_square_no:int) -> int:
	return (local_square_no - direction*2)%8
	
func global_to_local(global_square_no:int) -> int:
	return (global_square_no + direction*2)%8

#grid will use this to read the color of a cuddler's square
func get_color_of_square(square_no:int, local:bool):
	if local:
		return cuddle_colors[square_no]
	else:
		return get_color_of_square(
			self.global_to_local(square_no),
			true # = local
		)
	
#return the local square colors of a given color
func get_squares_of_color(color:Color):
	return color_to_index[color]

func _on_button_pressed() -> void:
	self.emit_signal("button_clicked")
	await rotate_90()

# prevents pushing the button
func disable_button() -> void:
	button.disabled = true

# enables the button
func enable_button() -> void:
	button.disabled = false

#give a list in order of local squares 0 thru 7 of Colors
func set_cuddle_colors(color_list) -> void:
	cuddle_colors = color_list
	
func paint_cuddle_colors() -> void:
	var square_counter = 0
	for color in cuddle_colors:
		edge_blocks[square_counter].color = color
		square_counter += 1
		
func paint_single_square(square_no, color, local = true) -> void:
	edge_blocks[square_no].color = color

		
#changes cuddle_colors list based on rotation. This is the global color scheme
##
#func update_colors() -> void:
	##print('Updating colors on cube:')
	##color_to_index: which squares have color color_to_index[name]?
	#for color_name in color_to_index:
		#for index in color_to_index[color_name]:
			##change the list of colors
			#cuddle_colors[index] = Color(color_name)
			##change the actual square color
			##print('edge blocks:')
			##print(edge_blocks)
			##print('cuddle colors:')
			##print(cuddle_colors)
			#edge_blocks[index].color = cuddle_colors[index]
	#lighten_block_colors(0.2)
#

func rotate_90() -> void:
	self.disable_button()
	button.release_focus()
	
	var spin_sound_pitch_width = 0.1
	spin_sound.pitch_scale = 2. + (randf()-0.5)*spin_sound_pitch_width
	spin_sound.play()
	
	direction = (direction + 1)%4 #advance the cardinal direction counterclockwise
	await self.spin()
	self.enable_button()
	self.size = Vector2(128,128)
	
#animation for transient squares
func spin(spin_time = 0.12):
	#await get_tree().process_frame  # wait one frame to ensure size is settled
	var spin_tween = create_tween()
	spin_tween.tween_property(self,"rotation", self.rotation-PI/2, spin_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	#spin_tween.tween_callback(self.queue_free)
	#await spin_tween.finished
	#self.size = Vector2(self.size[1], self.size[0])
	return spin_tween.finished
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func random_spin(spin_time = 1):
	var spin_tween = create_tween()
	#pick a number of times to spin 90 deg and a new direction
	var spin_count = randi()%16
	var new_direction = spin_count%4
	
	if fmod(self.rotation + spin_count*PI/2,2*PI) < 1e-2:
		spin_count += 1
	
	var spin_time_extra = randf()
	spin_tween.tween_property(self, "rotation", spin_count*PI/2, spin_time + spin_time_extra).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	
	self.disable_button()
	direction = new_direction
	
	await spin_tween.finished
	self.enable_button()
	self.size = Vector2(128,128)
	

#flashes global (by default) square
func flash_square(square_no, local = false, flash_time = 1):
	var this_square_no
	if local:
		this_square_no = square_no
	else:
		this_square_no = self.global_to_local(square_no)
	var this_edge_block = edge_blocks[this_square_no]
	var flash_tween = create_tween()
	var square_color = self.get_color_of_square(this_square_no, true)
	
	flash_tween.tween_property(
		this_edge_block,
		"color",
		Color(1,1,1,1),
		flash_time/10.
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_ELASTIC)
	#tweens run sequentially (not parallel) by default.
	flash_tween.tween_callback(enable_button)
	flash_tween.tween_property(
		this_edge_block,
		"color",
		square_color,
		flash_time*2/3.
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	#be sure to update the colors because the square_color variable
	#may no longer represent the color --- since it may have changed
	#due to a rotation.
	return null
