extends Control

#the grid handles all the cuddlefish, color checking
@onready var grid = $VBoxContainer/HBoxContainer/Grid
#randomize button tells all the cuddlefish to spin randomly
@onready var randomize_button = $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer2/RandomizeButton
#reset button rotates all squares to the solution
@onready var reset_button = $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer2/Reset
#check button performs a solution check
@onready var check_button = $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer2/Check
# quitter
@onready var quit_button = $VBoxContainer/HBoxContainer/PanelContainer2/VBoxContainer/QuitButton

@onready var win_screen = $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer2/WinScreen

var wonned = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	win_screen.hide()
	make_connections()
	if Input.is_action_pressed("instant_start"):
		random_spin_all_cuddlers(0, true)
	else:
		random_spin_all_cuddlers(4)
	grid.winstate.connect(check_win)

func handle_input():
	if Input.is_action_pressed("ui_accept"):
		check_button.button_pressed = true
	if Input.is_action_just_released("ui_accept"):
		check_button.toggle_mode = false
	if Input.is_action_just_pressed("ui_accept"):
		check_button.toggle_mode = true
		grid.perform_cuddler_comparison()
	if Input.is_action_just_pressed("ui_down"):
		self.random_spin_all_cuddlers()
	if Input.is_action_just_pressed("ui_up"):
		grid.check_cuddler_directions()
		self.check_win()
	#if Input.is_action_just_pressed("ui_left"):
		#self.reset_all_cuddlers()
		
func make_connections():
	randomize_button.pressed.connect(random_spin_all_cuddlers)
	reset_button.pressed.connect(reset_all_cuddlers)
	#check_button.pressed.connect(check_win)
	check_button.pressed.connect(grid.perform_cuddler_comparison)
	quit_button.pressed.connect(get_tree().quit)

#doesn't actually perform the comparisons, but relies on DIRECTION.RIGHT for all
#cuddlers when they are properly arranged.
func check_win():
	if grid.check_cuddler_directions() and not wonned:
		wonned = true
		randomize_button.disabled = true
		check_button.disabled = true
		win()
	
func win():
	var shader = get_tree().create_tween()
	var grid_shade = $GridShade
	win_screen.modulate = Color(1,1,1,0)
	grid_shade.self_modulate = Color(1,1,1,0)
	grid_shade.show()
	win_screen.show()
	shader.tween_property(grid_shade, 'self_modulate', Color(1,1,1,1), 1)
	shader.tween_property(win_screen, 'modulate', Color(1,1,1,1), 2)
	await shader.finished
	win_screen.get_child(1).cycle_animation()
	randomize_button.disabled = true
	check_button.disabled = true
	
func random_spin_all_cuddlers(extra_spins = 0, instantaneous = false) -> void:
	randomize_button.disabled = true
	reset_button.disabled = true
	check_button.disabled = true
	var tree = get_tree()
	tree.call_group('cuddlers','random_spin')
	if not instantaneous:
		await get_tree().create_timer(1).timeout
	if extra_spins > 0:
		random_spin_all_cuddlers(extra_spins - 1, instantaneous)
	else:
		randomize_button.disabled = false
		reset_button.disabled = false
		check_button.disabled = false 
	grid.perform_cuddler_comparison()
	
func reset_all_cuddlers():
	print("Resetting cuddlers")
	var tree = get_tree()
	randomize_button.disabled = true
	reset_button.disabled = true
	check_button.disabled = true
	tree.call_group('cuddlers','turn_to_direction')
	await get_tree().create_timer(1).timeout
	grid.perform_cuddler_comparison()
	
	randomize_button.disabled = false
	reset_button.disabled = false
	check_button.disabled = false 
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handle_input()
