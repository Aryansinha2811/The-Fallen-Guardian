extends ProgressBar

@onready var timer = $Timer

var health = 0 : set = set_health


func _ready():
	visible = true


func init_health(max_health):
	max_value = max_health
	value = max_health
	health = max_health


func set_health(new_health):
	var previous = health
	health = clamp(new_health, 0, max_value)
	value = health
	
	# Delay effect using timer
	if health < previous:
		timer.start()


func _on_timer_timeout():
	value = health
