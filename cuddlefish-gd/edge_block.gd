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


#preloaded scene for copying self.
#will be unused in final game --- cuddler 2 will itself rotate rather
#than create a visual instance of itself.

#squares labeled 0 thru 7 from right and xclockwise.
# [0,5] means a line goes from Right square (0) to Lower Left square (5)

#give me the local square indices of a given color.
#change this when coloring different cuddlers
var color_to_index = {
	'purple':[0,5],
	'orange':[1,6],
	'blue':[2,4],
	'green':[3,7],
	
}

#give me the color of local square i
var cuddle_colors = [
	Color('gray'),
	Color('gray'),
	Color('gray'),
	Color('gray'),
	Color('gray'),
	Color('gray'),
	Color('gray'),
	Color('gray'),
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.size = Vector2(126,126)
	# - Vector2(2,2)
	#store colored squares in a list
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
	
#return the local square colors of a given color
func get_squares_of_color(color:Color):
	return color_to_index[color]
	
func paint_cuddle_colors() -> void:
	var square_counter = 0
	for color in cuddle_colors:
		edge_blocks[square_counter].color = color
		square_counter += 1
		
func paint_single_square(square_no, color, local = true) -> void:
	if square_no == -1:
		self.C.color = color
	else:
		edge_blocks[square_no].color = color

func tween_square_color(square_no, color, time = 1):
	var color_tween = create_tween()
	var this_block
	if square_no == -1:
		this_block = self.C
	else:
		this_block = edge_blocks[square_no]
	color_tween.tween_property(this_block, 'color', color, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

		
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
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
