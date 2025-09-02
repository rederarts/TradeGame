# scripts/scene_specific/UIManager.gd
extends CanvasLayer

# 取引アイテム1行分のUIテンプレートシーンをインスペクターから設定
@export var trade_item_row_template: PackedScene

# --- UIノードへの参照 ---
# NPCが売るアイテムリストを表示するコンテナ
@onready var npc_sell_list_container = $TradePanel/ScrollContainerSell/VBoxContainer
# NPCが買うアイテムリストを表示するコンテナ
@onready var npc_buy_list_container = $TradePanel/ScrollContainerBuy/VBoxContainer


# NPCインスタンスを受け取り、取引UIを画面に表示するメイン関数
func display_trade_ui(npc_instance: Node2D):
	# 最初に既存のリストをクリアする
	clear_trade_lists()

	# --- NPCの「売りたい」リストをUIに表示 ---
	for item_info in npc_instance.current_sell_offer:
		# 1. アイテムIDから完全なItemDataを取得
		var item_id = item_info.get("item_id")
		var item_data: ItemData = ItemDatabase.get_item_data(item_id)
		
		if item_data == null:
			print("Error: ItemData not found for ID: ", item_id)
			continue

		# 2. テンプレートから新しい行UIをインスタンス化
		var new_row = trade_item_row_template.instantiate()

		# 3. 新しい行UIにデータを設定 (UIノードの名前は仮)
		new_row.get_node("ItemNameLabel").text = item_data.item_name
		new_row.get_node("QuantityLabel").text = "x" + str(item_info.get("quantity"))
		# プレイヤーが「買い取る」ので、buyback_priceを表示
		new_row.get_node("PriceLabel").text = str(item_data.buyback_price) + " G"
		new_row.get_node("TradeButton").text = "買う"

		# 4. コンテナに行UIを追加
		npc_sell_list_container.add_child(new_row)

	# --- NPCの「買いたい」リストも同様に表示 ---
	# (コードは省略しますが、"purchase_price"を使い、ボタンテキストを「売る」にするなど、同様の処理)
	

# 表示されている取引リストを全て削除する関数
func clear_trade_lists():
	for child in npc_sell_list_container.get_children():
		child.queue_free()
	for child in npc_buy_list_container.get_children():
		child.queue_free()
