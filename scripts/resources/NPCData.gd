# NPCData.gd
extends Resource
class_name NPCData

## --- NPCの基本情報 ---
@export var npc_name: String = "名無しのNPC"
@export var portrait: Texture2D # NPCの立ち絵

## --- NPCの分類 ---
# このカテゴリ情報を元に、どのTradeRuleを適用するかを判定する
@export_group("Categories")
@export var category_main: StringName = &"冒険者"  # 大カテゴリ (職業)
@export var category_sub: StringName = &"剣士"      # 中カテゴリ (役職)
@export var category_spec: StringName = &"片手剣"   # 小カテゴリ (専門)
@export var category_level: StringName = &"新米"    # 練度
