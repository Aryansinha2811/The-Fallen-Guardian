extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var health_bar = $HealthBar
@onready var detection_area = $DetectionArea
@onready var attack_area = $AttackArea

var player = null

var speed := 60
var health := 60

var normal_damage := 8
var bite_damage := 20

var attack_range := 70
var detection_range := 300

var is_dead := false
var is_attacking := false
var has_bitten_player := false   # NEW FLAG


func _ready():
	randomize()
	
	health_bar._init_health(health)
	health_bar.set_as_top_level(true)
	health_bar.visible = false
	
	attack_area.monitoring = false


func _physics_process(delta):

	if is_dead:
		return

	# Healthbar follow
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
		
		# Play Bite first time
		if not has_bitten_player:
			await bite_attack()
		else:
			await normal_attack()
		
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
# BITE ATTACK (FIRST HIT)
# =========================
func bite_attack():

	if is_dead:
		return

	is_attacking = true
	
	sprite.play("Bite")
	attack_area.monitoring = true
	
	await sprite.animation_finished
	
	attack_area.monitoring = false
	
	has_bitten_player = true
	is_attacking = false


# =========================
# NORMAL ATTACK
# =========================
func normal_attack():

	if is_dead:
		return

	is_attacking = true
	
	var attack_choice = randi() % 2
	
	if attack_choice == 0:
		sprite.play("Attack01")
	else:
		sprite.play("Attack02")

	attack_area.monitoring = true
	
	await sprite.animation_finished
	
	attack_area.monitoring = false
	
	is_attacking = false


# =========================
# HIT DETECTION
# =========================
func _on_attack_area_body_entered(body):

	if is_dead:
		return

	if body == self:
		return

	if body.has_method("take_damage"):
		
		# Decide damage type
		if not has_bitten_player:
			body.take_damage(bite_damage)
		else:
			body.take_damage(normal_damage)


# =========================
# DAMAGE FROM PLAYER
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

	if is_dead:
		return

	is_dead = true
	
	velocity = Vector2.ZERO
	
	sprite.play("Death")   # Loop OFF
	
	await sprite.animation_finished
	
	queue_free()


# =========================
# PLAYER DETECTION
# =========================
func _on_detection_area_body_entered(body):

	if body.name == "Player":
		player = body


func _on_detection_area_body_exited(body):

	if body == player:
		player = null
