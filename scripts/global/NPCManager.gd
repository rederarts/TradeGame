# scripts/global/NPCManager.gd
extends Node

# インスペクターから全てのTradeRuleリソースを登録するための配列
@export var trade_rules: Array[TradeRule]


# NPCのデータを受け取り、適用すべき最も優先度の高いルールを1つ返す関数
func get_applicable_rule_for_npc(npc_data: NPCData) -> TradeRule:
	var matching_rules: Array[TradeRule] = []

	# 登録されている全てのルールをチェックする
	for rule in trade_rules:
		if rule == null:
			continue

		var all_conditions_met = true
		# ルールが持つ全ての条件をチェックする
		for condition in rule.conditions:
			if not is_condition_met(npc_data, condition):
				all_conditions_met = false
				break # 一つでも条件が合わなければ、このルールのチェックは中断

		# 全ての条件を満たしていた場合、候補リストに追加
		if all_conditions_met:
			matching_rules.append(rule)

	# 候補が一つもなければ、nullを返す
	if matching_rules.is_empty():
		return null

	# 候補の中から、priorityが最も高いものを探す
	# 配列をpriorityの降順（大きい順）でソートする
	matching_rules.sort_custom(func(a, b): return a.priority > b.priority)

	# ソート後、最初の要素が最も優先度が高いルールになる
	return matching_rules[0]


# NPCデータと単一の条件を比較し、満たしているか(true/false)を返す内部関数
func is_condition_met(npc_data: NPCData, condition: Dictionary) -> bool:
	var type = condition.get("type")
	var value = condition.get("value")

	match type:
		"NPC_CATEGORY_MAIN":
			return npc_data.category_main == value
		"NPC_CATEGORY_SUB":
			return npc_data.category_sub == value
		"NPC_CATEGORY_SPEC":
			return npc_data.category_spec == value
		"NPC_CATEGORY_LEVEL":
			return npc_data.category_level == value
		# 今後、「特定の日付以降」などの他の条件を追加する場合は、ここにcaseを追加していく
		_:
			# 不明な条件タイプは常にfalseを返す
			return false
			
# TradeRuleのitem_poolを受け取り、ランダムな取引リストを生成して返す関数
func generate_trade_offer(item_pool: Array[Dictionary]) -> Array[Dictionary]:
	var final_offer: Array[Dictionary] = []

	if item_pool.is_empty():
		return final_offer

	# プール内の各アイテムについて、出現するかどうかを抽選する
	for item_data in item_pool:
		var appearance_chance = item_data.get("appearance_chance", 1.0)

		# 0.0 ~ 1.0のランダムな値を生成し、出現確率より低ければリストに追加
		if randf() <= appearance_chance:
			var item_id = item_data.get("item_id")
			var min_qty = item_data.get("min_quantity", 1)
			var max_qty = item_data.get("max_quantity", 1)

			# 最小個数と最大個数の間でランダムな個数を決定
			var quantity = randi_range(min_qty, max_qty)

			if quantity > 0:
				final_offer.append({
					"item_id": item_id,
					"quantity": quantity
				})
	
	return final_offer
