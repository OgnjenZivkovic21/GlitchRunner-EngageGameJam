extends Area2D

var speed = 400
var shooter = null
var direction = Vector2.RIGHT 

@export var bullet_damage = 10 
@export var max_distance = 170.0 # Maksimalna udaljenost koju metak prelazi

var distance_traveled = 0.0 # Brojač pređenog puta

func _physics_process(delta):
	# Izračunaj pomeraj u ovom frejmu
	var velocity = direction * speed * delta
	position += velocity
	
	# Dodaj dužinu pređenog puta
	distance_traveled += velocity.length()
	
	# Provera da li je metak prešao maksimalnu udaljenost
	if distance_traveled >= max_distance:
		destruct()

func _on_body_entered(body):
	# Ne pogađaj onoga ko je pucao
	if body == shooter: return
	
	# Ako pogodiš neprijatelja, nanesi štetu
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		body.take_damage(bullet_damage)
		
	destruct()

func destruct():
	queue_free()  
