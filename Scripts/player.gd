extends CharacterBody2D

@export_category("Movement Stats")
@export var speed: int = 400

@export_category("Player Stats")
@export var max_hp: int = 100
@export var max_mana: int = 50
@export var max_xp: int = 100

@export_category("Mecânicas de Tempo / Custos")
# Mantendo a lógica de tempo ativa (pode usar para dreno de fome/sede no futuro)
@export var dreno_hp_por_segundo: float = 0.0 
@export var regeneracao_mana_por_segundo: float = 3.0 # Mana recupera 3 pontos por segundo
@export var custo_disparo_poderoso: int = 15          # Quanto cada tiro gasta

var current_hp: float 
var current_mana: float
var current_xp: float

var move_direction: Vector2 = Vector2.ZERO

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

# --- Referências da UI ---
@onready var hud_hp: ProgressBar = $HUD/hp
@onready var hud_mana: ProgressBar = $HUD/holy_mana
@onready var hud_xp: ProgressBar = $HUD/xp

# --- Referências dos Textos ---
@onready var txt_hp: Label = $HUD/hp/Texto
@onready var txt_mana: Label = $HUD/holy_mana/Texto
@onready var txt_xp: Label = $HUD/xp/Texto

func _ready() -> void:
	current_hp = max_hp
	current_mana = max_mana
	current_xp = 0
	
	hud_hp.max_value = max_hp
	hud_hp.value = current_hp
	hud_mana.max_value = max_mana
	hud_mana.value = current_mana
	hud_xp.max_value = max_xp
	hud_xp.value = current_xp

func _physics_process(_delta: float) -> void:
	movement_loop()
	update_animation()
	
	# Exemplo: Se pressionar o botão de ataque (configure "atacar" nas Configurações do Projeto)
	if Input.is_action_just_pressed("atacar"):
		tentar_disparo_poderoso()

func _process(delta: float) -> void:
	# 1. DRENO PASSIVO (HP/Fome/Sede)
	if dreno_hp_por_segundo > 0:
		current_hp = clamp(current_hp - (dreno_hp_por_segundo * delta), 0, max_hp)
		hud_hp.value = current_hp
		
	# 2. REGENERAÇÃO PASSIVA DA MANA
	if current_mana < max_mana:
		current_mana = clamp(current_mana + (regeneracao_mana_por_segundo * delta), 0, max_mana)
		hud_mana.value = current_mana

	# 3. ATUALIZAÇÃO DOS TEXTOS EM TEMPO REAL (Acompanhando o visual da barra)
	txt_hp.text = "%d / %d" % [round(hud_hp.value), hud_hp.max_value]
	txt_mana.text = "%d / %d" % [round(hud_mana.value), hud_mana.max_value]
	txt_xp.text = "%d / %d" % [round(hud_xp.value), hud_xp.max_value]

func movement_loop() -> void:
	move_direction = Input.get_vector("left", "right", "up", "down")
	velocity = move_direction * speed
	move_and_slide()

func update_animation() -> void:
	var mouse_direction = (get_global_mouse_position() - global_position).normalized()
	animation_tree.set("parameters/Idle/blend_position", mouse_direction)
	animation_tree.set("parameters/Run/blend_position", mouse_direction)
	
	if move_direction != Vector2.ZERO:
		animation_playback.travel("Run")
	else:
		animation_playback.travel("Idle")

# ==========================================
# Mecânica do Disparo de Mana
# ==========================================

func tentar_disparo_poderoso() -> void:
	# Verifica se o jogador tem mana suficiente para o custo do tiro
	if current_mana >= custo_disparo_poderoso:
		gastar_mana(custo_disparo_poderoso)
		instanciar_projetil_poderoso()
	else:
		print("Sem mana sagrada suficiente!")

func instanciar_projetil_poderoso() -> void:
	print("Disparo Poderoso Realizado!")
	# Insira aqui o seu código que cria a cena do tiro (instantiate)

# ==========================================
# Funções de Impacto/Modificação da HUD
# ==========================================

func tomar_dano(quantidade: int) -> void:
	current_hp -= quantidade
	current_hp = clamp(current_hp, 0, max_hp)
	
	var tween = create_tween()
	tween.tween_property(hud_hp, "value", current_hp, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# --- NOVA VERIFICAÇÃO DE MORTE ---
	if current_hp <= 0:
		morrer()

# --- NOVA FUNÇÃO ---
func morrer() -> void:
	print("O jogador morreu! Resetando o universo...")
	
	# Desativa o processamento para o jogador parar de andar/atacar na hora
	set_physics_process(false)
	set_process(false)
	
	# Se você tiver uma animação de morte no AnimationTree, pode chamar aqui:
	# animation_playback.travel("Death")
	
	# Cria uma pequena pausa dramática de 1 segundo (para não resetar de forma bizarra no exato milissegundo)
	await get_tree().create_timer(1.0).timeout 
	
	# O comando mágico que reseta a cena inteira
	get_tree().reload_current_scene()

func gastar_mana(quantidade: int) -> void:
	current_mana -= quantidade
	current_mana = clamp(current_mana, 0, max_mana)
	
	# O Tween faz a barra dar aquele "pulo" rápido para baixo ao gastar
	var tween = create_tween()
	tween.tween_property(hud_mana, "value", current_mana, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func ganhar_xp(quantidade: int) -> void:
	current_xp += quantidade
	var tween = create_tween()
	tween.tween_property(hud_xp, "value", current_xp, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	if current_xp >= max_xp:
		subir_de_nivel()

func subir_de_nivel() -> void:
	current_xp = 0
	max_hp += 10
	current_hp = max_hp
	hud_hp.max_value = max_hp
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(hud_xp, "value", 0, 0.2)
	tween.tween_property(hud_hp, "value", current_hp, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	print("Level Up!")
