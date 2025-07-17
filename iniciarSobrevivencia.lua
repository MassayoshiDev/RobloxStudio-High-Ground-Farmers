local player = game.Players.LocalPlayer

local function iniciarSobrevivencia()
	local maxTime = 2
	local startTime = tick()
	local attr

	repeat
		wait()
		attr = player:GetAttribute("StartSobrevivencia")
	until attr ~= nil or tick() - startTime > maxTime

	local startAttr = attr or 0
	local iniciar = startAttr == 0

	if iniciar then
		print("PREPARANDO MODO SOBREVIVÊNCIA...")
		game.ReplicatedStorage.RemoteEvents.sobrevivencia.iniciarModoSobrevivencia:FireServer()
	else
		print("O PLAYER "..player.Name.." JÁ ESTÁ COM O MODO SOBREVIVÊNCIA ATIVO.")
	end

	task.wait(1.5)

	local function decFome(qnt)
		qnt = qnt or 1
		for i = 1, qnt do
			if player:GetAttribute("Fome") > 0 then
				task.wait(0.1)
				game.ReplicatedStorage.RemoteEvents.sobrevivencia.diminuir.fome:FireServer()
			end
		end
	end

	local function decSede(qnt)
		qnt = qnt or 1
		for i = 1, qnt do
			if player:GetAttribute("Sede") > 0 then
				task.wait(0.1)
				game.ReplicatedStorage.RemoteEvents.sobrevivencia.diminuir.sede:FireServer()
			end
		end
	end

	local function decVida(qnt)
		qnt = qnt or 1
		for i = 1, qnt do		
			task.wait(0.1)
			if player:GetAttribute("Vida") > 0 then
				game.ReplicatedStorage.RemoteEvents.sobrevivencia.diminuir.vida:FireServer()
			else
				game.ReplicatedStorage.RemoteEvents.sobrevivencia.morrer:FireServer(player)
			end
		end
	end

	while player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 do
		-- Explicando cada coisa na parte Dec do sistema de sobrevivência:
		-- [1] Ver se o player não está com fome e nem com sede
		-- 	┗ SIM:
		--		Se o player estiver bem, o loop será rodado mais devagar
		--	┗ NÃO:			
		--		Se estiver, o loop rodará mais rápido, diminuindo mais ainda os seus status
		-- [2] Depois, ele vê se o player está esfomeado ou com sede
		--	┗ SIM:
		--		Se for verdade, ele diminui a vida e outros status
		--	┗ NÃO:
		--		Se não, o processo de diminuição acontece normalmente
		--			┗ Sortea um número aleatório, um ou dois
		--				┗ UM: Diminuir Fome
		--					┗ Sortear número aleatório até 11
								┗ Se pegar 11, diminui 2 de fome
								┗ 5 ou menos diminui 1 de fome
								┗ Diminui 1 de fome
		--				┗ DOIS: Diminuir Sede
							┗ Diminui 1 de sede
		if player:GetAttribute("Fome") > 0 and player:GetAttribute("Sede") > 0 then
			local plusTime = math.random(1, 4)
			task.wait(4 + plusTime)
		else
			task.wait(1)
		end
		if player:GetAttribute("Sede") <= 0 or player:GetAttribute("Fome") <= 0 then
			decVida(4)
			decFome(3)
			decSede(3)
		else
			local WhichOneGonnaDec = math.random(1, 2) == 1
			if WhichOneGonnaDec then
				local decMoreHungry = math.random(1, 11)
				if decMoreHungry <= 5 then
					decFome(1)	
				elseif decMoreHungry == 11 then
					decFome(2)
				end
				decFome(1)			
			else
				decSede(1)			
			end
			decSede(1)	
		end
	end

	print("MODO SOBREVIVÊNCIA PAUSADO - "..player.Name.." MORREU")
end

-- Executa ao iniciar o jogo
iniciarSobrevivencia()

-- Reexecuta sempre que o personagem renascer
player.CharacterAdded:Connect(function()
	task.wait(1) -- Espera o personagem ser carregado
	iniciarSobrevivencia()
end)
