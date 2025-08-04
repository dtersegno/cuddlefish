extends Sprite2D

enum TYPES {V, H}
@export var type:TYPES

#number of variations on the surface "gunk" sprite
var no_variations = 6

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if type == TYPES.H:
		self.rotate(PI/2)
	pick_random_sprite()
	set_scale(Vector2(6,6))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("ui_accept"):
		#pick_random_sprite()
	pass

rotate_toward()

func pick_random_sprite():
	var frame_no = randi()%no_variations
	self.set_frame(frame_no)
