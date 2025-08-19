extends Node2D

@onready var hooksprite = $Hook
@onready var bodysprite = $Body
@onready var A = $Body/VBoxContainer/HBoxContainer/A
@onready var B = $Body/VBoxContainer/HBoxContainer/B
@onready var C = $Body/VBoxContainer/HBoxContainer/C
@onready var D = $Body/VBoxContainer/HBoxContainer/D
@onready var E = $Body/VBoxContainer/HBoxContainer/E
var dials


var letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dials = [A,B,C,D,E]
	pop_it()
	cycle_animation()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func pop_it():
	var hook_tween = get_tree().create_tween()
	hook_tween.tween_property(
		hooksprite,
		"position",
		hooksprite.position + Vector2(0,5),
		0.05
	)
	hook_tween.pause()
	await get_tree().create_timer(1).timeout
	hook_tween.play()
	hook_tween.tween_property(
		hooksprite,
		"position",
		hooksprite.position + Vector2(0,-30),
		0.5
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	var body_tween = get_tree().create_tween()
	body_tween.tween_property(
		bodysprite,
		"position",
		bodysprite.position + Vector2(0,3),
		0.5
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	await hook_tween.finished

func cycle_animation():
	#var animation_timer = Timer.new()
	#self.add_child(animation_timer)
	#animation_timer.start()
	while len(dials) > 0: #animation timer
		var era_timer = Timer.new() #era timer (when letters stop moving
		get_tree().root.add_child(era_timer)
		var frame_timer = Timer.new()
		get_tree().root.add_child(frame_timer)
		era_timer.start(0.5)
		while era_timer.is_stopped:
			frame_timer.start(0.05)
			cycle_letters(dials)
			

func auto_cycle():
	await get_tree().create_timer(0.1).timeout
	cycle_letters(dials)
	auto_cycle()

func cycle_letters(dial_list):
	var random_letter
	for dial in dial_list:
		random_letter = randi()%26
		dial.text = letters[random_letter]
