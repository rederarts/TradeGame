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
	$Sprite2D.texture = self.npc_data.portrait

	# --- 取引内容の決定ロジック ---
	# 1. 適用される可能性のある全てのルールを優先度順で取得
	var applicable_rules: Array[TradeRule] = NPCManager.get_applicable_rules_for_npc(self.npc_data)

	# 2. 売りたい/買いたいアイテムの最終的なプールを生成する
	var final_sell_pool = NPCManager.generate_final_item_pool(applicable_rules, self.npc_data.individual_sell_pool, &"OFFER_TO_SELL")
	var final_buy_pool = NPCManager.generate_final_item_pool(applicable_rules, self.npc_data.individual_buy_pool, &"OFFER_TO_BUY")
	
	# 3. 最終的なプールから取引内容を抽選
	if not final_sell_pool.is_empty():
		current_sell_offer = NPCManager.generate_trade_offer(final_sell_pool)
	if not final_buy_pool.is_empty():
		current_buy_offer = NPCManager.generate_trade_offer(final_buy_pool)

	# 4. 売買リストの競合を解決する（「買う」を優先）
	if not current_buy_offer.is_empty() and not current_sell_offer.is_empty():
		var buy_item_ids = {}
		for item in current_buy_offer:
			buy_item_ids[item.get("item_id")] = true
		current_sell_offer = current_sell_offer.filter(
			func(sell_item): return not buy_item_ids.has(sell_item.get("item_id"))
		)

	# デバッグ用に結果を出力
	print("NPC: ", npc_data.npc_name)
	if not current_sell_offer.is_empty():
		print("  売りたいもの(最終): ", current_sell_offer)
	if not current_buy_offer.is_empty():
		print("  買いたいもの(最終): ", current_buy_offer)
