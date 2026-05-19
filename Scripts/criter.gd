extends Area2D

@export var speed: float = 100.0
@export var rotation_speed: float = 3.0 
# Distância limite para o monstro parar antes de atacar (controlável no Inspector)
@export var attack_range: float = 50.0 

var player: Node2D = null
var is_chasing: bool = false

@onready var sprite = $Sprite2D
@onready var vision_area = $FOV

func _ready():
	vision_area.body_entered.connect(_on_see_player_body_entered)
	vision_area.body_exited.connect(_on_see_player_body_exited)

func _process(delta):
	vision_area.scale = Vector2.ONE 
	
	if is_chasing and player:
		var direction = global_position.direction_to(player.global_position)
		vision_area.rotation = global_position.angle_to_point(player.global_position) + PI
		
		if direction.x != 0:
			sprite.flip_h = (direction.x > 0)
			
		# Calcula a distância exata até o jogador
		var distance_to_player = global_position.distance_to(player.global_position)
		
		# Só se move se estiver mais longe que a distância de ataque
		if distance_to_player > attack_range:
			global_position += direction * speed * delta
		else:
			# O monstro parou perto do jogador. 
			# Espaço reservado para iniciar a animação/lógica de ataque futuramente.
			pass
		
	else:
		vision_area.rotation += rotation_speed * delta
		var fov_direction = Vector2.LEFT.rotated(vision_area.rotation)
		sprite.flip_h = (fov_direction.x > 0)

func _on_see_player_body_entered(body):
	if body == self: return
	if body.is_in_group("player") or body.name == "player":
		player = body
		is_chasing = true

func _on_see_player_body_exited(body):
	if body == player:
		player = null
		is_chasing = false
