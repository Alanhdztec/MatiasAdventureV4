extends CharacterBody2D


var speed = 25
var vidaHP=100
var danio
var dead = false
var playerEnArea = false
var player

func _ready():
	dead = false
	
func _physics_process(delta):
	if !dead:
		$deteccionArea/CollisionShape2D.disabled=false
		if playerEnArea:
			position+=(player.position - position) /speed
			$AnimatedSprite2D.play("movDer")
		else:
			$AnimatedSprite2D.play("reposo")
	if dead:
		$deteccionArea/CollisionShape2D.disabled=true




func _on_deteccion_area_body_entered(body):
	if body.has_method("player"):
		playerEnArea=true
		player=body


func _on_deteccion_area_body_exited(body):
	if body.has_method("player"):
		playerEnArea=false	
