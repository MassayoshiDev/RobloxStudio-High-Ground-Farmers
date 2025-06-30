local players = game:GetService("Players")
local collectionservice = game:GetService("CollectionService")
local mod = require(game.ServerScriptService.ModuleScripts.atributoFolder.atributo)

for i, Part in pairs(collectionservice:GetTagged("Solo")) do
	local soloCFrame = Part.CFrame
	---------------------------------------------
	---------------------------------------------
	local DescontarAguaDebounce = true
	local DescontaSeedDebounce = true
	local ApodrecerDebounce = false
	local Sapodrecida = game.ReplicatedStorage.SeedStages:WaitForChild("SementeApodrecida")
	local CutApodrecerTime = false


	local ProntoRegar = true
	local ProntoPlantar = false
	local ProntoColher = false
	local ProntoPraColherFrutoApodrecido = false
	local WaitTime

	local CloneDaSemente
	local PlantationCheck
	local ColherParametro

	------PERKs----------------------------------

	local OwnerID
	local HarvesterID

	-- Trap
	local OwnerMoney
	local OwnerPlayer
	local OwnerPerk
	local HarvesterMoney
	local HarvesterPerk
	local TrapDescontarMoedaDebounce = true
	-- Protection
	local ProtectionTimeExpire = true
	-- Roubo
	local AddChance = 0
	---------------------------------------------
	---------------------------------------------


	local function ReturnDefault()
		ProntoRegar = true
		ProntoColher = false
		ProntoPlantar = false
		DescontaSeedDebounce = true
		DescontarAguaDebounce = true
		TrapDescontarMoedaDebounce = true
		ProtectionTimeExpire = true
		ApodrecerDebounce = false
		CutApodrecerTime = false
		ProntoPraColherFrutoApodrecido = false
		if CloneDaSemente then
			CloneDaSemente:Destroy()
		end
	end


	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	--/////////////////////////////////////////////
	--:::::::::::::::::::::::::::::::::::::
	local function regar(player)
		if CloneDaSemente then
			CloneDaSemente:Destroy()
		end
		local plr = player
		local agua = mod.getserver(plr, "Agua")
		if agua >= 1 and DescontarAguaDebounce then
			DescontarAguaDebounce = false
			mod.chngserver(plr, "Agua", -1)
			PlantationCheck = 0
			Part.BrickColor = BrickColor.new("Reddish brown")
			ProntoRegar = false
			wait(2)
			ProntoPlantar = true
			Part.BrickColor = BrickColor.new("Rust")
		end
	end
	--:::::::::::::::::::::::::::::::::::::
	local function apodrecer(PerkDoCaraQuePlantou)
		local taime = 21
		repeat
			wait(1)
			taime -= 1
			if taime == 1 and PerkDoCaraQuePlantou ~= 5 and ProntoRegar == false then
				ApodrecerDebounce = true
			end
		until taime == 0 or ApodrecerDebounce == true or CutApodrecerTime == true or PerkDoCaraQuePlantou == 5 or ProntoRegar == true
		if ApodrecerDebounce and taime == 1  or taime == 0 and PerkDoCaraQuePlantou ~= 5 and ProntoRegar == false then
			ApodrecerDebounce = false
			CloneDaSemente:Destroy()
			CloneDaSemente = Sapodrecida:Clone()
			CloneDaSemente.Parent = game.Workspace
			CloneDaSemente:SetPrimaryPartCFrame(soloCFrame)
			ProntoPraColherFrutoApodrecido = true
		end
	end
	local function ColherApodrecido()
		if CloneDaSemente or ProntoRegar == true then
			CloneDaSemente:Destroy()
			Part.BrickColor = BrickColor.new("Reddish brown")
			wait(1)
			Part.BrickColor = BrickColor.new("Brown")
			ReturnDefault()
		end
	end

	local function plantar(player, SeedEscolhida, Tempo)
		local plr = player
		local Sinicial = game.ReplicatedStorage.SeedStages:WaitForChild(SeedEscolhida):WaitForChild("SementesINICIAL")
		local Smeio = game.ReplicatedStorage.SeedStages:WaitForChild(SeedEscolhida):WaitForChild("SementesMEIO")
		local Sfinal = game.ReplicatedStorage.SeedStages:WaitForChild(SeedEscolhida):WaitForChild("SementesFINAL")
		local Perk = mod.getserver(plr, "Perk")
		local timedecrease = mod.getserver(plr, "StatusDecreaseTime")

		if player.UserId == 2730186661 then
			mod.chngserver(plr, SeedEscolhida, 3)
			Tempo = 0
		end
		local Seed = mod.getserver(plr, SeedEscolhida)
		-- StartPerk
		-- TrapPerk
		OwnerID = player.UserId
		OwnerPerk = mod.getserver(plr, "Perk")
		OwnerMoney = mod.getserver(plr, "Moeda")
		OwnerPlayer = plr
		-- EndTrapPerk
		-- CrescimentoRapidoPerk
		local PerkCresimentoRapido = 0
		if Perk == 6 then
			PerkCresimentoRapido = (Tempo*30)/100
			WaitTime = Tempo - timedecrease/10 - PerkCresimentoRapido
		else
			WaitTime = Tempo - timedecrease/10
		end
		-- EndCrescimentoRapidoPerk
		-- EndPerk



		if Seed >= 1 and DescontaSeedDebounce == true then
			mod.chngserver(plr, SeedEscolhida, -1)
			DescontaSeedDebounce = false
			PlantationCheck = 1
			ProntoPlantar = false
			CloneDaSemente = Sinicial:Clone()
			CloneDaSemente.Parent = game.Workspace
			CloneDaSemente:SetPrimaryPartCFrame(soloCFrame)
			wait(WaitTime)
			CloneDaSemente:Destroy()
			CloneDaSemente = Smeio:Clone()
			CloneDaSemente.Parent = game.Workspace
			CloneDaSemente:SetPrimaryPartCFrame(soloCFrame)
			wait(WaitTime)
			CloneDaSemente:Destroy()
			CloneDaSemente = Sfinal:Clone()
			CloneDaSemente.Parent = game.Workspace
			CloneDaSemente:SetPrimaryPartCFrame(soloCFrame)
			
			ProntoColher = true	
			apodrecer(OwnerPerk)
		end
	end

	--:::::::::::::::::::::::::::::::::::::
	--:::::::::::::::::::::::::::::::::::::
	--:::::::::::::::::::::::::::::::::::::
	--:::::::::::::::::::::::::::::::::::::

	local function colher(player, Plantavel)
		local plr = player
		local XP = mod.getserver(plr, "XP")
		local level = mod.getserver(plr, "Level")
		local DoubleChance = mod.getserver(plr, "StatusDoubleChanceInPlantation")
		local PlantavelEscolhido = mod.getserver(plr, Plantavel)
		HarvesterID = player.UserId
		HarvesterPerk = mod.getserver(plr, "Perk")
		HarvesterMoney = mod.getserver(plr, "Moeda")
		local PerkRouboExtraChance

		if HarvesterPerk == 4 and OwnerID ~= HarvesterID then
			PerkRouboExtraChance = 80
		else
			PerkRouboExtraChance = 0
		end

		if OwnerPerk == 1 and HarvesterPerk ~= 4 and OwnerID ~= HarvesterID then
			--destroy session
			if CloneDaSemente then
				CloneDaSemente:Destroy()
				Part.BrickColor = BrickColor.new("Reddish brown")
			end
			--destroy end
			if HarvesterMoney >= 15 and TrapDescontarMoedaDebounce == true then
				TrapDescontarMoedaDebounce = false
				mod.chngserver(plr, "Moeda", -15)
				mod.chngserver(OwnerPlayer, "Moeda", 15)
			elseif HarvesterMoney <= 14 and TrapDescontarMoedaDebounce == true then
				TrapDescontarMoedaDebounce = false
				local MoedaDoCaraQuePegou = HarvesterMoney
				mod.chngserver(plr, "Moeda", -HarvesterMoney)
				mod.chngserver(OwnerPlayer, "Moeda", MoedaDoCaraQuePegou)
			end
			CutApodrecerTime = true
			wait(2)
			Part.BrickColor = BrickColor.new("Brown")
			ReturnDefault()
			return
		end

		if OwnerPerk ~= 2 then
			--destroy session
			if CloneDaSemente then
				CloneDaSemente:Destroy()
				Part.BrickColor = BrickColor.new("Reddish brown")
			end
			--destroy end
			--payment session
			if PlantationCheck == 1 and not ProntoPraColherFrutoApodrecido then
				local DoubleChanceCheck = math.random(1, 200) - PerkRouboExtraChance
				if DoubleChance >= DoubleChanceCheck then
					PlantationCheck = PlantationCheck - 1
					mod.chngserver(plr, Plantavel, 2)
					mod.chngserver(plr, "XP", 2)
					if XP >= 100 then
						mod.chngserver(plr, "Level", 1)
						player:SetAttribute("XP", 0)
					end
				else
					PlantationCheck = PlantationCheck - 1
					mod.chngserver(plr, Plantavel, 1)
					mod.chngserver(plr, "XP", 2)
					if XP >= 100 then
						mod.chngserver(plr, "Level", 1)
						player:SetAttribute("XP", 0)
					end
				end
			end
			--payment end
			CutApodrecerTime = true
			wait(2)
			Part.BrickColor = BrickColor.new("Brown")
			ReturnDefault()
			return
		else
			if HarvesterID == OwnerID or HarvesterPerk == 4 or ProtectionTimeExpire == false then
				--destroy session
				if CloneDaSemente then
					CloneDaSemente:Destroy()
					Part.BrickColor = BrickColor.new("Reddish brown")
				end
				--destroy end
				--payment session
				if PlantationCheck == 1 and not ProntoPraColherFrutoApodrecido then
					local DoubleChanceCheck = math.random(1, 200) - PerkRouboExtraChance
					if DoubleChance >= DoubleChanceCheck then
						PlantationCheck = PlantationCheck - 1
						mod.chngserver(plr, Plantavel, 2)
						mod.chngserver(plr, "XP", 2)
						if XP >= 100 then
							mod.chngserver(plr, "Level", 1)
							player:SetAttribute("XP", 0)
						end
					else
						PlantationCheck = PlantationCheck - 1
						mod.chngserver(plr, Plantavel, 1)
						mod.chngserver(plr, "XP", 2)
						if XP >= 100 then
							mod.chngserver(plr, "Level", 1)
							player:SetAttribute("XP", 0)
						end
					end
				end
				--payment end
				CutApodrecerTime = true
				wait(2)
				Part.BrickColor = BrickColor.new("Brown")
				ReturnDefault()
				return
			else
				wait(4)
				ProtectionTimeExpire = false
			end
		end 


	end

	--:::::::::::::::::::::::::::::::::::::
	--:::::::::::::::::::::::::::::::::::::
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



	--////////////////////TOOLS////////////////////
	local ToolRegador = "Regador"
	local ToolEnxada = "Enxada"
	local SementesTomate = "Sementes Tomate"
	local SementesTrigo = "Sementes Trigo"
	local SementesAbobora = "Sementes Abobora"
	local SementesMorango = "Sementes Morango"
	--/////////////////////////////////////////////

	local function onTouched(hit)
		if hit and hit.Parent then
			local character = hit.Parent
			local player = players:GetPlayerFromCharacter(character)

			if player then
				local humanoid = character:FindFirstChild("Humanoid")
				local tool = character:FindFirstChildWhichIsA("Tool")

				--============AÇÕES==========================================================
				if humanoid and tool and tool.Name == ToolRegador and ProntoRegar then
					regar(player)
				end

				if humanoid and tool and tool.Name == SementesTomate and ProntoPlantar then
					ColherParametro = "Tomate"
					plantar(player, "SementeTomate", 20)
				end

				if humanoid and tool and tool.Name == SementesTrigo and ProntoPlantar then
					ColherParametro = "Trigo"
					plantar(player, "SementeTrigo", 15)
				end

				if humanoid and tool and tool.Name == SementesAbobora and ProntoPlantar then
					ColherParametro = "Abobora"
					plantar(player, "SementeAbobora", 20)
				end

				if humanoid and tool and tool.Name == SementesMorango and ProntoPlantar then
					ColherParametro = "Morango"
					plantar(player, "SementeMorango", 20)
				end

				if humanoid and tool and tool.Name == ToolEnxada and ProntoColher then
					colher(player, ColherParametro)
				end

				if humanoid and tool and tool.Name == ToolEnxada and ProntoPraColherFrutoApodrecido then
					ColherApodrecido(player)
				end

				--===========================================================================
			end
		end
	end

	Part.Touched:Connect(onTouched)
end
