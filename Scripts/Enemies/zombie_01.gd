extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var health_bar = $HealthBar
@onready var detection_area = $DetectionArea
@onready var attack_area = $AttackArea

var player = null

var speed := 60
var health := 60
var damage := 5

var attack_range := 70
var detection_range := 300

var is_dead := false
var is_attacking := false


func _ready():
	randomize()
	
	health_bar._init_health(health)
	health_bar.set_as_top_level(true)
	health_bar.visible = false
	
	attack_area.monitoring = false


func _physics_process(delta):

	if is_dead:
		return

	# Keep healthbar above head
	health_bar.global_position = global_position + Vector2(0, -40)

	if player == null:
		velocity.x = 0
		sprite.play("Idle")
		move_and_slide()
		return

	var direction = player.global_position.x - global_position.x
	var distance = abs(direction)

	# Face player
	if direction > 0:
		sprite.flip_h = false
		attack_area.position.x = abs(attack_area.position.x)
	else:
		sprite.flip_h = true
		attack_area.position.x = -abs(attack_area.position.x)

	# ATTACK
	if distance <= attack_range and not is_attacking:
		velocity.x = 0
		attack()
		move_and_slide()
		return

	# CHASE
	if distance <= detection_range:
		velocity.x = sign(direction) * speed
		if not is_attacking:
			sprite.play("Run")
	else:
		velocity.x = 0
		sprite.play("Idle")

	move_and_slide()


# =========================
# ATTACK
# =========================
func attack():
	is_attacking = true
	velocity.x = 0
	
	var attack_choice = randi() % 2
	
	if attack_choice == 0:
		sprite.play("Attack01")
	else:
		sprite.play("Attack02")

	attack_area.monitoring = true
	
	await sprite.animation_finished
	
	attack_area.monitoring = false

	if player and attack_area.get_overlapping_bodies().has(player):
		if player.has_method("take_damage"):
			player.take_damage(damage)

	is_attacking = false


# =========================
# DAMAGE
# =========================
func take_damage(amount):
	if is_dead:
		return

	health -= amount
	
	health_bar.visible = true
	health_bar.health = health

	if health <= 0:
		die()


# =========================
# DEATH
# =========================
func die():
	is_dead = true
	velocity = Vector2.ZERO
	sprite.play("Death")
	
	await sprite.animation_finished
	
	queue_free()


# =========================
# DETECTION
# =========================
func _on_detection_area_body_entered(body):
	if body.name == "Player":
		player = body


func _on_detection_area_body_exited(body):
	if body == player:
		player = null
