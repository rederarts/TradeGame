# scripts/scene_specific/ItemDetailPopup.gd
extends PanelContainer

# ボタンが押されたことをUIManagerに通知するためのシグナル
signal confirmed(item_id, quantity_to_trade, price, transaction_type)
signal cancelled
signal asked_question(item_id)
signal waited

# ポップアップが現在表示しているアイテムの情報
var current_item_id: String
var current_price: int
var current_max_quantity: int
var current_transaction_type: String # "BUY" or "SELL"

var quantity_to_trade: int = 1

# --- UIノードへの参照 ---
@onready var darken_overlay = $DarkenOverlay
@onready var item_image = $ContentVBox/ItemImage
@onready var item_description_label = $ContentVBox/ItemDescriptionLabel
@onready var quantity_label = $ContentVBox/QuantitySelector/QuantityLabel
@onready var confirm_button = $ContentVBox/ActionButtons/ConfirmButton
# ... 他のボタンへの参照も同様に追加

func _ready():
	# 各ボタンのpressedシグナルを内部の関数に接続
	confirm_button.pressed.connect(_on_confirm_pressed)
	$ContentVBox/ActionButtons/CancelButton.pressed.connect(_on_cancel_pressed)
	$ContentVBox/ActionButtons/AskButton.pressed.connect(_on_ask_pressed)
	$ContentVBox/ActionButtons/WaitButton.pressed.connect(_on_wait_pressed)
	$ContentVBox/QuantitySelector/PlusButton.pressed.connect(_on_plus_pressed)
	$ContentVBox/QuantitySelector/MinusButton.pressed.connect(_on_minus_pressed)
	hide() # 最初は隠しておく

# UIManagerから呼ばれ、ポップアップを開く関数
func open_with_data(item_data: ItemData, item_info: Dictionary, type: String):
	current_item_id = item_info.get("item_id")
	current_max_quantity = item_info.get("quantity")
	current_transaction_type = type
	quantity_to_trade = 1 # 数量をリセット

	# アイテム画像
	if item_data.icon:
		item_image.texture = item_data.icon
	else:
		item_image.texture = load("res://assets/images/items/アイテム画像NoImage（背景透過）.png")
	
	# アイテム説明
	item_description_label.text = item_data.description
	
	# 価格とボタンのテキストを設定
	if type == "BUY": # プレイヤーが買う
		current_price = item_data.buyback_price
		confirm_button.text = "買う"
	else: # プレイヤーが売る
		current_price = item_data.purchase_price
		confirm_button.text = "売る"
	
	_update_quantity_label()
	show()

func _update_quantity_label():
	quantity_label.text = str(quantity_to_trade) + " / " + str(current_max_quantity)

func _on_plus_pressed():
	quantity_to_trade = min(quantity_to_trade + 1, current_max_quantity)
	_update_quantity_label()

func _on_minus_pressed():
	quantity_to_trade = max(quantity_to_trade - 1, 1)
	_update_quantity_label()

# --- シグナル発信 ---
func _on_confirm_pressed():
	confirmed.emit(current_item_id, quantity_to_trade, current_price, current_transaction_type)
	hide()

func _on_cancel_pressed():
	cancelled.emit()
	hide()

func _on_ask_pressed():
	asked_question.emit(current_item_id)
	# hide() # 質問中は閉じない方が良いかもしれない

func _on_wait_pressed():
	waited.emit()
	hide()
