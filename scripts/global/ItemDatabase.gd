# scripts/global/ItemDatabase.gd
extends Node

# インスペクターで全ItemDataリソースを登録する
@export var item_data_list: Array[ItemData]

# ItemDataをIDですぐに探せるように、辞書に変換して保持する
var item_database: Dictionary = {}

func _ready():
	# ゲーム開始時に配列から辞書へ変換する
	for item_data in item_data_list:
		# resource_pathをIDとして使う。例: "res://resources/items/rusty_sword.tres"
		if item_data != null:
			item_database[item_data.resource_path] = item_data

# ID（リソースのパス）を渡して、対応するItemDataを返す関数
func get_item_data(item_id: String) -> ItemData:
	return item_database.get(item_id)
