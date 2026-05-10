extends Node

enum WeaponType { WHIP, MAGIC_WAND, KNIFE, GARLIC, HOLY_WATER, FIREBALL, LIGHTNING, CROSS, SPIN_BLADE, BIBLE, FREEZE_RAY, POISON_CLOUD, SHIELD, METEOR, LIFESTEAL_AURA, INFERNO_STORM, ABSOLUTE_ZERO, DEATH_SCYTHE, THOR_HAMMER, PLAGUE_KING, DIVINE_APOCALYPSE, VOID_DEVOUR }

var WEAPON_DATA: Dictionary = {
	WeaponType.WHIP: {
		"name": "鞭子",
		"description": "水平横扫，穿透敌人",
		"base_damage": 10,
		"base_cooldown": 1.5,
		"base_area": 1.0,
		"icon_color": Color.YELLOW,
	},
	WeaponType.MAGIC_WAND: {
		"name": "魔杖",
		"description": "向最近的敌人发射弹幕",
		"base_damage": 10,
		"base_cooldown": 1.2,
		"base_speed": 300.0,
		"icon_color": Color.CYAN,
	},
	WeaponType.KNIFE: {
		"name": "飞刀",
		"description": "向面朝方向快速投掷飞刀",
		"base_damage": 8,
		"base_cooldown": 0.8,
		"base_speed": 500.0,
		"icon_color": Color.SILVER,
	},
	WeaponType.GARLIC: {
		"name": "大蒜",
		"description": "对周围敌人持续造成伤害",
		"base_damage": 5,
		"base_cooldown": 0.4,
		"base_area": 80.0,
		"icon_color": Color.GREEN_YELLOW,
	},
	WeaponType.HOLY_WATER: {
		"name": "圣水",
		"description": "在地面生成持续伤害区域",
		"base_damage": 8,
		"base_cooldown": 3.0,
		"base_area": 50.0,
		"base_duration": 3.0,
		"icon_color": Color.DODGER_BLUE,
	},
	WeaponType.FIREBALL: {
		"name": "火球术",
		"description": "发射爆炸火球，造成范围伤害",
		"base_damage": 15,
		"base_cooldown": 2.5,
		"base_area": 60.0,
		"base_speed": 250.0,
		"icon_color": Color.ORANGE_RED,
	},
	WeaponType.LIGHTNING: {
		"name": "闪电链",
		"description": "击中敌人后链式传导给附近敌人",
		"base_damage": 12,
		"base_cooldown": 1.8,
		"base_area": 100.0,
		"icon_color": Color.LIGHT_YELLOW,
	},
	WeaponType.CROSS: {
		"name": "十字架",
		"description": "抛出回旋镖，飞出后自动飞回",
		"base_damage": 12,
		"base_cooldown": 2.0,
		"base_speed": 350.0,
		"icon_color": Color.GOLD,
	},
	WeaponType.SPIN_BLADE: {
		"name": "旋风斩",
		"description": "刀刃持续绕玩家旋转切割敌人",
		"base_damage": 8,
		"base_cooldown": 0.0,
		"base_area": 60.0,
		"icon_color": Color.LIGHT_STEEL_BLUE,
	},
	WeaponType.BIBLE: {
		"name": "圣经",
		"description": "多本圣经环绕玩家旋转",
		"base_damage": 10,
		"base_cooldown": 5.0,
		"base_area": 80.0,
		"base_duration": 4.0,
		"icon_color": Color.WHEAT,
	},
	WeaponType.FREEZE_RAY: {
		"name": "冰冻射线",
		"description": "发射穿透射线，击中敌人减速",
		"base_damage": 6,
		"base_cooldown": 3.0,
		"base_speed": 400.0,
		"icon_color": Color.LIGHT_CYAN,
	},
	WeaponType.POISON_CLOUD: {
		"name": "毒雾",
		"description": "移动时在身后留下持续伤害毒雾",
		"base_damage": 3,
		"base_cooldown": 0.5,
		"base_area": 40.0,
		"base_duration": 5.0,
		"icon_color": Color.DARK_GREEN,
	},
	WeaponType.SHIELD: {
		"name": "护盾",
		"description": "生成护盾弹开并伤害接触的敌人",
		"base_damage": 15,
		"base_cooldown": 3.0,
		"base_area": 50.0,
		"base_duration": 1.5,
		"icon_color": Color.CORNFLOWER_BLUE,
	},
	WeaponType.METEOR: {
		"name": "陨石",
		"description": "从天而降砸向敌人密集区域",
		"base_damage": 30,
		"base_cooldown": 4.0,
		"base_area": 80.0,
		"icon_color": Color.FIREBRICK,
	},
	WeaponType.LIFESTEAL_AURA: {
		"name": "吸血光环",
		"description": "对周围敌人造成伤害并回复生命",
		"base_damage": 5,
		"base_cooldown": 2.0,
		"base_area": 90.0,
		"icon_color": Color.DARK_ORCHID,
	},
	WeaponType.INFERNO_STORM: {
		"name": "炼狱风暴",
		"description": "火球雨从天而降，覆盖大片区域",
		"base_damage": 50,
		"base_cooldown": 3.0,
		"base_area": 200.0,
		"icon_color": Color(1.0, 0.4, 0.0),
		"is_evolution": true,
	},
	WeaponType.ABSOLUTE_ZERO: {
		"name": "绝对零度",
		"description": "冰冻脉冲冻结屏幕内所有敌人",
		"base_damage": 25,
		"base_cooldown": 5.0,
		"base_area": 350.0,
		"icon_color": Color(0.5, 0.9, 1.0),
		"is_evolution": true,
	},
	WeaponType.DEATH_SCYTHE: {
		"name": "死神之镰",
		"description": "巨型暗影镰刀持续 360 度旋转横扫",
		"base_damage": 40,
		"base_cooldown": 0.0,
		"base_area": 180.0,
		"icon_color": Color(0.3, 0.0, 0.3),
		"is_evolution": true,
	},
	WeaponType.THOR_HAMMER: {
		"name": "雷神之锤",
		"description": "回旋雷锤沿途雷击，终点巨型雷爆",
		"base_damage": 45,
		"base_cooldown": 2.5,
		"base_speed": 300.0,
		"base_area": 120.0,
		"icon_color": Color(0.6, 0.8, 1.0),
		"is_evolution": true,
	},
	WeaponType.PLAGUE_KING: {
		"name": "瘟疫之王",
		"description": "200px 致命毒圈持续减速并腐蚀敌人",
		"base_damage": 20,
		"base_cooldown": 0.3,
		"base_area": 200.0,
		"icon_color": Color(0.4, 0.8, 0.0),
		"is_evolution": true,
	},
	WeaponType.DIVINE_APOCALYPSE: {
		"name": "天启圣光",
		"description": "12 本巨型圣经环绕并自带不灭护盾",
		"base_damage": 35,
		"base_cooldown": 0.0,
		"base_area": 150.0,
		"icon_color": Color(1.0, 0.9, 0.5),
		"is_evolution": true,
	},
	WeaponType.VOID_DEVOUR: {
		"name": "虚空吞噬",
		"description": "8 发追踪暗能量弹，吸血并连锁爆炸",
		"base_damage": 30,
		"base_cooldown": 2.0,
		"base_speed": 350.0,
		"base_area": 80.0,
		"icon_color": Color(0.5, 0.0, 0.7),
		"is_evolution": true,
	},
}

const EVOLUTION_RECIPES: Dictionary = {
	WeaponType.INFERNO_STORM: [WeaponType.FIREBALL, WeaponType.METEOR],
	WeaponType.ABSOLUTE_ZERO: [WeaponType.FREEZE_RAY, WeaponType.HOLY_WATER],
	WeaponType.DEATH_SCYTHE: [WeaponType.WHIP, WeaponType.SPIN_BLADE],
	WeaponType.THOR_HAMMER: [WeaponType.LIGHTNING, WeaponType.CROSS],
	WeaponType.PLAGUE_KING: [WeaponType.POISON_CLOUD, WeaponType.GARLIC],
	WeaponType.DIVINE_APOCALYPSE: [WeaponType.BIBLE, WeaponType.SHIELD],
	WeaponType.VOID_DEVOUR: [WeaponType.LIFESTEAL_AURA, WeaponType.MAGIC_WAND],
}

var ENEMY_TYPES: Dictionary = {
	"bat": {
		"name": "蝙蝠",
		"health": 5.0,
		"damage": 5,
		"speed": 80.0,
		"xp_value": 1,
		"size": 8.0,
		"color": Color(0.8, 0.2, 0.2),
	},
	"skeleton": {
		"name": "骷髅",
		"health": 15.0,
		"damage": 10,
		"speed": 50.0,
		"xp_value": 3,
		"size": 12.0,
		"color": Color(0.9, 0.9, 0.8),
	},
	"zombie": {
		"name": "僵尸",
		"health": 30.0,
		"damage": 8,
		"speed": 30.0,
		"xp_value": 5,
		"size": 14.0,
		"color": Color(0.3, 0.7, 0.3),
	},
	"ghost": {
		"name": "幽灵",
		"health": 10.0,
		"damage": 12,
		"speed": 100.0,
		"xp_value": 4,
		"size": 10.0,
		"color": Color(0.6, 0.6, 0.9),
	},
	"boss": {
		"name": "Boss",
		"health": 200.0,
		"damage": 20,
		"speed": 40.0,
		"xp_value": 50,
		"size": 24.0,
		"color": Color(0.9, 0.1, 0.1),
	},
	# 机制怪（PRD 5.10.1）
	"charger": {
		"name": "冲锋者",
		"health": 50.0,
		"damage": 8,
		"charge_damage": 16,
		"speed": 24.0,
		"charge_speed": 110.0,
		"xp_value": 8,
		"size": 14.0,
		"color": Color(0.85, 0.25, 0.15),
		"behavior": "charger",
	},
	"ranged": {
		"name": "巫医",
		"health": 24.0,
		"damage": 10,
		"speed": 30.0,
		"retreat_speed": 36.0,
		"keep_distance": 140.0,
		"shoot_interval": 2.5,
		"xp_value": 6,
		"size": 12.0,
		"color": Color(0.55, 0.3, 0.85),
		"behavior": "ranged",
	},
}

# 机制怪 modulate（PRD 5.10.2）
const MECH_ENEMY_MODULATE: Dictionary = {
	"charger": Color(1.0, 0.45, 0.45),
	"ranged": Color(0.7, 0.55, 0.95),
}

const BOSS_DATA: Dictionary = {
	"bone_lord": {
		"name": "骸骨领主",
		"health_mult": 2.5,
		"damage_mult": 2.0,
		"speed": 75.0,
		"size": 40.0,
		"color": Color(0.9, 0.85, 0.6),
		"skills": ["bone_spike", "summon_skeleton", "charge"],
		"damage_cap": 15,
	},
	"shadow_lich": {
		"name": "暗影巫妖",
		"health_mult": 3.5,
		"damage_mult": 2.5,
		"speed": 60.0,
		"size": 48.0,
		"color": Color(0.5, 0.2, 0.8),
		"skills": ["soul_barrage", "phantom_split", "dark_field"],
		"damage_cap": 20,
	},
	"blood_moon": {
		"name": "血月魔王",
		"health_mult": 5.0,
		"damage_mult": 3.0,
		"speed": 70.0,
		"size": 56.0,
		"color": Color(0.8, 0.05, 0.15),
		"skills": ["moon_wrath", "summon_elite", "undying"],
		"damage_cap": 28,
	},
}

var STAGE_DATA: Dictionary = {
	1: {"name": "1-1 新手训练", "chapter": "幽暗森林", "description": "消灭 30 只蝙蝠", "duration": 60.0, "bg_style": "grassland", "enemy_pool": ["bat"], "difficulty_mult": 0.8, "spawn_rate": 1.0, "win_condition": "kills", "win_value": 30, "boss_count": 0, "boss_time": [], "unlock_requires": 0},
	2: {"name": "1-2 骸骨丛林", "chapter": "幽暗森林", "description": "消灭 50 只敌人", "duration": 90.0, "bg_style": "grassland", "enemy_pool": ["bat", "bat", "skeleton"], "difficulty_mult": 0.9, "spawn_rate": 1.0, "win_condition": "kills", "win_value": 50, "boss_count": 0, "boss_time": [], "unlock_requires": 1},
	3: {"name": "1-3 僵尸围城", "chapter": "幽暗森林", "description": "存活 90 秒", "duration": 90.0, "bg_style": "grassland", "enemy_pool": ["zombie", "zombie", "bat"], "difficulty_mult": 0.9, "spawn_rate": 1.2, "win_condition": "survive", "win_value": 90, "boss_count": 0, "boss_time": [], "unlock_requires": 2},
	4: {"name": "1-4 幽灵夜袭", "chapter": "幽暗森林", "description": "消灭 80 只敌人", "duration": 120.0, "bg_style": "grassland", "enemy_pool": ["ghost", "ghost", "bat"], "difficulty_mult": 1.0, "spawn_rate": 1.1, "win_condition": "kills", "win_value": 80, "boss_count": 0, "boss_time": [], "unlock_requires": 3},
	5: {"name": "1-5 森林守卫", "chapter": "幽暗森林", "description": "击败 Boss", "duration": 120.0, "bg_style": "grassland", "enemy_pool": ["bat", "skeleton"], "difficulty_mult": 1.0, "spawn_rate": 0.8, "win_condition": "boss", "win_value": 1, "boss_count": 1, "boss_time": [10.0], "unlock_requires": 4, "boss_id": "bone_lord"},
	6: {"name": "2-1 骨兵方阵", "chapter": "亡灵墓地", "description": "消灭 100 只敌人", "duration": 120.0, "bg_style": "dungeon", "enemy_pool": ["skeleton", "skeleton", "bat"], "difficulty_mult": 1.1, "spawn_rate": 1.3, "win_condition": "kills", "win_value": 100, "boss_count": 0, "boss_time": [], "unlock_requires": 5, "mech_enemy_chance": 0.05},
	7: {"name": "2-2 毒沼幽潭", "chapter": "亡灵墓地", "description": "存活 120 秒", "duration": 120.0, "bg_style": "dungeon", "enemy_pool": ["zombie", "zombie", "zombie", "bat"], "difficulty_mult": 1.2, "spawn_rate": 1.2, "win_condition": "survive", "win_value": 120, "boss_count": 0, "boss_time": [], "unlock_requires": 6, "mech_enemy_chance": 0.05},
	8: {"name": "2-3 鬼影重重", "chapter": "亡灵墓地", "description": "消灭 80 只幽灵", "duration": 120.0, "bg_style": "dungeon", "enemy_pool": ["ghost"], "difficulty_mult": 1.2, "spawn_rate": 1.4, "win_condition": "kills", "win_value": 80, "boss_count": 0, "boss_time": [], "unlock_requires": 7, "mech_enemy_chance": 0.05},
	9: {"name": "2-4 亡灵潮汐", "chapter": "亡灵墓地", "description": "消灭 150 只敌人", "duration": 150.0, "bg_style": "dungeon", "enemy_pool": ["bat", "skeleton", "zombie", "ghost"], "difficulty_mult": 1.3, "spawn_rate": 1.5, "win_condition": "kills", "win_value": 150, "boss_count": 0, "boss_time": [], "unlock_requires": 8, "mech_enemy_chance": 0.05},
	10: {"name": "2-5 墓地领主", "chapter": "亡灵墓地", "description": "击败 2 个 Boss", "duration": 150.0, "bg_style": "dungeon", "enemy_pool": ["skeleton", "zombie", "ghost"], "difficulty_mult": 1.3, "spawn_rate": 1.0, "win_condition": "boss", "win_value": 2, "boss_count": 2, "boss_time": [15.0, 75.0], "unlock_requires": 9, "boss_ids": ["bone_lord", "shadow_lich"], "mech_enemy_chance": 0.05},
	11: {"name": "3-1 烈焰蝙蝠", "chapter": "熔岩地狱", "description": "存活 150 秒", "duration": 150.0, "bg_style": "lava", "enemy_pool": ["bat", "bat", "bat", "skeleton"], "difficulty_mult": 1.5, "spawn_rate": 1.8, "win_condition": "survive", "win_value": 150, "boss_count": 0, "boss_time": [], "unlock_requires": 10, "mech_enemy_chance": 0.15},
	12: {"name": "3-2 骨火军团", "chapter": "熔岩地狱", "description": "消灭 120 只敌人", "duration": 150.0, "bg_style": "lava", "enemy_pool": ["skeleton", "skeleton", "zombie"], "difficulty_mult": 1.6, "spawn_rate": 1.5, "win_condition": "kills", "win_value": 120, "boss_count": 0, "boss_time": [], "unlock_requires": 11, "mech_enemy_chance": 0.15},
	13: {"name": "3-3 幽魂狂潮", "chapter": "熔岩地狱", "description": "消灭 100 只幽灵", "duration": 150.0, "bg_style": "lava", "enemy_pool": ["ghost", "ghost", "bat"], "difficulty_mult": 1.7, "spawn_rate": 1.6, "win_condition": "kills", "win_value": 100, "boss_count": 0, "boss_time": [], "unlock_requires": 12, "mech_enemy_chance": 0.15},
	14: {"name": "3-4 地狱混战", "chapter": "熔岩地狱", "description": "消灭 200 只敌人", "duration": 180.0, "bg_style": "lava", "enemy_pool": ["bat", "skeleton", "zombie", "ghost"], "difficulty_mult": 1.8, "spawn_rate": 1.8, "win_condition": "kills", "win_value": 200, "boss_count": 0, "boss_time": [], "unlock_requires": 13, "mech_enemy_chance": 0.15},
	15: {"name": "3-5 炎魔", "chapter": "熔岩地狱", "description": "击败 3 个 Boss", "duration": 180.0, "bg_style": "lava", "enemy_pool": ["skeleton", "zombie", "ghost"], "difficulty_mult": 1.8, "spawn_rate": 1.2, "win_condition": "boss", "win_value": 3, "boss_count": 3, "boss_time": [15.0, 70.0, 130.0], "unlock_requires": 14, "boss_ids": ["bone_lord", "shadow_lich", "blood_moon"], "mech_enemy_chance": 0.15},
	16: {"name": "4-1 虚空侵蚀", "chapter": "虚空深渊", "description": "存活 180 秒", "duration": 180.0, "bg_style": "ice", "enemy_pool": ["bat", "skeleton", "zombie", "ghost"], "difficulty_mult": 2.0, "spawn_rate": 2.0, "win_condition": "survive", "win_value": 180, "boss_count": 0, "boss_time": [], "unlock_requires": 15, "mech_enemy_chance": 0.25},
	17: {"name": "4-2 灵魂风暴", "chapter": "虚空深渊", "description": "消灭 200 只敌人", "duration": 180.0, "bg_style": "ice", "enemy_pool": ["ghost", "ghost", "skeleton", "bat"], "difficulty_mult": 2.0, "spawn_rate": 2.2, "win_condition": "kills", "win_value": 200, "boss_count": 0, "boss_time": [], "unlock_requires": 16, "mech_enemy_chance": 0.25},
	18: {"name": "4-3 末日军团", "chapter": "虚空深渊", "description": "消灭 250 只敌人", "duration": 210.0, "bg_style": "ice", "enemy_pool": ["skeleton", "zombie", "ghost"], "difficulty_mult": 2.2, "spawn_rate": 2.0, "win_condition": "kills", "win_value": 250, "boss_count": 1, "boss_time": [60.0], "unlock_requires": 17, "boss_id": "shadow_lich", "mech_enemy_chance": 0.25},
	19: {"name": "4-4 深渊之战", "chapter": "虚空深渊", "description": "存活 240 秒", "duration": 240.0, "bg_style": "ice", "enemy_pool": ["bat", "skeleton", "zombie", "ghost"], "difficulty_mult": 2.5, "spawn_rate": 2.5, "win_condition": "survive", "win_value": 240, "boss_count": 0, "boss_time": [], "unlock_requires": 18, "mech_enemy_chance": 0.25},
	20: {"name": "4-5 最终Boss", "chapter": "虚空深渊", "description": "击败 5 个 Boss", "duration": 300.0, "bg_style": "ice", "enemy_pool": ["skeleton", "zombie", "ghost", "ghost"], "difficulty_mult": 2.5, "spawn_rate": 1.5, "win_condition": "boss", "win_value": 5, "boss_count": 5, "boss_time": [20.0, 70.0, 130.0, 200.0, 260.0], "unlock_requires": 19, "boss_ids": ["bone_lord", "shadow_lich", "blood_moon", "bone_lord", "shadow_lich"], "mech_enemy_chance": 0.25},
}

var unlocked_stages: Array = [1]
var cleared_stages: Array = []
var current_stage: int = 0
var boss_kills_this_stage: int = 0
var leaderboard: Array = []
const MAX_LEADERBOARD := 10

# Character system
const CHARACTER_DATA: Dictionary = {
	"mystery_survivor": {"name": "神秘幸存者", "style": "style_i_mystery", "role": "默认", "weapon": 0, "max_health": 100, "base_speed": 200.0, "damage_mult": 1.0, "cooldown_mult": 1.0, "pickup_mult": 1.0, "passive": "survival_instinct", "passive_name": "求生本能", "passive_desc": "血量低于30%时移速+25%", "unlock_type": "free", "unlock_value": 0},
	"blue_knight": {"name": "蓝甲骑士", "style": "style_a_knight", "role": "坦克", "weapon": 0, "max_health": 150, "base_speed": 170.0, "damage_mult": 1.0, "cooldown_mult": 1.0, "pickup_mult": 0.9, "passive": "iron_wall", "passive_name": "铁壁", "passive_desc": "受到伤害降低20%", "unlock_type": "free", "unlock_value": 0},
	"pico8_retro": {"name": "PICO-8 复古", "style": "style_e_pico8", "role": "平衡", "weapon": 5, "max_health": 100, "base_speed": 200.0, "damage_mult": 1.05, "cooldown_mult": 0.95, "pickup_mult": 1.05, "passive": "retro_luck", "passive_name": "复古幸运", "passive_desc": "经验值获取+20%", "unlock_type": "free", "unlock_value": 0},
	"green_ranger": {"name": "翠林游侠", "style": "style_c_ranger", "role": "远程", "weapon": 2, "max_health": 75, "base_speed": 240.0, "damage_mult": 1.0, "cooldown_mult": 1.0, "pickup_mult": 1.6, "passive": "eagle_eye", "passive_name": "鹰眼", "passive_desc": "投射物射程和速度+25%", "unlock_type": "stage", "unlock_value": 3},
	"red_samurai": {"name": "赤焰武士", "style": "style_b_samurai", "role": "近战", "weapon": 7, "max_health": 85, "base_speed": 210.0, "damage_mult": 1.3, "cooldown_mult": 0.85, "pickup_mult": 0.8, "passive": "bloodthirst", "passive_name": "嗜血", "passive_desc": "每杀10敌攻击+15%持续5秒,叠3层", "unlock_type": "stage", "unlock_value": 5},
	"dark_mage": {"name": "暗夜法师", "style": "style_d_mage", "role": "法师", "weapon": 1, "max_health": 60, "base_speed": 190.0, "damage_mult": 1.0, "cooldown_mult": 0.6, "pickup_mult": 1.0, "passive": "mana_surge", "passive_name": "魔力涌动", "passive_desc": "每25秒所有武器额外发射一次", "unlock_type": "stage", "unlock_value": 8},
	"sweetie_cute": {"name": "Sweetie 柔和", "style": "style_f_sweetie", "role": "辅助", "weapon": 4, "max_health": 130, "base_speed": 180.0, "damage_mult": 0.7, "cooldown_mult": 1.1, "pickup_mult": 1.8, "passive": "life_spring", "passive_name": "生命之泉", "passive_desc": "每5秒回复1点HP", "unlock_type": "survival", "unlock_value": 600},
	"cyber_ninja": {"name": "赛博朋克", "style": "style_h_cyber", "role": "速攻", "weapon": 8, "max_health": 80, "base_speed": 260.0, "damage_mult": 1.0, "cooldown_mult": 0.6, "pickup_mult": 1.0, "passive": "overclock", "passive_name": "超频芯片", "passive_desc": "连续移动2秒后冷却+40%", "unlock_type": "kills", "unlock_value": 5000},
	"dark_gothic": {"name": "暗黑哥特", "style": "style_g_gothic", "role": "暴击", "weapon": 6, "max_health": 60, "base_speed": 200.0, "damage_mult": 1.6, "cooldown_mult": 1.0, "pickup_mult": 0.7, "passive": "soul_drain", "passive_name": "灵魂汲取", "passive_desc": "击杀敌人回复1HP", "unlock_type": "stage", "unlock_value": 15},
	"princess_wedding": {"name": "公主婚礼", "style": "style_j_princess", "role": "范围", "weapon": 9, "max_health": 90, "base_speed": 195.0, "damage_mult": 0.85, "cooldown_mult": 0.9, "pickup_mult": 1.3, "passive": "divine_protection", "passive_name": "神圣庇护", "passive_desc": "致命伤免死回复30%HP,60秒冷却", "unlock_type": "stage_all", "unlock_value": 20},
}

const CHARACTER_ORDER: Array = [
	"mystery_survivor", "blue_knight", "pico8_retro",
	"green_ranger", "red_samurai", "dark_mage",
	"sweetie_cute", "cyber_ninja", "dark_gothic",
	"princess_wedding",
]

var selected_character: String = "mystery_survivor"
var unlocked_characters: Array = ["mystery_survivor", "blue_knight", "pico8_retro"]
var total_kills_all_time: int = 0
var best_free_survival: float = 0.0

const CHEST_DROP_CHANCE_NORMAL := 0.03
const CHEST_DROP_CHANCE_BOSS := 0.5
const CHEST_SPAWN_INTERVAL_MIN := 25.0
const CHEST_SPAWN_INTERVAL_MAX := 50.0
const CHEST_SPAWN_DISTANCE := 350.0

# Visual clarity and performance knobs. Mobile defaults to a cleaner, cheaper profile.
const PLAYER_VISUAL_SCALE := 1.28
const PLAYER_VISUAL_SCALE_MOBILE := 1.35
const PLAYER_MARKER_ALPHA := 0.38
const ENEMY_CAP_DEFAULT := 240
const ENEMY_CAP_MOBILE := 150
const VFX_PARTICLE_BUDGET_DEFAULT := 180
const VFX_PARTICLE_BUDGET_MOBILE := 80
const FLOAT_TEXT_CAP_DEFAULT := 48
const FLOAT_TEXT_CAP_MOBILE := 18
const FLOAT_TEXT_PER_SECOND_DEFAULT := 60
const FLOAT_TEXT_PER_SECOND_MOBILE := 18
# 普通武器拖尾长度（PRD 5.3 / 5.9.2）：4 帧；进化武器自行渲染保留 8 帧
const PROJECTILE_TRAIL_LENGTH_DEFAULT := 4
const PROJECTILE_TRAIL_LENGTH_MOBILE := 3
const PROJECTILE_TRAIL_LENGTH_EVOLVED := 8
const SPAWN_RATE_SCALE_DEFAULT := 0.88
const SPAWN_RATE_SCALE_MOBILE := 0.62
const SWARM_COUNT_SCALE_DEFAULT := 0.78
const SWARM_COUNT_SCALE_MOBILE := 0.55
const FORMATION_COUNT_SCALE_DEFAULT := 0.82
const FORMATION_COUNT_SCALE_MOBILE := 0.58
const WORLD_EVENT_INTERVAL_MIN := 28.0
const WORLD_EVENT_INTERVAL_MAX := 42.0

var player_ref: CharacterBody2D = null
var enemies_container: Node2D = null
var pickups_container: Node2D = null
var joystick_ref: Control = null
var total_kills: int = 0
var elapsed_time: float = 0.0
var pixel_theme: Theme = null
var sprites: Dictionary = {}
var weapon_icons: Dictionary = {}
var current_style: String = "style_i_mystery"
var bg_style: String = "mystery_skull"

# z-index 统一规划（v0.6 PRD 5.9.1）
const Z_BACKGROUND := -10
const Z_DANGER_ZONE := -5
const Z_HEALING_POINT := -4
const Z_GEM := 0
const Z_ENEMY := 0
const Z_PLAYER_MARKER := 0
const Z_PLAYER := 1
const Z_BOSS := 2
const Z_TRAIL := 5
const Z_VFX_MID := 7
const Z_VFX_HIGH := 10
const Z_FLOAT_TEXT := 20
const Z_BANNER := 50
const Z_SCREEN_FLASH := 100

# Pixel UI color palette
const UI_BG_DARK := Color(0.05, 0.05, 0.10)
const UI_BG := Color(0.10, 0.10, 0.18)
const UI_BG_LIGHT := Color(0.15, 0.15, 0.25)
const UI_BG_HOVER := Color(0.18, 0.18, 0.30)
const UI_BG_PRESSED := Color(0.06, 0.06, 0.12)
const UI_BORDER := Color(0.25, 0.25, 0.40)
const UI_BORDER_HI := Color(0.35, 0.35, 0.55)
const UI_BORDER_LO := Color(0.12, 0.12, 0.22)
const UI_TEXT := Color(0.92, 0.92, 0.96)
const UI_TEXT_DIM := Color(0.55, 0.55, 0.70)
const UI_GOLD := Color(1.0, 0.84, 0.0)
const UI_RED := Color(0.85, 0.2, 0.2)
const UI_BLUE := Color(0.25, 0.6, 1.0)
const UI_GREEN := Color(0.2, 0.8, 0.3)
const PX := 2


func get_xp_for_level(level: int) -> int:
	return int(5 + level * 10 + pow(level, 1.5))


func get_difficulty_multiplier(time_elapsed: float) -> float:
	return 1.0 + (time_elapsed / 60.0) * 0.5


func get_weapon_damage(weapon_type: int, level: int) -> int:
	var base: int = WEAPON_DATA[weapon_type]["base_damage"]
	return int(base * (1.0 + (level - 1) * 0.2))


func get_weapon_cooldown(weapon_type: int, level: int) -> float:
	var base: float = WEAPON_DATA[weapon_type]["base_cooldown"]
	return base * (1.0 - (level - 1) * 0.08)


func get_weapon_area(weapon_type: int, level: int) -> float:
	if not WEAPON_DATA[weapon_type].has("base_area"):
		return 1.0
	var base: float = WEAPON_DATA[weapon_type]["base_area"]
	return base * (1.0 + (level - 1) * 0.1)


func _ready() -> void:
	_setup_inputs()
	pixel_theme = _build_pixel_theme()
	_load_sprites(current_style)
	weapon_icons = SpriteGen.generate_weapon_icons()
	load_save()


func _load_sprites(style: String) -> void:
	current_style = style
	sprites = preload("res://scripts/sprite_loader.gd").load_all(style)
	if sprites.is_empty():
		sprites = _generate_style_sprites(style)
	# 3 个具体 Boss sprite 兜底：style 文件夹和 style 生成器都不一定提供，统一程序化补
	for boss_id in ["bone_lord", "shadow_lich", "blood_moon"]:
		var key: String = "boss_" + boss_id
		if not sprites.has(key):
			sprites[key] = [
				SpriteGen.gen_boss_for(boss_id, 0),
				SpriteGen.gen_boss_for(boss_id, 1),
			]


func _generate_style_sprites(style: String) -> Dictionary:
	match style:
		"style_b_samurai":
			return SpriteGenVariants.generate_style_b()
		"style_c_ranger":
			return SpriteGenVariants.generate_style_c()
		"style_d_mage":
			return SpriteGenVariants.generate_style_d()
		"style_e_pico8":
			return SpriteGenStyles.generate_style_e()
		"style_f_sweetie":
			return SpriteGenStyles.generate_style_f()
		"style_g_gothic":
			return SpriteGenStyles.generate_style_g()
		"style_h_cyber":
			return SpriteGenStyles.generate_style_h()
		"style_i_mystery":
			return SpriteGenStyles.generate_style_i()
		"style_j_princess":
			return SpriteGenStyles.generate_style_j()
	return SpriteGen.generate_all()


func switch_style(style: String) -> void:
	_load_sprites(style)


func is_mobile() -> bool:
	return OS.get_name() in ["Android", "iOS"]


func is_low_fx_mode() -> bool:
	return is_mobile()


func get_player_visual_scale() -> float:
	return PLAYER_VISUAL_SCALE_MOBILE if is_mobile() else PLAYER_VISUAL_SCALE


func get_enemy_cap() -> int:
	return ENEMY_CAP_MOBILE if is_mobile() else ENEMY_CAP_DEFAULT


func get_vfx_particle_budget() -> int:
	return VFX_PARTICLE_BUDGET_MOBILE if is_low_fx_mode() else VFX_PARTICLE_BUDGET_DEFAULT


func get_float_text_cap() -> int:
	return FLOAT_TEXT_CAP_MOBILE if is_low_fx_mode() else FLOAT_TEXT_CAP_DEFAULT


func get_float_text_per_second() -> int:
	return FLOAT_TEXT_PER_SECOND_MOBILE if is_low_fx_mode() else FLOAT_TEXT_PER_SECOND_DEFAULT


func get_projectile_trail_length() -> int:
	return PROJECTILE_TRAIL_LENGTH_MOBILE if is_low_fx_mode() else PROJECTILE_TRAIL_LENGTH_DEFAULT


func get_spawn_rate_scale() -> float:
	return SPAWN_RATE_SCALE_MOBILE if is_mobile() else SPAWN_RATE_SCALE_DEFAULT


func get_swarm_count_scale() -> float:
	return SWARM_COUNT_SCALE_MOBILE if is_mobile() else SWARM_COUNT_SCALE_DEFAULT


func get_formation_count_scale() -> float:
	return FORMATION_COUNT_SCALE_MOBILE if is_mobile() else FORMATION_COUNT_SCALE_DEFAULT


func should_reduce_enemy_detail() -> bool:
	return is_low_fx_mode() or get_tree().get_nodes_in_group("enemies").size() > 120


func _setup_inputs() -> void:
	var action_keys := {
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
	}
	for action_name in action_keys:
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		for key in action_keys[action_name]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action_name, event)


func _build_pixel_theme() -> Theme:
	var t := Theme.new()

	# Button — 3D embossed pixel style
	t.set_stylebox("normal", "Button", _px_btn(UI_BG_LIGHT, UI_BORDER_HI, false))
	t.set_stylebox("hover", "Button", _px_btn(UI_BG_HOVER, Color(0.5, 0.45, 0.7), false))
	t.set_stylebox("pressed", "Button", _px_btn(UI_BG_PRESSED, UI_BORDER_LO, true))
	t.set_stylebox("disabled", "Button", _px_btn(UI_BG_DARK, UI_BORDER_LO, false))
	t.set_stylebox("focus", "Button", _px_btn(UI_BG_HOVER, UI_GOLD, false))
	t.set_color("font_color", "Button", UI_TEXT)
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_pressed_color", "Button", UI_TEXT_DIM)
	t.set_constant("outline_size", "Button", 2)
	t.set_color("font_outline_color", "Button", Color(0, 0, 0, 0.9))

	# PanelContainer — double-border pixel frame
	t.set_stylebox("panel", "PanelContainer", _px_panel())

	# ProgressBar
	t.set_stylebox("background", "ProgressBar", _px_bar_theme_bg())
	t.set_stylebox("fill", "ProgressBar", _px_flat(UI_BLUE))

	# HSlider
	var slider_bg := _px_flat(UI_BG_DARK)
	slider_bg.set_content_margin_all(0)
	t.set_stylebox("slider", "HSlider", slider_bg)
	t.set_stylebox("grabber_area", "HSlider", _px_flat(UI_BLUE))
	t.set_stylebox("grabber_area_highlight", "HSlider", _px_flat(UI_BLUE.lightened(0.2)))

	# Label — crisp pixel text
	t.set_color("font_color", "Label", UI_TEXT)
	t.set_constant("outline_size", "Label", 2)
	t.set_color("font_outline_color", "Label", Color(0, 0, 0, 0.8))
	t.set_constant("shadow_offset_x", "Label", PX)
	t.set_constant("shadow_offset_y", "Label", PX)
	t.set_color("font_shadow_color", "Label", Color(0, 0, 0, 0.5))

	# CheckButton
	t.set_color("font_color", "CheckButton", UI_TEXT)
	t.set_constant("outline_size", "CheckButton", 2)
	t.set_color("font_outline_color", "CheckButton", Color(0, 0, 0, 0.8))

	# ScrollContainer
	t.set_stylebox("panel", "ScrollContainer", StyleBoxEmpty.new())

	return t


func _px_btn(bg: Color, border: Color, pressed: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(0)
	if pressed:
		s.border_color = border
		s.set_border_width_all(PX)
		s.border_width_top = PX * 2
		s.border_width_left = PX * 2
		s.border_width_bottom = PX
		s.border_width_right = PX
		s.shadow_color = Color(0, 0, 0, 0)
	else:
		s.border_width_top = PX
		s.border_width_left = PX
		s.border_width_bottom = PX * 2
		s.border_width_right = PX * 2
		s.border_color = border
		s.shadow_color = Color(0, 0, 0, 0.35)
		s.shadow_size = PX
		s.shadow_offset = Vector2(PX, PX)
	s.set_content_margin_all(PX * 4)
	s.set_expand_margin_all(0)
	return s


func _px_panel() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.08, 0.08, 0.14, 0.95)
	s.border_color = UI_BORDER_HI
	s.border_width_top = PX
	s.border_width_left = PX
	s.border_width_bottom = PX * 2
	s.border_width_right = PX * 2
	s.set_corner_radius_all(0)
	s.set_content_margin_all(PX * 5)
	s.shadow_color = Color(0, 0, 0, 0.5)
	s.shadow_size = PX * 2
	s.shadow_offset = Vector2(PX * 2, PX * 2)
	s.set_expand_margin_all(0)
	return s


func _px_bar_theme_bg() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.02, 0.02, 0.05)
	s.border_color = UI_BORDER_LO
	s.border_width_top = PX * 2
	s.border_width_left = PX * 2
	s.border_width_bottom = PX
	s.border_width_right = PX
	s.set_corner_radius_all(0)
	s.set_content_margin_all(PX)
	return s


func _px_box(bg: Color, border: Color, inset: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(PX)
	s.set_corner_radius_all(0)
	s.set_content_margin_all(PX * 4)
	if inset:
		s.shadow_color = Color(0, 0, 0, 0)
	else:
		s.shadow_color = Color(0, 0, 0, 0.3)
		s.shadow_size = PX
		s.shadow_offset = Vector2(PX, PX)
	s.set_expand_margin_all(0)
	return s


func _px_flat(bg: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(0)
	s.set_border_width_all(0)
	s.set_content_margin_all(PX * 2)
	return s


func is_character_unlocked(char_id: String) -> bool:
	return char_id in unlocked_characters


func check_character_unlocks() -> Array:
	var newly_unlocked: Array = []
	for char_id in CHARACTER_ORDER:
		if char_id in unlocked_characters:
			continue
		var data: Dictionary = CHARACTER_DATA[char_id]
		var ut: String = data["unlock_type"]
		var uv = data["unlock_value"]
		var unlocked := false
		match ut:
			"free":
				unlocked = true
			"stage":
				unlocked = int(uv) in cleared_stages
			"stage_all":
				unlocked = cleared_stages.size() >= int(uv)
			"survival":
				unlocked = best_free_survival >= float(uv)
			"kills":
				unlocked = total_kills_all_time >= int(uv)
		if unlocked:
			unlocked_characters.append(char_id)
			newly_unlocked.append(char_id)
	if not newly_unlocked.is_empty():
		save_game()
	return newly_unlocked


func get_character_data() -> Dictionary:
	return CHARACTER_DATA.get(selected_character, CHARACTER_DATA["mystery_survivor"])


func save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "unlocked", unlocked_stages.duplicate())
	cfg.set_value("progress", "cleared", cleared_stages.duplicate())
	var lb_save: Array = []
	for entry in leaderboard:
		lb_save.append({"time": entry["time"], "kills": entry["kills"], "level": entry["level"]})
	cfg.set_value("leaderboard", "records", lb_save)
	cfg.set_value("characters", "unlocked", unlocked_characters.duplicate())
	cfg.set_value("characters", "total_kills_all_time", total_kills_all_time)
	cfg.set_value("characters", "best_free_survival", best_free_survival)
	cfg.save("user://save.cfg")


func load_save() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://save.cfg") == OK:
		var u = cfg.get_value("progress", "unlocked", [1])
		unlocked_stages = u if u is Array else [1]
		var c = cfg.get_value("progress", "cleared", [])
		cleared_stages = c if c is Array else []
		var lb = cfg.get_value("leaderboard", "records", [])
		leaderboard = lb if lb is Array else []
		var uc = cfg.get_value("characters", "unlocked", ["mystery_survivor", "blue_knight", "pico8_retro"])
		unlocked_characters = uc if uc is Array else ["mystery_survivor", "blue_knight", "pico8_retro"]
		total_kills_all_time = cfg.get_value("characters", "total_kills_all_time", 0)
		best_free_survival = cfg.get_value("characters", "best_free_survival", 0.0)
	else:
		unlocked_stages = [1]
		cleared_stages = []
		leaderboard = []
		unlocked_characters = ["mystery_survivor", "blue_knight", "pico8_retro"]
		total_kills_all_time = 0
		best_free_survival = 0.0


func add_leaderboard_entry(time: float, kills: int, lvl: int) -> int:
	var entry: Dictionary = {"time": time, "kills": kills, "level": lvl}
	leaderboard.append(entry)
	leaderboard.sort_custom(_compare_records)
	if leaderboard.size() > MAX_LEADERBOARD:
		leaderboard.resize(MAX_LEADERBOARD)
	var rank: int = -1
	for i in range(leaderboard.size()):
		if leaderboard[i] == entry:
			rank = i + 1
			break
	save_game()
	return rank


func _compare_records(a: Dictionary, b: Dictionary) -> bool:
	if a["time"] != b["time"]:
		return a["time"] > b["time"]
	if a["kills"] != b["kills"]:
		return a["kills"] > b["kills"]
	return a["level"] > b["level"]


func unlock_stage(stage_id: int) -> void:
	if not unlocked_stages.has(stage_id):
		unlocked_stages.append(stage_id)
	save_game()


func clear_stage(stage_id: int) -> void:
	if not cleared_stages.has(stage_id):
		cleared_stages.append(stage_id)
	var next_id: int = stage_id + 1
	if STAGE_DATA.has(next_id):
		unlock_stage(next_id)
	save_game()


func get_stage_data() -> Dictionary:
	if current_stage > 0 and STAGE_DATA.has(current_stage):
		return STAGE_DATA[current_stage]
	return {}


func is_stage_mode() -> bool:
	return current_stage > 0
