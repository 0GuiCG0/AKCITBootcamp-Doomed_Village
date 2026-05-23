extends Area2D

@export var dialog_box: Control 
# Arraste os nós de Botão do seu DialogBox para cá no Inspector
@export var botao_conversar: Button 
@export var botao_loja: Button 

var player_in_range: bool = false
var vezes_conversadas: int = 0 # Contador de interações

func _ready():
	# Conectamos os sinais de "pressed" (clique) dos botões às nossas funções
	if botao_conversar:
		botao_conversar.pressed.connect(_on_botao_conversar_pressed)
	if botao_loja:
		botao_loja.pressed.connect(_on_botao_loja_pressed)

func _on_body_entered(body):
	if body.is_in_group("player"): 
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		fechar_dialogo()

func _input(event):
	if event.is_action_pressed("interact") and player_in_range:
		if not dialog_box.visible:
			abrir_dialogo()
		else:
			fechar_dialogo()

# --- FUNÇÕES DE CONTROLE DA UI ---

func abrir_dialogo():
	dialog_box.show()
	# Texto de saudação padrão sempre que abrir
	dialog_box.get_node("dialogo").text = "Hehe! O que vai querer hoje?"
	botao_conversar.show()
	botao_loja.show()

func fechar_dialogo():
	dialog_box.hide()

# --- FUNÇÕES DOS BOTÕES ---

func _on_botao_conversar_pressed():
	vezes_conversadas += 1
	dialogos()

func _on_botao_loja_pressed():
	dialog_box.get_node("dialogo").text = "Dê uma olhada nas minhas mercadorias!"
	# Coloque aqui a lógica para abrir o painel do Inventário/Loja
	# Ex: loja_ui.show()

# --- FUNÇÃO DE DIÁLOGOS DINÂMICOS ---

func dialogos():
	# O comando 'match' funciona como um 'switch' ou vários 'if/elif', 
	# perfeito para checar números exatos
	match vezes_conversadas:
		1:
			dialog_box.get_node("dialogo").text = "Sabe... essa floresta costumava ser mais segura."
		2:
			dialog_box.get_node("dialogo").text = "Eu não sou apenas um mercador, eu já fui um mago respeitado! ...É sério."
		3:
			dialog_box.get_node("dialogo").text = "Você faz muitas perguntas para quem não está comprando nada."
		4:
			dialog_box.get_node("dialogo").text = "Vai comprar ou vai ficar aí me encarando?"
		_: 
			# O '_' serve como fallback (para qualquer número maior que 4)
			dialog_box.get_node("dialogo").text = "..."
