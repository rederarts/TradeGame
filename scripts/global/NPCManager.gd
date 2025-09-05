# scripts/global/NPCManager.gd
extends Node

# インスペクターから全てのTradeRuleリソースを登録するための配列
@export var trade_rules: Array[TradeRule]


# NPCのデータを受け取り、適用すべき最も優先度の高いルールを1つ返す関数
func get_applicable_rules_for_npc(npc_data: NPCData) -> Array[TradeRule]:
	var matching_rules: Array[TradeRule] = []
	for rule in trade_rules:
		if rule == null: continue
		var all_conditions_met = true
		for condition in rule.conditions:
			if not is_condition_met(npc_data, condition):
				all_conditions_met = false
				break
		if all_conditions_met:
			matching_rules.append(rule)
	
	# ★ルールをpriorityの降順（大きい順）でソートする
	matching_rules.sort_custom(func(a, b): return a.priority > b.priority)
	return matching_rules
	
func generate_final_item_pool(rules: Array[TradeRule], individual_pool: Array[Dictionary], action_type: StringName) -> Array[Dictionary]:
	var final_items: Dictionary = {}

	# 1. まず、適用されるルールを優先度順にチェック
	for rule in rules:
		if rule.action_type == action_type:
			for item in rule.item_pool:
				var item_id = item.get("item_id")
				# まだこのアイテムが登録されていなければ（＝より優先度の高いルールになければ）追加
				if not final_items.has(item_id):
					final_items[item_id] = item
	
	# 2. 次に、個別設定で上書き（個別設定はルールより常に優先）
	for item in individual_pool:
		var item_id = item.get("item_id")
		final_items[item_id] = item
		
	# --- ★ここからが修正箇所 ---
	# 3. 辞書から配列へ、安全な方法で変換する
	var final_pool: Array[Dictionary] = []
	for item_data in final_items.values():
		final_pool.append(item_data)
		
	return final_pool

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

@export var npc_data_list: Array[NPCData] # インスペクターから全NPCDataリソースを登録

# 登録されたNPCリストからランダムに一つを返す
func get_random_npc_data() -> NPCData:
	if npc_data_list.is_empty():
		return null
	return npc_data_list.pick_random()

# 2つのアイテムプールをマージ（統合＆上書き）する内部関数
# scripts/global/NPCManager.gd

# 2つのアイテムプールをマージ（統合＆上書き）する内部関数
# 2つのアイテムプールをマージ（統合＆上書き）する内部関数
func _merge_item_pools(base_pool: Array[Dictionary], override_pool: Array[Dictionary]) -> Array[Dictionary]:
	var merged_items: Dictionary = {}

	# (競合を解決するロジック... この部分は変更なし)
	for item in base_pool:
		merged_items[item.get("item_id")] = item

	for override_item in override_pool:
		var item_id = override_item.get("item_id")
		
		if merged_items.has(item_id):
			var existing_chance = merged_items[item_id].get("appearance_chance", 1.0)
			var override_chance = override_item.get("appearance_chance", 1.0)
			
			if override_chance < existing_chance:
				merged_items[item_id] = override_item
		else:
			merged_items[item_id] = override_item
	
	# --- ★ここからが変更箇所 ---
	# 1. まず、空の型付けされた配列を作成する
	var final_pool: Array[Dictionary] = []
	
	# 2. 辞書の値（アイテム情報）を一つずつループで取り出す
	for item_data in merged_items.values():
		# 3. 型付けされた配列に要素を追加していく
		final_pool.append(item_data)
		
	# 4. 最終的に完成した型付け配列を返す
	return final_pool
