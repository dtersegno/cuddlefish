extends PanelContainer

var edge_blocks = [] #will be filled in in initialize in
@onready var c_block = $GridContainer/C

#squares labeled 0 thru 7 from right and xclockwise.
# [0,5] means a line goes from Right square (0) to Lower Left square (5)

var default_colors = [
	'DARK_ORCHID',
	'DARK_ORANGE',
	'CORNFLOWER_BLUE',
	'CHARTREUSE',
	'GRAY'
]
var color_to_index = {
	'DARK_ORCHID':[0,5],
	'DARK_ORANGE':[1,6],
	'CORNFLOWER_BLUE':[2,4],
	'CHARTREUSE':[3,7],
	'GRAY':[0,1,2,3,4,5,6,7]
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
	update_colors()

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


func lighten_block_colors():
	for block in edge_blocks:
		block.color = block.color.lightened(0.2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func color_square(square_no, color):
	#colors squares 0 - 7 for edges or -1 for center
	if square_no == -1:
		c_block.color = color
	else:
		color_to_index

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
