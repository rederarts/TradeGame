# scripts/scene_specific/UIManager.gd
extends CanvasLayer

signal sleep_requested
signal transaction_ended

@export var trade_item_row_template: PackedScene

# --- UIノードへの参照 ---
@onready var npc_sell_list_container = $VisitUI/TabBuyAndSell/客が売りたいアイテムを確認する/Control/BuyItemScrollContainer/VBoxContainer
@onready var npc_buy_list_container = $VisitUI/TabBuyAndSell/客が買いたいアイテムを確認する/Control/SellItemScrollContainer/VBoxContainer
@onready var sleep_button = $DayEndUI/SleepButton
@onready var end_transaction_button = $VisitUI/EndTransactionButton
@onready var visit_ui = $VisitUI
@onready var day_end_ui = $DayEndUI

@onready var npc_image = $VisitUI/NPCImage
@onready var npc_name_label = $VisitUI/NPCDialogueWindow/TalkNPCName
@onready var empty_sell_message_label = $VisitUI/TabBuyAndSell/客が売りたいアイテムを確認する/Control/EmptySellMessageLabel
@onready var empty_buy_message_label = $VisitUI/TabBuyAndSell/客が買いたいアイテムを確認する/Control/EmptyBuyMessageLabel
@onready var money_label = $MoneyLabel

@onready var item_detail_popup = $ItemDetailPopup
@onready var npc_dialogue_window = $VisitUI/NPCDialogueWindow
@onready var npc_dialogue_label = $VisitUI/NPCDialogueWindow/NPCDialogue

# ポップアップに渡すため、現在の取引情報を一時的に保持する変数
var current_popup_item_info: Dictionary

func _ready():
	PlayerManager.money_changed.connect(_on_player_money_changed)
	_on_player_money_changed(PlayerManager.current_money)
	
	# ポップアップからのシグナルを接続
	item_detail_popup.confirmed.connect(_on_popup_confirmed)
	item_detail_popup.cancelled.connect(_on_popup_cancelled)
	
	# デフォルトでダイアログは非表示
	npc_dialogue_window.hide()

# ★所持金が変更されたときに呼ばれる関数
func _on_player_money_changed(new_money: int):
	money_label.text = str(new_money) + " G"
	
# ★朝になったら呼ばれる関数
func display_day_ui():
	visit_ui.show()
	day_end_ui.hide()
# ★夜になったら呼ばれる関数
func display_night_ui():
	visit_ui.hide()
	day_end_ui.show()
# display_trade_ui関数
func display_trade_ui(npc_instance: Node2D):
	clear_trade_lists()
	
	npc_name_label.text = npc_instance.npc_data.npc_name
	
	if npc_instance.npc_data.portrait != null:
		npc_image.texture = npc_instance.npc_data.portrait
	else:
		npc_image.texture = load("res://assets/images/characters/立ち絵NoImage（背景透過）.png")
		
	empty_sell_message_label.hide()
	empty_buy_message_label.hide()

	var sell_offer = npc_instance.current_sell_offer
	var buy_offer = npc_instance.current_buy_offer

	#  売買リストが両方とも空の場合
	if sell_offer.is_empty() and buy_offer.is_empty():
		empty_sell_message_label.text = "今日は特に用はないんだ。また来るよ。"
		empty_sell_message_label.show()
		empty_buy_message_label.hide() # 念のため非表示
		return # ★ここで処理を終了

	#  売りたいリストが空の場合
	if sell_offer.is_empty():
		empty_sell_message_label.text = "今日は売りたいアイテムはなくて、買いに来たんだ"
		empty_sell_message_label.show()
	else:
		for item_info in sell_offer:
			# (既存のadd_child処理)
			var item_id = item_info.get("item_id")
			var quantity = item_info.get("quantity")
			var item_data: ItemData = ItemDatabase.get_item_data(item_id)
			if item_data == null: continue
			var new_row = trade_item_row_template.instantiate()
			new_row.get_node("HBoxContainer/ItemNameLabel").text = item_data.item_name
			new_row.get_node("HBoxContainer/QuantityLabel").text = "x" + str(quantity)
			new_row.pressed.connect(_on_trade_item_button_pressed.bind(item_info, "BUY"))
			npc_sell_list_container.call_deferred("add_child", new_row)

	#  買いたいリストが空の場合
	if buy_offer.is_empty():
		empty_buy_message_label.text = "今日は買おうと思って要るアイテムはなくて、売りに来たんだ"
		empty_buy_message_label.show()
	else:
		for item_info in buy_offer:
			# (既存のadd_child処理)
			var item_id = item_info.get("item_id")
			var quantity = item_info.get("quantity")
			var item_data: ItemData = ItemDatabase.get_item_data(item_id)
			if item_data == null: continue
			var new_row = trade_item_row_template.instantiate()
			new_row.get_node("HBoxContainer/ItemNameLabel").text = item_data.item_name
			new_row.get_node("HBoxContainer/QuantityLabel").text = "x" + str(quantity)
			if not InventoryManager.has_item(item_id, quantity):
				new_row.disabled = true
			new_row.pressed.connect(_on_trade_item_button_pressed.bind(item_info, "SELL"))
			npc_buy_list_container.call_deferred("add_child", new_row)

# アイテムボタンが押されたら、対応するデータと共にポップアップを開く
func _on_trade_item_button_pressed(item_info: Dictionary, type: String):
	var item_data: ItemData = ItemDatabase.get_item_data(item_info.get("item_id"))
	if item_data:
		item_detail_popup.open_with_data(item_data, item_info, type)

# ポップアップで「買う/売る」が確定された時の処理
func _on_popup_confirmed(item_id: String, quantity: int, price: int, type: String):
	if type == "BUY":
		var total_cost = price * quantity
		if PlayerManager.has_enough_money(total_cost):
			PlayerManager.subtract_money(total_cost)
			InventoryManager.add_item(item_id, quantity)
			show_npc_dialogue("毎度あり！")
		else:
			show_npc_dialogue("おっと、お金が足りないようだぜ。")
	elif type == "SELL":
		var total_gain = price * quantity
		if InventoryManager.has_item(item_id, quantity):
			InventoryManager.remove_item(item_id, quantity)
			PlayerManager.add_money(total_gain)
			show_npc_dialogue("これを探してたんだ、助かるよ！")
		else:
			show_npc_dialogue("おっと、そいつはそんなに持ってないじゃないか。")
			
# ポップアップで「買わない/売らない」が選択された時の処理
func _on_popup_cancelled():
	# ここに条件分岐セリフのロジックを実装
	show_npc_dialogue("そうかい、残念だ。")

# セリフウィンドウを表示するヘルパー関数
func show_npc_dialogue(text: String):
	npc_dialogue_label.text = text
	npc_dialogue_window.show()

func clear_trade_lists():
	for child in npc_sell_list_container.get_children():
		child.queue_free()
	for child in npc_buy_list_container.get_children():
		child.queue_free()

func _on_end_transaction_button_pressed():
	# transaction_endedシグナルを発信する
	transaction_ended.emit()
# 「寝る」ボタンが押されたときに呼ばれる関数
func _on_sleep_button_pressed():
	sleep_requested.emit()
