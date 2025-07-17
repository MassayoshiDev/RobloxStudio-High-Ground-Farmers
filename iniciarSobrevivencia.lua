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
				game.ReplicatedStorage.RemoteEvents.sobrevivencia.diminuir.fome:FireServer()
			end
		end
	end

	local function decSede(qnt)
		qnt = qnt or 1
		for i = 1, qnt do
			if player:GetAttribute("Sede") > 0 then
				game.ReplicatedStorage.RemoteEvents.sobrevivencia.diminuir.sede:FireServer()
			end
		end
	end

	local function decVida(qnt)
		qnt = qnt or 1
		for i = 1, qnt do
			if player:GetAttribute("Vida") > 0 then
				game.ReplicatedStorage.RemoteEvents.sobrevivencia.diminuir.vida:FireServer()
			else
				game.ReplicatedStorage.RemoteEvents.sobrevivencia.morrer:FireServer(player)
			end
		end
	end

	while player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 do
		task.wait(4)
		if player:GetAttribute("Sede") <= 0 or player:GetAttribute("Fome") <= 0 then
			decVida(4)
			decFome(3)
			decSede(3)
		else
			local WhichOneGonnaDec = math.random(1, 2) == 1
			if WhichOneGonnaDec then
				decFome(1)			
			else
				decSede(1)			
			end
			decSede(1)	
		end
	end

	print("MODO SOBREVIVÊNCIA PAUSADO - PLAYER MORREU")
end

-- Executa ao iniciar o jogo
iniciarSobrevivencia()

-- Reexecuta sempre que o personagem renascer
player.CharacterAdded:Connect(function()
	task.wait(1) -- Espera o personagem ser carregado
	iniciarSobrevivencia()
end)
