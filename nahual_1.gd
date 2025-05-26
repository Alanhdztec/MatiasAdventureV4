
extends CharacterBody2D

const vel = 25
var estado= reposo
var isRoaming = true
var chateo = false
var player
var playerInChatZone
var dir = Vector2.RIGHT
var startPosition

enum {
	reposo, 
	nuevaDireccion, 
	MOVE
}

func _ready():
	randomize()
	startPosition = position
	
func _process(delta):
		if estado == 0 or estado == 1:
			$AnimatedSprite2D.play("reposo")
		elif estado == 2 and !chateo:
			if dir.x == -1:
				$AnimatedSprite2D.play("caminarDere")
			if dir.x == 1:
				$AnimatedSprite2D.play("caminarDere")
			if dir.y == -1:
				$AnimatedSprite2D.play("caminarArriba")
			if dir.y == 1:
				$AnimatedSprite2D.play("caminarAbajo")
		if isRoaming:
			match estado:
				reposo:
					pass
				nuevaDireccion:
					dir = elegir([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN])
				MOVE:
					move(delta)
		if Input.is_action_just_pressed("chatear"):
			print("chatting")
			$dialogoBox.start()
			isRoaming =false
			chateo=true
			$AnimatedSprite2D.play("reposo")

func elegir(array):
	array.shuffle()
	return array.front()
	
func move(delta):
	if !chateo:
		position += dir * vel * delta


func _on_areadetection_2d_body_entered(body):
	if body.has_method("player"):
		player=body
		playerInChatZone= true


func _on_areadetection_2d_body_exited(body):
	if body.has_method("player"):
		playerInChatZone=false


func _on_timer_timeout():
	#$Timer.wait_time= elegir([0.5, 1, 1.5])
	#estado=elegir([reposo, nuevaDireccion, MOVE])
	pass


func _on_dialogo_box_dialogo_fin():
	chateo= false
	isRoaming=true
