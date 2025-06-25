extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.connect("pressed", self._on_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_button_pressed():
	print("button pressed!")
