extends Node3D

func _ready():
	print("CoPlayForge: Main scene loaded successfully!")
	print("Creating simple demo...")
	
	# Create a simple test unit to verify everything works
	var test_unit = Unit.new()
	add_child(test_unit)
	test_unit.position = Vector3(0, 1, 0)
	
	print("Demo unit created. Project is working!")
