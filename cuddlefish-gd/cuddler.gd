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

@onready var edge_blocks = [R, UR, U, UL, L, DL, D, DR]

@onready var button = $Button


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

var cuddle_colors = [
	Color('DARK_ORCHID'),
	Color('DARK_ORANGE'),
	Color('HONEYDEW'),
	Color('CHARTREUSE'),
	Color('CORNFLOWER_BLUE'),
	Color('DARK_ORCHID'),
	Color('DARK_ORCHID'),
	Color('HONEYDEW'),
	Color('DARK_ORCHID')
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(self._on_button_pressed)
	set_edge_block_colors(cuddle_colors)
	lighten_block_colors()
	
func _on_button_pressed():
	rotate_block_colors()
	#lighten_block_colors()

func rotate_block_colors():
	var first_block_color = edge_blocks[0].color
	for block_index in range(len(edge_blocks) - 1):
		var this_block = edge_blocks[block_index]
		var next_block = edge_blocks[block_index + 1]
		this_block.color = next_block.color
	edge_blocks[-1].color = first_block_color
	return null

func lighten_block_colors():
	for block in edge_blocks:
		block.color = block.color.lightened(0.2)

func set_edge_block_colors(colors):
	for index in range(len(edge_blocks)):
		edge_blocks[index].color = colors[index]
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
