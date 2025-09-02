# scripts/scene_specific/NPC.gd
extends Node2D

# このNPCのマスターデータ
var npc_data: NPCData

# 今回の訪問でNPCが「プレイヤーに売りたい」アイテムのリスト
# 例: [{"item_id": "rusty_sword", "quantity": 2}]
var current_sell_offer: Array[Dictionary] = []

# 今回の訪問でNPCが「プレイヤーから買いたい」アイテムのリスト
var current_buy_offer: Array[Dictionary] = []


# NPCがシーンに登場した時に呼ばれる初期化関数
func initialize(data: NPCData):
	self.npc_data = data

	# 自分の立ち絵を設定
	$Sprite2D.texture = self.npc_data.portrait

	# --- 取引内容の決定 ---
	# 1. 自分に適用されるルールをNPCManagerに問い合わせる
	var rule: TradeRule = NPCManager.get_applicable_rule_for_npc(self.npc_data)

	# 2. 適切なルールが見つかった場合のみ、取引内容を生成する
	if rule != null:
		# 3. ルールのアクションタイプに応じて、適切なリストに抽選結果を入れる
		if rule.action_type == &"OFFER_TO_SELL":
			current_sell_offer = NPCManager.generate_trade_offer(rule.item_pool)
		elif rule.action_type == &"OFFER_TO_BUY":
			current_buy_offer = NPCManager.generate_trade_offer(rule.item_pool)
	
	# デバッグ用に結果を出力
	print("NPC: ", npc_data.npc_name)
	if not current_sell_offer.is_empty():
		print("  売りたいもの: ", current_sell_offer)
	if not current_buy_offer.is_empty():
		print("  買いたいもの: ", current_buy_offer)
