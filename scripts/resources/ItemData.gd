extends Resource
class_name ItemData

## --- 基本情報 ---
@export var item_name: String = "新しいアイテム"
@export_multiline var description: String = "これはアイテムの説明です。"
@export var icon: Texture2D # アイテムのアイコン画像

## --- 価格設定 ---
@export_group("Price Settings")
# 店主（プレイヤー）がNPCからアイテムを「買い取る」ときの価格
@export var buyback_price: int = 10
# 店主（プレイヤー）がNPCにアイテムを「販売」するときの価格
@export var purchase_price: int = 20

## --- インベントリ関連 ---
@export_group("Inventory Settings")
@export var grid_size: Vector2i = Vector2i(1, 1) # 棚での占有マス数 (幅, 高さ)
@export var depth: int = 1 # 奥行き
@export var volume: int = 1 # 倉庫での容量
@export var is_stackable: bool = false # 重ね置き可能か
@export var max_stack_count: int = 1 # is_stackableがtrueの場合の最大数

## --- 知識システム関連 ---
@export_group("Knowledge System")
# 知識レベルに応じた説明文のリスト
# Key(int): 知識レベル, Value(String): そのレベルでの説明文
@export var knowledge_descriptions: Dictionary = {0: "まだ何もわかっていない。"}


func _init():
	# volumeが未設定の場合、サイズから自動計算する
	if volume <= 1 and (grid_size.x > 1 or grid_size.y > 1 or depth > 1):
		volume = grid_size.x * grid_size.y * depth
