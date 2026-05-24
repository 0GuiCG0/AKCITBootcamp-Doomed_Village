extends CharacterBody2D

@export var speed: float = 150.0
# Multiplicador que define o quão maior a área de visão será (2.0 = dobro do tamanho)
@export var fov_multiplier: float = 2.0 

var player: Node2D = null
var is_chasing: bool = false

@onready var vision_area: Area2D = $FOV

func _ready() -> void:
	# Aplica o multiplicador para aumentar a área de detecção logo ao iniciar a cena
	vision_area.scale = Vector2(fov_multiplier, fov_multiplier)
	
	# Conecta os sinais da área de visão
	vision_area.body_entered.connect(_on_fov_body_entered)
	vision_area.body_exited.connect(_on_fov_body_exited)

func _physics_process(delta: float) -> void:
	if is_chasing and player:
		# Calcula a direção exata para onde o jogador está
		var direction = global_position.direction_to(player.global_position)
		
		# Move o inimigo usando o sistema de física (evita atravessar paredes)
		velocity = direction * speed
		move_and_slide()
		
		# Gira o cone de visão para continuar olhando para o jogador durante a perseguição
		vision_area.rotation = global_position.angle_to_point(player.global_position) + PI
		
	else:
		# O inimigo fica parado se não houver jogador na área
		velocity = Vector2.ZERO
		move_and_slide()

# --- SINAIS DE DETECÇÃO ---

func _on_fov_body_entered(body: Node2D) -> void:
	if body == self: return # Evita que o inimigo detecte a si mesmo
	
	# Verifica se o corpo que entrou possui o grupo ou o nome do player
	if body.is_ingroup("player") or body.name == "player":
		player = body
		is_chasing = true
		print("Jogador entrou no campo de visão! Iniciando perseguição.")

func _on_fov_body_exited(body: Node2D) -> void:
	# Se o jogador sair da área ampliada, o inimigo para de seguir
	if body == player:
		player = null
		is_chasing = false
		print("Jogador escapou do campo de visão.")
