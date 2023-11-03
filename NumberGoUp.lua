-- Register the behaviour
behaviour("NumberGoUp")

function NumberGoUp:Awake()
	self.gameObject.name = "Number Go Up"
	self.expGainListeners = {}
	self.levelUpListeners = {}
end

function NumberGoUp:Start()
	self.script.StartCoroutine(self:DelayedStart())

	self.baseXP = 1500
	self.multiplier = 1.3
	self.levelCap = 100

	if self.script.modSaveData then
		self:LoadData()
	else
		print("<color=red>Save data is nil!</color>")
	end
	

	self.hasMatchEnded = false
	GameEvents.onMatchEnd.AddListener(self,"OnMatchEnd")
end

--Score system compatibility
function NumberGoUp:DelayedStart()
	return function()
		coroutine.yield(WaitForSeconds(0.1))
		local scoreSystemObj = self.gameObject.Find("Score System")
		if scoreSystemObj then
			self.scoreSystem = scoreSystemObj.GetComponent(ScriptedBehaviour)
			local function onScore(score)
				self:AddXP(score)
			end
			self.scoreSystem.self:SubscribeToScoreEvent(self,onScore)
			self.enabled = true
		end
	end
end

function NumberGoUp:Update()
	-- Run every frame
	--[[if Input.GetKeyDown(KeyCode.T) then
		self:AddXP(1500)
	end

	if Input.GetKeyDown(KeyCode.O) then
		self:SaveData()
	end]]--
end

function NumberGoUp:AddXP(val)
	if self.playerLevel >= self.levelCap then return end
	if self.hasMatchEnded then return end

	self.playerExp = self.playerExp + val
	print("Player EXP: " .. self.playerExp .. "/" .. self:GetEXPRequired())

	self:InvokeGainExpEvent(val)
	self:CheckForLevelUp()
end

function NumberGoUp:GetEXPRequired()
	return self.baseXP * self.multiplier * self.playerLevel
end

function NumberGoUp:CheckForLevelUp()
	if self.playerExp >= self:GetEXPRequired() then
		self.playerExp = self.playerExp - self:GetEXPRequired()
		local oldLevel = self.playerLevel
		self.playerLevel = self.playerLevel + 1
		print("Level Up: " .. oldLevel .. " -> " .. self.playerLevel)
		self:InvokeLevelUpEvent(oldLevel, self.playerLevel)
	end
end

function NumberGoUp:LoadData()
	--Create default data if no data is set.
	if not self.script.modSaveData.HasInteger("PlayerLevel") then
		self.script.modSaveData.StoreInteger("PlayerLevel",1)
	end
	if not self.script.modSaveData.HasInteger("PlayerExp") then
		self.script.modSaveData.StoreInteger("PlayerExp",0)
	end

	self.playerLevel = self.script.modSaveData.GetInteger("PlayerLevel")
	self.playerExp = self.script.modSaveData.GetInteger("PlayerExp")

	print("Player Level: " .. self.playerLevel)
	print("Player EXP: " .. self.playerExp .. "/" .. self:GetEXPRequired())

	self:CheckForLevelUp()
end

function NumberGoUp:OnMatchEnd(team)
	if self.script.modSaveData then
		self:SaveData()
		self.scoreSystem.self:UnsubscribeToScoreEvent(self)
	end
	self.hasMatchEnded = true
end

function NumberGoUp:SaveData()
	self.script.modSaveData.StoreInteger("PlayerLevel", self.playerLevel)
	self.script.modSaveData.StoreInteger("PlayerExp", math.floor(self.playerExp))
end

function NumberGoUp:SubscribeToGainExpEvent(owner,func)
	self.expGainListeners[owner] = func
end

function NumberGoUp:UnsubscribeToGainExpEvent(owner)
	self.expGainListeners[owner] = nil
end

function NumberGoUp:InvokeGainExpEvent(exp)
	for owner, func in pairs(self.expGainListeners) do
		func(exp)
	end
end

function NumberGoUp:SubscribeToLevelUpEvent(owner,func)
	self.levelUpListeners[owner] = func
end

function NumberGoUp:UnsubscribeToLevelUpEvent(owner)
	self.levelUpListeners[owner] = nil
end

function NumberGoUp:InvokeLevelUpEvent(oldLevel, newLevel)
	for owner, func in pairs(self.levelUpListeners) do
		func(oldLevel, newLevel)
	end
end