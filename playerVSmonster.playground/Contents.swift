//1) В игре есть Существа. К ним относятся Игрок и Монстры.
//2) У Существа есть параметры Атака и Защита. Это целые числа от 1 до 30.
//3) У Существа есть Здоровье. Это натуральное число от 0 до N. Если Здоровье становится равным 0, то Существо умирает. Игрок может себя исцелить до 4-х раз на 30% от максимального Здоровья.
//4) У Существа есть параметр Урон. Это диапазон натуральных чисел M - N. Например, 1-6.
//5) Одно Существо может ударить другое по такому алгоритму:
//  - Рассчитываем Модификатор атаки. Он равен разности Атаки атакующего и Защиты защищающегося плюс 1
//  - Успех определяется броском N кубиков с цифрами от 1 до 6, где N - это Модификатор атаки. Всегда бросается хотя бы один кубик.
//	- Удар считается успешным, если хотя бы на одном из кубиков выпадает 5 или 6
//  - Если удар успешен, то берется произвольное значение из параметра Урон атакующего и вычитается из Здоровья защищающегося.

class Creature {
	var attack: Int
	var defense: Int
	var health: Int
	var damageRange: ClosedRange<Int>
	
	init(attack: Int, defense: Int, health: Int, damageRange: ClosedRange<Int>) {
		self.attack = attack
		self.defense = defense
		self.health = health
		self.damageRange = damageRange
		checkingParameters()
	}
	
	func die() {
		print("Существо погибло")
	}
	
	func takeDamage(damage: Int) {
		health -= damage
		if health <= 0 {
			die()
		}
	}
	
	func takeAttack(target: Creature) -> Int {
		var damage = 0
		let attackModifier = attack - target.defense + 1
		let diceRolls = max(1, attackModifier)
		
		var successfulHit = false
		for _ in 0..<diceRolls {
			let diceRoll = Int.random(in: 1...6)
			if diceRoll >= 5 {
				successfulHit = true
				break
			}
		}
		
		if successfulHit {
			damage = Int.random(in: damageRange)
			target.takeDamage(damage: damage)
		}
		
		return damage
	}
	
	private func setRange(_ number: Int) -> Int {
		if number < 1 {
			return 1
		} else if attack > 30 {
			return 30
		}
		return number
	}
	
	private func checkingParameters() {
		attack = setRange(attack)
		defense = setRange(defense)
		health = health < 1 ? 1 : health
	}
}

class Player: Creature {
	let maxHealth: Int
	private let healing = 0.3
	private var numberFirstAid = 4
	
	override init(attack: Int, defense: Int, health: Int, damageRange: ClosedRange<Int>) {
		self.maxHealth = health
		super.init(attack: attack, defense: defense, health: health, damageRange: damageRange)
	}
	
	func takeHeal() {
		if numberFirstAid > 0 {
			numberFirstAid -= 1
			health += Int(Double(maxHealth) * healing)
			if health > maxHealth {
				health = maxHealth
			}
		}
		print("Игрок подлечился")
	}
	
	override func die() {
		print("Игрок погиб")
	}
}

class Monster: Creature {
	override func die() {
		print("Монстр погиб")
	}
}

// Бойцы
let player = Player(attack: 10, defense: 10, health: 10, damageRange: 1...6)
let monster = Monster(attack: 10, defense: 10, health: 10, damageRange: 1...6)

// Смертельная битва
print("Начнется смертельная битва")
print("Monster VS Player")

var round = 0
while player.health > 1, monster.health > 1 {
	round += 1
	print("Раунд № \(round)")
	print("Здоровье Игрока: \(player.health) - Здоровье Монстра: \(monster.health)")
	print("Игрок нанес урон: \(player.takeAttack(target: monster)) - Монстр нанес урон: \(monster.takeAttack(target: player))")
	if  player.health > 0, player.health < player.maxHealth / 2 {
		player.takeHeal()
	}
}
