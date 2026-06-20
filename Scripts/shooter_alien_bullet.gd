extends Area2D

var speed = 400
var shooter = null
@export var bullet_demage = 10

func _physics_process(delta):
	translate(transform.x * speed * delta)

func _on_body_entered(body):
	if body == shooter: return
	
	if body.is_in_group("Player"):
		body.take_damage(bullet_demage)
	
	# Umesto direktnog destruct(), pozivamo ga da odradi "animaciju" zvuka
	destruct()

func destruct():
	# 1. Zaustavi kretanje metka
	set_physics_process(false) 
	
	# 2. Sakrij vizuelni deo metka
	$Sprite2D.hide() 
	
	# 3. Isključi koliziju (da ne udari u nešto drugo dok zvuk traje)
	# Koristimo set_deferred jer se ovo dešava usred fizickog procesa
	$CollisionShape2D.set_deferred("disabled", true)
	
	# 4. Pusti zvuk
	$AudioStreamPlayer2D.play()
	
	await $AudioStreamPlayer2D.finished
	
	queue_free()
