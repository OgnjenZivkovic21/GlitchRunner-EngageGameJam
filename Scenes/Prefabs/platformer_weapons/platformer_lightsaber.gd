extends Weapon

@onready var attack_sprite = $attack
@onready var hurtbox_shape = $Hurtbox/CollisionShape2D

func _ready():
	attack_sprite.visible = false
	hurtbox_shape.disabled = true

func flip_weapon(is_left: bool):
	attack_sprite.flip_h = is_left

func attack():
	if attack_sprite.visible:
		return
		
	attack_sprite.visible = true
	hurtbox_shape.disabled = false
	
	attack_sprite.play("default")
	await attack_sprite.animation_finished
	
	attack_sprite.visible = false
	hurtbox_shape.disabled = true


func _on_hurtbox_body_entered(body: Node2D) -> void:
	print("udarac dat, ", body)
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		body.take_damage(damage);
