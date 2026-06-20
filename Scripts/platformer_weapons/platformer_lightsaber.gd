extends Weapon

func attack():
	print("Zamahnuo mačem!")
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("swing")

# Dodajemo flip_weapon kako bi igrač mogao normalno da se kreće i okreće sa mačem
func flip_weapon(is_left: bool):
	# Ako tvoj mač koristi Sprite2D za vizuelni prikaz:
	if has_node("Sprite2D"):
		$Sprite2D.flip_h = is_left
	elif has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.flip_h = is_left
