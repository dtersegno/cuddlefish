extends GridContainer

@onready var cuddler_prime = $Cuddler

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_cuddlefish()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func create_cuddlefish(number_to_create:int):
	for new_cuddler_counter in range(number_to_create):
		var new_cuddler = cuddler_prime.duplicate()
		self.add_child(new_cuddler)
		new_cuddler.add_to_group('cuddlers')
