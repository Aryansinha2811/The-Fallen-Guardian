extends ProgressBar

@onready var damage_bar = $DamageBar
@onready var timer = $Timer

var health = 0 : set = _set_health


func _ready():
	visible = false   # Hide until damage


func _set_health(new_health):
	var prev_health = health
	health = clamp(new_health, 0, max_value)
	value = health
	
	# Delayed damage effect
	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health


func _init_health(_health):
	health = _health
	max_value = health
	value = health
	
	damage_bar.max_value = health
	damage_bar.value = health


func _on_timer_timeout():
	damage_bar.value = health
