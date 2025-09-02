# TradeRule.gd
extends Resource
class_name TradeRule

## --- ルールの基本設定 ---
@export var rule_name: String = "新しいルール"
@export var priority: int = 0 # 数値が高いほど優先される

## --- ルール発動条件 ---
# このリスト内の条件を "全て" 満たした場合にルールが発動する
# 例: {"type": "NPC_CATEGORY", "value": "新米冒険者"}
# 例: {"type": "CURRENT_DAY", "compare": "GREATER_THAN", "value": 10}
@export var conditions: Array[Dictionary] = []

## --- ルール発動後の行動 ---
@export_group("Action")
# "OFFER_TO_SELL" (NPCが売る) or "OFFER_TO_BUY" (NPCが買う)
@export var action_type: StringName = &"OFFER_TO_SELL"

# NPCが提示する可能性のあるアイテムのリスト
# この中から確率と個数の抽選が行われる
@export var item_pool: Array[Dictionary] = []

## --- item_poolの構造の参考 ---
# [
#     {
#         "item_id": "item_database_key",  # ItemDatabaseで管理するID
#         "appearance_chance": 1.0,        # 1.0 = 100%
#         "min_quantity": 1,
#         "max_quantity": 1
#     }
# ]
