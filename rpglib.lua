if not fight then
	fight = {}
	rpg_dropped_items = {}
end

RPGCHAT = -1001457976044

function reloadStats()
	local n = 0
	for i,b in pairs(users) do 
		if b.rpg then 
			for _,it in pairs(b.rpg.bp) do 
				if it~=0 and it.attr then 
					for ind=1,#it.attr do 
						local id = it.attr[ind].i 
						if id > 0 then
							it.attr[ind] = makeAttribute(id)
						end
					end
				end
			end
			for _,it in pairs(b.rpg.equip) do 
				if it~=0 and it.attr then 
					for ind=1,#it.attr do 
						local id = it.attr[ind].i 
						if id > 0 then
							it.attr[ind] = makeAttribute(id)
						end
					end
				end
			end
		end
	end
	for i,b in pairs(users) do 
		if b.rpg then 
			SaveUser(i)
		end 
	end
end

function selectModifier(itemObj, canAdd)
	if not itemObj then 
		local canAdd = {}
		for i,b in pairs(attributes) do 
			if math.random(0, 1000) <= b.chance then 
				canAdd[#canAdd+1] = i
			end 
		end
		return makeAttribute(canAdd[math.random(1, #canAdd)])
	end
	local cad = canAdd[math.random(1, #canAdd)]
	for x=1,5 do 
		
		local found = false

		for i=1, itemObj.slots do 
			if itemObj.attr[i] ~= 0 and itemObj.attr[i].i == cad then
				found = true
				break
			end
		end
		if not found then 
			return cad
		else 
			cad = canAdd[math.random(1, #canAdd)]
		end
	end
	return cad
end

function addModifier(itemObj)
	if itemObj.attr then 
		local canAdd = {}
		for i,b in pairs(attributes) do 
			if math.random(0, 1000) <= b.chance then 
				canAdd[#canAdd+1] = i
			end 
		end
		if not itemObj.slots then 
			itemObj.slots =items[itemObj[1]].slot 
		end
		for i=1, itemObj.slots do 
			local cad = selectModifier(itemObj, canAdd)
			if itemObj.attr[i].i == 0 then 
				
				itemObj.attr[i] = makeAttribute(cad)
				return true, "Added modifier: "..genAttrDesc(itemObj.attr[i]) 
			end
		end
		return false, "No extra slots left"
	end
	return false, "err"
end

function giveLuckyModifier(itemObj)
	if itemObj.attr then 
		if not itemObj.slots then 
			itemObj.slots =items[itemObj[1]].slot 
		end
		for i=1, itemObj.slots do 
			if itemObj.attr[i].i == 0 then 				
				local mod = math.random(1, #attributes)
				itemObj.attr[i] = makeAttribute(mod)
				return true, "Added modifier: "..genAttrDesc(itemObj.attr[i]) 
			end
		end
		return false, "No extra slots left"
	end
	return false, "err"
end

function rerollSlots(itemObj)
	if itemObj.attr then 
		if not itemObj.slots then 
			itemObj.slots =items[itemObj[1]].slot 
		end
		local cnt = itemObj.slots 
		itemObj.slots, maxSlot = makeSlots(itemObj[1])
		
		if cnt >= maxSlot then 
			return false, "Item is already on max slots!"
		end

		if itemObj.slots == cnt and cnt > 1 then 
			itemObj.slots = itemObj.slots -1
		end

		if cnt > itemObj.slots then 
			for i=1, cnt do 
				if i > itemObj.slots then 
					itemObj.attr[i] = nil
				end
			end
		else 
			for i=1, itemObj.slots do 
				if not itemObj.attr[i] then 				
					itemObj.attr[i] = blankAttr()
				end
			end
		end
		return true, "You item now have "..itemObj.slots.." slots! (Max: "..maxSlot..")\n"..renderItem(itemObj)
	end
	return false, "err"
end


function removeModifier(itemObj)
	if itemObj.attr then 
		local can = {}
		if not itemObj.slots then 
			itemObj.slots =items[itemObj[1]].slot 
		end
		for i=1, itemObj.slots do 
			if itemObj.attr[i].i ~= 0 then 
				can[#can+1] = i
				print("ATTR "..i,Dump(itemObj.attr[i]))
				--itemObj.attr[i] = makeAttribute(math.random(1, #attributes))
				--return true, genAttrDesc(itemObj.attr[i])
			end
		end
		if #can == 0 then 
			return false, "No modifiers"
		end
		local sel = can[math.random(1, #can)]
		local desc =  genAttrDesc(itemObj.attr[sel])
		itemObj.attr[sel] = blankAttr()
		return true, "Removed modifier: "..desc.."-"..sel
	end
	return false, "err"
end


function populateModifiers(itemObj)
	if itemObj.attr then
		local str = "" 
		local canAdd = {}

		for i,b in pairs(attributes) do 
			if math.random(0, 1000) <= b.chance then 
				canAdd[#canAdd+1] = i
			end 
		end
		if not itemObj.slots then 
			itemObj.slots =items[itemObj[1]].slot 
		end
		for i=1, itemObj.slots do 
			--if itemObj.attr[i].i == 0 then 
				local cad = selectModifier(itemObj, canAdd)
				itemObj.attr[i] = makeAttribute(cad)
				str = str .. genAttrDesc(itemObj.attr[i]).."\n"
			--end
		end
		return true, str
	end
	return false, "err"
end




items = {
	[1] = {stock=1, name = "🍎", work = function(a, c) a.h = a.h+20 gainExp(a, 5,nil, "APPL") return {true, "Restored +20 life", 1} end 				, desc = "Restore +20 HP +5 EXP"		, prob=50000, price=25, stack=true},
	[2] = {stock=1, name = "🧀", work = function(a, c) a.h = a.h+100 return {true,"Restored +100 life", 1} end 			, desc = "Restore +100 HP"		, prob=40000, price=40, stack=true},
	[3] = {stock=1, name = "🍰", work = function(a, c) a.h = a.h+500 return {true,"Restored +500 life", 1} end 			, desc = "Restore +500 HP"		, prob=3000, price=200, stack=true},
	[4] = {stock=1, name = "🥇", work = function(a, c) gainExp(a, 200,nil, "MED") return {true,"+200 Exp", 1} end 					, desc = " +200 EXP on use"		, prob=200,	price=3000, stack=true},
	
	[5] = {craft=removeModifier,stock=1, name = "🍺", work = function(a, c) return {false,"Use /rpgcraft to use this item", 1} end 		, desc = "Remove a random modifier of a item"		, prob=2400,	price=650, stack=true},
	[6] = {craft=addModifier,stock=1, name = "🥃", work = function(a, c) return {false,"Use /rpgcraft to use this item", 1} end 		, desc = "Add a random modifier to a item"		    , prob=2400,	price=650, stack=true},
	
	[7] = {stock=1,	name = "🍆", work = function(a, c) a.h = a.h+5000 return {true,"Restored +1000 life", 1} end 			, desc = "Restored +5000 life"	, prob=1400,	price=2000, stack=true},
	[8] = {stock=1, name = "🥈", work = function(a, c) gainExp(a, 50,nil, "MED2") return {true,"+50 Exp", 1} end 						, desc = " +50 EXP on use"			, prob=500, price=1000, stack=true},
	[9] = {stock=1, name = "🥉", work = function(a, c) gainExp(a, 20,nil, "MED3") return {true,"+20 Exp", 1} end 						, desc = " +20 EXP on use"			, prob=400, price=700, stack=true},
	[10] = {stock=1, name = "⚔️", work = function(a, c) if (c < a.ea) then return{false, "you need %d items", a.ea} end a.ea = a.ea+1 return {true,"+1 ATK", a.ea-1} end 						, desc = "+1 ATK permamently (each use cost more)"					, prob=900		, price=1000, stack=true},
	[11] = {stock=1, name = "🛡", work = function(a, c) if (c < a.ed) then return{false, "you need %d items", a.ed} end a.ed = a.ed+1 return {true,"+1 DEF", a.ed-1} end 						, desc = "+1 DEF permamently (each use cost more)"						, prob=900	, price=1000, stack=true},
	[13] = {name = "📝", work = function(a, c) a.d = a.d-1 a.a = a.a-1 a.s = a.s+2 return {true,"-1 ATK -1 DEF +2 Skill", 1} end 	, desc = "Remove 1 atk and def and give +2 skill pts"		, prob=1500, price=3000, stack=true},
	[12] = {name = "🎁", work = function(a, c) local id = nonequip[math.random(1,#nonequip)] addItem(a, id, 1) return {true,"You found a "..items[id].name, 1} end 	, desc = "Add a random item"		, prob=1000, price=0, stack=true},
	[14] = {stock=1, name = "♻️", work = function(a, c) resetRpg(a) return {true,"All stats reseted. Nothing in return but your skill pts", 1} end,  desc = "RESET ALL STATS!!"		, prob=00, price=10, stack=true},
	[15] = {stock=1, name = "☕️", work = function(a, c) if (c < a.ee) then return{false, "you need %d items", a.ee} end a.ee = a.ee+1 return {true,"+1 AGI", a.ee-1} end 					, desc = "+1 AGI permamently (each use cost more)"						, prob=900, price=1000, stack=true},
	[16] = {stock=1, name = "💉", work = function(a, c) local n = math.floor(a.ev/4) if (c < n) then return{false, "you need %d items", n} end a.ev = a.ev+4 return {true,"+4 LIFE", n-1} end 						, desc = "+4 LIFE permamently (each use cost more)"							, prob=900, price=1000, stack=true},
	[17] = {stock=1, name = "🔝", work = function(a, c) a.s = a.s+1 return {true,"+1 SKILL POINT", 1} end 				, desc = "+1 SKILL POINT permamently"					, prob=10, price=3000, nore=true, stack=true},
	[18] = {name = "💳", work = function(a, c) a.h = 1 local mon = math.random(100,500) addGold(a, mon) return {true,"Life set to 1. Won "..formatMoney(mon), 1} end 				, desc = "Set your life to 0, Gets money instead"					, prob=1500, price=0, stack=true},
	
	[19] = {craft=populateModifiers,stock=1, name = "🍷", work = function(a, c) return {false,"Use /rpgcraft to use this item", 1} end 		, desc = "Reroll all modifiers of a item"		    , prob=2400,	price=650, stack=true},
	



	[47] = {stock=1, name = "📦", work = function(a, c, nm) 
		local id = math.random(20, 46); 
		local it = addItem(a, id, 1) 
		bot.sendMessage(RPGCHAT, "@"..nm.." found a <b>"..items[id].name..(items[it[1]].desc or items[it[1]].genDesc(it)).."</b> in a 📦", "HTML")
		return {true,"You found a "..items[id].name..(items[it[1]].desc or items[it[1]].genDesc(it)).."\nUse /rpgequip to equip\nUse /rpgcraft to craft the slots", 1}

	end 		, desc = "Gives a random equipment."		    , prob=00,	price=0, stack=false},


	[48] = {stock=1, name = "🚽", work = function(a, c, nm) 
		local id = math.random(49, 52); 
		local it = addItem(a, id, 1) 
		bot.sendMessage(RPGCHAT, "@"..nm.." found a <b>"..items[id].name..(items[it[1]].desc or items[it[1]].genDesc(it)).."</b> in a 🚽", "HTML")
		return {true,"You found a "..items[id].name..(items[it[1]].desc or items[it[1]].genDesc(it)).."\nUse /rpgequip to equip\nUse /rpgcraft to craft the slots", 1}

	end 		, desc = "Gives a random equipment."		    , prob=00,	price=0, stack=false},
	
 
	[60] = {craft=giveLuckyModifier,stock=1, name = "🍾", work = function(a, c) return {false,"Use /rpgcraft to use this item", 1} end 		, desc = "Add a lucky modifier"		, prob=10,	price=15000, stack=true},
	[61] = {craft=rerollSlots,stock=1, name = "🍵", work = function(a, c) return {false,"Use /rpgcraft to use this item", 1} end 		, desc = "Reroll the amount of slots in a item"		, prob=2400,	price=600, stack=true},
	
	[62] = {stock=1, name = "🥣", work = function(a, c, nm) 
		spawnManaPool(nm)
		return {true,"You spawned a mana pool at the main chat!", 1}

	end 	, desc = "Spawn a mana pool in the main chat"		    , prob=10,	price=100, stack=true},	


	used = {}
}

droppable = {}

--[[
			helmet 1
			armor = 2
			weapon = 3
			legs = 4
			boots = 5
			ring = 6
			necklace = 7
		]]
ITEM_CLASS_ = 0
ITEM_CLASS_HEALTH 			= 1
ITEM_CLASS_HEALTH_MAX 		= 2


ITEM_CLASS_ATTACK 			= 3
ITEM_CLASS_ATTACK_MAX 		= 4

ITEM_CLASS_DEFENSE 			= 5
ITEM_CLASS_DEFENSE_MAX 		= 6

ITEM_CLASS_EVASION 			= 7
ITEM_CLASS_EVASION_MAX 		= 8

ITEM_CLASS_VITALITY			= 9
ITEM_CLASS_VITALITY_MAX 	= 10

ITEM_CLASS_CRITICAL 		= 11

ITEM_CLASS_HEAL 	= 12
ITEM_CLASS_EXP 		= 13

ITEM_CLASS_EVADE = 14
ITEM_CLASS_ACCURACY = 15
ITEM_CLASS_BLOCK = 16


SLOT_HELMET = 1
SLOT_ARMOR 	= 2
SLOT_WEAPON = 3
SLOT_LEGS	= 4
SLOT_BOOTS	= 5
SLOT_RING 	= 6
SLOT_NECKLACE=7

SLOT_FIRST  = SLOT_HELMET
SLOT_LAST	= SLOT_NECKLACE

maxslots = {
	[SLOT_HELMET] = 5,
	[SLOT_ARMOR] = 5,
	[SLOT_WEAPON] = 6,
	[SLOT_BOOTS] = 4,
	[SLOT_RING] = 5,
	[SLOT_NECKLACE] = 5,
	[SLOT_LEGS] = 4,
}

equips = {
	[SLOT_HELMET] = {
		{id=20, name="⛑", slot=2, chance=80, attr=2},
		{id=21, name="👺", slot=3, chance=40, attr=40},
		{id=22, name="👑", slot=4, chance=10, attr=22},
		{id=23, name="🕶", slot=1, chance=100, attr=37},
		{id=24, name="🎀", slot=2, chance=80, attr=12},
	},
	[SLOT_ARMOR] = {
		{id=25, name="🧥", slot=2, chance=80, attr=12},
		{id=26, name="👗", slot=3, chance=40, attr=37},
		{id=27, name="👘", slot=2, chance=80, attr=2},
		{id=28, name="👙", slot=4, chance=20, attr=22},
	},
	[SLOT_WEAPON] = {
		{id=29, name="🌂", slot=2, chance=50, attr=8},
		{id=30, name="🦴", slot=1, chance=100, attr=24},
		{id=31, name="🥕", slot=2, chance=50, attr=27},
		{id=32, name="🥄", slot=1, chance=80, attr=31},
		{id=33, name="🍡", slot=3, chance=20, attr=43},
		{id=34, name="🍢", slot=3, chance=20, attr=40},
		{id=35, name="🗡", slot=2, chance=50, atrr=20},
		{id=36, name="🔱", slot=4, chance=20, attr=10},
		{id=37, name="🧷", slot=6, chance=5, attr=5},
		--'🔨⛏'
	},
	[SLOT_BOOTS] = {
		{id=38, name="🥾", slot=2, chance=80, attr=2},
		{id=39, name="🧦", slot=1, chance=100, attr=22},
		{id=40, name="👠", slot=2, chance=80, attr=12},
		{id=41, name="👢", slot=3, chance=20, attr=37},

	},
	[SLOT_RING] = {
		{id=42, name="💍", slot=3, chance=20, attr=15},
		{id=43, name="⚙️", slot=3, chance=20, attr=10},
		{id=44, name="🍩", slot=3, chance=20, attr=5},
	},
	[SLOT_NECKLACE] = {
		{id=45, name="🧣", slot=1, chance=100, attr=26},
		{id=46, name="📿", slot=4, chance=20, attr=18},
	},

	[SLOT_LEGS] = {
		{id=49, name="👖", slot=2, chance=80, attr=37},
		{id=50, name="🍁", slot=1, chance=120, attr=12},
		{id=51, name="🧻", slot=2, chance=80, attr=22},
		{id=52, name="🍑", slot=3, chance=20, attr=2},
	}

}



attributes = {
	{name="HP.t1"	, v = {5,15}			,	class=ITEM_CLASS_HEALTH 		,chance=400 }, --1
	{name="HP.t2"	, v = {16,30}			,	class=ITEM_CLASS_HEALTH 		,chance=100 },
	{name="HP.t3"	, v = {31,50}			,	class=ITEM_CLASS_HEALTH 		,chance=50 },
	{name="HP.t4"	, v = {51,70}			,	class=ITEM_CLASS_HEALTH 		,chance=5 },
	{name="MAX HP.t1"	, p = {4,6}			,	class=ITEM_CLASS_HEALTH_MAX 	,chance=20 }, --5

	{name="ATK.t1"	, v = {2,4}				,	class=ITEM_CLASS_ATTACK 		,chance=1000 }, --6
	{name="ATK.t2"	, v = {5,9}			,	class=ITEM_CLASS_ATTACK 		,chance=100 },
	{name="ATK.t3"	, v = {10,15}			,	class=ITEM_CLASS_ATTACK 		,chance=50 },
	{name="ATK.t4"	, v = {16,25}			,	class=ITEM_CLASS_ATTACK 		,chance=5 },
	{name="MAX ATK.t1"	, p = {4,6}			,	class=ITEM_CLASS_ATTACK_MAX 	,chance=60 }, --10

	{name="DEF.t1"	, v = {2,4}				,	class=ITEM_CLASS_DEFENSE 		,chance=1000 },
	{name="DEF.t2"	, v = {5,9}			,	class=ITEM_CLASS_DEFENSE 		,chance=100 },
	{name="DEF.t3"	, v = {10,15}			,	class=ITEM_CLASS_DEFENSE 		,chance=50 },
	{name="DEF.t4"	, v = {16,25}			,	class=ITEM_CLASS_DEFENSE 		,chance=5 },
	{name="MAX DEF.t1"	, p = {4,6}			,	class=ITEM_CLASS_DEFENSE_MAX 	,chance=60 }, --15

	{name="AGI.t1"	, v = {2,4}				,	class=ITEM_CLASS_EVASION 		,chance=1000 },
	{name="AGI.t2"	, v = {5,9}			,	class=ITEM_CLASS_EVASION 		,chance=100 },
	{name="AGI.t3"	, v = {10,15}			,	class=ITEM_CLASS_EVASION 		,chance=50 },
	{name="AGI.t4"	, v = {16,25}			,	class=ITEM_CLASS_EVASION 		,chance=5 },
	{name="MAX AGI.t1"	, p = {4,6}			,	class=ITEM_CLASS_EVASION_MAX 	,chance=60 }, --20

	{name="VIT.t1"	, v = {2,4}				,	class=ITEM_CLASS_VITALITY 		,chance=1000 },
	{name="VIT.t2"	, v = {5,9}			,	class=ITEM_CLASS_VITALITY 		,chance=100 },
	{name="VIT.t3"	, v = {10,15}			,	class=ITEM_CLASS_VITALITY 		,chance=50 },
	{name="VIT.t4"	, v = {16,25}			,	class=ITEM_CLASS_VITALITY 		,chance=5 },
	{name="MAX VIT.t1"	, p = {1,2}			,	class=ITEM_CLASS_VITALITY_MAX 	,chance=60 }, --25


	{name="Inc Crit.t1"	, p = {20,30}		,	class=ITEM_CLASS_CRITICAL 		,chance=300 },
	{name="Inc Crit.t2"	, p = {31,60}		,	class=ITEM_CLASS_CRITICAL 		,chance=150 },
	


	{name="HEAL.t1"	, p = {5,100}			,	class=ITEM_CLASS_HEAL 			,chance=1000 },
	{name="HEAL.t2"	, p = {101,200}			,	class=ITEM_CLASS_HEAL 			,chance=110 },
	{name="HEAL.t3"	, p = {201,300}			,	class=ITEM_CLASS_HEAL 				,chance=100 }, --30
	{name="HEAL.t4"	, p = {301,500}			,	class=ITEM_CLASS_HEAL 			,chance=5 },

	{name="EXP.t1"		, p = {5,20}		,	class=ITEM_CLASS_EXP 			,chance=300 },


	{name="MAX HP.t2"	, p = {7,11}		,	class=ITEM_CLASS_HEALTH_MAX 	,chance=5 },
	{name="EXP.t2"		, p = {21,30}		,	class=ITEM_CLASS_EXP 			,chance=40 },

	{name="Inc Crit.t3"	, p = {61,120}		,	class=ITEM_CLASS_CRITICAL 		,chance=5 }, --35

	{name="Inc Evade.t1"	, p = {20,30}		,	class=ITEM_CLASS_EVADE 		,chance=300 },
	{name="Inc Evade.t2"	, p = {31,60}		,	class=ITEM_CLASS_EVADE 		,chance=150 },
	{name="Inc Evade.t3"	, p = {61,120}		,	class=ITEM_CLASS_EVADE 		,chance=5 },

	{name="Inc Accuracy.t1"	, p = {20,30}		,	class=ITEM_CLASS_ACCURACY 		,chance=300 },
	{name="Inc Accuracy.t2"	, p = {31,60}		,	class=ITEM_CLASS_ACCURACY 		,chance=150 }, --40
	{name="Inc Accuracy.t3"	, p = {61,120}		,	class=ITEM_CLASS_ACCURACY 		,chance=5 },

	{name="Inc Block.t1"	, p = {20,30}		,	class=ITEM_CLASS_BLOCK 		,chance=300 },
	{name="Inc Block.t2"	, p = {31,60}		,	class=ITEM_CLASS_BLOCK 		,chance=150 },
	{name="Inc Block.t3"	, p = {61,120}		,	class=ITEM_CLASS_BLOCK 		,chance=5 },

	{name="Insta Kill.t1"	, p = {1,1}			,	class=ITEM_CLASS_INSTAKILL		,chance=0 }, --45

	{name="Life drain.t1"	, p = {2,3}			,	class=ITEM_CLASS_LIFEDRAIN		,chance=30 }, --45
	{name="Life drain.t2"	, p = {4,6}			,	class=ITEM_CLASS_LIFEDRAIN		,chance=15 }, --45
	{name="Life drain.t3"	, p = {7,11}		,	class=ITEM_CLASS_LIFEDRAIN		,chance=5 }, --45


	{name="Damage Amp.t1"	, p = {8,10}			,	class=ITEM_CLASS_DAMAGE_AMP		,chance=30 }, --45
	{name="Damage Amp.t2"	, p = {11,13}			,	class=ITEM_CLASS_DAMAGE_AMP		,chance=15 }, --45
	{name="Damage Amp.t3"	, p = {14,16}			,	class=ITEM_CLASS_DAMAGE_AMP		,chance=5 }, --45


	{name="Damage reduction.t1"	, p = {11,13}		,	class=ITEM_CLASS_DAMAGE_RED		,chance=30 }, --45
	{name="Damage reduction.t2"	, p = {14,16}		,	class=ITEM_CLASS_DAMAGE_RED		,chance=15 }, --45
	{name="Damage reduction.t3"	, p = {17,22}		,	class=ITEM_CLASS_DAMAGE_RED		,chance=5 }, --45


}
print(#attributes)

nonequip = {

}

for id, item in pairs(items) do
	if not item.equip and tonumber(id) then
		nonequip[#nonequip+1] = id
	end
end





function whereTextEquip(a)
	if a == SLOT_HELMET then 
		return "Helmet"
	elseif a == SLOT_ARMOR then 
		return "Armor"
	elseif a == SLOT_WEAPON then 
		return "Weapon"
	elseif a == SLOT_LEGS then 
		return "Legs"
	elseif a == SLOT_BOOTS then 
		return "Boots"
	elseif a == SLOT_RING then 
		return "Ring"
	elseif a == SLOT_NECKLACE then 
		return "Necklace"

	end
end

function getItemAttribute(item, classid, p)
	local t = 0
	local has = false
	for i,b in pairs(item.attr) do 
		if b.i ~= 0 and attributes[b.i] then
			if attributes[b.i].class == classid then
				t = t + ((p and b.p or b.v) or 0) 
				has = true
			end
		end
	end
	if item[1] and items[item[1]] and items[item[1]].implicit then
		if attributes[items[item[1]].implicit].class == classid then
			local b = attributes[items[item[1]].implicit]
			t = t + ((p and b.p[2]/100 or b.v[2]) or 0) 
		end
	end
	return t, has
end


function getAttributeModifier(data, classid)
	local n = 0
	local has = false
	for i,b in pairs(data.equip or {}) do 
		if b ~= 0 then 
			local am, disHas = getItemAttribute(b, classid)
			n = n + am 
			if disHas then 
				has = true
			end
		end
	end
	return n, has
end

function getAttributePercent(data, classid)
	local n = 1
	local has = false
	for i,b in pairs(data.equip or {}) do 
		if b ~= 0 then 
			local am, disHas = getItemAttribute(b, classid, true)
			n = n + am 
			if disHas then 
				has = true
			end
		end
	end
	return n, has
end

function blankAttr() 
	--value = nil
	--probability = nil
	--name = "-"
	--id = 0
	return {i=0}
end




function makeAttribute(id)
	local attr = blankAttr()
	attr.i = id 
	if attributes[id].v then 
		attr.v = math.random(attributes[id].v[1], attributes[id].v[2])
	end
	if attributes[id].p then 
		attr.p = math.random(attributes[id].p[1], attributes[id].p[2])/100
	end

	return attr
end


function makeSlots(id)
	local slotChance = 3500
    local slots = 0

    local maxSlots = (maxslots[items[id].equip] or 2) -1
    for i=1, maxSlots do 
        if math.random(0, 10000) >= (slotChance - (i/maxSlots)*0) then 
            break
        else 
        	slots = i
        end
    end
	return 1 + slots, maxSlots+1
end

function getAttrName(id)
	return attributes[id] and attributes[id].name or '-'
end

function genAttrDesc(a)
	return ((a.v and a.v ~= 0) and (a.v.." ") or "")..((a.p and a.p ~= 0) and ((a.p*100).."% ") or "")..getAttrName(a.i)
end

function genImplicitDesc(id)
	local a = {i=id}
	if attributes[id].v then 
		a.v = attributes[id].v[2]
	end

	if attributes[id].p then 
		a.p = attributes[id].p[2]/100
	end


	return ((a.v and a.v ~= 0) and (a.v.." ") or "")..((a.p and a.p ~= 0) and ((a.p*100).."% ") or "")..getAttrName(a.i)
end


local function genDesc(item)
	local desc = ""
	if not item.attr then 
		item.attr = {}
	end
	if not item.slots then 
		item.slots = items[item[1]].slot
	end
	for i=1,item.slots do
		if not item.attr[i] then 
			item.attr[i] = blankAttr()
		end
		desc = desc.." ["..genAttrDesc(item.attr[i]).."]"
	end
	return (items[item[1]].implicit and ("{"..genImplicitDesc( items[item[1]].implicit).."}") or "")..desc
end

droppable = {}
function populate()
	--set to a static thing
	for i,b in pairs(equips) do 
		local itype = i 
		for _, itemObj in pairs(b) do 
			items[itemObj.id] = {
				equip = itype,
				name = itemObj.name,
				stack=false,
				stock=true,
				--prob=00,
				implicit = itemObj.attr, 
				prob=70,
				price=2000,
				slot=itemObj.slot or 2,
				--blockbuy=true,
				work = function(a, c) return {false,"WIP", 0} end,
				--new =  itemObj.new or function(id) local amount = items[id].slot; local atrib = {} for i=1,amount do atrib[#atrib+1] = blankAttr()  end return atrib end,
				genDesc=genDesc,
			}
		end
	end
	
	for i,b in pairs(items) do
		if not b.equip and b.prob and b.prob > 0 then
			droppable[#droppable+1] = i
		end
	end
end

populate()

function gib()

	local dat = users['mockthebear'].rpg
	for i,b in pairs(dat.bp) do
		if b[1] >= 19 then 
			b[1] = 1
		end
	end
	addItem(dat, 19, 1)
	addItem(dat, 20, 1)
	
	addItem(dat, 21, 1)
end

function renderSet(data)
	local str = ""
	for i,b in pairs(data.equip) do 
		if b ~= 0 then
			str = str .. items[b[1]].name.." - "..whereTextEquip(items[b[1]].equip)..'\n'..(items[b[1]].desc or items[b[1]].genDesc(b)).."\n"
		end
	end
	return str
end

function renderSlotItem(data, id)
	local b = data.equip[id]
	if type(b) ~= "table" then 
		return "???"
	end
	return items[b[1]].name.." - "..whereTextEquip(items[b[1]].equip)..'\n'..(items[b[1]].desc or items[b[1]].genDesc(b)).."\n"
	-- body
end

function renderItem(it)
	return items[it[1]].name..(items[it[1]].equip and (items[it[1]].genDesc(it) ) or ("") )
end

function processEquipUse(msg)
	local user, item = msg.data:match("eq:(.-):(%d+)")
	if msg.from.username:lower() ~=user then 
		deploy_answerCallbackQuery(msg.id, "This is not your backpack", "true")
		return
	end
	item = tonumber(item)
	if item == 0 then
		deploy_answerCallbackQuery(msg.id, "Closing backpack")
		deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
		return
	end
	local data = getUserRpg(msg.from.username)
	if data then
		
		if not items.used[msg.message.message_id] then
			items.used[msg.message.message_id] = true
			scheduleEvent(0, function()
				items.used[msg.message.message_id] = false
			end)
			
			if not data.bp[item] then
				return
			end

			if items[data.bp[item][1]].equip then 
				local itemObj = data.bp[item]
				table.remove(data.bp,item)
				local itemType = items[itemObj[1]]
				--print(data.equip[itemType.equip])
				if data.equip[itemType.equip] ~= 0 then
					local old = data.equip[itemType.equip]

					
					data.bp[#data.bp+1] = old
				end
				data.equip[itemType.equip] = itemObj 

				deploy_answerCallbackQuery(msg.id, "Equiped\n"..renderSet(data), "true")
			else 
				deploy_answerCallbackQuery(msg.id, "This is not a equipable item : "..data.bp[item][1], "true")
				return
			end
			 
			

			local kb, str = renderEquipButtons(data, msg.from.username)
			--deploy_editMessageReplyMarkup(msg.message.chat.id, msg.message.message_id, msg.inline_message_id, kb)
			bot.editMessageText(msg.message.chat.id, msg.message.message_id, msg.id, renderSet(data).."\nEquipaments:\n".. str, "HTML", nil, kb)
		else
			deploy_answerCallbackQuery(msg.id, "Too fast. wait.")
		end
	else
		deploy_answerCallbackQuery(msg.id, "You dont have a RPG character. use /rpgstart", "true")
	end
	SaveUser(msg.from.username)
end



function renderEquipButtons(data, uname)
	local keyb = {}
	keyb[1] = {}
	local cnt = 0
	local height = 1

	local equip = ""
	local itemN = 0
	for i=1,#data.bp do
		
		if items[data.bp[i][1]].equip then 
			cnt = cnt +1
			if cnt > 2 then 
				height = height +1
				cnt = 1
				keyb[height] = {}
			end
			itemN = itemN +1
			equip = equip .."<b>"..itemN..". </b>" .. items[data.bp[i][1]].name.." - <i>"..whereTextEquip(items[data.bp[i][1]].equip)..' '..(items[data.bp[i][1]].desc or items[data.bp[i][1]].genDesc(data.bp[i])).."</i>\n"
			keyb[height][cnt] = {text = itemN..". "..items[data.bp[i][1]].name..(items[data.bp[i][1]].desc or items[data.bp[i][1]].genDesc(data.bp[i])), callback_data = "eq:"..uname..":"..i }

		end
		
	end
	keyb[height+1] = {}
	keyb[height+1][1] = {text = "❌Close❌", callback_data = "bp:"..uname..":0" }
	local JSON = require("JSON")
	local kb = JSON:encode({inline_keyboard = keyb})
	return kb, (equip:len() > 0 and ("Equipaments (/rpgequip + /rpgcraft): \n"..equip) or "You dont have any equipments")
end

function string:makeItCute()
	self = self:gsub("%[","[<b>")
	self = self:gsub("%]","</b>]")
	return self
end


function rpgEquips(msg)
	local data = getUserRpg(msg.from.username)
	if not data then 
		wut = say("Sorry, you dont have a rpg character. use /rpgstart to join")
		return
	else
		if type(data.bp) == "string" then
			data.bp = {}
		end
		if msg.chat.type ~= "private" then 
			reply_delete("Use your backpack in the private chat with me.")
			return
		end
		writeLog(data, "asked for equips")
		local kb,str = renderEquipButtons(data, msg.from.username)
		local wut = bot.sendMessage(msg.chat.id, renderSet(data):makeItCute().."\nEquipaments:\n"..str.."\n\nCraft itens with /rpgcraft", "HTML", true, false, nil, kb)
		if msg.chat.type ~= "private" then 
			scheduleEvent(20, function()
				if wut and wut.ok then
					deploy_deleteMessage(wut.result.chat.id,wut.result.message_id)
				end
			end)
		end
	end
end



function findItem(data, id)
	for i,b in pairs(data.bp) do 
		if b[1] == id then 
			return b, i
		end
	end
	return nil
end



function renderMisteryButtons(chest)
	local keyb = {}
	for i=1,#chest.happen do
		keyb[i] = {}
		local cnt = 0 
		for a,c in pairs(chest.used) do 
			if c == i then 
				cnt = cnt +1
			end
		end
		keyb[i][1] = {text = "Option "..i.." has "..cnt.." uses", callback_data = "rpg:mb:"..i..":"..chest.id }
	end

	local JSON = require("JSON")
	local kb = JSON:encode({inline_keyboard = keyb})
	return kb
end
if not mistery then 
	mistery = {}
end

function bonusess()
	local bon = nil

	local n = math.random(1,15)
	if n == 1 then 
		bon = {
			msg = "You won 150% of your total gold.",
			f=function (a)
				addGold(a, a.g * 1.5)
			end
		}
	elseif n == 2 then 
		bon = {
			msg = "You lost 30% of your total gold.",
			f=function (a)
				addGold(a, -a.g * 0.3)
			end
		}
	elseif n == 3 then 
		bon = {
			msg = "No you have a coldown on /rploot of 2 hours",
			f=function (a)
				a.loot = os.time() + 3600 * 2
			end
		}
	elseif n == 4 then 
		bon = {
			msg = "You lost a random item on your backpac.",
			f=function (a)
				randomDelete(a)
			end
		}
	elseif n == 5 then 
		bon = {
			msg = "You found two 📦",
			f=function (a)
				addItem(a, 47, 2) 
			end
		}
	elseif n == 6 then 
		bon = {
			msg = "You lost one level.\n\nJust kidding. Nothing happened.",
			f=function (a)
			end
		}
	elseif n == 7 then 
		bon = {
			msg = "You lost exp like you lost a battle!",
			f=function (a)
				local drain = math.floor( (getExpToLevel(a.lvl+1)-getExpToLevel(a.lvl))*0.1 )

				local expected = drain 	

				local noLess = getExpToLevel(a.lvl)
				if a.exp-drain < noLess then 
					drain = a.exp-noLess
				end
				drain = math.max(drain, 0)
				loseExp(a, drain)
			end
		}
	elseif n == 8 then 
		bon = {
			msg = "You won TWICE of the equivalent EXP you would lose if you lost.",
			f=function (a)
				local drain = math.floor( (getExpToLevel(a.lvl+1)-getExpToLevel(a.lvl))*0.1 )

				local expected = drain 	

				local noLess = getExpToLevel(a.lvl)
				if a.exp-drain < noLess then 
					drain = a.exp-noLess
				end
				drain = math.max(drain, 0)
				gainExp(a, drain * 2)
			end
		}
	elseif n == 9 then 
		bon = {
			msg = "You found "..formatMoney(3333),
			f=function (a)
				a.g = a.g + 3333
			end
		}
	elseif n == 10 then 
		bon = {
			msg = "Congrats. Nothing.",
			f=function (a)
			end
		}
	elseif n == 11 then 
		bon = {
			msg = "You found 5x🍺 5x🥃 5x🍷. Time to craft!",
			f=function (a)
				addItem(a, 5, 5) 
				addItem(a, 6, 5) 
				addItem(a, 19, 5) 
			end
		}
	elseif n == 12 then 
		bon = {
			msg = "You "..formatMoney(),
			f=function (a)
				addGold(a, 1000) 
			end
		}
	elseif n == 13 then 
		bon = {
			msg = "Nice. 500 xp!",
			f=function (a)
				gainExp(a, 500)
			end
		}
	elseif n == 14 then 
		bon = {
			msg = "Your rpgloot now have bonuses!",
			f=function (a)
				a.loot = os.time() - 3600 * 24 * 50
			end
		}
	elseif n == 15 then 
		bon = {
			msg = "You found 3 🍾",
			f=function (a)
				addItem(a, 60, 3) 
			end
		}
	end

	return bon
end
function spawnMisteryBox(msg)

	local chest = {uses = 0, used={}, type="mistery", happen = {
		bonusess(),
		bonusess(),
		bonusess(),
		bonusess(),

	}}
	mistery[os.time()] = chest
	mistery[os.time()].id = os.time()

	local kb = renderMisteryButtons(chest)


	local wut = bot.sendPhoto(msg.chat.id, 'mystery-box.jpg', "Four boxes appeared!\nYou can open only one!\nThe effects can be good or bad.", false, nil, kb, "HTML")

	chest.msg = wut
end





function processMisteryBox(msg, data, id, mbid)
	mbid = tonumber(mbid)
	id = tonumber(id)
	if not mistery[mbid] then 
		deploy_answerCallbackQuery(msg.id, "Those boxes dont exist anymore :/")
		return
	end
	local mist =  mistery[mbid]
	if not mist.used[msg.from.id] then
		mist.used[msg.from.id] = id
		mist.uses = mist.uses +1 
		deploy_answerCallbackQuery(msg.id, mist.happen[id].msg or "???", "true")

		mist.happen[id].f(data)

		deploy_sendMessage(msg.from.id, mist.happen[id].msg or "??") 

		local kb = renderMisteryButtons(mist)

		deploy_editMessageReplyMarkup(msg.message.chat.id, msg.message.message_id, msg.inline_message_id, kb)
	else 
		deploy_answerCallbackQuery(msg.id, "You cant use it again!")
	end
end

function processRpgCall(msg)
	local data = getUserRpg(msg.from.username)
	if data then
		updateHealthByTicks(data)
		local call = msg.data:match("rpg:(.+)")

		if call:match("mb:(%d+):(%d+)") then 
			processMisteryBox(msg, data, call:match("mb:(%d+):(%d+)"))
			return
		elseif call:match("pool:(%d+):(%d+)") then 
			processManaPool(msg, data, call:match("pool:(%d+):(%d+)"))
			return
		elseif call:match("drop:(.-):(.-):(%d+)") then
			local tgt, uname, id =  call:match("drop:(.-):(.-):(%d+)")
			id = tonumber(id)
			deploy_answerCallbackQuery(msg.id, "Ok -> "..tgt) 
			confirmDrop(msg, data, id, tgt)
			return
		elseif call:match("dropconfirm:(.-):(%d+):(%d+)") then
			local tgt, id, amount =  call:match("dropconfirm:(.-):(%d+):(%d+)")

			id = tonumber(id)
			amount = tonumber(amount)
			doDrop(msg, data, id, amount, tgt)
			return
		elseif call:match("dropclaim:(%d+)") then
			local id =  call:match("dropclaim:(%d+)")
			id = tonumber(id)
			doDropClaim(msg, data, id)
			return
		elseif call:match("equippls") then
			swapToSellEquips(msg, data)
			return
		elseif call:match("itempls") then
			swapToSellRegular(msg, data)
			return
		else 
			deploy_answerCallbackQuery(msg.id, "Unknow: "..msg.data, "true")
		end
	else
		deploy_answerCallbackQuery(msg.id, "Você nao participa do rpg", "true")
	end
end

function doDropClaim(msg, data, dropid)
	if not rpg_dropped_items[dropid] then 
		deploy_answerCallbackQuery(msg.id, "Already claimed.", "true")
		--deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
		return 
	end

	local uid = addItem(data, rpg_dropped_items[dropid][1], rpg_dropped_items[dropid][2])
	if  rpg_dropped_items[dropid].attr then 
		uid.attr =  rpg_dropped_items[dropid].attr
		uid.slots =  rpg_dropped_items[dropid].slots
	end
	rpg_dropped_items[dropid].attr = nil
	rpg_dropped_items[dropid].slots = nil
	deploy_answerCallbackQuery(msg.id, "You claimed it!", "true")
	bot.editMessageText(msg.message.chat.id, msg.message.message_id, msg.id, "User @"..msg.from.username.." claimed "..rpg_dropped_items[dropid][2].."x "..renderItem(uid), "HTML", nil)
	--deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
	SaveUser(msg.from.username)
end



function doDrop(msg, data, id, amount, tgt)
	local it = data.bp[id]
	local tgtid = RPGCHAT
	if tgt ~= msg.from.username then
		if not users[tgt] or not users[tgt].telegramid then 
			deploy_answerCallbackQuery(msg.id, "Unknow: user @"..tgt, "true")
			return 
		else 
			tgtid = users[tgt].telegramid
			deploy_answerCallbackQuery(msg.id, "Dropped "..renderItem(it).." to @"..tgt, "true")
		end
	else 
		deploy_answerCallbackQuery(msg.id, "Dropped "..renderItem(it), "true")
	end

	if not it then 
		deploy_answerCallbackQuery(msg.id, "Missing item", "true")
		return
	end

	local dropid = os.time()
	if it[2] <= amount then 
		amount = it[2]
		table.remove(data.bp, id)
		rpg_dropped_items[dropid] = it
	else 
		it[2] = it[2] - amount
		rpg_dropped_items[dropid] = {it[1], amount}
	end	

	if tgtid == RPGCHAT then 
		checkQuestInner(data, msg.from.username, msg, "rpgdrop")
	end

	deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
	
	displayDroppedItem(tgtid, rpg_dropped_items[dropid], msg.from.username, dropid)

	SaveUser(msg.from.username)
end

function displayDroppedItem(chatid, itemObject, who, id)
	local keyb = {{},{}}
	keyb[1][1] = {text = "Claim item", callback_data = "rpg:dropclaim:"..id }
	local JSON = require("JSON")
	local kb = JSON:encode({inline_keyboard = keyb})

	bot.sendMessage(chatid, "User @"..who.." dropped a "..itemObject[2].."x "..renderItem(itemObject), "HTML", true, false, nil, kb)
	
end

function confirmDrop(msg, data, id, tgt)
	local it = data.bp[id]
	if not it then 
		return
	end
	if items[it[1]].equip then
		local keyb = {{},{}}
		keyb[1][1] = {text = "❌No❌", callback_data = "bp:"..msg.from.username..":0" }
		keyb[2][1] = {text = "✅Yes✅", callback_data = "rpg:dropconfirm:"..tgt..":"..id..":1" }
		local JSON = require("JSON")
		local kb = JSON:encode({inline_keyboard = keyb})
		bot.editMessageText(msg.message.chat.id, msg.message.message_id, msg.id, "Are you sure you want to drop? "..renderItem(data.bp[id]), "HTML", nil, kb)
	else
		local keyb = {{}, {}}
		keyb[1][1] = {text = "❌No❌", callback_data = "bp:"..msg.from.username..":0" }
		keyb[2][1] = {text = "1x", callback_data = "rpg:dropconfirm:"..tgt..":"..id..":1" }
		for i=1,10 do 
			if i*5 <= it[2] then 
				keyb[i+2] =  {{text = (i*5).."x", callback_data = "rpg:dropconfirm:"..tgt..":"..id..":"..(i*5) }}
			end
		end
		local JSON = require("JSON")
		local kb = JSON:encode({inline_keyboard = keyb})
		bot.editMessageText(msg.message.chat.id, msg.message.message_id, msg.id, "How much you want to drop of "..renderItem(data.bp[id]), "HTML", nil, kb)
	end
end

 
function processChangeCraft(msg)
	local user, item = msg.data:match("cfm:(.-):(%d+)")
	if msg.from.username:lower() ~=user then 
		deploy_answerCallbackQuery(msg.id, "This is not your backpack", "true")
		return
	end
	item = tonumber(item)
	if item == 0 then
		deploy_answerCallbackQuery(msg.id, "Closing backpack")
		deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
		return
	end
	local data = getUserRpg(msg.from.username)
	if data then
		if not items.used[msg.message.message_id] then
			items.used[msg.message.message_id] = true
			scheduleEvent(0, function()
				items.used[msg.message.message_id] = false
			end)
			
			if not data.bp[item] then
				return
			end

			if items[data.bp[item][1]].craft then 
				data.us = data.bp[item][1]
				local kb, str = renderCraftOptions(data, msg.from.username, data.us)
				deploy_answerCallbackQuery(msg.id, "Now you are using "..items[data.bp[item][1]].name, "true")
				--scheduleEvent(1, function()
					--deploy_editMessageReplyMarkup(msg.message.chat.id, msg.message.message_id, msg.inline_message_id, kb)
					bot.editMessageText(msg.message.chat.id, msg.message.message_id, msg.id, str.."\n\n<b>Your set:</b>\n"..renderSet(data):makeItCute().."\n\nChange itens with /rpgequip", "HTML", nil, kb)
				--end)

				
			else 
				deploy_answerCallbackQuery(msg.id, "This is not a crafting item.", "true")
			end
		else 
			deploy_answerCallbackQuery(msg.id, "Too fast. wait.")
		end
	else
		deploy_answerCallbackQuery(msg.id, "Você nao participa do rpg", "true")
	end
	SaveUser(msg.from.username)
end

--[[function renderCraftItens()
	local keyb = {}
	keyb[1] = {}
	local cnt = 0
	local height = 1

	local equip = ""
	local fnd = ""
	for i=1,#data.bp do
		if items[data.bp[i][1] ].craft then 
			
			cnt = cnt +1
			if cnt > 2 then 
				height = height +1
				cnt = 1
				keyb[height] = {}
			end
			--print("add")
			fnd = fnd .. items[data.bp[i][1] ].name
			keyb[height][cnt] = {text = items[data.bp[i][1] ].name..(items[data.bp[i][1] ].desc or items[data.bp[i][1] ].genDesc(data.bp[i])), callback_data = "cfm:"..uname..":"..i }
		end
	end
	keyb[height+1] = {}
	keyb[height+1][1] = {text = "❌Close❌", callback_data = "bp:"..uname..":0" }
	local JSON = require("JSON")
	local kb = JSON:encode({inline_keyboard = keyb})
	return kb, (equip:len() > 0 and ("Equipaments (/rpgequip): \n"..equip) or "You dont have any equipments").."\n"..fnd

end]]

function renderCraftOptions(data, uname, w)
	local keyb = {}
	keyb[1] = {}
	local cnt = 0
	local height = 1

	local equip = ""
	height  = height +1
	keyb[height] = {}
	local cntr = 1

	local found, where = findItem(data, 6)
	if found  then
		keyb[height][1] = {text = tostring(found[2]).."x 🥃 add random modifier", callback_data = "cfm:"..where..":"..w }
		height = height +1
		keyb[height] = {}
	end

	found, where = findItem(data, 19)
	if found then
		keyb[height][1] = {text = tostring(found[2]).."x🍷 reroll all", callback_data = "cfm:"..where..":"..w }
		height = height +1
		keyb[height] = {}
	end 

	found, where = findItem(data, 5)
	if found then

		keyb[height][1] = {text = tostring(found[2]).."x🍺 remove random modifier", callback_data = "cfm:"..where..":"..w }
		height = height +1
		keyb[height] = {}
	end

	found, where = findItem(data, 60)
	if found then

		keyb[height][1] = {text = tostring(found[2]).."x🍾 add modifier with luck", callback_data = "cfm:"..where..":"..w }
		height = height +1
		keyb[height] = {}
	end

	found, where = findItem(data, 61)
	if found then

		keyb[height][1] = {text = tostring(found[2]).."x🍵 Modify slot count", callback_data = "cfm:"..where..":"..w }
		height = height +1
		keyb[height] = {}
	end

	
	keyb[height][1] = {text = "↩️Go back↩️", callback_data = "bcarpgkplz" }

	keyb[height+1] = {}
	keyb[height+1][1] = {text = "❌Close❌", callback_data = "bp:"..uname..":0" }


	local JSON = require("JSON")
	local kb = JSON:encode({inline_keyboard = keyb})
	local left = 0
	for i,b in pairs(data.bp) do 
		if b[1] == w then 
			left = left + b[2]
		end
	end
	return kb, ""
end

--User has selectd the item to be crafted
function processSelectedCraftableItem(msg)
	local user, slot = msg.data:match("cfti:(.-):(%d+)")
	if msg.from.username:lower() ~=user then 
		deploy_answerCallbackQuery(msg.id, "This is not your backpack", "true")
		return
	end
	slot = tonumber(slot)
	if item == 0 then
		deploy_answerCallbackQuery(msg.id, "Closing backpack")
		deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
		return
	end
	local data = getUserRpg(msg.from.username)
	if data then
		local kb = renderCraftOptions(data, msg.from.username, slot)
		bot.editMessageText(msg.message.chat.id, msg.message.message_id, msg.id, "You are crafting\n\n".. renderSlotItem(data, slot), "HTML", nil, kb)
	else
		deploy_answerCallbackQuery(msg.id, "Você nao participa do rpg", "true")
	end
	SaveUser(msg.from.username)
end



function processCraft(msg)
	local backpackItem, slotItem = msg.data:match("cfm:(%d+):(%d+)")

	backpackItem = tonumber(backpackItem)
	slotItem = tonumber(slotItem)
	
	local data = getUserRpg(msg.from.username)
	if data then
		if item == 0 or backpackItem == 0 then
			
			deploy_answerCallbackQuery(msg.id, "Choose!", "true")

			--local kb,str = renderCraftTypes(data, msg.from.username)
			--bot.sendMessage(msg.chat.id, renderSet(data).."\nItens:\n"..str, "HTML", true, false, nil, kb)


			--bot.editMessageText(msg.message.chat.id, msg.message.message_id, msg.id, renderSet(data):makeItCute().."\nItens:\n"..str, "HTML", nil, kb)
			return
		end
		if not items.used[msg.message.message_id] then
			items.used[msg.message.message_id] = true
			scheduleEvent(0, function()
				items.used[msg.message.message_id] = false
			end)
			
			if not data.equip[slotItem] or data.equip[slotItem] == 0 then
				deploy_answerCallbackQuery(msg.id, "You need a item on this slot", "true")
				return
			end

			local craftMaterial = data.bp[backpackItem]

			if craftMaterial then 
				
				if not items[craftMaterial[1]].craft then 
					deploy_answerCallbackQuery(msg.id, "??????? "..items[craftMaterial[1]].name, "true")
					return
				end
				
				local ret, str2 = items[craftMaterial[1]].craft(data.equip[slotItem])
				if not ret then 
					deploy_answerCallbackQuery(msg.id, str2, "true")
					return
				end

				craftMaterial[2] = craftMaterial[2] - 1
		
				if craftMaterial[2] == 0 then 
					table.remove(data.bp, backpackItem)
				end


				deploy_answerCallbackQuery(msg.id, "Used one "..items[craftMaterial[1]].name.."\n"..str2, "true")


				local kb = renderCraftOptions(data, msg.from.username, slotItem)
				bot.editMessageText(msg.message.chat.id, msg.message.message_id, msg.id, "--------------------------------------------\nYou are crafting\n\n".. renderSlotItem(data, slotItem), "HTML", nil, kb)
				
			else 
				deploy_answerCallbackQuery(msg.id, "You dont have enought ", "true")
			end
			--deploy_answerCallbackQuery(msg.id, "uwused"..backpackItem..":"..slotItem, "true")
		else 
			deploy_answerCallbackQuery(msg.id, "Too fast. wait.")
		end
	else
		deploy_answerCallbackQuery(msg.id, "Você nao participa do rpg", "true")
	end
	SaveUser(msg.from.username)
end


-- the /rpgcraft
function renderRpgCraft(msg, edit)
	local data = getUserRpg(msg.from.username)
	if not data then 
		say("Sorry, you dont have a rpg character. use /rpgstart to join")
		return
	else
		if type(data.bp) == "string" then
			data.bp = {}
		end
		if msg.chat and msg.chat.type ~= "private" then 
			reply_delete("Use your crafting in the private chat with me.")
			return
		end

		writeLog(data, "used craft")
		local kb,str = renderCraftableItens(data, msg.from.username)
		if edit then 
			bot.editMessageText(msg.message.chat.id, msg.message.message_id, msg.id, "First equipe some itens, then craft the equipped itens.\nChange itens with /rpgequip\n\n<b>with some itens equiped, select wich item you want to craft</b>", "HTML", nil, kb)
		else 
			bot.sendMessage(msg.chat.id,"First equipe some itens, then craft the equipped itens.\nChange itens with /rpgequip\n\n<b>with some itens equiped, select wich item you want to craft</b>", "HTML", true, false, nil, kb)
		end
		

	end
end



function renderCraftableItens(data, uname)
	--Should send only the items
	local keyb = {}
	keyb[1] = {}
	local cnt = 0
	local height = 1

	local equip = ""
	for i=SLOT_FIRST, SLOT_LAST do
		cnt = cnt +1
		if cnt > 1 then 
			height = height +1
			cnt = 1
			keyb[height] = {}
		end
		keyb[height][cnt] = {text = whereTextEquip(i)..(data.equip[i] ~= 0 and items[data.equip[i][1]].name or "[nothing]").." "..(data.equip[i] ~= 0 and (items[data.equip[i][1]].desc or items[data.equip[i][1]].genDesc(data.equip[i])) or ""), callback_data = "cfti:"..uname..":"..i }
	end

	height  = height +1
	keyb[height] = {}
	 
	height = height +1
	

	keyb[height] = {}
	keyb[height][1] = {text = "❌Close❌", callback_data = "bp:"..uname..":0" }

	local JSON = require("JSON")
	local kb = JSON:encode({inline_keyboard = keyb})

	return kb, "<bSelect a item to be crafted</b>"

end



if not stock then
	stock = {}
end

local exchangeRate = 0.25

function rpgLoad()
	stock = configs["storestock"] or {[14]=1, [1] = 255, [2] = 255, [3] = 255, [4] = 20, [5] = 100, [6] = 100, [7] = 20, [8] = 90, [9] = 100, [17] = 0, [16] = 8, [15] = 8, [10] = 8, [11]=8,  [19] = 100, [60] = 10 , [61] = 200,[62] = 5 }
	print("Loaded RPG!")
end

if not chests then 
	chests = {}
end

function makeChest(v)
	local chest = {}

	chest.max = math.random(10,20)
	local given = {}
	chest.count = 0

	chest.reward = {exp=math.random(100,500), money=math.random(0,3000) }
	for i=1,math.random(3,6) do 
		local id = droppable[math.random(1, #droppable)]
		if not given[id] and (not v or (v and id ~= 62 and id ~= 4 and id ~= 17)) then 
			given[id] = 1
			chest.reward[#chest.reward+1] = {id,math.random(1,6)}
		end
	end
	if math.random(0, 1000) <= 100 then 
		chest.reward[#chest.reward+1] = {47, 1}
	end
	return chest
end

function processChestUse(msg)
	local chest = msg.data:match("chest:(%d+)")

	chest = tonumber(chest)
	if chest == 0 or not chests[chest] or chests[chest].count >= chests[chest].max then
		print("CHEST IS DEAD", item)
		print("CHEST IS DEAD", Dump(chests[chest] or {}))
		deploy_answerCallbackQuery(msg.id, "The chest is empty")
		deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
		return
	end

	local data = getUserRpg(msg.from.username)
	if data then
		
		if not chests[chest][msg.from.username] or (tonumber(chests[chest][msg.from.username]) and chests[chest][msg.from.username] <= os.time()) then
			chests[chest][msg.from.username] = os.time() + 600 * 2

			writeLog(data, "chest "..chest)

			chests[chest].count = chests[chest].count + 1

			local contains = formatReward2(chests[chest].reward)
			giveReward(data, chests[chest].reward, "You found in the chest:\n")

			deploy_answerCallbackQuery(msg.id, contains)

			if chests[chest].count >= chests[chest].max then 
				print("Chest is dead because "..chests[chest].count)
				deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
				return
			end

			local kb = renderChestButtons(chests[chest])
			print("chesty to ", msg.from.username)
			deploy_editMessageReplyMarkup(msg.message.chat.id, msg.message.message_id, msg.inline_message_id, kb)
		else
			print("uuh no", msg.from.username)
			deploy_answerCallbackQuery(msg.id, "You have to wait more "..(chests[chest][msg.from.username] - os.time()).." seconds to loot again!" )
		end
	else
		print("No chest to ", msg.from.username)
		deploy_answerCallbackQuery(msg.id, "You dont have a RPG character. Use /rpgstart ", "true")
	end
	SaveUser(msg.from.username)
end

function renderManaButtons(chest)
	local keyb = {{},{},{},{}}
	keyb[1][1] = {text = "Add 1 mana", callback_data = "rpg:pool:1:"..chest.id }
	keyb[2][1] = {text = "Add 5 mana", callback_data = "rpg:pool:5:"..chest.id }
	keyb[3][1] = {text = "Add 10 mana", callback_data = "rpg:pool:10:"..chest.id }
	keyb[4][1] = {text = "Add All mana", callback_data = "rpg:pool:0:"..chest.id }
		

	local JSON = require("JSON")
	local kb = JSON:encode({inline_keyboard = keyb})
	return kb
end

function spawnManaPool(uname)

	local chest = {
		type="mana",
		mana = 0,
		max = math.random(200,300),
		spawn=uname,
		used={}
	}
	mistery[os.time()] = chest
	mistery[os.time()].id = os.time()

	local kb = renderManaButtons(chest)
	--
	local wut = bot.sendPhoto(RPGCHAT, 'mana-pool.jpg', "A mana pool its here.\n"..(uname and ("It was summoned by @"..uname.."") or "").."\nYou can add mana to to be appleased upon its completion!\n\n<b>Mana: 0/"..chest.max.."</b>", false, nil, kb, "HTML")
	if wut.result and wut.result.message_id then
		bot.pinChatMessage(RPGCHAT, wut.result.message_id)
	end
	chest.msg = wut
end

function processManaPool(msg, data, value, mbid)
	mbid = tonumber(mbid)
	value = tonumber(value)
	if not mistery[mbid] then 
		deploy_answerCallbackQuery(msg.id, "This manapool dont exist anymore!")
		return
	end
	if value == 0 then 
		value = math.max(1,data.mana)
	end

	if data.mana < value then 
		deploy_answerCallbackQuery(msg.id, "You dont have enought mana!\nYou only have "..data.mana.."/"..getManaMax(data), "true")
		return
	end
	local pool =  mistery[mbid]
	if not pool.used[msg.from.username] then 
		pool.used[msg.from.username] = 0
	end


	pool.used[msg.from.username] = pool.used[msg.from.username] + value

	pool.mana = pool.mana + value
	spentMana(data, value)

	local kb = renderManaButtons(pool)
	deploy_answerCallbackQuery(msg.id, "Added "..value.." mana!\nNow you have "..data.mana.."/"..getManaMax(data), "true")

	bot.editMessageCaption(msg.message.chat.id, msg.message.message_id, msg.inline_message_id, "A mana pool its here.\n"..(pool.spawn and ("It was summoned by @"..pool.spawn.."") or "").."\nYou can add mana to to be appleased upon its completion!\n\n<b>Mana: "..pool.mana.."/"..pool.max.."</b>\n\nID: "..mbid, kb, "HTML")


	if mistery[mbid].mana >= mistery[mbid].max then
		local total = mistery[mbid].max
		local exp = 900 + total * 2
		if pool.msg and pool.msg.result and pool.msg.result.message_id then
			for i,b in pairs(pool.used) do
				local data2 = getUserRpg(msg.from.username)
				if data2 then
					local helped = b/total 

					gainExp(data2, helped* exp)
					bot.sendMessage(users[i].telegramid, 'The mana pool you helped became a chest!\nAs you helped to fill '..string.format("%2.2f%%", helped* 100)..' of it, you won '..string.format("%d",exp*helped)..' exp!\n<a href="https://t.me/telerpg/'..pool.msg.result.message_id..'">[Go to message]</a>', "HTML")
				end
			end
		end
		--local prize = math.random(0, 1) 
		--if prize == 1 then
		mistery[mbid] = nil
		local chest = makeChest(true)
		chests[os.time()] = chest
		chests[os.time()].id = os.time()

		local kb = renderChestButtons(chest)
		bot.editMessageCaption(msg.message.chat.id, msg.message.message_id, msg.inline_message_id, "This mana pool became a chest containing "..formatReward2(chests[os.time()].reward), kb, "HTML")

		bot.pinChatMessage(msg.message.chat.id, msg.message.message_id)
	end
end

function spentMana(data, amount)
	data.mana = data.mana - amount
end

function renderChestButtons(chest)
	local keyb = {{}}
	keyb[1] = {}
	keyb[1][1] = {text = "Open chest ["..chest.count.."/"..chest.max.."]", callback_data = "chest:"..chest.id }
		

	local JSON = require("JSON")
	local kb = JSON:encode({inline_keyboard = keyb})
	return kb
end
function renderChest(msg)
	local data = getUserRpg(msg.from.username)
	if data then
		local chest = makeChest()
		chests[os.time()] = chest
		chests[os.time()].id = os.time()

		local kb = renderChestButtons(chest)


		local wut = bot.sendPhoto(msg.chat.id, 'shest.jpg', "A chest appeared containing "..formatReward2(chests[os.time()].reward).."!", false, nil, kb, "HTML")

		if msg.chat.type ~= "private" then 
			--[[scheduleEvent(30, function()
				if wut and wut.ok then
					bot.deleteMessage(wut.result.chat.id,wut.result.message_id)
				end
			end)]]
		end
	else 
		say("Sorry, you dont have a rpg character. use /rpgstart to join")
	end
end


if not monsters then
	print("MADE NEW MONS")
	monsters = {}
else 
	print("JUST RELOAD")
end

function rpgSave()
	configs["storestock"] = stock
	saveConfig("storestock")
end

function bernoulli(p)
	local n = 0
	for i=1,10 do 
		if math.random(0,100) < p then 
			n = n +1
		else
			break
		end
	end
end



function getRpgHelp()
	return [[<u>Welcome to Burrbot's RPG system!</u>
<b>(THIS IS A BETA)</b>
The system is super simple. You join it using /rpgstart and that's it!
From then on, any message sent by you in a chat the bot is in will award you some XP. 

With the RPG, each time you say something you may get some XP.
Note that spamming messages will make your XP goes down. You level up using text messages, <b>but overusing means losing exp</b>.
You can also hunt for loot and money using <b>/rpgloot</b>!

Okay, now you have some XP and loot, right? Eventually you will level up and can choose to add some stats:
•HP (Health, duh)
•Attack (Deals more damage)
•Defense (Reduces damage taken and can reflect damage)
•Agility (Increase changes of crit, evasion, accuracy)
You can check your stats, XP and such using <b>/rpgstats</b>

These stats can be used to fight another players!
You can go in a chat and use <b>/battle</b> and the next person who clicks is gonna battle against you.
Or you can go in private chat with me, and say <b>/battle @username</b> to challange someone.

The winner steal some EXP and Money from the loser... Now, its possible that you are in a low HP.

HP lost will regenerate 1 point per 20 seconds. But you can use some itens to heal!
Your mana regenerate at 1 every 10 minutes.
Use those itens using the command <b>/rpgbackpack</b>. 

Ran out of itens? Buy/Sell some using <b>/rpgbuy</b> and <b>/rpgsell</b>

Top players can be seen with <b>/rpgtop</b> and local top players can be seen using <b>/rpgtopbychat</b>

There is a mode that helps playing, just use <b>/rpgmode</b> and use the custom keyboard.

Once a day you can get a quest with /rpgquest

<i>The messages are auto deleted in chats.</i>

Official group: @telerpg
Creator: @Mockthebear

That's all :D

Liked this rpg? Consider using <b>/donate</b>
]]
end

function addGold(data, g)
	local old = data.g
	data.g = data.g +g
	data.g = math.ceil(data.g)
	writeLog(data, "change gold from "..old.." to "..data.g.." ("..g..")")
end
function startRpg(msg)
	if users[msg.from.username].rpg then 
		deploy_sendMessage(msg.chat.id, "You already have a rpg profile")
		return
	end
	if not users[msg.from.username].telegramid then 
		deploy_sendMessage(msg.chat.id, "You need to go on private with me")
		return
	end

	local msge = bot.sendMessage(users[msg.from.username].telegramid, "RPG profile started.")
	if not msge.ok then 
		users[msg.from.username].telegramid = msg.from.id
		msge = bot.sendMessage(users[msg.from.username].telegramid, "trying again...")
		if not msge.ok then
			bot.sendMessage(msg.chat.id, "Try again sending on pvt my private, i need permission to send you a message.")
			return
		end
	end

	deploy_sendMessage(users[msg.from.username].telegramid, getRpgHelp(), "HTML")

	if users[msg.from.username].rpg_old then 
		users[msg.from.username].rpg = users[msg.from.username].rpg_old
		showStats(msg, who)
		return
	end

	users[msg.from.username].rpg = blankStats()
	users[msg.from.username].rpg.t = os.time()
	users[msg.from.username].rpg.id = msg.from.id
	users[msg.from.username].rpg.beta = users[msg.from.username].medal
	users[msg.from.username].rpg.bp={ 
		{1, 10}, {2, 8}, {3, 3}, {9,1}, {math.random(5,6),2}, {choose(17,16,15,10,11),1} 
	}
	
	showStats(msg, who)
end


function blankStats()
	return {
		exp=1,
		lvl=1,
		m=0, -- between talk coldown
		a=5,--Attack
		d=5, --defense
		e=1, --evasion
		h=20, --Health var
		g=10, --gold
		s = 0, --stat points
		v = 20, -- vitality (base health)
		ki=0, de=0, --Kills death

		ea = 0,
		ed = 0,
		ee = 0,
		ev = 0,

		pa = 1,
		pd = 1,
		pe = 1,
		pv = 1,

		bm_dif=true, 		--Dont battle level diff again
		bm_rep=false,		--Dont repeat the same person within 5 mins
		bm_norep=false,

		bid = 0,			--battle message id
		bch = 0,			--battle chat id

		
		equip={[SLOT_HELMET]=0,[SLOT_ARMOR]=0,[SLOT_WEAPON]=0,[SLOT_LEGS]=0,[SLOT_BOOTS]=0,[SLOT_RING]=0, [SLOT_NECKLACE] = 0 }

	} 
end

function addEquips()
	for i,b in pairs(users) do 
		if b.rpg  then 
			b.rpg.equip={[SLOT_HELMET]=0,[SLOT_ARMOR]=0,[SLOT_WEAPON]=0,[SLOT_LEGS]=0,[SLOT_BOOTS]=0,[SLOT_RING]=0, [SLOT_NECKLACE] = 0 }
			for _,it in pairs(b.rpg.bp) do
       	 		if it[1] >= 19 then 
          			it[1] =1
				end
			end
			SaveUser(i)
	    end
	end
end

function resetRpg(data)
	local new = blankStats()

	local sav = {
		exp=0,
		ea=0,
		ed=0,
		ee=0,
		ev=0,
		pa=1,
		pd=1,
		pe=1,
		pv=1,
		ki=0, 
		de=0,
		g=0,
		m=0,

	}
	local olBP = data.bp 
	local olEquip = data.equip

	for i,b in pairs(sav) do 
		sav[i] = data[i] or sav[i]
	end

	for i,b in pairs(new) do 
		data[i] = b
	end

	for i,b in pairs(sav) do 
		data[i] = sav[i]
	end
	local xp = data.exp
	data.exp = 0
	data.lvl = 1

	gainExp(data, xp, true, "new character" )

	data.bp = olBP
	data.equip = olEquip
end

function addItem(data, id, amount) 
	amount = math.floor(amount)

	local added = false
	if type(data.bp) == "string" then
		data.bp = {}
	end
	if items[id].stack then
		for i,b in pairs(data.bp) do 
			if b[1] == id then 
				b[2] = b[2] +amount
				added = b

				break
			end
		end
	end
	if not added then 
		data.bp[#data.bp+1] = {id, amount}
		if items[id].equip then 
			local canAdd = {}

			data.bp[#data.bp].slots = makeSlots(id) or 2
			data.bp[#data.bp].attr = {}
			for i=1, data.bp[#data.bp].slots do 
				data.bp[#data.bp].attr[i] = selectModifier()
			end
			
		end
		added = data.bp[#data.bp]
	end
	writeLog(data, "added item "..id.." total of "..amount)
	return added
end




function processNoDuel(msg)
	if not items.used[msg.message.message_id] then
		items.used[msg.message.message_id] = true
		local user2 = msg.data:match("noduel:(.+)")
		
		local a = getUserRpg(msg.from.username)
		local b = getUserRpg(user2)

		deploy_answerCallbackQuery(msg.id, "Denied")
		deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)


		deploy_sendMessage(msg.from.id, "Denied", "HTML")	
		deploy_sendMessage(users[user2].telegramid, msg.from.username.." denied your request.", "HTML")

	
	end
end

function processDuel(msg)
	if not items.used[msg.message.message_id] then
		items.used[msg.message.message_id] = true
		local user2 = msg.data:match("duel:(.+)")
		--print(user2, msg.from.username, msg.data)
		local a = getUserRpg(msg.from.username)
		local b = getUserRpg(user2)

		deploy_answerCallbackQuery(msg.id, "Fight done")
		deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)

		if not a or not b then 
			deploy_answerCallbackQuery(msg.id, "Someone dont play RPG anymore.")
			return false
		end

		a.hm = maxHealth(a)
		b.hm = maxHealth(b)
		a.h = math.min(a.h, a.hm)
		b.h = math.min(b.h, b.hm)

		a.n = msg.from.first_name
		b.n = users[user2].first_name or user2

		if a.h == 0 or b.h == 0 then 
			deploy_sendMessage(msg.from.id, "Someone dont have enought hp", "HTML")	
			deploy_sendMessage(users[user2].telegramid, "Someone dont have enought hp", "HTML")
		end

		writeLog(a, "duel a")
		writeLog(b, "duel b")

		local luta = 'Fight between <b><a href="tg://user?id='..users[user2].telegramid..'">'..(b.beta and "["..b.beta.."]" or "")..users[user2].first_name..'</a> level '..b.lvl.." ["..math.max(b.h,0).."/"..b.hm..']</b> <i>A: '..getAttack(b)..' D: '..getDefense(b)..'</i>\nVersus <b><a href="tg://user?id='..msg.from.id..'">'..(a.beta and "["..a.beta.."]" or "")..msg.from.first_name..'</a> level '..a.lvl.." ["..math.max(a.h,0).."/"..a.hm..']</b> <i>A: '..getAttack(a)..' D: '..getDefense(b)..'</i>'
		
		deploy_sendMessage(msg.from.id, luta, "HTML")	
		deploy_sendMessage(users[user2].telegramid, luta, "HTML")

		local ret,f = battle(msg.from.username, user2, msg.from.first_name, users[user2].first_name or user2)

		deploy_sendMessage(msg.from.id, ret, "HTML")	
		deploy_sendMessage(users[user2].telegramid, ret, "HTML")

		f()
		
	end
end

function getAttack(data, text)
	if text then 
		return tostring( math.floor(data.a* data.pa)..(data.ea ~= 0 and (" +"..math.floor((data.ea + (data.ta or 0)* data.pa )) ) or "")..(data.pa ~= 1 and ("*"..((data.pa-1)*100).."%") or "") )
	end
	return math.ceil( ( (data.ea + (data.ta or 0) + data.a) * data.pa + getAttributeModifier(data, ITEM_CLASS_ATTACK)) * getAttributePercent(data, ITEM_CLASS_ATTACK_MAX))
end
function getDefense(data, text)
	if text then 
		return tostring( math.floor(data.d* data.pd)..(data.ed ~= 0 and (" +"..math.floor((data.ed + (data.td or 0)* data.pd )) ) or "")..(data.pd ~= 1 and ("*"..((data.pd-1)*100).."%") or "") )
	end
	return math.ceil( ((data.ed + (data.td or 0) + data.d) * data.pd + getAttributeModifier(data, ITEM_CLASS_DEFENSE)) * getAttributePercent(data, ITEM_CLASS_DEFENSE_MAX))
end
function getEvasion(data, text)
	if text then 
		return tostring( math.floor(data.e* data.pe)..(data.ee ~= 0 and (" +"..math.floor((data.ee + (data.ta or 0)* data.pe )) ) or "")..(data.pe ~= 1 and ("*"..((data.pe-1)*100).."%") or "") )
	end
	return math.ceil( (( (data.ee or 0) + (data.te or 0) + data.e) * data.pe + getAttributeModifier(data, ITEM_CLASS_EVASION)) * getAttributePercent(data, ITEM_CLASS_EVASION_MAX) )
end
function getVitality(data, text)
	if text then 
		return tostring( math.floor(data.v* data.pv)..(data.ev ~= 0 and (" +"..math.floor((data.ev + (data.tv or 0)* data.pv )) ) or "")..(data.pv ~= 1 and ("*"..((data.pv-1)*100).."%") or "") )
	end
	return math.ceil( ((data.ev + (data.tv or 0) + data.v) * data.pv + getAttributeModifier(data, ITEM_CLASS_VITALITY)) * getAttributePercent(data, ITEM_CLASS_VITALITY_MAX))
end

function formatMoney(amount)
	if not amount then
		return ""
	end
	local diamons = math.floor(amount/10000)
	local paper = amount%10000
	if amount == 0 then 
		return "0💰" 
	end
	local coin = paper%100
	paper = math.floor(paper/100)

	return (diamons > 0 and (diamons.."💎 ") or "" )..(paper > 0 and (paper.."💵"	) or "")..(coin > 0 and (coin.."💰"	) or "")
end

function processBackpackUse(msg)
	local user, item = msg.data:match("bp:(.-):(%d+)")
	if msg.from.username:lower() ~=user then 
		deploy_answerCallbackQuery(msg.id, "This is not your backpack", "true")
		return
	end
	item = tonumber(item)
	if item == 0 then
		deploy_answerCallbackQuery(msg.id, "Closing backpack")
		deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
		return
	end
	local data = getUserRpg(msg.from.username)
	if data then
		
		if not items.used[msg.message.message_id] then
			--items.used[msg.message.message_id] = true
			--scheduleEvent(0, function()
			--	items.used[msg.message.message_id] = false
			--end)
			
			if not data.bp[item] then
				return
			end

			if data.bp[item][2] <= 0 then 
				table.remove(data.bp,item)
				return
			end

			writeLog(data, "used backpack "..item) 

			local ret, err = pcall(items[data.bp[item][1]].work,data, data.bp[item][2], msg.from.username)
			if not err[1] then 
				deploy_answerCallbackQuery(msg.id, "You cannot use because "..err[2]:format(err[3])..".")
				return
			end
			data.bp[item][2] = data.bp[item][2] - err[3]
			local nnn = items[data.bp[item][1]].name
			if data.bp[item][2] <= 0 then 
				table.remove(data.bp,item)
			end
			local mesage = "Used: "..tostring(err[3])..nnn.." -> "..err[2]..(ret and "\n\nStatus now:\n"..pullStats(data):gsub("<%l>", ""):gsub("</%l>", ""):gsub("</code>", ""):gsub("<code>", "") or "AVISA O MOCK PLZ")
			deploy_answerCallbackQuery(msg.id, mesage:sub(1,199) , "true")

			local kb = renderBackpackButtons(data, msg.from.username)
			deploy_editMessageReplyMarkup(msg.message.chat.id, msg.message.message_id, msg.inline_message_id, kb)

			--bot.deleteMessage(msg.message.chat.id, msg.message.message_id)
		else
			deploy_answerCallbackQuery(msg.id, "Too fast. wait.")
		end
	else
		deploy_answerCallbackQuery(msg.id, "Você nao participa do rpg", "true")
	end
	SaveUser(msg.from.username)
end


function rpgDrop(msg, tgt)
	local data = getUserRpg(msg.from.username)
	if data then
		if type(data.bp) == "string" then
			data.bp = {}
		end
		if msg.chat.type ~= "private" then 
			reply_delete("Use your backpack in the private chat with me.")
			return
		end
		if #data.bp == 0 then
			deploy_sendMessage(msg.chat.id, selectUsername(msg, true).."'s backpack is empty\n\n<b>Money: "..formatMoney(data.g).."</b>", "HTML")
		end
		tgt = tgt or msg.from.username
		writeLog(data, "asked for drop")
		local kb = renderBackpackButtons(data, msg.from.username, "rpg:drop:"..tgt, true)
		bot.sendMessage(msg.chat.id, "Choose a item to be dropped to @"..tgt.."!\n\nYou can drop something to a person using /rpgdrop @username", "HTML", true, false, nil, kb)
		
	else 
		say("Sorry, you dont have a rpg character. use /rpgstart to join")
	end

	
end

function buyItem(data, item)
	if data.g >= items[item].price then 

		addGold(data, -items[item].price)

		writeLog(data, "bought item item "..item.." for "..math.floor(items[item].price))
		addItem(data, item, 1)
		return true
	end
	writeLog(data, "failed to buy item "..item)
	return false
end

function sellItem(data, item)
	if type(data.bp) == "string" then
		data.bp = {}
	end
	local removed = false
	
	local b = data.bp[item]
	if not b then 
		return false
	end
	if b[2] <= 0 then 
		b[2] = 0
		return false
	end 
	b[2] = b[2] - 1
	if b[2] == 0 then 
		table.remove(data.bp, item)
	end
	removed = true
		
	
	if removed then
		addGold(data, math.floor(items[b[1]].price*exchangeRate))
		writeLog(data, "sold item "..item.." for "..math.floor(items[b[1]].price*exchangeRate))
		return true, b[1]
	end
	writeLog(data, "failed to sell item "..item)
	return false
end


function renderSkillButtons(data)
	local keyb = {}
	keyb[1] = {}
	

	if data.s <= 0 then
		keyb[1][1] = {text = "Close", callback_data = "skill:0" }
	else
		local n = 1
		
		keyb[1][1] = {text = "+1 Attack", callback_data = "skill:2" }
		keyb[1][2] = {text = "+1 Defense", callback_data = "skill:1" }
		keyb[1][3] = {text = "+6 Life (1pt)", callback_data = "skill:10" }
		keyb[1][4] = {text = "+1 Agility", callback_data = "skill:20" }
		n =n +1
		if data.s >= 4 then 
			keyb[n] = {}
			keyb[n][1] = {text = "+4 Attack", callback_data = "skill:4" }
			keyb[n][2] = {text = "+4 Defense", callback_data = "skill:3" }
			keyb[n][3] = {text = "+24 Life (4pt)", callback_data = "skill:11" }
			keyb[n][4] = {text = "+4 Agility", callback_data = "skill:21" }
			n =n +1
		end
		if data.s >= 8 then 
			keyb[n] = {}
			keyb[n][1] = {text = "+8 Attack", callback_data = "skill:6" }
			keyb[n][2] = {text = "+8 Defense", callback_data = "skill:5" }
			keyb[n][3] = {text = "+48 Life (8pt)", callback_data = "skill:12" }
			keyb[n][4] = {text = "+8 Agility", callback_data = "skill:22" }
			n =n +1
		end
		if data.s >= 16 then 
			keyb[n] = {}
			keyb[n][1] = {text = "+16 Attack", callback_data = "skill:8" }
			keyb[n][2] = {text = "+16 Defense", callback_data = "skill:7" }
			keyb[n][3] = {text = "+96 Life (8pt)", callback_data = "skill:13" }
			keyb[n][4] = {text = "+16 Agility", callback_data = "skill:23" }
			n =n +1
		end


		keyb[n] = {}
		keyb[n][1] = {text = "Close", callback_data = "skill:0" }
	end

	local JSON = require("JSON")
	local kb = JSON:encode({inline_keyboard = keyb})
	return kb, str
end


if not progress then
	progress = {
		qc = 1,
	}
end

quests = {
	[1] = {desc="Say 'bom dia' or 'good morning' in 3 chats with more than 50 users.", reward={exp=50, money=150, {3, 2}, {2, 5}, {10, 1} } , max = 3} ,
	[2] = {desc="Chat with in a chat! Must be said more then 20 letters 5 times in a chat with more than 50 users. Dont do spam otherwise your quest will fail", reward={exp=90, money=210, {1, 1}, {3, 3}, {11, 1} }, max = 5			},
	[3] = {desc="Use an /hoje or /today command in a chat", reward={exp=30, money=110,  {3, 3}, {15, 1} }, max = 1	},
	[4] = {desc="Go hunt with /rpgloot 4 times", reward={exp=100, money=310,  {3, 2}, {18, 1}, {15, 1} }, max = 4	},
	[5] = {desc="Win a battle with /battle", reward={exp=40, money=310,  {7, 1}, {16, 1},}, max = 1	},
	[6] = {desc="Drop a item in the main chat using /rpgdrop", reward={exp=40, money=310,  {7, 1}, {16, 1},}, max = 1	},
	--[7] = {desc="Earn a total of 1000 exp", reward={exp=20, money=1010,  {11, 1}, {12, 1},}, max = 1000	},

}

quests[1].task = function(msg, data, prog, arg)
	if not msg or not msg.chat.id then
		return
	end

	if chats[msg.chat.id] and chats[msg.chat.id].data.mc >= 10 then 
		if msg.text and (msg.text:find("bom dia") or msg.text:find("bom morning")) then 
			print("Task to ", data.id.." -> ", arg)
			prog.counter = prog.counter +1
		end
	end
end

quests[2].task = function(msg, data, prog, arg)
	if not msg or not msg.chat.id  then
		return
	end
	
	if chats[msg.chat.id] and chats[msg.chat.id].data.mc >= 10 then  --and 
		
		if msg.text and (msg.text:len() > 20) then  --
			for i,b in pairs(prog.etc) do 
				if b == msg.text then 
					prog.failed = true
					return
				end
			end
			if msg.text:find("aaaaaaaaaaa") or msg.text:find("xxxxxxxxx") or msg.text:find("%.%.%.%.%.%.%.%.") or msg.text:find("asdf") or msg.text:find("qwert") or msg.text:find("12345678") then 
				prog.failed = true
				return
			end
			prog.etc[#prog.etc+1] = msg.text
			print("Task to ", data.id.." -> ", arg)
			prog.counter = prog.counter +1
			
		end
	end
end

quests[3].task = function(msg, data, prog, arg)
	if not msg or not msg.chat.id then
		return
	end
	if chats[msg.chat.id] then 
		if msg.text and (msg.text == "/hoje" or msg.text == "/hoje@burrsobot" or msg.text == "/today" or msg.text == "/today@burrsobot") then 
			prog.counter = prog.counter +1
		end
	end
end

quests[4].task = function(msg, data, prog, arg)
	if arg ~= "rpgloot" then
		return
	end
	print("Task to ", data.id.." -> ", arg)
	prog.counter = prog.counter +1
end

quests[5].task = function(msg, data, prog, arg)
	if arg ~= "battle-win" then
		return
	end
	print("Task to ", data.id.." -> ", arg)
	prog.counter = prog.counter +1
end

quests[6].task = function(msg, data, prog, arg)
	if arg ~= "rpgdrop" then
		return
	end
	print("Task to ", data.id.." -> ", arg)
	prog.counter = prog.counter +1
end
--[[
quests[7].task = function(msg, data, prog, arg, cnt)
	if arg ~= "rpgexp" then
		return
	end
	print("Task to ", data.id.." -> ", arg)
	prog.counter = prog.counter + cnt
end]]

function formatReward(prize)

	local rew = ""
	rew = rew .. (prize.exp and ("<b>Exp:</b> "..prize.exp.."\n") or "") 
	rew = rew .. (prize.money and ("<b>Money</b>: "..formatMoney(prize.money).."\n") or "")
	re = rew .."Items: "
	for i=1, #prize do 
		rew = rew .. prize[i][2]..items[prize[i][1]].name.." "
	end
	return rew
end

function formatReward2(prize)

	local rew = ""
	if prize.exp then
		rew = rew .. prize.exp.." XP,"
	end
	if prize.money then
		rew = rew .. formatMoney(prize.money)..", "
	end
	for i=1, #prize do 
		rew = rew .. prize[i][2]..items[prize[i][1]].name..", "
	end
	return rew:sub(1, #rew-2)
end

function giveReward(data, prize, what)
	if not what then 
		what = "You received:\n"
	end
	for i=1, #prize do 
		addItem(data, prize[i][1],prize[i][2])
		
	end
	if prize.money then
		addGold(data, prize.money)
	end
	if prize.exp then
		gainExp(data, prize.exp)
	end
	deploy_sendMessage(data.id, what ..formatReward(prize), "HTML")
end

function checkQuestInner(data, username, msg, arg, amount)
	amount = tonumber(amount or 1) or 1
	if type(username) == 'table' then
		for i,b in pairs(users) do 
			if b.telegramid == username.id then 
				username = i
				break
			end
		end
	end
	local prog = progress[username]
	if prog then 
		local qid = data.q
		local day = tonumber(os.date("%d"))
		if data.qd ~= day then 
			data.q = nil --Kill quest
			progress[username] = nil --stop completion
			return 
		end

		--process quest progress

		quests[qid].task(msg, data, prog, arg, amount)

		if prog.failed then 
			deploy_sendMessage(data.id, "✴️ou failed your quest!✴️", "HTML")
			data.q = nil --Kill quest
			progress[username] = nil --stop completion
			return 
		end


		if quests[qid].max <= prog.counter then 
			if msg then
				if msg.chat then
					local m1 = bot.sendMessage(msg.chat.id, "🎉", "HTML", nil, nil, msg.message_id)

					scheduleEvent(10, function()
						if m1.ok then
							deploy_deleteMessage(m1.result.chat.id,m1.result.message_id)
						end
					end)
				end
			end

			giveReward(data, quests[qid].reward, "You finished quest <b>"..qid.."</b> and received:\n")
			data.comp = day 	--complete
			progress[username] = nil -- stop completio
			SaveUser(username)
		end
	end
end

function checkQuest(msg, data)
	checkQuestInner(data, msg.from.username, msg, "chat")
end


function renderQuest(msg)
	local data = getUserRpg(msg.from.username)
	if data then
		if msg.chat.type ~= "private" then 
			reply("Use it on private!")
			return
		end
		local left = string.format("%2.2d:%2.2d",(23-tonumber(os.date("%H"))),(59-tonumber(os.date("%M"))))
		local day = tonumber(os.date("%d"))

		local newQuest = false


		if data.comp == day then 
			deploy_sendMessage(msg.chat.id, "You already completed your quest today.\n\nNext quest in <i>"..left.."</i>", "HTML")
			return
		end
		print("Check for q", data.q)
		if not data.q or data.qd ~= day then 
			data.q = (progress.qc%(#quests)) +1
			progress.qc = progress.qc +1
			data.qd = day
			newQuest = true 
		end



		local str = selectUsername(msg, true).." quest!\n".. ( newQuest and ("<b>NEW QUEST! #"..data.q.."</b>\n") or ("<b>Quest of the day "..os.date("%D").."</b>\n"))
		
		str = str .. "\n Your quest is: <code>"..quests[data.q].desc.."</code>\n"
		if not progress[msg.from.username] or newQuest then 
			progress[msg.from.username] = {counter = 0, max = quests[data.q].max, etc = {}}
		end
		local pro = progress[msg.from.username]
		str = str .. "Progress: <code>"..renderProgress(pro.counter/pro.max).."</code> <b>"..pro.counter.."/"..pro.max.."</b>\nTime left: "..left..":00\n<b>Reward:</b>"..formatReward2(quests[data.q].reward).."\n<i>If the bot restarts (maintence), you will lose your progress and have to call /rpgquest again.</i>"

		deploy_sendMessage(msg.chat.id, str, "HTML")
		return

	else 
		reply("Sorry, you dont have a rpg character. use /rpgstart to join")
	end
end


function rpgQuit( msg )
	local data = getUserRpg(msg.from.username)
	if data then
		users[msg.from.username].rpg_old = users[msg.from.username].rpg
		users[msg.from.username].rpg = nil
		say_admin("Ele saiu: "..msg.from.username)
		reply("You are not playing anymore.\nYou can start again with the same character with /rpgstart")
		SaveUser(msg.from.username)
	end
end


function renderSkills(msg)
	SaveUser(msg.from.username)
	local data = getUserRpg(msg.from.username)
	if data then
		if msg.chat.type ~= "private" then 
			reply("Use it on private!")
			return
		end
		writeLog(data, "asked for render skills")
		local kb = renderSkillButtons(data)
        bot.sendMessage(msg.chat.id, msg.from.username.."'s Skill points\nPoints to use: <b>"..data.s.."</b>", "HTML",nil, nil, nil, kb)		
	end
end

function checkLimitations(a,b)
	--A wants to fight
	--B pressed.
	if a.bm_dif then 
		if (math.abs(a.lvl-b.lvl) > 2) then
			return false, "The level difference is too high."
		end
	end
	if a.bm_norep then 
		if battlelog[a.id] and battlelog[a.id][b.id] and battlelog[a.id][b.id] <= os.time() then
			return false, "You cant battle this person again within 5 minutes. Wait more "..(battlelog[a.id][b.id] - os.time())
		end
	end

	return true
end
if not battlelog then
battlelog = {}
end

function processChatBattle(msg)
	local who = msg.data:match("bttl:(.+)")
	local data = getUserRpg(msg.from.username)
	if data then
		if users[who] then
			local a = getUserRpg(who)
			if a.bch == msg.message.chat.id and a.bid == msg.message.message_id then 
				local lim, err = checkLimitations(a, data)
				if not lim then 
					deploy_answerCallbackQuery(msg.id, err)
					return
				end



				
				deploy_deleteMessage(a.bch, a.bid)
				if who == msg.from.username then 
					deploy_answerCallbackQuery(msg.id, "Cancelled.")
					a.bch = 0
					a.bid = 0
					return
				else 
					deploy_answerCallbackQuery(msg.id, "Done")
				end
				
				a.n = users[who].first_name or who
				data.n = msg.from.first_name

				a.hm = maxHealth(a)
				data.hm = maxHealth(data)
				a.h = math.min(a.h, a.hm)
				data.h = math.min(data.h, data.hm)
				local luta = 'Fight between <b><a href="tg://user?id='..users[who].telegramid..'">'..(a.beta and "["..a.beta.."]" or "")..users[who].first_name..'</a> level '..a.lvl.." ["..math.max(a.h,0).."/"..a.hm..']</b> <i>A: '..a.a..' D: '..a.d..'</i>\n'..
				'Versus <b><a href="tg://user?id='..msg.from.id..'">'..(data.beta and "["..data.beta.."]" or "")..msg.from.first_name..'</a> level '..data.lvl.." ["..math.max(data.h,0).."/"..data.hm..']</b> <i>A: '..data.a..' D: '..data.d..'</i>'
	
				local m1 = bot.sendMessage(a.bch, luta, "HTML")			
				
				local ret,f = battle(data, a, msg.from.first_name, users[who].first_name or who)

				local m2 = bot.sendMessage(a.bch, ret, "HTML")

				if not battlelog[a.id] then
					battlelog[a.id] = {}
				end
				local bl = battlelog[a.id]

				
				bl[data.id] = os.time() + 5 * 60
						
				f()
				
				deploy_sendMessage(msg.from.id, "Battle log:\n"..ret, "HTML")
				deploy_sendMessage(users[who].telegramid, "Battle log:\n"..ret, "HTML")

				scheduleEvent(120, function()
					if m2.ok then
						deploy_deleteMessage(m2.result.chat.id,m2.result.message_id)
					end
					if m1.ok then
						deploy_deleteMessage(m1.result.chat.id,m1.result.message_id)
					end
				end)
				

				a.bch = 0
				a.bid = 0
			else 	
				deploy_answerCallbackQuery(msg.id, "Expired invite.", "true")
			end
		else
			deploy_answerCallbackQuery(msg.id, "ERR 499", "true")
		end
	else 
		deploy_answerCallbackQuery(msg.id, "Você nao participa do rpg", "true")
	end
end


function processSkillPoint(msg)
	SaveUser(msg.from.username)
	local data = getUserRpg(msg.from.username)
	if data then
		local id = msg.data:match("skill:(%d+)")
		if not data.cd or data.cd < os.time() then
			if data.h <= 0 then 
				deploy_answerCallbackQuery(msg.id,  "You dont have enought health!", "true")
			end
			if data.s <= 0 then 
				deploy_answerCallbackQuery(msg.id, "You dont have skill points.")
				deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
				return
			end
			writeLog(data, "added skill "..id)
			id = tonumber(id)
			local what = ""
			data.cd = os.time() +2
			if id == 1 then 
				if data.s-1 < 0 then 
					deploy_answerCallbackQuery(msg.id, "You dont have skill points.")
					return
				end
				data.d = data.d +1
				data.s = data.s -1	
				what = "+1 Defense"
			elseif id == 2 then 
				if data.s-1 < 0 then 
					deploy_answerCallbackQuery(msg.id, "You dont have skill points.")
					return
				end
				data.a = data.a +1
				data.s = data.s -1	
				what = "+1 Attack"
			elseif id == 3 then 
				if data.s-4 < 0 then 
					deploy_answerCallbackQuery(msg.id, "You dont have skill points.")
					return
				end
				data.d = data.d +4
				data.s = data.s -4
				what = "+4 Defense"
			elseif id == 4 then 
				if data.s-4 < 0 then 
					deploy_answerCallbackQuery(msg.id, "You dont have skill points.")
					return
				end
				data.a = data.a +4
				data.s = data.s -4
				what = "+4 Attack"
			elseif id == 5 then 
				if data.s-8 < 0 then 
					deploy_answerCallbackQuery(msg.id, "You dont have skill points.")
					return
				end
				data.d = data.d +8
				data.s = data.s -8
				what = "+8 Defense"
			elseif id == 6 then 
				if data.s-8 < 0 then 
					deploy_answerCallbackQuery(msg.id, "You dont have skill points.")
					return
				end
				data.a = data.a +8
				data.s = data.s -8
				what = "+8 Attack"
			elseif id == 7 then
			if data.s-16 < 0 then 
					deploy_answerCallbackQuery(msg.id, "You dont have skill points.")
					return
				end 
				data.d = data.d +16
				data.s = data.s -16
				what = "+16 Defense"
			elseif id == 8 then 
				if data.s-16 < 0 then 
					deploy_answerCallbackQuery(msg.id, "You dont have skill points.")
					return
				end
				data.a = data.a +16
				data.s = data.s -16
				what = "+16 Attack"

			elseif id == 10 then 
				if data.s-1 < 0 then 
					deploy_answerCallbackQuery(msg.id, "You dont have skill points.")
					return
				end
				data.v = data.v +6
				data.s = data.s -1
				what = "+6 Max life"
			elseif id == 11 then 
				if data.s-4 < 0 then 
					deploy_answerCallbackQuery(msg.id, "You dont have skill points.")
					return
				end
				data.v = data.v +24
				data.s = data.s -4
				what = "+12 Max life"
			elseif id == 12 then 
				if data.s-6 < 0 then 
					deploy_answerCallbackQuery(msg.id, "You dont have skill points.")
					return
				end
				data.v = data.v +48
				data.s = data.s -8
				what = "+24 Max life"
			elseif id == 13 then 
				if data.s-16 < 0 then 
					deploy_answerCallbackQuery(msg.id, "You dont have skill points.")
					return
				end
				data.v = data.v +96
				data.s = data.s -16
				what = "+96 Max life"
			elseif id == 20 then 
				if data.s-1 < 0 then 
					deploy_answerCallbackQuery(msg.id, "You dont have skill points.")
					return
				end
				data.e = data.e +1
				data.s = data.s -1
				what = "+1 Agility"
			elseif id == 21 then 
				if data.s-4 < 0 then 
					deploy_answerCallbackQuery(msg.id, "You dont have skill points.")
					return
				end
				data.e = data.e +4
				data.s = data.s -4
				what = "+4 Agility"
			elseif id == 22 then 
				if data.s-8 < 0 then 
					deploy_answerCallbackQuery(msg.id, "You dont have skill points.")
					return
				end
				data.e = data.e +8
				data.s = data.s -8
				what = "+8 Agility"
			elseif id == 23 then 
				if data.s-16 <= 0 then 
					deploy_answerCallbackQuery(msg.id, "You dont have skill points.")
					return
				end
				data.e = data.e +16
				data.s = data.s -16
				what = "+16 Agility"
			else 
				deploy_answerCallbackQuery(msg.id, "Closing skills window")
				deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
				return
			end
						
			deploy_answerCallbackQuery(msg.id,  "Added "..what.."\n\n"..(pullStats(data):gsub("<%l>", ""):gsub("</%l>", ""):gsub("</code>", ""):gsub("<code>", "")), "true")			
			local kb = renderSkillButtons(data)
			bot.editMessageText(msg.message.chat.id, msg.message.message_id, msg.id, msg.from.username.."'s Skill points\nPoints to use: <b>"..data.s.."</b>", "HTML", nil , kb)
			--deploy_editMessageReplyMarkup(msg.message.chat.id, msg.message.message_id, msg.inline_message_id, kb)
		else 
			deploy_answerCallbackQuery(msg.id, "Too fast! Try again.", "true")
		end
	end
end

function swapToSellEquips(msg, data)
	deploy_editMessageReplyMarkup(msg.message.chat.id, msg.message.message_id, msg.inline_message_id, renderSellButtons(data, 1, true))
end

function swapToSellRegular(msg, data)
	deploy_editMessageReplyMarkup(msg.message.chat.id, msg.message.message_id, msg.inline_message_id, renderSellButtons(data, 1, false))
end


function processSellItem(msg)
	SaveUser(msg.from.username)
	local data = getUserRpg(msg.from.username)
	if data then
		local id = msg.data:match("sell:(%d+)")
		id = tonumber(id)
		if not data.bp[id] then 
			deploy_answerCallbackQuery(msg.id, "Unknow item", "true")
		else
			writeLog(data, "tried to sell "..id)
			local succes, soldid = sellItem(data, id)
			if succes then
				deploy_answerCallbackQuery(msg.id, "You sold "..items[soldid].name.." for "..formatMoney(math.floor(items[soldid].price*exchangeRate) ).. "\nNow you have "..formatMoney(data.g), "true")
				if items[soldid].stock then
					stock[soldid] = (stock[soldid] or 0) +1
				end

				deploy_editMessageReplyMarkup(msg.message.chat.id, msg.message.message_id, msg.inline_message_id, renderSellButtons(data, 1))
				

				 rpgSave()
			else 
				if not items[soldid] then 
					deploy_answerCallbackQuery(msg.id, "??", "true")
					deploy_editMessageReplyMarkup(msg.message.chat.id, msg.message.message_id, msg.inline_message_id, renderSellButtons(data, 1))
				
					return
				end
				deploy_answerCallbackQuery(msg.id, "You dont have this item ("..items[soldid].name..") to sell.", "true")
			end
			--
		end
	else
		deploy_answerCallbackQuery(msg.id, "Você nao participa do rpg", "true")
	end
end

function formatMobButton(mob)
	local keyb = {}
	keyb[1] = {}

	if not mob then 
		return nil
	end
	keyb[1][1] = {text = "Attack "..mob.name.." ["..mob.h.."/"..mob.hm.."]", callback_data = "punch:"..mob.id }
	local JSON = require("JSON")
	local kb = JSON:encode({inline_keyboard = keyb})
	return kb
end
 
function spawSomething()
	local id = os.time()
	monsters[id] = blankStats() 
	monsters[id].name = "BIG NUGG BOI"
	monsters[id].hm= 500000
	monsters[id].h = 500000
	monsters[id].a = 8
	monsters[id].d = 30
	monsters[id].e = 8
	monsters[id].helper = {}
	monsters[id].id = id
	monsters[id].exp = 10000
	monsters[id].g =   30000
		--sendPhoto(chat_id, photo, caption, disable_notification, reply_to_message_id, reply_markup, parse)
	monsters[id].msg =bot.sendDocument(g_chatid, 'CgACAgQAAxkBAAECAZRfDewYYrsJYyXqbl_X5aabH7OZcQACZQADPpg9URBNuxSsCY13GgQ', "The <b>"..monsters[id].name.."</b> has been spawned!\n\nHealth: "..monsters[id].h.."\nAttack:"..getAttack(monsters[id]).."\nDefense:"..monsters[id].d.."\n\nIt carries: "..monsters[id].exp.." XP and "..formatMoney(monsters[id].g), false, nil, formatMobButton(monsters[id]), "HTML")

	--monsters[id].msg = bot.sendMessage(g_chatid, "The "..monsters[id].name.." has been spawned!\n\nHealth: "..monsters[id].h.."\nAttack:"..getAttack(monsters[id]).."\nDefense:"..monsters[id].d.."\n\nIt carries: "..monsters[id].exp.." XP and "..formatMoney(monsters[id].g), "HTML", true, false, nil, formatMobButton(monsters[id]))
end

--spawSomething()

function printMonster(id)
	bot.sendMessage(g_chatid, "The "..monsters[id].name.." has been spawned!\n\nHealth: "..monsters[id].h.."\nAttack:"..getAttack(monsters[id]).."\nDefense:"..getDefense(monsters[id]).."\n\nIt carries: "..monsters[id].exp.." XP and "..formatMoney(monsters[id].g), "HTML", true, false, nil, formatMobButton(monsters[id]))
end

function processCombat(msg)
	local data = getUserRpg(msg.from.username)
	if data then
		SaveUser(msg.from.username)
		local id = msg.data:match("punch:(%d+)")
		id = tonumber(id)
		if not monsters[id] then 
			deploy_answerCallbackQuery(msg.id, "Unknow monster o dead monster", "true")
		else
			print("PUNCHING: "..msg.from.username)
			if not data.cd or data.cd < os.time() then
				if data.h <= 0 then 
					deploy_answerCallbackQuery(msg.id,  "You dont have enought health!", "true")
					return
				end
				data.cd = os.time() +2
				local bd = {
					firstTurn = true,
					tire = 1,
					expand=1,
				}
				local loge = "" 
				
				writeLog(data, "combat")

				monsters[id].n = monsters[id].name
				data.n = msg.from.first_name 



		
				updateHealthByTicks(data)

				data.hm = maxHealth(data)

				data.h = math.min(data.h, data.hm)

				local inital = monsters[id].h
				local mh = data.h

				repeat 
					loge = loge ..turn( data, monsters[id], bd )
					if data.rep then
						data.rep = data.rep -1
						if data.rep < 0 then 
							data.rep = nil
						end
					end
				until not data.rep
	
				if data.h >= 0 and monsters[id].h >=0 then
					repeat 
						loge = loge ..turn( monsters[id], data, bd )
						if monsters[id].rep then
							monsters[id].rep = monsters[id].rep -1
							if monsters[id].rep < 0 then 
								monsters[id].rep = nil
							end 
						end
					until not monsters[id].rep
				end 
				local dealt = math.max(0,inital-monsters[id].h)


				

				monsters[id].helper[msg.from.username] = (monsters[id].helper[msg.from.username] or 0) + dealt

				loge = loge.."\nYour health is ["..math.max(data.h,0).."/"..data.hm.."]"
				loge = loge.."\n"..monsters[id].n.." health is ["..math.max(monsters[id].h,0).."/"..monsters[id].hm.."]"
				--loge = loge.."\nTotal damage you dealt: "..monsters[id].helper[msg.from.username].." dmg"
				--print(loge)

				if data.h <= 0 then 
					local drain = math.floor(data.exp * 0.1)
					local minExp = ((data.exp-drain) - getExpToLevel(data.lvl) )
					if minExp < 0 then 
						drain = math.abs(minExp)
					end
					data.de = data.de+1
					loge = loge.."\n\nYou died and lost "..drain.." XP!"
					loseExp(data, drain)
					monsters[id].exp = monsters[id].exp + math.floor(drain/10)
				end


				
				data.n = nil
				monsters[id].tdmg = nil
				data.tdmg = nil
				monsters[id].rep = nil
				data.rep = nil   

				local took = mh-data.h
			
				deploy_answerCallbackQuery(msg.id, loge:len() > 200 and ("Battle log sent on private\nTLDR: You dealt "..dealt.." damage and took "..took.." damage") or loge:gsub("<%l>",""):gsub("</%l>",""):gsub("</code>", ""):gsub("<code>", ""), "true")

				if monsters[id].h <= 0 then 
					local total = 0
					for i,b in pairs(monsters[id].helper) do 
						total = total + b
					end
					local str = "Sharing: "..monsters[id].exp.." XP!\n\nParticipation:\n"
					for i,b in pairs(monsters[id].helper) do
						local exp = (b/total)*monsters[id].exp
						local gold = math.ceil(monsters[id].g * (b/total))
						str = str .. "@"..i .." dealt "..b.." damage -> "..string.format("%2.2f",(b/total*100)).."% = <b>"..math.ceil(exp).." EXP</b> and "..formatMoney(gold).."\n" 
						local dd = getUserRpg(i)
						gainExp(dd, math.ceil(exp),nio, "BOIS" ) 
						addGold(dd, gold)

					end 
					logText("RPG", str)
					
					local res = bot.sendMessage(msg.message.chat.id, "The "..monsters[id].name.." <b>is dead!</b>\n"..str, "HTML")
					if not res.ok then 
						res = bot.sendMessage(msg.message.chat.id, "The "..monsters[id].name.." <b>is dead!</b>\n"..str)
						if not res.ok then 
							say_big("The "..monsters[id].name.." <b>is dead!</b>\n"..str)
						end
					end
					monsters[id] = nil
					return
				end
				deploy_sendMessage(msg.from.id, loge.."\nTotal damage you dealt: "..monsters[id].helper[msg.from.username], "HTML")
				deploy_editMessageReplyMarkup(msg.message.chat.id, msg.message.message_id, msg.inline_message_id, formatMobButton(monsters[id]))
				--bot.editMessageText(msg.message.chat.id, msg.message.message_id, msg.id, "The "..monsters[id].name.." has been spawned!\n\nHealth: "..monsters[id].h.."\nAttack:"..monsters[id].a.."\nDefense:"..monsters[id].d, "HTML", nil ,formatMobButton(monsters[id]))
			else 
				data.cd = data.cd + 1
				deploy_answerCallbackQuery(msg.id, "Too fast! As a penalty you will have to wait more "..(data.cd-os.time()).." seconds.", "true")
			end
		end

		
	else
		deploy_answerCallbackQuery(msg.id, "Você nao participa do rpg", "true")
	end


end

function renderBattleSettings(b)
	local JSON = require("JSON")
	local keyb = {{},{},{}}
			--print(user, user.from, user.from.username)
	keyb[1][1] = {text = (b.bm_dif and "[ON] level protection" or "[OFF] level protection"), callback_data = "bpro:1" }
	keyb[2][1] = {text = (b.bm_norep and "[ON] battle coldown S.P" or "[OFF] battle coldown S.P"), callback_data = "bpro:2" }
	keyb[3][1] = {text = "❌Close❌", callback_data = "bpro:0" }

	local kb = JSON:encode({inline_keyboard = keyb})
	return kb
end
	
function processBattleSettings(msg)
	local data = getUserRpg(msg.from.username)
	if data then
		SaveUser(msg.from.username)
		local id = msg.data:match("bpro:(%d+)")
		id = tonumber(id)
		if id == 1 then 
			data.bm_dif = (not data.bm_dif)
		elseif id == 2 then
			data.bm_norep = (not data.bm_norep)
		else 
			deploy_answerCallbackQuery(msg.id, "Closing settings")
			deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
			return
		end
		deploy_editMessageReplyMarkup(msg.message.chat.id, msg.message.message_id, msg.inline_message_id, renderBattleSettings(data))
			
		
	else
		deploy_answerCallbackQuery(msg.id, "Você nao participa do rpg", "true")
	end
end

function processBuyItem(msg)
	local data = getUserRpg(msg.from.username)
	if data then
		SaveUser(msg.from.username)
		local id = msg.data:match("buy:(%d+)")
		id = tonumber(id)
		if not items[id] then 
			deploy_answerCallbackQuery(msg.id, "Unknow item", "true")
		else
			if items[id].stock then 
				if not stock[id] or stock[id] < 0 then
					deploy_answerCallbackQuery(msg.id, "Out of stock", "true")
					return
				end
			end
			writeLog(data, "tried to buy "..id)
			if buyItem(data, id) then
				deploy_answerCallbackQuery(msg.id, "You bought "..items[id].name.." for "..formatMoney(items[id].price).."\n\nYou have: "..formatMoney(data.g), "true")
				if stock[id] then
					stock[id] = stock[id] -1
					deploy_editMessageReplyMarkup(msg.message.chat.id, msg.message.message_id, msg.inline_message_id, renderShopBuyButtons())
				end
				 rpgSave()
			else 
				deploy_answerCallbackQuery(msg.id, "You dont have enought money to buy it.", "true")
			end
			--
		end
	else
		deploy_answerCallbackQuery(msg.id, "Você nao participa do rpg", "true")
	end
end

function showMoney(msg)
	local data = getUserRpg(msg.from.username)
	if data then
		deploy_answerCallbackQuery(msg.id, "You have a total of: "..formatMoney(data.g), "true")
	else
		deploy_answerCallbackQuery(msg.id, "Você nao participa do rpg", "true")
	end
end

function showBpFast(msg)
	local data = getUserRpg(msg.from.username)
	if data then
		if type(data.bp) == "string" then
			data.bp = {}
		end
		if #data.bp == 0 then 
			deploy_answerCallbackQuery(msg.id, "Your backpack is empty", "true")
			return
		end

		local str = "Your backpack contains:\n"
		for i=1,#data.bp do
			str = str .. data.bp[i][2].."x "..items[data.bp[i][1]].name.."\n"
		end

		deploy_answerCallbackQuery(msg.id, str.."\n\nAnd "..formatMoney(data.g), "true")
	else
		deploy_answerCallbackQuery(msg.id, "Você nao participa do rpg", "true")
	end
end

function renderSellButtons(data, e, onlyEquip)
	local keyb = {}
		keyb[1] = {}
		local cnt = 0
		local height = 1

		--[[local onlyK = {}
		for i=1,#data.bp do 
			if onlyEquip then 
				if items[data.bp[1] ].equip then
					onlyK[i] = (onlyK[data.bp[1] ] or 0) + data.bp[i][2]
				end
			else
				if not items[data.bp[1] ].equip then
					onlyK[i] = (onlyK[data.bp[1] ] or 0) + data.bp[i][2]
				end
			end
		end]]

	
		--[[for i,b in pairs(items) do
			if b.name and b.price > 0 then

				if not e or onlyK[i] then
					end
			end
		end]]
		for i,b in pairs(data.bp) do 

			local canShow = false 
			if onlyEquip then 
				if items[b[1] ].equip then
					canShow = true
				end
			else
				if not items[b[1] ].equip then
					canShow = true
				end
			
			end 

			if canShow then
				cnt = cnt +1
				if cnt > 3 then 
					height = height +1
					cnt = 1
					keyb[height] = {}
				end
				keyb[height][cnt] = {text = (b[2].." ")..items[b[1]].name..(items[b[1]].equip and items[b[1]].genDesc(b) or "").." > "..formatMoney(math.floor(items[b[1]].price*exchangeRate)), callback_data = "sell:"..i }
			end	
		end
		keyb[height+1] = {}
		keyb[height+1][1] = {text = "❓💵How much do i have?💵❓", callback_data = "moneyplz" }
		keyb[height+2] = {}
		keyb[height+2][1] = {text = "🎒Whats in my backpack?🎒", callback_data = "bpplz" }
		keyb[height+3] = {}
		if onlyEquip then 
			keyb[height+3][1] = {text = "🥇Sell items🥇", callback_data = "rpg:itempls" }
		else
			keyb[height+3][1] = {text = "🗡Sell equipaments🗡", callback_data = "rpg:equippls" }
		end
		local JSON = require("JSON")
		local kb = JSON:encode({inline_keyboard = keyb})
	return kb
end

function renderShopSell(msg, e)
	local data = getUserRpg(msg.from.username)
	if data then
		if type(data.bp) == "string" then
			data.bp = {}
		end

		
		local wut = bot.sendMessage(msg.chat.id, "Shop is open! Com and grab!\n\n📈📈<b>YOU ARE SELLING</b>📈📈\n💎=100💵\nSTONKS\nThere is a official group for the RPG https://t.me/telerpg", "HTML", true, false, nil, renderSellButtons(data, e, false))
		
		writeLog(data, "asked for sell shop")
		if msg.chat.type ~= "private" then 
			scheduleEvent(60, function()
				if wut and wut.ok then 
					deploy_deleteMessage(wut.result.chat.id,wut.result.message_id)
					deploy_deleteMessage(msg.chat.id,msg.message_id)
				end
			end)
		end
	else 
		say("Sorry, you dont have a rpg character. use /rpgstart to join")
	end
end
function renderShopBuyButtons()
	local keyb = {}
	keyb[1] = {}
	local cnt = 0
	local height = 1

	for i,b in pairs(items) do
		if b.name and b.price > 0 and not b.blockbuy then
			if not b.stock or (b.stock and (stock[i] and stock[i] > 0)) then
				cnt = cnt +1
				if cnt > 2 then 
					height = height +1
					cnt = 1
					keyb[height] = {}
				end
				local stk = (b.stock and (stock[i] and stock[i] > 0)) and (" ("..stock[i]..")") or ""
				
				keyb[height][cnt] = {text = formatMoney(b.price).." > "..b.name..stk , callback_data = "buy:"..i }
			end
		end
	end
	keyb[height+1] = {}
	keyb[height+1][1] = {text = "❓💵How much do i have?💵❓", callback_data = "moneyplz" }
	keyb[height+2] = {}
	keyb[height+2][1] = {text = "🎒Whats in my backpack?🎒", callback_data = "bpplz" }
	local JSON = require("JSON")
	local kb = JSON:encode({inline_keyboard = keyb})
	return kb
end

function renderShopBuy(msg)
	local data = getUserRpg(msg.from.username)
	if data then
		if type(data.bp) == "string" then
			data.bp = {}
		end

		local wut = bot.sendMessage(msg.chat.id, "Shop is open! Com and grab!\n\n📉📉<b>YOU ARE BUYING</b>📉📉\n💎=100💵\nSTONKS\nThere is a official group for the RPG https://t.me/telerpg", "HTML", true, false, nil, renderShopBuyButtons())
		writeLog(data, "asked buy shop")
		if msg.chat.type ~= "private" then 
			scheduleEvent(60, function()
				if wut and wut.ok then
					deploy_deleteMessage(wut.result.chat.id,wut.result.message_id)
					deploy_deleteMessage(msg.chat.id,msg.message_id)
				end
			end)
		end
	else 
		say("Sorry, you dont have a rpg character. use /rpgstart to join")
	end
end

function renderBackpackButtons(data, uname, act, showEquip)
	local keyb = {}
	keyb[1] = {}
	act = act or "bp"
	local cnt = 0
	local height = 1
	local str = ""
	local equip = ""
	for i=1,#data.bp do
		
		if not showEquip and items[data.bp[i][1]].equip then 
			equip = equip .. items[data.bp[i][1]].name.." - <i>"..whereTextEquip(items[data.bp[i][1]].equip)..' '..(items[data.bp[i][1]].desc or items[data.bp[i][1]].genDesc(data.bp[i])).."</i>\n"
			--keyb[height][cnt] = {text = items[data.bp[i][1]].name.." "..data.bp[i][2].."x", callback_data = "it:"..uname..":"..i }
		else 
			cnt = cnt +1
			if cnt > 4 then 
				height = height +1
				cnt = 1
				keyb[height] = {}
			end
			str = str .. items[data.bp[i][1]].name.." - <i>"..(items[data.bp[i][1]].desc or items[data.bp[i][1]].genDesc(data.bp[i])).."</i>\n"
			keyb[height][cnt] = {text = renderItem(data.bp[i]).." "..data.bp[i][2].."x", callback_data = act..":"..uname..":"..i }
		end
		
		
	end
	keyb[height+1] = {}
	keyb[height+1][1] = {text = "❌Close❌", callback_data = "bp:"..uname..":0" }
	local JSON = require("JSON")
	local kb = JSON:encode({inline_keyboard = keyb})
	
	if #(str..(equip:len() > 0 and ("\nEquipaments (/rpgequip + /rpgcraft): \n"..equip) or "")) > 2000 then 
		str = str .."\n\n<b>Too much items!</b>"
	else 
		str = str..(equip:len() > 0 and ("\nEquipaments (/rpgequip + /rpgcraft): \n"..equip) or "")
	end
	return kb, str
end

function renderBackpack(msg)
	local data = getUserRpg(msg.from.username)
	if data then
		if type(data.bp) == "string" then
			data.bp = {}
		end
		if msg.chat.type ~= "private" then 
			reply_delete("Use your backpack in the private chat with me.")
			return
		end
		if #data.bp == 0 then
			deploy_sendMessage(msg.chat.id, selectUsername(msg, true).."'s backpack is empty\n\n<b>Money: "..formatMoney(data.g).."</b>", "HTML")
		end
		writeLog(data, "asked for backpack")
		local kb,str = renderBackpackButtons(data, msg.from.username)

		local wut = bot.sendMessage(msg.chat.id, selectUsername(msg, true).."'s backpack\n\n"..str.."\n\n<b>Money: "..formatMoney(data.g).."</b>\n( /rpgbackpack )", "HTML", true, false, nil, kb)
		if not wut.ok then 
			say_big("BUG:"..Dump(wut))
		end
		if msg.chat.type ~= "private" then 
			scheduleEvent(20, function()
				if wut and wut.ok then
					deploy_deleteMessage(wut.result.chat.id,wut.result.message_id)
				end
			end)
		end
	else 
		say("Sorry, you dont have a rpg character. use /rpgstart to join")
	end
end




function getExpToLevel(level)
	return math.floor(50 *(  ( level * level * level) - (6* level * level) + (17 * level)  - 12 )/40)
end

function updateHealthByTicks(data)
	if data.t and  data.t <= os.time() then 
		local diff = os.time()-(data.t-20)
		local health = math.floor(diff/20)
		data.t = os.time() + 20 - (diff%20)
		data.h = data.h + health * getAttributePercent(data, ITEM_CLASS_HEAL)


		
	end
	local rate = 600
	if data.tm and data.tm <= os.time() then 
		local diff = os.time()-(data.tm-rate)
		local mana = math.floor(diff/rate)
		data.tm = os.time() + rate - (diff%rate)
		data.mana = data.mana + mana 
		data.mana = math.min(data.mana, getManaMax(data))
	end
end

function drainExp(to, from, drain)

	local minExp = ((from.exp-drain) - getExpToLevel(from.lvl) )
	if minExp < 0 then 
		drain = math.abs(from.exp -  getExpToLevel(from.lvl))
	end
	--print("Draining exp "..drain)
    
    deploy_sendMessage(to.id, "You got "..drain.." exp", "HTML", nil, nil, nil)
    deploy_sendMessage(from.id, "You lost "..drain.." exp", "HTML", nil, nil, nil)
        	
	gainExp(to, math.floor(drain*1.0), nil, "FROM BATTLE", true)
	loseExp(from, drain)
	return drain
end


function loseExp(data, addExp)
	writeLog(data, "Lost "..addExp)
	data.exp = math.max( getExpToLevel(data.lvl) ,data.exp - addExp)
end

--[[

#1 kaile_oficial level 49 with 130083 exp
#2 garcus level 42 with 82727 exp
#3 zonaro level 41 with 74547 exp
#4 natloveless level 40 with 73296 exp
#5 toberal level 38 with 58699 exp
#6 cyansparkwolf level 33 with 37482 exp
#7 voltripulstar level 27 with 19716 exp
#8 in2ecticidepls level 26 with 17472 exp
#9 bearusu_myo level 26 with 17454 exp
#10 wagesn level 25 with 16007 exp

users['kaile_oficial'].rpg.beta = '🎖'
 users['zonaro'].rpg.beta = '🎖'
 users['toberal'].rpg.beta = '🎖'
 users['cyansparkwolf'].rpg.beta = '🎖'
 users['wagesn'].rpg.beta = '🎖'
 users['bearusu_myo'].rpg.beta = '🎖'

 ]]

function writeLog(data,what)
	logText("RPG", os.time().."\t"..data.id.."\t"..data.exp.."\t"..data.lvl.."\t"..data.h.."\t["..data.a..","..data.d..","..data.v..","..data.e.."]\t"..data.g.."\t["..what.."]\r\n")
end

function gainExp(data, addExp, notify, place, noMultiply)

	if not noMultiply then 
		addExp = addExp * getAttributePercent(data, ITEM_CLASS_EXP) 
	end
	local xp = getExpToLevel(data.lvl+1)

	data.exp = math.ceil(data.exp + addExp)
	local old = g_bot
	setBot("rpg")
	local n = 0


	while xp <= data.exp do
        data.lvl = data.lvl +1


        xp = getExpToLevel(data.lvl+1)

        local left = math.max(0, (xp-data.exp))

        data.s = data.s + 10
        data.h = data.h + 5

        --print(data.id.." new level: "..data.lvl)
        writeLog(data, "Gained a new level")
       

        
  

        if not notify then
        	--print("You reached level <b>"..data.lvl.."</b>!")
        	local extra = ""
        	if data.lvl%5 == 0 then 
        		extra = extra.."\n\n<b>Liked this RPG or the BOT? Consider donating with /donate :3</b>"
        	end
        	local kb = renderSkillButtons(data)
        	if data.lvl >= 10 then 	
        		deploy_sendMessage(data.id, "You reached level <b>"..data.lvl.."</b>!\n\nYou gained:\nSkill points: <b>+4</b>\nMax life: +5\nYou need "..left.." XP to next lvl\nAnd got a "..items[12].name.."\n"..extra, "HTML", nil, nil, nil)
        		addItem(data, 12, 1)
        	else 
        		deploy_sendMessage(data.id, "You reached level <b>"..data.lvl.."</b>!\n\nYou gained:\nSkill points: <b>+4</b>\nMax life: +5\nYou need "..left.." XP to next lvl\n"..extra, "HTML", nil, nil, nil)
        	end
        	scheduleEvent(5,function()
        		local kb = renderSkillButtons(data)
        		bot.sendMessage(data.id, "Skill points\nPoints to use: <b>"..data.s.."</b>", "HTML",nil, nil, nil, kb)
        	end)
        end
       	--SaveUser(msg.from.username)

       	n =n + 1
       	if n > 40 then 
       		break
       	end

    end
    setBot(old)

end
function processRpg(msg) 
	local data = getUserRpg(msg.from.username)
	if data then
		if msg.chat.type ~= "private" and chats[msg.chat.id].data.mc >= 15 then 
		    if users[msg.from.username].rpg then 
		        
		        if data.m <= os.time() then 
		        	local diff = math.random(1,4)

		        	gainExp(data, diff , nil, "TALKO")

		        	data.m = os.time()+4
		        else
		        	data.m = data.m+2
		        	if (data.m-os.time() > 20) then
		        		loseExp(data, 5)
		        	end
		        end
		        checkQuest(msg, data)
		        
		    end
		end
		updateHealthByTicks(data)
	end
	
end

function maxHealth(data)
	return (getVitality(data) + ((data.lvl-1) * 8) + getAttributeModifier(data, ITEM_CLASS_HEALTH)) * getAttributePercent(data, ITEM_CLASS_HEALTH_MAX)
end

function getManaMax(data)
	return 5 + math.floor((data.lvl/2))
end

function getUserRpg(who)
	local usr = users[who]
	if not usr then 
		return nil, 0
	end
	local r = usr.rpg
	if not r then 
		return nil, 1
	end
	if not r.mana then 
		r.tm = os.time()
		r.mana = 1
		SaveUser(who)
	end
	return r
end
function reestock()
	local dropc = 1
	for i=1,6 do
		if math.random(0,1000) <= (600) then 
			break
		end
		dropc = dropc +1 
	end
	local dropch = {}
	for i=1,10 do 
		for i,b in pairs(items) do 
			if type(i) == 'number' and i <= 19 then 
				if math.random(0,100000) < b.prob and not b.nore then 
					dropch[#dropch+1] = i
				end
			end
		end
	end
	local ree = ""
	for i=1,dropc do
		local dropId = dropch[math.random(1,#dropch)]
		stock[dropId] = (stock[dropId] or 0)+2
		ree = ree..items[dropId].name
	end
	return ree
end
function randomDelete(data)
	local i = math.random(1, #data.bp)
	data.bp[i][2] = data.bp[i][2] -1
	if data.bp[i][2] <= 0 then 
		table.remove(data.bp, i)
	end
end



function  rpgLoot(msg)	
	local data = getUserRpg(msg.from.username)
	local wut
	local used = false
	if not data then 
		wut = say("Sorry, you dont have a rpg character. use /rpgstart to join")
		return
	else
		

		if not data.loot or data.loot <= os.time() then 
			if not data.loot or data.loot == 0 then 
				data.loot = os.time()
			end
			local w = reestock()
			local diff = os.time() - data.loot 
		
			local more = math.floor(diff/(60*5) ) --turns

			local extra =  more * 0.0025

			extra = math.min(extra, 1.5)
			local money = 0

			local exp = 0

			if not data.noloot then 
				data.noloot = 0
			end
			--[[if more <= 1 then 
				data.noloot = data.noloot + 1
				if data.noloot >= 20 then
					if data.noloot >= 25 then
						g_sayMode = "HTML"
						reply("<i>You did a hunt for loot too many times and lost a item from the backpack.</i>")
						g_sayMode = ""
						randomDelete(data)
					else 
						g_sayMode = "HTML"
						reply("<i>You did a hunt for loot but found nothing, you should wait an hour or two.</i>")
						g_sayMode = ""
					end
					data.loot = os.time() + 60 * 5
					return
				end
			elseif more >= 3 then 
				data.noloot = 0
			end]]


			

			
			--/lua users['mockthebear'].rpg.loot = os.time() - 3600 * 4


			
			local dropc = math.random(0,100) <= (80 - 60 * extra) and 1 or 0
			local ne = 0
			for a=1, 1+math.floor( math.min(25, more/10)) do
				ne = ne +1
				money = money +  math.random(1,110)

				exp = exp + ((math.random(0,100) <= 40) and math.random(5,50) or 0)

		
				for i=1,6 do
					if math.random(0,1000) <= (300) then 
						break
					end
					dropc = dropc +1 
				end
			end

			local dropch = {}
			for i=1,20 do 
				for i,b in pairs(items) do 
					if type(i) == 'number' then 
						if b.prob ~= 0 and math.random(0,100000) < b.prob then 
							dropch[#dropch+1] = i
						end
					end
				end
			end
			local missed = ""
			if more > 0 then 
				missed = "You missed "..more.." turns"..(ne > 1 and " and won +"..ne.." extra loot" or "")..".\n"
			end
			writeLog(data, "is looting")

			local dorps = {}
			if #dropch == 0 or dropc == 0 then 
				g_sayMode = "HTML"

				if exp == 0 then
					wut = reply(missed.."<i>You did a hunt for loot but found nothing except "..formatMoney(money).."</i>\nReestocked "..w)
				else 
					wut = reply(missed.."<i>You went hunting and found </i><b>+"..exp.." EXP plus "..formatMoney(money).."</b>.\nReestocked "..w)
				end
				writeLog(data, "looted "..exp.."xp and "..money)
				g_sayMode = nil 
			else 
				local found = ""
				local uitems = {}
				for i=1,dropc do
					local dropId = dropch[math.random(1,#dropch)]
					uitems[dropId] = (uitems[dropId] or 0) +1
					--found = found.. "* "..items[dropId].name.."\n"
					
				end
	
				for i,b in pairs(uitems) do 
					local it = addItem(data, i, (items[i].equip and 1 or b))
					found = found.. "* "..(items[i].equip and 1 or b).." "..items[i].name
					if items[i].equip then 
						found = found .. items[it[1]].genDesc(it)
					end
					found = found .. "\n"
					dorps[#dorps+1] = i
				end
				g_sayMode = "HTML"
				wut = reply(missed.."<i>You went hunting and found:</i>\n"..found..(exp > 0 and ("<b>+ "..exp.." EXP</b>") or ""  ).."\nAlso "..formatMoney(money).."\nUse /rpgbackpack to access inventory\nReestocked: "..w)
				writeLog(data, "looted "..exp.."xp and "..money.." and items")
				g_sayMode = nil 
				
			end
			addGold(data, money)
			if exp > 0 then 
				gainExp(data, exp,nil, "lut")
			end
			checkQuestInner(data, msg.from.username, msg, "rpgloot")
			used = true
			data.loot = os.time() + 60 * 5

			msg.chat.id = RPGCHAT
			if  math.random(0,1000) <= 10 then 
				spawnMisteryBox(msg)
			end
			if  math.random(0,1000) <= 10 then 
				renderChest(msg)
			end
			if math.random(0,1000) <= (100) and #dorps >= 2 then 
				local dropid = os.time()
				rpg_dropped_items[dropid] = {dorps[math.random(1, #dorps)], math.random(1,3)}
				displayDroppedItem(RPGCHAT, rpg_dropped_items[dropid], msg.from.username, dropid)
			end
		else
			g_sayMode = "HTML"
			local left = data.loot - os.time()
			wut = reply("<i>You found nothing... try again in "..(math.floor(left/60)..":"..(left%60)).."</i>")
			g_sayMode = nil 
		end
	end
	if msg.chat.type ~= "private" then 
		scheduleEvent(used and 20 or 8, function()
			deploy_deleteMessage(msg.chat.id, msg.message_id)
			if wut then
				deploy_deleteMessage(wut.result.chat.id,wut.result.message_id)
			end
		end)
	end
end

function pullStats(data, tool)
	local health = maxHealth(data)

	data.h = math.min(data.h,maxHealth(data))
	data.h = math.max(0,data.h)

	local from 	= getExpToLevel(data.lvl)
	local to 	= getExpToLevel(data.lvl+1)

	local need = (to-from)
	local got  = data.exp-from

	data.e = data.e or 1
	local str = "<b>Exp: %d</b> <i>(%2.2f%% need %d)</i>\n<b>Level: %d</b> <code>"..renderProgress(got/need).."</code>\n<b>ATK:</b> %s\n<b>DEF:</b> %s\n<b>AGI:</b> %s\n<b>HP:</b> %d/%d\n<b>Money:</b> "..formatMoney(data.g)
	if not tool then 
		str = str.."\n".. ("<b>Mana</b> "..data.mana.."/"..getManaMax(data))
		str = str.."\n"..(data.s > 0 and ("<b>Skill points:</b> "..data.s.." (use /rpgskills on private)") or "")

	end
	return str:format(data.exp, math.max(0,( got/need * 100 )), need-got, data.lvl, 
		tostring(getAttack(data, true)):gsub("%%","%%"), 
		tostring(getDefense(data, true)):gsub("%%","%%"),
		tostring(getEvasion(data,true)):gsub("%%","%%"), 
		 data.h, health)
end

function renderProgress(p, nm)
	-- body
	nm = nm or 10
	local dots = string.rep('.', math.ceil( nm - nm* (p) )		)
	local bars = string.rep('|', math.floor( nm * (p)	)		)
	return '['..bars..dots..']'
end

function getEvadeChance(data)
	return math.min(750,(90 +  10 * ( getEvasion(data)/15 + getDefense(data)/40 )   ) * getAttributePercent(data, ITEM_CLASS_EVADE))
end 

function getAccuracyChance(data)
	return math.min(750,(90 + math.min(750, 10 * ( getEvasion(data)/15 )   )) * getAttributePercent(data, ITEM_CLASS_ACCURACY))
end 

function pullTrueStats(data)
	local health = maxHealth(data)

	data.h = math.min(data.h,maxHealth(data))
	data.h = math.max(0,data.h)

	local from 	= getExpToLevel(data.lvl)
	local to 	= getExpToLevel(data.lvl+1)

	local need = (to-from)
	local got  = data.exp-from

	data.e = data.e or 1
	local str = "<b>Exp: %d</b> <i>(%2.2f%% need %d)</i>\n<b>Level: %d</b>\n<code>"..renderProgress(got/need, 15).."</code>\n<b>•ATK:</b> %s\n<b>•DEF:</b> %s\n<b>•AGI:</b> %s\n<b>•HP:</b> %d/%d\n<b>•Mana</b> %d/%d\n<b>•Money:</b> "..formatMoney(data.g).."\n<code>Critical: %2.2f%%\nEvasion: %2.2f %%\nAccuracy: %2.2f %%\nBlock: %2.2f %%\nMax damage: %d\n</code>"
	if not tool then 
		str = str.."\n"..(data.s > 0 and ("<b>Skill points:</b> "..data.s.." (use /rpgskills on private)") or "")

	end
	return str:format(data.exp, math.max(0,( got/need * 100 )), need-got, data.lvl, 
		tostring(getAttack(data)..(" <code>("..getAttack(data, true)..")</code>") ):gsub("%%","%%"), 
		tostring(getDefense(data)..(" <code>("..getDefense(data, true)..")</code>") ):gsub("%%","%%"),
		tostring(getEvasion(data)..(" <code>("..getEvasion(data, true)..")</code>") ):gsub("%%","%%"), 
		
		data.h, health,
		data.mana, getManaMax(data),
		math.min(75 , (4 + math.min(70,(getAttack(data)/80 + getEvasion(data)/60) ) ) * getAttributePercent(data, ITEM_CLASS_CRITICAL) ),

		getEvadeChance(data) / 10,
		getAccuracyChance(data) / 10,
		calculateBlockChance(data) /10,
		calculateMaxDamage(data)
		

		)
end

function showStats(msg, who, welcome)
	if not who then 
		who = msg.from.username
	end	
	local data = getUserRpg(who)
	if not data then 
		say("Sorry, you dont have a rpg character. use /rpgstart to join")
		return
	end
	
	local from 	= getExpToLevel(data.lvl)
	local to 	= getExpToLevel(data.lvl+1)
 
	local need = (to-from)
	local got  = data.exp-from	
	local setStr = renderSet(data):makeItCute()
	local str = (welcome and "Welcome to the RPG\nYou gain exp while you talk in chats with the bot. Private does'nt work.\n\n" or "").."Stats de @"..who..":\n\n"..pullTrueStats(data).."\n"..(setStr:len() > 0 and ("<b>Equipaments:</b>\n"..setStr) or "")
	

	local wut = bot.sendMessage(msg.chat.id, str, "HTML")
	if msg.chat.type ~= "private" then 
		scheduleEvent(20, function()
			if wut and wut.ok then
				deploy_deleteMessage(wut.result.chat.id,wut.result.message_id)
				deploy_deleteMessage(msg.chat.id,msg.message_id)
			end
		end)
	end
	SaveUser(who)
end

function critical(data, dmg)
	data.e = data.e or 1
	if math.random(0,1000) <= math.min(750 , (40 + math.min(700,10*(getAttack(data)/80 + getEvasion(data)/60) ) ) * getAttributePercent(data, ITEM_CLASS_CRITICAL) ) then 
		return dmg*2.5, " ✴️Critical✴️"
	end
	return dmg, ""
end

function calculateMaxDamage(data)
	return getAttack(data)*1.7 - getEvasion(data)*0.05 
end

function calculateBlockChance(data)

	return math.min(500,math.max(25,math.min(500, (50 + math.min(500, getDefense(data) +  (getDefense(data)*0.5-getAttack(data)*0.45 )*2) ) * getAttributePercent(data, ITEM_CLASS_BLOCK) )))
end
--[[
io.write(string.format("D/A  \t"))
for d=0,250, 10 do
	io.write(string.format("D=%3d\t",d))
end
io.write("\n")
for a=0,250, 10 do 
	io.write(string.format("A=%3d\t",a))
	for d=0,250, 10 do 
		local n = math.min(500, (50 + math.min(500, d +  (d*0.5-a*0.5 )*2) )  )/10
		if n <= 0 then 
			io.write("[not]\t")
		else
			io.write(string.format("%2.2f%%\t",n))
		end
	end
	io.write("\n")
end]]


function attack( a,b, bd )
	b.e = b.e or 1
	if getAttack(a) <= 0 or getDefense(a) <= 0 then 
		a.h = 0
		return " have negative atk/def and fell on the ground dead."
	end
	local log = bd.firstTurn and "attacking "..b.n or "attacks "..b.n

	local evadePerc = getEvadeChance(b)
	local accuracyPerc = getAccuracyChance(a)

	

	local selfDamage = false
	if a.id == b.id then
		log = "damaged itself"
		selfDamage = true
	end 
	--local aux = getAttack(a) --100 * (math.log10(aux*aux) )  * math.pow(bd.tire, 1/6)
	local mdmg = calculateMaxDamage(a)
	local dmg = math.random(math.ceil(mdmg*0.7), mdmg )
	local def = math.floor(getDefense(b) / math.pow(bd.tire, 1/12))
	--aux = getDefense(a)
	--local def = 100 * (math.log10(aux*aux) ) / math.pow(bd.tire, 1/16)

	--log = "["..dmg.."/"..def.."] "
	--dmg = math.random(dmg/2, dmg)
	dmg = math.floor(dmg * math.pow(bd.tire, 1/6))
	def = math.ceil(def)



	if selfDamage then 
		--dmg = math.ceil(a.tdmg and (getAttack(a)*1.5) or math.max(1,math.floor(dmg - def*0.8)))
		dmg, crit = critical(a, dmg) 
		

		dmg = math.floor((1 + getAttributePercent(a, ITEM_CLASS_DAMAGE_AMP) - getAttributePercent(b, ITEM_CLASS_DAMAGE_RED)) * dmg)
		log = log .. " dealing <i>"..(a.tdmg and "❗️" or "")..dmg..(a.tdmg and "❗️" or "")..crit.." damage</i>."

		b.h = b.h - dmg

		local drain = math.floor((getAttributePercent(a, ITEM_CLASS_LIFEDRAIN)-1) * dmg) * (1+((1-getAttributePercent(a, ITEM_CLASS_HEAL)/8)))
		a.h = a.h + drain
		if (drain > 1) then 
			log = log .. ' <pre>Drained '..(drain)..' life.</pre>'
		end

		a.tdmg = nil
		return log
	end


	if (math.random(0,1000) <= evadePerc) and not a.tdmg then 

		evadePerc = math.random(evadePerc/2, evadePerc)
		local oldAccuracy = accuracyPerc
		accuracyPerc = math.random(accuracyPerc/2, accuracyPerc)

		if accuracyPerc <=  evadePerc then
			return log.." but "..b.n.." evaded!"
		end
		accuracyPerc = oldAccuracy
	end

	if ((getAttributePercent(a, ITEM_CLASS_INSTAKILL) -1) * 100) > math.random(0, 1000) then 
		b.h = 0
		return log .." <u>was a insta kill!</u>."
	end
	

	--if dmg > def or a.tdmg or math.random(0,1000) <= accuracyPerc then
		
	dmg = dmg - def * 2.2

	if dmg <= 0 then 

		dmg = math.ceil(dmg*(-0.6))
		if dmg == 0 or  (math.random(0,1000) <= getEvadeChance(a)/4) then 
			return log .." <u>🛡but was blocked🛡</u>."
		end
		dmg, crit = critical(a, dmg) 

		dmg = (1 + getAttributePercent(b, ITEM_CLASS_DAMAGE_AMP) - getAttributePercent(a, ITEM_CLASS_DAMAGE_RED)) * dmg

		local drain = math.floor((getAttributePercent(a, ITEM_CLASS_LIFEDRAIN)-1) * dmg) * (1+((1-getAttributePercent(a, ITEM_CLASS_HEAL)/8)))
		b.h = b.h + drain
		if (drain > 1) then 
			log = log .. ' <pre>Drained '..(drain)..' life.</pre>'
		end

		a.h = a.h - dmg
		log = log .. " <u>🛡but was blocked🛡</u> and "..b.n.." dealt <b>"..dmg..crit.." damage </b> as <i>parry</i> on "..a.n.."."
		if (drain > 1) then 
			log = log .. ' Drained '..(drain)..' life.'
		end
		return log
	end


	if not a.tdmg and  ( math.random(0,1000) <= (calculateBlockChance(b) - accuracyPerc/2 ) ) then
		if calculateBlockChance(b) > getEvadeChance(a) then 
			dmg = getDefense(b)*3
			dmg, crit = critical(a, dmg) 

			dmg = math.floor((1 + getAttributePercent(b, ITEM_CLASS_DAMAGE_AMP) - getAttributePercent(a, ITEM_CLASS_DAMAGE_RED)) * dmg)

			a.h = a.h - dmg

			local drain = math.floor((getAttributePercent(b, ITEM_CLASS_LIFEDRAIN)-1) * dmg) * (1+((1-getAttributePercent(a, ITEM_CLASS_HEAL)/8)))
			b.h = b.h + drain
			if (drain > 1) then 
				log = log .. ' <pre>Drained '..(drain)..' life.</pre>'
			end


			log = log .. " <u>🛡but was blocked🛡</u> and "..b.n.." dealt <b>"..dmg..crit.." damage </b> as <i>reflect</i> on "..a.n.."."
			if (drain > 1) then 
				log = log .. ' Drained '..(drain)..' life.'
			end
			return log
		else
			return log .." <u>🛡but was blocked🛡</u>."
		end
	end

	
	local crit = ""
	dmg, crit = critical(a, dmg) 

	


	dmg = math.floor((1 + getAttributePercent(a, ITEM_CLASS_DAMAGE_AMP) - getAttributePercent(b, ITEM_CLASS_DAMAGE_RED)) * dmg)

	log = log .. " dealing <b>"..(a.tdmg and "❗️" or "")..dmg..(a.tdmg and "❗️" or "")..crit.." damage</b>."
	b.h = b.h - dmg

	local drain = math.floor((getAttributePercent(a, ITEM_CLASS_LIFEDRAIN)-1) * dmg) * (1+((1-getAttributePercent(a, ITEM_CLASS_HEAL)/8)))
	a.h = a.h + drain
	if (drain > 1) then 
		log = log .. ' Drained '..(drain)..' life.'
	end

	a.tdmg = nil

	--[[else 
		log = log .. " with "..dmg
		dmg = math.floor(getDefense(b) * math.pow(bd.tire, 1/6))
		if math.random(0,1000) <= (getEvadeChance(a)) then
			return log .." <u>🛡but was blocked🛡</u>."
		end
		local crit = ""
		dmg, crit = critical(a, dmg) 
		a.h = a.h - dmg
		log = log .. " <u>🛡but was blocked🛡</u> and dealt <b>"..dmg..crit.." damage </b> in <i>reflect</i>."
	end]]

	return log

end


function turn_miss(a,b, bd)
	if getAttack(a) > (getDefense(a)+getEvasion(a))*1.4 then
		return " missed and "..attack(a,a, bd), "⚠️"
	elseif (math.random(0, 1000) <= math.min(700,10*getEvasion(a)/20) ) then
		return attack(a,b, bd), a.tdmg and "‼️" or "💥"
	else
		a.tdmg = nil
		return "but it was a <u>MISS</u>!", "☁️"
	end
end

function turn_moredef(a,b, bd)
	local more = math.ceil(math.random(3,15)* math.pow(bd.tire, 1/4) * getAttributePercent(a, ITEM_CLASS_TEMP) )
	a.td = (a.td or 0) + more
	return "took a defensive position. <b>+"..more.." DEF</b>" , "🛡"
end

function turn_moreatk(a,b, bd)
	local more = math.ceil(math.random(5,8)* math.pow(bd.tire, 1/4) * getAttributePercent(a, ITEM_CLASS_TEMP) )
	a.ta = (a.ta or 0) + more
	return "took a defensive position. <b>+"..more.." DEF</b>" , "⚔️"
end

function turn_heal(a,b, bd)
	local heal = math.floor( ( math.random(5,25) * (1/4 * a.lvl) )* getAttributePercent(a, ITEM_CLASS_HEAL) * getAttributePercent(a, ITEM_CLASS_TEMP))
	a.h = a.h + heal 
	return "took theturn to heal himself. <b>+"..heal.." HP</b>." , "💚"
end

function turn_confuse(a,b, bd)
	if getAttack(a) > (getEvasion(a)+getDefense(a))*1.4 then
		return "got confused and"..attack(a,a, bd), "💫"
	else
		return "got confused and lost the turn.", "💫" 
	end
end

function turn_true(a,b, bd)
	a.tdmg = true
	--a.rep = (a.rep or 0) + 1
	return "prepared himself to do a <b>true damage</b> on next turn." ,"💢"
end

function turn_adrenalline(a,b, bd)
	a.rep = (a.rep or 0) + 2
	return "got adrenaline rush and its going to have two turns." ,"⏩"
end

function turn_attack(a,b, bd)
	return attack(a,b, bd), a.tdmg and "‼️" or "💥"
end

function turn(a,b, bd)
	local log = ""
	local todo = math.random(0,1000)
	if bd.firstTurn then 
		log = log .. "started "	
	end
	if a.tdmg then 
		todo = 1000
	end
	local startmsg = a.n.." ["..a.h.."/"..a.hm.."]"
	local emoj = ""


		local moveStat = math.min(70,getEvasion(a)/10)
		local defStat = math.min(5,getDefense(a))
		local acc = getAccuracyChance(a)/3
		local dos = {
			{chance=480-acc, 	turn_miss },
			--{chance=200, 	turn_moreatk},
			--{chance=200, 	turn_moredef},
			{chance=150+ defStat * 2, 	turn_heal  }, 
			{chance=250 	-  moveStat*2, 	turn_confuse},
			{chance=190+moveStat, 	turn_true},
			{chance=150		+ moveStat*2, 	turn_adrenalline },
			{chance=1000 , 	turn_attack},
		}

		local canDo = {}
		for i=1,#dos do 
			if todo <= dos[i].chance then 
				canDo[#canDo+1] = dos[i][1]
			end
		end

		if #canDo == 0 then 
			canDo[1] = dos[#dos][1]
		end

		local r1, r2 = canDo[math.random(1,#canDo)](a,b, bd)
		log = log .. r1 
		emoj = r2

	
	if a.h <= 0 or b.h <= 0 then 
		emoj = "⚰️"
	end
	bd.firstTurn = false
	--a.h = 0
	return emoj.."("..todo..") <b>"..startmsg.."</b> "..log.."\n"
end

function battle(fulano, ciclano, an, bn, fun)

	local a = type(fulano) == 'table' and fulano or getUserRpg(fulano)
	local b = type(ciclano) == 'table' and ciclano or getUserRpg(ciclano)

	if not a or not b then 
		error("MISSING OBJ RPG "..fulano.."|"..ciclano)
	end

	writeLog(a, "is battling as a")
	writeLog(b, "is battling as b")

	a.n = an
	b.n = bn

	updateHealthByTicks(a)
	updateHealthByTicks(b)

	a.hm = maxHealth(a)
	b.hm = maxHealth(b)
	a.h = math.min(a.h, a.hm)
	b.h = math.min(b.h, b.hm)
	local log = ""
	local first = (math.abs(a.lvl-b.lvl) < 5) and (math.random(0, 100) > 50) or (a.lvl < b.lvl)
	local bd = {
		firstTurn = true,
		tire = 1,
		cycles=0,
	}
	if (math.abs(a.lvl-b.lvl) > 2) then 
		local more = 1 + (math.abs(a.lvl-b.lvl)-2)
		more = math.floor(math.max(1, more*0.50))
		more =  math.min(5, more)
		local who = a.lvl > b.lvl and b or a
		log = log .. "🔮 The level difference is too big. "..who.n.." has <b>extra "..(more).." turns</b>!\n"
		who.rep = more		
	end
	


	while (a.h > 0 and b.h > 0) do 
		print(a.n, a.h, b.n, b.h, "->>", bd.tire)
		if first then 
			log = log..turn(a,b, bd)
			if not a.rep then
				first = false
			else 
				a.rep = a.rep -1
				if a.rep < 0 then 
					a.rep = nil
					first = false
					bd.cycles = bd.cycles +1
				end
			end
		else 
			log = log..turn(b,a, bd)
			if not b.rep then

				first = true
			else 
				b.rep = b.rep -1
				if b.rep < 0 then 
					b.rep = nil
					first = true
					bd.cycles = bd.cycles +1
				end
			end
		end
		bd.tire = bd.tire +1
		if a.h <= 0 or b.h <= 0 then
			break
		end
	end


	local drain = 0
	if a.h <= 0 then 
	
		local less = math.floor(a.g * 0.05)

		drain = math.floor( (getExpToLevel(a.lvl+1)-getExpToLevel(a.lvl))*0.1 )

		local expected = drain 	

		local more = false
		local noLess = getExpToLevel(a.lvl)
		if a.exp-drain < noLess then 
			drain = a.exp-noLess
			less = math.floor(a.g * 0.4)
			more = true
		end
		drain = math.max(drain, 0)
		a.de = a.de+1
		b.ki = b.ki+1

		if fun then 
			less = 0
			drain = 0
		end

		addGold(a, -less)
		addGold(b, less)
		log = log .. "\n<b>"..b.n.." ["..math.max(b.h,0).."/"..b.hm.."]</b> defeated 🏳️<b>"..a.n.." ["..math.max(a.h,0).."/"..a.hm.."]</b>🏳️ Stole <i>"..drain.." EXP "..(more and " and as a penalty for not having enought exp ("..expected.."), took 40% of the money, total of " or " and ").." "..formatMoney(less).." from the loser</i>!"
		
		--log = log .. "DEBUG: A: "..Dump(a).."\nDEBUG B:"..Dump(b)

		checkQuestInner(b, ciclano, nil, "battle-win")

	else 
		
		local less = math.floor(b.g * 0.04)
		
		
		drain = math.floor( (getExpToLevel(a.lvl+1)-getExpToLevel(a.lvl))*0.1 )
	

	
		local expected = drain
		local more = false
		local noLess = getExpToLevel(b.lvl)
		b.de = b.de+1
		a.ki = a.ki+1

		if b.exp-drain < noLess then 

			drain = b.exp - noLess
			less = math.floor(b.g * 0.4)
			more = true
		end
		drain = math.max(drain, 0)

		if fun then 
			less = 0
			drain = 0
		end

		addGold(b, -less)
		addGold(a, less)

		
		log = log .. "\n<b>"..a.n.." ["..math.max(a.h,0).."/"..a.hm.."]</b> defeated 🏳️<b>"..b.n.." ["..math.max(b.h,0).."/"..b.hm.."]</b>🏳️! Stole <i>"..drain.." EXP "..(more and " and as a penalty for not having enought exp ("..expected.."), took 20% of the money, total of " or " and ").." "..formatMoney(less).."from the loser</i>"
		checkQuestInner(a, fulano, nil, "battle-win")
		--log = log .. "DEBUG: A: "..Dump(a).."\nDEBUG B:"..Dump(b)
	end
	a.ta = nil
	a.td = nil
	b.ta = nil
	b.td = nil


	a.n = nil
	b.n = nil
	a.tdmg = nil
	b.tdmg = nil
	a.rep = nil
	b.rep = nil

	writeLog(a, "finished a")
	writeLog(b, "finished b")
	
	return log, function()
		--print("Exp a:"..a.exp)
		--print("Exp b:"..b.exp)
		if a.h <= 0 then 
			drainExp(b, a, drain)
		else 
			drainExp(a, b, drain)
		end
		a.h = math.max(0,a.h)
		b.h = math.max(0,b.h)

		writeLog(a, "battle done as a")
		writeLog(b, "battle done as b")
	end

end




function probabilities(fulano, ciclano, an, bn)

	local a = type(fulano) == 'table' and fulano or getUserRpg(fulano)
	local b = type(ciclano) == 'table' and ciclano or getUserRpg(ciclano)

	if not a or not b then 
		error("MISSING OBJ RPG "..fulano.."|"..ciclano)
	end

	local aah = a.h
	local bbh = b.h
	
	local wa = 0
	local wb = 0
	for i=1,500 do 
		a.n = an
		b.n = bn
		a.hm = maxHealth(a)
		b.hm = maxHealth(b)
		a.h = a.hm 
		b.h = b.hm
		local first = (math.abs(a.lvl-b.lvl) < 5) and (math.random(0, 100) > 50) or (a.lvl < b.lvl)
		local bd = {
			firstTurn = true,
			tire = 1,
			cycles=0,
		}
		if (math.abs(a.lvl-b.lvl) > 2) then 
			local more = 1 + (math.abs(a.lvl-b.lvl)-2)
			more = math.floor(math.max(1, more*0.50))
			more =  math.min(5, more)
			local who = a.lvl > b.lvl and b or a
			who.rep = more		
		end	


		while (a.h > 0 and b.h > 0) do 
			if first then 
				turn(a,b, bd)
				if not a.rep then
					first = false
				else 
					a.rep = a.rep -1
					if a.rep < 0 then 
						a.rep = nil
						first = false
						bd.cycles = bd.cycles +1
					end
				end
			else 
				turn(b,a, bd)
				if not b.rep then

					first = true
				else 
					b.rep = b.rep -1
					if b.rep < 0 then 
						b.rep = nil
						first = true
						bd.cycles = bd.cycles +1
					end
				end
			end
			bd.tire = bd.tire +1
			if a.h <= 0 or b.h <= 0 then
				break
			end
		end

		a.ta = nil
		a.td = nil
		b.ta = nil
		b.td = nil


		a.n = nil
		b.n = nil
		a.tdmg = nil
		b.tdmg = nil
		a.rep = nil
		b.rep = nil

		local drain = 0
		if a.h <= 0 then 
			wb = wb +1
		else 
			wa = wa +1
		end
		
	
	end

	a.h = aah
	b.h = bbh
	
	return wa, wb
end

--[[
local a =battle({
	exp = getExpToLevel(22),
	a=10,
	d=10,
	h=80,
	v=30,
	g=10,
	lvl=21,
}, {
	exp = getExpToLevel(23),
	a=100,
	d=100,
	v=300,
	h=300,
	g=300,
	lvl=24,
}, "Mock","TOberal")

]]


--Renato [163/204] defeated 🏳️Mock [0/222]🏳️! Stole -3448 EXP  and as a penalty for not having enought exp (871), took 40% of the money, total of  39💵from the loserDEBUG: A:   a = 85
  --[[
local a = {
  exp = 5252,
  d = 92,
  g = 447,
  h = 163,
  loot = 1578333517,
  m = 1578333591,
  level = 1,
  n = 'Renato',
  s = 0,
  id = 902671345,
  t = 1578333599,
  v = 68,
  lvl = 18,
  
  hm = 204,
  boss = 1578283689,
  cd = 1578330328,
}


b = {  a = 17,
  exp = 8702,
  d = 96,
  g = 96,
  boss = 1578284123,
  loot = 1578332454,
  m = 1578333578,
  level = 1,
  n = Mock,
  s = 0,
  id = 81891406,
  t = 1578333607,
  v = 62,
  lvl = 21,
  hm = 222,
  cd = 1578329726,
  
  h = -40,
}
local e = battle(b,a, "Renato", "Mock")
print(e)]]

