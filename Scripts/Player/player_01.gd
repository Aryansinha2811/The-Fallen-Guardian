extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -320.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea

# Healthbar from UI
@onready var health_bar = get_tree().get_first_node_in_group("player_healthbar")

var is_attacking = false
var is_hurt = false
var is_dead = false

var damage = 30

var max_health = 250
var health = 250


func _ready():
	if health_bar:
		health_bar.init_health(max_health)


func _physics_process(delta):

	if is_dead:
		return

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("ui_left", "ui_right")

	# Attack input
	if Input.is_action_just_pressed("attack1") and not is_attacking and not is_hurt:
		attack("Attack")
		return
	
	if Input.is_action_just_pressed("attack2") and not is_attacking and not is_hurt:
		attack("Attack02")
		return

	# Movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Flip
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Animations
	if not is_attacking and not is_hurt:
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("Idle")
			else:
				animated_sprite.play("Run")
		else:
			animated_sprite.play("Jump")

	move_and_slide()


func attack(anim_name):
	is_attacking = true
	
	animated_sprite.play(anim_name)
	attack_area.monitoring = true
	
	await animated_sprite.animation_finished
	
	attack_area.monitoring = false
	is_attacking = false


func _on_attack_area_body_entered(body):
	if body == self:
		return
	
	if body.has_method("take_damage"):
		body.take_damage(damage)


# =========================
# DAMAGE SYSTEM
# =========================
func take_damage(amount):

	if is_dead:
		return

	health -= amount
	
	print("Player took damage:", amount, " Health:", health)

	# Update UI
	if health_bar:
		health_bar.health = health

	# Play hurt animation
	hurt()

	if health <= 0:
		die()


func hurt():
	if is_hurt or is_dead:
		return
	
	is_hurt = true
	
	animated_sprite.play("Hurt")
	
	await animated_sprite.animation_finished
	
	is_hurt = false


# =========================
# DEATH
# =========================
func die():

	if is_dead:
		return

	is_dead = true
	
	velocity = Vector2.ZERO
	
	animated_sprite.play("Death")
	
	await animated_sprite.animation_finished
	
	queue_free()
