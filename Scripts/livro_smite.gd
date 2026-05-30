extends Area2D

@onready var sprite: Sprite2D = $livro

func _ready() -> void:
	# Conecta o sinal de entrar na área
	body_entered.connect(_on_body_entered)
	
	# Efeito do livro flutuando magicamente
	var tween = create_tween().set_loops()
	tween.tween_property(sprite, "position:y", -5.0, 1.0).as_relative().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "position:y", 5.0, 1.0).as_relative().set_trans(Tween.TRANS_SINE)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("aprender_smite"):
			body.aprender_smite()
			queue_free()
