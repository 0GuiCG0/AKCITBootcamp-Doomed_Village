extends Node2D

# Referências
@onready var player: CharacterBody2D = $Player
@onready var enemy: Area2D = $Enemy # Atualizado para RigidBody2D do passo anterior

# Carrega a imagem do cenário (Recomendo usar .png ao invés de .jpg pela transparência)
var spritesheet_cenario = preload("res://Assets/Cena/florest_no-floor.png") 

func _ready():
	# ... seu código de inicialização do player e inimigo ...
	
	gerar_cenario()

# --- FUNÇÃO PARA GERAR O CENÁRIO VIA CÓDIGO ---
func gerar_cenario():
	# 1. Defina as posições (X, Y) onde você quer que os objetos apareçam na fase
	var posicoes_arvores = [Vector2(100, 150), Vector2(400, 100), Vector2(-150, 200)]
	var posicoes_pedras = [Vector2(250, 300), Vector2(-50, 50)]
	
	# 2. Defina o "Recorte" (Rect2) de onde a árvore e a pedra estão na imagem original
	# Formato: Rect2(Posição_X_na_imagem, Posição_Y_na_imagem, Largura, Altura)
	# ATENÇÃO: Você precisará ajustar os números abaixo baseados nos pixels exatos da sua imagem!
	var regiao_arvore = Rect2(0, 0, 128, 128) # Exemplo: Recorte do topo esquerdo
	var regiao_pedra = Rect2(256, 128, 64, 64) # Exemplo: Recorte do meio da imagem
	
	# 3. Cria os objetos usando os loops
	for pos in posicoes_arvores:
		criar_obstaculo(regiao_arvore, pos)
		
	for pos in posicoes_pedras:
		criar_obstaculo(regiao_pedra, pos)

# Função que constrói o obstáculo com textura e colisão
func criar_obstaculo(regiao_imagem: Rect2, posicao_mundo: Vector2):
	# Cria um corpo estático (para o jogador e inimigo não conseguirem atravessar)
	var corpo_estatico = StaticBody2D.new()
	corpo_estatico.position = posicao_mundo
	
	# Cria o Sprite e aplica apenas a região recortada da spritesheet
	var sprite = Sprite2D.new()
	sprite.texture = spritesheet_cenario
	sprite.region_enabled = true
	sprite.region_rect = regiao_imagem
	
	# Cria a caixa de colisão física
	var colisao = CollisionShape2D.new()
	var formato = RectangleShape2D.new()
	# Faz a colisão ser um pouco menor que o tamanho da imagem para ficar mais natural
	formato.size = regiao_imagem.size * 0.7 
	colisao.shape = formato
	
	# Monta a estrutura de nós (Coloca Sprite e Colisão dentro do Corpo Estático)
	corpo_estatico.add_child(sprite)
	corpo_estatico.add_child(colisao)
	
	# Adiciona o objeto final na cena principal
	add_child(corpo_estatico)
