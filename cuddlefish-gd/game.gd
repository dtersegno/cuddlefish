extends Control

#the grid handles all the cuddlefish, color checking
@onready var grid = $VBoxContainer/HBoxContainer/Grid
#randomize button tells all the cuddlefish to spin randomly
@onready var randomize_button = $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer2/RandomizeButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_connections()

func make_connections():
	randomize_button.pressed.connect(random_spin_all_cuddlers)
	
func random_spin_all_cuddlers() -> void:
	get_tree().call_group('cuddlers','random_spin')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
