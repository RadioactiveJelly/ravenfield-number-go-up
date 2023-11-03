-- Register the behaviour
behaviour("NumberGoUpHUD")

function NumberGoUpHUD:Start()
	local function onExp(val)
		self:UpdateMeter()
	end
	self.targets.NGU.self:SubscribeToGainExpEvent(self, onExp)

	local function onLevelUp(oldLvl, newLvl)
		self:UpdateMeter()
		self:UpdateLevelText()
		self.targets.Animator.SetTrigger("LevelUp")
		self.targets.AudioSource.Play()
	end
	self.targets.NGU.self:SubscribeToLevelUpEvent(self, onLevelUp)

	self:UpdateMeter()
	self:UpdateLevelText()
end

function NumberGoUpHUD:UpdateMeter()
	local expReq = self.targets.NGU.self:GetEXPRequired()
	local playerExp = self.targets.NGU.self.playerExp

	self.targets.ExpText.text = playerExp .. "/" .. expReq
	self.targets.ExpBar.fillAmount = playerExp/expReq
end

function NumberGoUpHUD:OnExpGain()
	self:UpdateMeter()
end

function NumberGoUpHUD:UpdateLevelText()
	self.targets.LevelText.text = "LVL " .. self.targets.NGU.self.playerLevel
end