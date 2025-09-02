# scripts/scene_specific/MainScene.gd
extends Node2D

@export var npc_scene: PackedScene # インスペクターからNPC.tscnを設定
@onready var npc_spawn_point = $NPC_SpawnPoint # NPCの表示位置
@onready var ui_manager = $UI # UI.tscnのインスタンス

var current_npc_instance: Node2D = null

func _ready():
	# GameManagerの状態変化シグナルに関数を接続
	GameManager.state_changed.connect(_on_game_state_changed)
	ui_manager.transaction_ended.connect(end_current_transaction)
	# ゲーム開始時に最初の客を呼ぶ
	_on_game_state_changed(GameManager.current_state)


# ゲームの状態が変化したときに呼ばれる関数
func _on_game_state_changed(new_state: GameManager.GameState):
	match new_state:
		GameManager.GameState.DAY_WAITING:
			# 客待ち状態なら、次の客をスポーンさせる
			spawn_next_npc()
		GameManager.GameState.NIGHT:
			# 夜になったら、NPCを消してUIを更新
			if is_instance_valid(current_npc_instance):
				current_npc_instance.queue_free()
			ui_manager.display_night_ui() # UIManagerに夜用UI表示を依頼 (後で実装)


# 次の客を生成して表示する関数
func spawn_next_npc():
	# NPCManagerからランダムなNPCデータを取得 (後でNPCManagerにこの関数を追加)
	var npc_data: NPCData = NPCManager.get_random_npc_data()
	if npc_data == null:
		print("Error: NPCデータが取得できませんでした。")
		return

	# NPCシーンをインスタンス化
	current_npc_instance = npc_scene.instantiate()
	current_npc_instance.position = npc_spawn_point.position
	
	# NPCを初期化して、取引内容を決定させる
	current_npc_instance.initialize(npc_data)

	# シーンにNPCを追加
	add_child(current_npc_instance)

	# UIManagerに取引UIの表示を依頼
	ui_manager.display_trade_ui(current_npc_instance)
	GameManager.current_state = GameManager.GameState.DAY_TRADING


# 取引終了時にUIのボタンなどから呼び出す関数
func end_current_transaction():
	if is_instance_valid(current_npc_instance):
		current_npc_instance.queue_free()
	
	ui_manager.clear_trade_lists()
	
	# GameManagerにターンを進めるよう依頼
	GameManager.progress_turn()
