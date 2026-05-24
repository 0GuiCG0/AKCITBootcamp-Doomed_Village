extends Area2D

# Expondo a variável para você vincular o boss no Inspector
@export var boss_node: NodePath 

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player") or body.name == "player":
		# Busca o nó do boss com base no caminho passado no Inspector
		var boss = get_node_or_null(boss_node)
		
		# Se encontrou o boss e ele possui a função de ativar
		if boss and boss.has_method("activate_boss"):
			boss.activate_boss()
			
			# Remove o gatilho da cena para não ser ativado novamente
			queue_free()
