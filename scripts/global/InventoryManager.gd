# scripts/global/InventoryManager.gd
extends Node

# プレイヤーの所持アイテムを管理する辞書
# Key(String): アイテムID (リソースパス)
# Value(int): 所持数
var inventory: Dictionary = {}

# アイテムを追加する関数
func add_item(item_id: String, quantity: int):
	# データベースからアイテムの基本情報を取得
	var item_data: ItemData = ItemDatabase.get_item_data(item_id)
	if item_data == null:
		print("Error: 無効なアイテムIDです: ", item_id)
		return

	# スタック可能なアイテムか、すでにインベントリにある場合
	if item_data.is_stackable or inventory.has(item_id):
		# すでに持っている場合は個数を加算、なければ新しく追加
		inventory[item_id] = inventory.get(item_id, 0) + quantity
	# スタック不可で、インベントリにない場合 (将来的な拡張用)
	else:
		# 本来は個別のアイテムとして管理するが、今回はシンプルに個数で管理
		inventory[item_id] = inventory.get(item_id, 0) + quantity

	print(item_data.item_name, " を ", quantity, " 個入手しました。現在の所持数: ", inventory[item_id])
	# TODO: インベントリUIの更新シグナルをemitする

# アイテムを削除する関数
func remove_item(item_id: String, quantity: int):
	if has_item(item_id, quantity):
		inventory[item_id] -= quantity
		# もし個数が0になったら、インベントリからキーごと削除
		if inventory[item_id] <= 0:
			inventory.erase(item_id)
		
		var item_data: ItemData = ItemDatabase.get_item_data(item_id)
		print(item_data.item_name, " を ", quantity, " 個使用/売却しました。")
		# TODO: インベントリUIの更新シグナルをemitする
	else:
		print("Error: ", item_id, " を ", quantity, " 個持っていません。")

# 指定したアイテムを指定した数だけ持っているかチェックする関数
func has_item(item_id: String, quantity: int) -> bool:
	return inventory.get(item_id, 0) >= quantity
