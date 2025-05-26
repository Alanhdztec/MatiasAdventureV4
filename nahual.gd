extends CharacterBody2D

var speed = 40
var vidaHP = 100
var danio
var dead = false
var playerEnArea = false
var player
var can_take_damage = true  
var player_ref: Node2D = null
var knockback_force=200
var puede_golpear := true  

@export var tiempo_entre_golpes := 1.5  # En segundos
@onready var animated_sprite = $AnimatedSprite2D  # Referencia cacheada

func _ready():
	dead = false
	$hitbox/CollisionShape2D.disabled = false
	$hitbox.area_entered.connect(_on_hurt_box_area_entered)

func _physics_process(delta):
	if !dead:
		$areaDetec/CollisionShape2D.disabled = false
		if playerEnArea and player:
			
			# Atacar al jugador si está cerca
			if position.distance_to(player.position) < 10:  # Ajusta el rango
				if player.has_method("take_damage"):
					player.take_damage(10, global_position)  # 10 es el daño
			# Calcular dirección al jugador
			var direction = (player.position - position).normalized()
			
			# Mover al enemigo
			position += direction * speed * delta
			
			# Aplicar flip según dirección horizontal
			if direction.x != 0:  # Solo cambiar flip si hay movimiento horizontal
				animated_sprite.flip_h = direction.x < 0
			
			# Reproducir animación de movimiento
			animated_sprite.play("movDerecha")
		else:
			animated_sprite.play("reposoEne")
	else:
		$areaDetec/CollisionShape2D.disabled = true
# 🔥 GOLPE AL JUGADOR SOLO CADA CIERTO TIEMPO
		if position.distance_to(player.position) < 15 and puede_golpear:
			if player.has_method("take_damage"):
				player.take_damage(10, global_position)
				puede_golpear = false
				await get_tree().create_timer(tiempo_entre_golpes).timeout
				puede_golpear = true


func _on_area_detec_body_entered(body):
	if body.has_method("player"):
		playerEnArea = true
		player = body
		player_ref = body

func _on_area_detec_body_exited(body):
	if body.has_method("player"):
		playerEnArea = false
		player = null
		player_ref = null

func take_damage(damage: int, source_position: Vector2 = Vector2.ZERO):
	if dead or not can_take_damage:
		return
		
	vidaHP -= damage
	print("Enemigo recibió ", damage, " de daño. Vida restante: ", vidaHP)
	
	# Efecto visual
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	# Knockback
	if source_position != Vector2.ZERO:
		var knockback_dir = (global_position - source_position).normalized()
		velocity = knockback_dir * knockback_force
		move_and_slide()
	
	# Temporizador de invencibilidad breve
	can_take_damage = false
	await get_tree().create_timer(0.5).timeout
	can_take_damage = true
	
	if vidaHP <= 0:
		die()
		
func die():
	if dead:  # Evita que se ejecute múltiples veces
		return
	
	dead = true
	set_physics_process(false)  # Detener el procesamiento físico
	
	# Desactivar todas las colisiones
	$hitbox/CollisionShape2D.set_deferred("disabled", true)
	$areaDetec/CollisionShape2D.set_deferred("disabled", true)
	
	# Reproducir animación de muerte
	animated_sprite.play("eliminado")
	
	# Esperar a que termine la animación de muerte
	await animated_sprite.animation_finished
	
	# Eliminar el enemigo de la escena
	queue_free()

func _on_hurt_box_area_entered(area):
	if area.is_in_group("player_attack") and area.get_parent().is_attacking:
		var player = area.get_parent()
		take_damage(player.attack_damage, player.global_position)
