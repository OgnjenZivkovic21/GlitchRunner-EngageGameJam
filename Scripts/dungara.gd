extends Area2D
class_name DungaraLoot

func _ready() -> void:
	# Povezujemo signal koji Area2D ima ugrađen u sebi
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Proveravamo da li je telo koje je nagazilo na pušku zapravo igrač
	if body.is_in_group("player") or body.is_in_group("Player"):
		print("Igrač je nagazio na loot puške! Šaljem zahtev igraču...")
		
		# Pozivamo funkciju koju smo dodali igraču iznad
		if body.has_method("equip_weapon"):
			body.equip_weapon("platformer_dungara")
			
		# Brišemo ovaj loot objekat sa zemlje jer je pokupljen
		queue_free()
