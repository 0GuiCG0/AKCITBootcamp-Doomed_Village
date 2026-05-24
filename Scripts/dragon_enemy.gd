extends CharacterBody2D

@export var speed: float = 120.0 
@export var rotation_speed: float = 3.0 
@export var attack_range: float = 60.0 

# --- NOVA VARIÁVEL: Define se o boss já foi despertado ---
@export var is_active: bool = false 

# --- Variáveis para a Animação Procedural de Voo/Caminhada ---
@export var walk_anim_speed: float = 15.0 
@export var walk_anim_angle: float = 0.15 
@export var walk_anim_bounce: float = 5.0 
var walk_timer: float = 0.0
var sprite_base_position: Vector2 

# --- Variáveis de Ataque ---
@export var attack_damage: int = 20
@export var attack_cooldown: float = 1.5 
var can_attack: bool = true
var is_attacking: bool = false

var player: Node2D = null
var is_chasing: bool = false

@onready var sprite = $Sprite2D
@onready var vision_area = $FOV 
@onready var anim_player = $AnimationPlayer 

func _ready():
	sprite_base_position = sprite.position
	if vision_area:
		vision_area.body_entered.connect(_on_see_player_body_entered)
		vision_area.body_exited.connect(_on_see_player_body_exited)

func _physics_process(delta):
	if not vision_area: return
	vision_area.scale = Vector2.ONE 
	
	# Se o boss não estiver ativo, ele fica parado na animação idle
	if not is_active:
		if anim_player and anim_player.has_animation("idle") and anim_player.current_animation != "idle":
			anim_player.play("idle")
		return
	
	if is_attacking:
		_reset_sprite_transform(delta)
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	if is_chasing and player:
		var direction = global_position.direction_to(player.global_position)
		vision_area.rotation = global_position.angle_to_point(player.global_position) + PI
		
		if direction.x != 0:
			sprite.flip_h = (direction.x > 0)
			
		var distance_to_player = global_position.distance_to(player.global_position)
		
		if distance_to_player > attack_range:
			# --- ESTADO: PERSEGUINDO ---
			velocity = direction * speed
			move_and_slide()
			
			if anim_player and anim_player.has_animation("walking") and anim_player.current_animation != "walking":
				anim_player.play("walking")
			
			walk_timer += delta
			sprite.rotation = sin(walk_timer * walk_anim_speed) * walk_anim_angle
			sprite.position.y = sprite_base_position.y - abs(cos(walk_timer * walk_anim_speed)) * walk_anim_bounce
			
		else:
			# --- ESTADO: PARADO PERTO DO PLAYER ---
			velocity = Vector2.ZERO
			move_and_slide()
			_reset_sprite_transform(delta)
			
			if can_attack:
				attack()
			else:
				if anim_player and anim_player.has_animation("idle") and anim_player.current_animation != "idle":
					anim_player.play("idle")
		
	else:
		# --- ESTADO: IDLE (Rodando FOV) ---
		velocity = Vector2.ZERO
		move_and_slide()
		
		vision_area.rotation += rotation_speed * delta
		var fov_direction = Vector2.LEFT.rotated(vision_area.rotation)
		sprite.flip_h = (fov_direction.x > 0)
		
		if anim_player and anim_player.has_animation("idle") and anim_player.current_animation != "idle":
			anim_player.play("idle")
			
		_reset_sprite_transform(delta)

func _reset_sprite_transform(delta):
	walk_timer = 0.0
	sprite.rotation = lerp(sprite.rotation, 0.0, delta * 10.0)
	sprite.position.y = lerp(sprite.position.y, sprite_base_position.y, delta * 10.0)

func _on_see_player_body_entered(body):
	if body == self: return
	if body.is_in_group("player") or body.name == "player":
		player = body
		# Só inicia a perseguição de imediato se o boss já estiver ativo
		if is_active:
			is_chasing = true

func _on_see_player_body_exited(body):
	if body == player:
		player = null
		is_chasing = false
		
func attack():
	if can_attack:
		can_attack = false 
		is_attacking = true 
		
		if anim_player and anim_player.has_animation("attack"):
			anim_player.play("attack")
			
		print("Dragão atacou o jogador!")
		
		if anim_player and anim_player.has_animation("attack"):
			await anim_player.animation_finished
		else:
			await get_tree().create_timer(0.5).timeout 
		
		is_attacking = false 
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

# --- NOVA FUNÇÃO: Chamada pelo gatilho do mapa para acordar o boss ---
func activate_boss():
	is_active = true
	print("Boss ativado!")
	# Caso o jogador já esteja dentro do campo de visão ao ativar
	if player:
		is_chasing = true
