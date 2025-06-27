extends GridContainer

@onready var cuddler_prime = $Cuddler_Prime

var cuddler = preload("res://cuddler.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_cuddlefish(25)
	cuddler_prime.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func create_cuddlefish(number_to_create:int):
	for new_cuddler_counter in range(number_to_create):
		var new_cuddler = cuddler.instantiate()
		self.add_child(new_cuddler)
		new_cuddler.add_to_group('cuddlers')

# whether the colors at certain positions of
#two cuddlers are the same

# mark which internal squares to compare.
#ex V: [6,2] compares the bottom of the first cuddler
#to the top of the second.
# squares start at 0 at Right, 1 at Upper Right,
# and continue xclockwise to 7 at the Lower Right
# comparison order is important.
var comparisons = {
	"V":[6,2], #top to bottom
	"H":[0,4], #right to left
	"D1":[7,3], #lower right to upper left
	"D2":[5,1], #lower left to upper right
	"EE_L": [4,4], #both lefts
	"EE_R": [0,0], #both rights
	"EE_U": [2,2], #both tops
	"EE_D": [6,6], #both bottoms
	"EC_L": [5,3], #lower left to upper left
	"EC_R": [7,1], #lower right to upper right
	"EC_U": [1,3], #upper right to upper left
	"EC_D": [7,5], #lower right to lower left
}

var squares_to_compare_25 = {
	"V":[
		[0,5],[1,6],[2,7],[3,8],[4,9],
		[5,10],[6,11],[7,12],[8,13],[9,14],
		[10,15],[11,16],[12,17],[13,18],[14,19],
		[15,20],[16,21],[17,22],[18,23],[19,24]
	]
}

func cuddle_compare(cuddler1, cuddler2, comparison):
	var indices = comparisons[comparison]
	var color1 = cuddler1.edge_blocks[indices[0]].color
	var color2 = cuddler2.edge_blocks[indices[1]].color
	return color1 == color2

func compare_all():
	for cuddler1 in self.get_children():
		for cuddler2 in self.get_children():
			if cuddle_compare(cuddler1, cuddler2, "H"):
				print(
					"H compare true!"
				)
	return null
