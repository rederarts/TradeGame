# scripts/scene_specific/UIManager.gd
extends CanvasLayer
signal transaction_ended
signal sleep_requested

@export var trade_item_row_template: PackedScene

@onready var npc_sell_list_container = $TradePanel/ScrollContainerSell/VBoxContainer
@onready var npc_buy_list_container = $TradePanel/ScrollContainerBuy/VBoxContainer
@onready var sleep_button = $SleepButton

# display_trade_ui関数を更新
func display_trade_ui(npc_instance: Node2D):
	clear_trade_lists()

	# --- NPCの「売りたい」リストをUIに表示 ---
	for item_info in npc_instance.current_sell_offer:
		var item_id = item_info.get("item_id")
		var quantity = item_info.get("quantity")
		var item_data: ItemData = ItemDatabase.get_item_data(item_id)
		
		if item_data == null: continue

		var new_row = trade_item_row_template.instantiate()
		var button = new_row.get_node("TradeButton")

		new_row.get_node("ItemNameLabel").text = item_data.item_name
		new_row.get_node("QuantityLabel").text = "x" + str(quantity)
		new_row.get_node("PriceLabel").text = str(item_data.buyback_price) + " G"
		button.text = "買う"
		
		button.pressed.connect(
			_on_buy_button_pressed.bind(item_id, quantity, item_data.buyback_price, button)
		)

		npc_sell_list_container.add_child(new_row)

	# --- NPCの「買いたい」リストをUIに表示 ---
	for item_info in npc_instance.current_buy_offer:
		var item_id = item_info.get("item_id")
		var quantity = item_info.get("quantity")
		var item_data: ItemData = ItemDatabase.get_item_data(item_id)

		if item_data == null: continue

		var new_row = trade_item_row_template.instantiate()
		var button = new_row.get_node("TradeButton")

		new_row.get_node("ItemNameLabel").text = item_data.item_name
		new_row.get_node("QuantityLabel").text = "x" + str(quantity)
		# プレイヤーが「販売する」ので、purchase_priceを表示
		new_row.get_node("PriceLabel").text = str(item_data.purchase_price) + " G"
		button.text = "売る"

		button.pressed.connect(
			_on_sell_button_pressed.bind(item_id, quantity, item_data.purchase_price, button)
		)

		npc_buy_list_container.add_child(new_row)


func clear_trade_lists():
	for child in npc_sell_list_container.get_children():
		child.queue_free()
	for child in npc_buy_list_container.get_children():
		child.queue_free()

# 「買う」ボタンが押されたときに実行される関数 (更新)
func _on_buy_button_pressed(item_id: String, quantity: int, price: int, button: Button):
	var total_cost = price * quantity

	if PlayerManager.has_enough_money(total_cost):
		PlayerManager.subtract_money(total_cost)
		
		# ★コメントアウトを解除！
		InventoryManager.add_item(item_id, quantity)

		print(item_id, " を購入しました。")
		# 購入成功後、ボタンを無効化して再度押せないようにする
		button.disabled = true
	else:
		print("お金が足りません！")


# 「売る」ボタンが押されたときに実行される関数 (新規追加)
func _on_sell_button_pressed(item_id: String, quantity: int, price: int, button: Button):
	var total_gain = price * quantity

	# 1. アイテムを持っているかチェック
	if InventoryManager.has_item(item_id, quantity):
		# 2. インベントリからアイテムを削除
		InventoryManager.remove_item(item_id, quantity)
		
		# 3. お金を受け取る
		PlayerManager.add_money(total_gain)

		print(item_id, " を売却しました。")
		# 売却成功後、ボタンを無効化
		button.disabled = true
	else:
		print("アイテムが足りません！")
		# 在庫がない場合もボタンを無効化しておく
		button.disabled = true

func _on_end_transaction_button_pressed():
	# transaction_endedシグナルを発信する
	transaction_ended.emit()
# 「寝る」ボタンが押されたときに呼ばれる関数
func _on_sleep_button_pressed():
	sleep_requested.emit()

# 朝になったら呼ばれる関数
func display_day_ui():
	print("朝になりました。")
	# 取引UIと「見送る」ボタンを表示する
	$TradePanel.show()
	$EndTransactionButton.show()
	
	# 「寝る」ボタンを非表示にする
	sleep_button.hide()

# 夜になったら呼ばれる関数
func display_night_ui():
	print("夜になりました。")
	# 取引UIと「見送る」ボタンを非表示にする
	$TradePanel.hide()
	$EndTransactionButton.hide() 
	
	# 「寝る」ボタンを表示する
	sleep_button.show()
