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

#points to pairs of squares in a 5x5 grid,
# [[0..4],[5..9],[10..14],[14..19],[20..24]]
#that the given comparison is applied
var compare_these_cuddlers_25 = {
	"V":[
		[0,5],[1,6],[2,7],[3,8],[4,9],
		[5,10],[6,11],[7,12],[8,13],[9,14],
		[10,15],[11,16],[12,17],[13,18],[14,19],
		[15,20],[16,21],[17,22],[18,23],[19,24]
	],
	"H":[
		[0, 1],
 		[1, 2],
		[2, 3],
		[3, 4],
		[5, 6],
		[6, 7],
		[7, 8],
		[8, 9],
		[10, 11],
		[11, 12],
		[12, 13],
		[13, 14],
		[15, 16],
		[16, 17],
		[17, 18],
		[18, 19],
		[20, 21],
		[21, 22],
		[22, 23],
		[23, 24]
	],
	"D1":[[0, 6],
		 [1, 7],
		 [2, 8],
		 [3, 9],
		 [5, 11],
		 [6, 12],
		 [7, 13],
		 [8, 14],
		 [10, 16],
		 [11, 17],
		 [12, 18],
		 [13, 19],
		 [15, 21],
		 [16, 22],
		 [17, 23],
		 [18, 24]],
	"D2":[
		[1, 5],
		 [2, 6],
		 [3, 7],
		 [4, 8],
		 [6, 10],
		 [7, 11],
		 [8, 12],
		 [9, 13],
		 [11, 15],
		 [12, 16],
		 [13, 17],
		 [14, 18],
		 [16, 20],
		 [17, 21],
		 [18, 22],
		 [19, 23]
		],
	"EC_R":[
		[4,9],
		[9,14],
		[14,19],
		[19,24]
	],
	"EC_U":[
		[0,1],
		[1,2],
		[2,3],
		[3,4]
	],
	"EC_L":[
		[0,5],
		[5,10],
		[10,15],
		[15,20]
	],
	"EC_D":[
		[20, 21],
		[21, 22],
		[22, 23],
		[23, 24]
	]
}

#take two squares and a type of comparison.
#return the result of the comparison.
#ex
#cuddle_compare(<cuddler A>,<cuddler B>, "V")
#compares cuddler A's square 6 to cuddler B's square 2.

func cuddle_compare(cuddler1, cuddler2, comparison):
	var square_indices = comparisons[comparison]
	var color1 = cuddler1.edge_blocks[square_indices[0]].color
	var color2 = cuddler2.edge_blocks[square_indices[1]].color
	return color1 == color2
	
func compare_all_cuddlers():
	var result = {}
	for comparison in comparisons:
		var comparison_result = []
		var cuddlers_to_compare = compare_these_cuddlers_25[comparison]
		for cuddler_pair in cuddlers_to_compare:
			var cuddlerA = cuddler_pair[0]
			var cuddlerB = cuddler_pair[1]
			var square_pair = comparisons[comparison]
			var square1 = square_pair[0]
			var square2 = square_pair[1]
			comparison_result.append(
				[
					square_pair,
					cuddle_compare(
						cuddlerA,
						cuddlerB,
						comparison
					)
				]
		)

func compare_all():
	for cuddler1 in self.get_children():
		for cuddler2 in self.get_children():
			if cuddle_compare(cuddler1, cuddler2, "H"):
				print(
					"H compare true!"
				)
	return null
