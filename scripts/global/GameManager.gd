# scripts/global/GameManager.gd
extends Node

# ゲームの状態を定義するEnum
enum GameState {
	DAY_WAITING,  # 客を待っている状態
	DAY_TRADING,  # 取引中の状態
	NIGHT         # 夜の状態
}

const MAX_CUSTOMERS_PER_DAY: int = 6
var customer_count_today: int = 0
var current_day: int = 1

# 現在のゲーム状態。初期状態は「客待ち」
var current_state: GameState = GameState.DAY_WAITING

# ゲームの状態が変化したことを他のスクリプトに通知するシグナル
signal state_changed(new_state: GameState)


# ターン（客一人分）を進める関数
func progress_turn():
	customer_count_today += 1
	print("本日の来客数: ", customer_count_today, "/", MAX_CUSTOMERS_PER_DAY)

	if customer_count_today >= MAX_CUSTOMERS_PER_DAY:
		# 規定数に達したら夜へ
		current_state = GameState.NIGHT
	else:
		# まだ昼なので、次の客を待つ状態へ
		current_state = GameState.DAY_WAITING
	
	state_changed.emit(current_state)


# 新しい一日を始める関数
func start_new_day():
	current_day += 1
	customer_count_today = 0
	current_state = GameState.DAY_WAITING
	print("--- ", current_day, "日目の朝 ---")
	state_changed.emit(current_state)
