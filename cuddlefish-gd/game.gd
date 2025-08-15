extends Control

#the grid handles all the cuddlefish, color checking
@onready var grid = $VBoxContainer/HBoxContainer/Grid
#randomize button tells all the cuddlefish to spin randomly
@onready var randomize_button = $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer2/RandomizeButton
#reset button rotates all squares to the solution
@onready var reset_button = $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer2/Reset
#check button performs a solution check
@onready var check_button = $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer2/Check

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_connections()

func handle_input():
	if Input.is_action_just_pressed("ui_accept"):
		grid.perform_cuddler_comparison()
	if Input.is_action_just_pressed("ui_down"):
		get_tree().call_group('cuddlers','random_spin')
	if Input.is_action_just_pressed("ui_up"):
		grid.check_cuddler_directions()
		self.check_win()
		
func make_connections():
	randomize_button.pressed.connect(random_spin_all_cuddlers)
	reset_button.pressed.connect(reset_all_cuddlers)
	check_button.pressed.connect(check_win)

#doesn't actually perform the comparisons, but relies on DIRECTION.RIGHT for all
#cuddlers when they are properly arranged.
func check_win():
	grid.perform_cuddler_comparison()
	
func random_spin_all_cuddlers() -> void:
	var tree = get_tree()
	tree.call_group('cuddlers','random_spin')
	await get_tree().create_timer(1).timeout
	grid.perform_cuddler_comparison()
	
func reset_all_cuddlers():
	print("Resetting cuddlers")
	var tree = get_tree()
	tree.call_group('cuddlers','turn_to_direction')
	await get_tree().create_timer(1).timeout
	grid.perform_cuddler_comparison()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handle_input()
