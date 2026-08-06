extends Control

@onready var rank_label: Label = $RankLabel
@onready var multiplier_label: Label = $MultiplierLabel
@onready var combo_bar: ProgressBar = $ComboBar
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	ComboManager.combo_updated.connect(_on_combo_updated)
	ComboManager.combo_dropped.connect(_on_combo_dropped)

func _process(delta: float) -> void:
	if ComboManager.combo_count > 0:
		combo_bar.value = (ComboManager.combo_timer / ComboManager.combo_window) * 100

func _on_combo_updated(count: int, rank: String, multiplier: float) -> void:
	if not visible:
		visible = true
	
	var prev_rank = rank_label.text
	rank_label.text = rank
	multiplier_label.text = str(multiplier) + "x XP"
	
	if prev_rank != rank:
		animation_player.play("rank_up")
	else:
		animation_player.play("hit")
	
	match rank:
		"D": rank_label.modulate = Color.GRAY                                                                                                                                                                
		"C": rank_label.modulate = Color.WHITE                                                                                                                                                               
		"B": rank_label.modulate = Color.GREEN                                                                                                                                                               
		"A": rank_label.modulate = Color.BLUE                                                                                                                                                                
		"S": rank_label.modulate = Color.PURPLE                                                                                                                                                              
		"SSS": rank_label.modulate = Color.GOLD
	
func _on_combo_dropped() -> void:
	visible = false
	rank_label.text = ""
	RunState.modifier_multiplier = 1
