class_name AIBehavior
extends Resource

@export var aggression_level: float = 0.5  # 0.0 = defensive, 1.0 = aggressive
@export var support_priority: float = 0.5  # How much to prioritize supporting allies

func _init():
	pass

func get_next_action(unit) -> String:
	# Simple AI logic for now
	if unit.current_health < unit.get_total_stats().health * 0.25:
		return "retreat"
	elif aggression_level > 0.7:
		return "attack"
	else:
		return "defend"
