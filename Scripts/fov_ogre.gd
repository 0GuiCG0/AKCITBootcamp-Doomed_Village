extends Area2D

# Configuração de cor e transparência
@export var fov_color: Color = Color(1, 0, 0, 0.3) # Vermelho translúcido

# Referência correta para o nó filho que desenha o polígono azul no editor
# MUDE ABAIXO para bater exatamente com o nome na sua árvore (ex: $vision_shape ou $CollisionPolygon2D)
@onready var collision_shape_node = $vision_shape

func _draw():
	# Verificamos se o nó de colisão existe e é do tipo correto
	if collision_shape_node and collision_shape_node is CollisionPolygon2D:
		# Pegamos os pontos originais
		var points = collision_shape_node.polygon
		if points.size() > 1:
			# --- CORREÇÃO DE COORDENADAS ---
			
			# Pegamos a "matriz de transformação" local do nó de colisão.
			# Isso inclui a posição, rotação e escala que você definiu para ele no editor
			# em relação a este nó Area2D pai.
			var shape_transform = collision_shape_node.get_transform()
			
			var transformed_points = PackedVector2Array()
			
			# Aplicamos essa transformação matemática em cada ponto antes de desenhar
			for point in points:
				# Multiplicar o ponto pela matriz alinha ele perfeitamente com a colisão
				transformed_points.append(shape_transform * point)
				
			# Agora desenhamos os pontos já corrigidos
			draw_polygon(transformed_points, PackedColorArray([fov_color]))
	else:
		print("ERRO NO FOV: O nó filho de colisão não foi encontrado ou não é um CollisionPolygon2D.")

func _process(_delta):
	# ESSENCIAL: Avisamos ao Godot que precisamos redesenhar este nó em cada frame.
	# Isso garante que o desenho acompanhe o monstro e o giro do radar sem atrasos.
	queue_redraw()
