# scripts/global/PlayerManager.gd
extends Node

# 現在の所持金
var current_money: int = 100 # 初期所持金を100Gに設定

# お金を増やす関数
func add_money(amount: int):
	current_money += amount
	print("所持金: ", current_money) # デバッグ用にコンソール出力

# お金を減らす関数
func subtract_money(amount: int):
	current_money -= amount
	print("所持金: ", current_money)

# 指定した金額を持っているかチェックする関数
func has_enough_money(amount: int) -> bool:
	return current_money >= amount
