wait(1)
local Plat = script.Parent
if not Plat.PrimaryPart then
	Plat.PrimaryPart = Plat:FindFirstChild("Plat")
end
local PlatCloneData = game.ReplicatedStorage.PlatFolder:WaitForChild("Plat")
local PlatCavernaClone = game.ReplicatedStorage.PlatFolder.CavernaFolder:WaitForChild("PlatComEscada")
local PlatSideCheckersFolder = game.ReplicatedStorage.PlatFolder.PlatSideCheckers
local TemAlgoDentro = false
local L, R, F, B = 0, 0, 0, 0
local VezessSubidasParaGerarIlhas = 0
local platSize = (Plat.PrimaryPart.Size.X + Plat.PrimaryPart.Size.Z) / 2
local podecontinuar = true
local ilhaCooldown = 0
local evitarSpawnarIlhaRecentePraNaoLagar = 0
local evitarIrParaTrasTemporariamenteNoInicio = 0
local PlatClone
local bloqueadorQuandoSobeData = game.ReplicatedStorage.PlatFolder.BloqueadoresDeLadoQuandoSobe
local VezesSemSubir = 0
local evitarLoopInfinitoNosBloqueadores = 0

-- CAVERNA
local VezesSubidasGerarCaverna = 0
local BlocosAtePoderVoltarAIrPraFrente = 100
local evitarIrParaTrasQuandoForSpawnarCaverna = 0
local DebouncePraSpawnarUmaVez = true
local Debounce = true
-- FIM CAVERNA


-- Função que espera um lado
local function esperarLado(folder, nome)
	local timeout = 5
	local tempoInicial = tick()
	local child = nil

	repeat
		child = folder:FindFirstChild(nome)
		if not child then
			print("Esperando pelo lado:", nome)
			task.wait(0.5)
		end
	until child or tick() - tempoInicial > timeout

	if not child then
		warn(">> NÃO ENCONTRADO:", nome)
	end

	return child
end

wait(1)

local lados = {
	back = esperarLado(PlatSideCheckersFolder, "AuxBack"),
	front = esperarLado(PlatSideCheckersFolder, "AuxFront"),
	left = esperarLado(PlatSideCheckersFolder, "AuxLeft"),
	right = esperarLado(PlatSideCheckersFolder, "AuxRight"),
}

for nome, side in pairs(lados) do
	if side then
		local sideClone = side:Clone()
		if nome == "back" then
			sideClone.Position = Plat.PrimaryPart.Position + Vector3.new(0, 0, platSize)
		elseif nome == "front" then
			sideClone.Position = Plat.PrimaryPart.Position + Vector3.new(0, 0, -platSize)
		elseif nome == "left" then
			sideClone.Position = Plat.PrimaryPart.Position + Vector3.new(-platSize, 0, 0)
		elseif nome == "right" then
			sideClone.Position = Plat.PrimaryPart.Position + Vector3.new(platSize, 0, 0)
		end
		sideClone.Parent = Plat
	else
		warn("Lado", nome, "nao foi clonado porque nao foi encontrado.")
	end
end

wait(2)

local function HaAlgoDentro(bloco)
	if not bloco or not bloco:IsA("BasePart") then
		return true, {}
	end

	local cframe = bloco.CFrame
	local originalSize = bloco.Size
	local reductionFactor = 0.95
	local innerSize = originalSize * reductionFactor

	local parts = workspace:GetPartBoundsInBox(cframe, innerSize)
	local partesDentro = {}

	local platFolder = game.Workspace:FindFirstChild("PastaParaArmazenarPastas")
	if not platFolder then return true, {} end

	local platCloneFolder = platFolder:FindFirstChild("PlatCloneFolder")
	if not platCloneFolder then return true, {} end

	local nomesNaoPermitidos = {
		terra = true,
		grama = true,
		Tronco = true,
		Folhaum = true,
		Folhadois = true
	}

	for _, part in ipairs(parts) do
		if
			part ~= bloco
			and part:IsA("BasePart")
			and not bloco:IsDescendantOf(part)
			and part.Name ~= "Bloco24x24"
			and part.Name ~= "aux"
			and part.Name ~= "CaveBlockCore"
		then
			local ignorar = false

			-- Ignora se for parte de um jogador (tem Humanoid no ancestral)
			local modelAncestor = part:FindFirstAncestorOfClass("Model")
			if modelAncestor and modelAncestor:FindFirstChildOfClass("Humanoid") then
				ignorar = true
			end

			-- Ignora se for parte de um modelo PlatClonado, exceto nomes permitidos
			if not ignorar then
				for _, model in ipairs(platCloneFolder:GetChildren()) do
					if model:IsA("Model") and model.Name == "PlatClonado" and part:IsDescendantOf(model) then
						if not nomesNaoPermitidos[part.Name] then
							ignorar = true
							break
						end
					end
				end
			end

			if not ignorar then
				table.insert(partesDentro, part)
			end
		end
	end

	return #partesDentro > 0, partesDentro
end



local function destruirArvoreQuandoSubir()
	local bloco24x24 = game.ReplicatedStorage.PlatFolder.Bloco24x24:Clone()
	bloco24x24.Position = Plat.PrimaryPart.Position + Vector3.new(0, 8, 0)
	bloco24x24.Parent = Plat
	local temalgo, partes = HaAlgoDentro(bloco24x24)
	if temalgo then
		for _, part in pairs(partes) do
			if part.Name == "Tronco" or part.Name == "Folhadois" or part.Name == "Folhaum" then
				local arvore = part:FindFirstAncestorOfClass("Model")
				if arvore then
					arvore:Destroy()
				end
			end
		end		
	end
	bloco24x24:Destroy()
end

local function gerarBloqueadoresDeLadoQuandoSubir(cframe)
	local podeEncerrar = false
	local rotacionador = 90
	local bloqueadorNovo = bloqueadorQuandoSobeData:Clone()
	if not bloqueadorNovo.PrimaryPart then
		bloqueadorNovo.PrimaryPart = bloqueadorNovo:WaitForChild("centro")
	end
	local tentativasMaximas = 15
	bloqueadorNovo.PrimaryPart = bloqueadorNovo:WaitForChild("centro")
	bloqueadorNovo:SetPrimaryPartCFrame(cframe)
	bloqueadorNovo.Parent = game.Workspace
	while podeEncerrar == false do
		tentativasMaximas -= 1
		if tentativasMaximas <= 0 then
			podeEncerrar = true
			bloqueadorNovo:Destroy()
			return "vouTirarMinhaPropriaVida"
		end 
		task.wait(0.1)		
		while not bloqueadorNovo.PrimaryPart do
			print("TAMO PROCURANDO A PRIMARYPART DO BLOQUEADORNOVO")
			task.wait(1)
			if not bloqueadorNovo.PrimaryPart then
				bloqueadorNovo.PrimaryPart = bloqueadorNovo:WaitForChild("centro")
			end
			bloqueadorNovo.PrimaryPart = bloqueadorNovo:WaitForChild("centro")
			if bloqueadorNovo.PrimaryPart then
				break
			end
		end
		bloqueadorNovo:SetPrimaryPartCFrame(bloqueadorNovo.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(rotacionador), 0))
		for _, bloco in pairs(bloqueadorNovo:GetChildren()) do
			local temalgo, nomes = HaAlgoDentro(bloco)
			if temalgo then
				for _, nome in pairs(nomes) do
					local blocoDeOutroBloqueador = nome:FindFirstAncestorOfClass("Model")
					if blocoDeOutroBloqueador then
						if blocoDeOutroBloqueador.Name == "BloqueadoresDeLadoQuandoSobe" then							
							print("o bloco faz parte do modelo chamado BloqueadoresDeLadoQuandoSobe, logo iremos destruí-lo")
							nome:Destroy()
							if bloco.Name ~= "auxBlock" and bloco.Name ~= "auxFrontOfBlock" then
								bloco:Destroy()							
							end
						end
					end
					if not Plat:IsAncestorOf(nome) and not bloqueadorNovo:IsAncestorOf(nome) then
						podeEncerrar = false
						if nome.Name == "Tronco" or nome.Name == "Folhadois" or nome.Name == "Folhaum" then
							local arvore = nome:FindFirstAncestorOfClass("Model")
							if arvore then
								arvore:Destroy()
							end
						end
					else
						podeEncerrar = true
					end
				end
			else
				if bloco.Name == "auxBlock" then					
					podeEncerrar = true
				end
			end			
		end
	end
	destruirArvoreQuandoSubir()
	bloqueadorNovo:WaitForChild("auxBlock"):Destroy()
	bloqueadorNovo:WaitForChild("auxFrontOfBlock"):Destroy()
	return "podeContinuar"
end

-- Verifica se uma part é válida (se é chamada "entrar" ou está dentro do Plat)
local function EhPartePermitida(part, plat)
	if part.Name == "entrar" or part.Name == "hitbox" or part.Name == "checker" then
		return true
	end
	return plat:IsAncestorOf(part)
end

-- Checa se todas as partes dentro da hitbox são válidas
local function TodasPartesSaoValidas(partes, plat)
	for _, part in ipairs(partes) do
		if not EhPartePermitida(part, plat) then
			return false
		end
	end
	return true
end

local function SpawnIlha()
	-- Bloqueia a geração de blocos enquanto a ilha está sendo spawnada
	podecontinuar = false

	local lados = {[1] = 180, [2] = 360, [3] = 90, [4] = 270}
	local ladoEscolhido = math.random(1, 4)
	local rotacao = lados[ladoEscolhido]
	local ilhasDisponiveis = {}

	-- Loop para verificar quais ilhas podem ser spawnadas sem colisão
	for idIlha, ilha in ipairs(game.ReplicatedStorage.PlatFolder.ilhas:GetChildren()) do
		local hitboxName = "ilha"..idIlha.."_hitbox"
		local modelName = "ilha"..idIlha.."_model"
		local hitbox = ilha:FindFirstChild(hitboxName)
		local ilhaModel = ilha:FindFirstChild(modelName)

		if hitbox and ilhaModel then
			local clone = hitbox:Clone()
			clone.Parent = workspace
			clone:SetPrimaryPartCFrame(CFrame.new(Plat.PrimaryPart.Position) * CFrame.Angles(0, math.rad(rotacao), 0))
			task.wait(0.03)

			-- Verifica se há colisão dentro da hitbox
			local temAlgo, partesDentro = HaAlgoDentro(clone:FindFirstChild("hitbox"))

			-- Permite o spawn se não houver colisão ou se partes são permitidas
			if not temAlgo or TodasPartesSaoValidas(workspace:GetPartBoundsInBox(clone.hitbox.CFrame, clone.hitbox.Size * 0.9), Plat) then
				table.insert(ilhasDisponiveis, { model = ilhaModel, rotacao = rotacao })
				for _, part in pairs(clone:GetChildren()) do
					task.wait(0.01)
					if part:IsA("BasePart") then
						if part.Name ~= "hitbox" then
							part:Destroy()
						else
							wait(1)
							part.Transparency = 1
							ilhaCooldown = 0
							VezessSubidasParaGerarIlhas = 0
						end
					end
				end
			else
				clone:Destroy()
				task.wait(0.3)
			end

		end
		task.wait(0.05)
	end

	-- Se houver ilhas disponíveis para spawnar
	if #ilhasDisponiveis > 0 then
		local sorteada = ilhasDisponiveis[math.random(1, #ilhasDisponiveis)]
		local modelClone = sorteada.model:Clone()
		modelClone.Parent = workspace
		print("ROTACAO: "..sorteada.rotacao)
		modelClone:SetPrimaryPartCFrame(CFrame.new(Plat.PrimaryPart.Position) * CFrame.Angles(0, math.rad(sorteada.rotacao), 0))
	end

	-- Libera o sistema para continuar gerando blocos
	podecontinuar = true
end

local function SpawnCaverna()
	if evitarIrParaTrasQuandoForSpawnarCaverna >= BlocosAtePoderVoltarAIrPraFrente and not Debounce then
		print("RESETADO")
		evitarIrParaTrasQuandoForSpawnarCaverna = 0
		DebouncePraSpawnarUmaVez = true
		Debounce = true
	else
		if evitarIrParaTrasQuandoForSpawnarCaverna >= BlocosAtePoderVoltarAIrPraFrente/2 and DebouncePraSpawnarUmaVez then 
			DebouncePraSpawnarUmaVez = false
			PlatClone = PlatCavernaClone
			local caverna = game.ReplicatedStorage.PlatFolder.CavernaFolder.CavernaHitboxes:WaitForChild("cavernaHitbox1"):Clone()
			caverna.Parent = game.Workspace
			caverna:SetPrimaryPartCFrame(script.Parent.PrimaryPart.CFrame)
			print("CAVERNA SPAWNADA")
		end
		evitarIrParaTrasQuandoForSpawnarCaverna += 1
	end

end


local function ClonePlat(PlatClone, PlatPosition, LadoEscolhido)
	local newClone = PlatClone:Clone()
	newClone.Parent = game.Workspace.PastaParaArmazenarPastas.PlatCloneFolder
	newClone.Name = "PlatClonado"
	if not newClone.PrimaryPart then
		newClone.PrimaryPart = newClone:FindFirstChild("Plat")
	end
	newClone:SetPrimaryPartCFrame(CFrame.new(PlatPosition))
	game.Workspace.totalDeBlocosGerados.Value += 1
	if evitarIrParaTrasQuandoForSpawnarCaverna > 0 then
		evitarIrParaTrasQuandoForSpawnarCaverna += 1
	end
	evitarLoopInfinitoNosBloqueadores = 0
end

local function WhichSideAvaliable(PCframe)	
	local lados = {
		back = Plat:FindFirstChild("AuxBack"),
		front = Plat:FindFirstChild("AuxFront"),
		left = Plat:FindFirstChild("AuxLeft"),
		right = Plat:FindFirstChild("AuxRight")
	}
	for nome, side in pairs(lados) do
		if side then
			local temAlgo, _ = HaAlgoDentro(side)
			if temAlgo then
				if nome == "back" then 
					B = 1 
				end
				if nome == "front" then 
					F = 1 
				end
				if nome == "left" then 
					L = 1 
				end
				if nome == "right" then 
					R = 1 
				end
			end
		end
	end
	if evitarIrParaTrasTemporariamenteNoInicio <= 30 then
		B = 1
		evitarIrParaTrasTemporariamenteNoInicio +=1
	end
end

local function PlaceWork()
	L, R, F, B = 0, 0, 0, 0
	local PlatCframe = Plat:GetPrimaryPartCFrame()
	local PlatPosition = Plat.PrimaryPart.Position
	WhichSideAvaliable(PlatCframe)
	local Decided = false
	local SidePicked = "Nil"
	repeat
		if evitarIrParaTrasQuandoForSpawnarCaverna >= BlocosAtePoderVoltarAIrPraFrente then
			SpawnIlha()
			evitarIrParaTrasQuandoForSpawnarCaverna = 0
		end
		local WhichSideItPicked = math.random(1, 4)
		if WhichSideItPicked == 1 and L == 0 then 
			Decided = true SidePicked = "Left"
		elseif WhichSideItPicked == 2 and R == 0 then 
			Decided = true SidePicked = "Right"
		elseif WhichSideItPicked == 3 and F == 0 then 
			Decided = true SidePicked = "Front"
		elseif WhichSideItPicked == 4 and B == 0 and evitarIrParaTrasQuandoForSpawnarCaverna == 0 then 
			if L+R+F ~= 3 then
				local vaiIrPraTras = math.random(1, 8) ~= 3
				if vaiIrPraTras then
					Decided = true SidePicked = "Back"
				end
			else
				Decided = true SidePicked = "Back"
			end
		end
		if L + R + F == 3 and evitarIrParaTrasQuandoForSpawnarCaverna > 0 then
			Decided = true SidePicked = "Back" 
		end
	until Decided or L + R + F + B == 4

	local offset = Vector3.new(0, 0, 0)

	if SidePicked == "Left" then 
		offset = Vector3.new(-platSize, 0, 0)
	elseif SidePicked == "Right" then 
		offset = Vector3.new(platSize, 0, 0)
	elseif SidePicked == "Front" then 
		offset = Vector3.new(0, 0, -platSize)
	elseif SidePicked == "Back" then 
		offset = Vector3.new(0, 0, platSize) 
	end

	if evitarIrParaTrasQuandoForSpawnarCaverna >= BlocosAtePoderVoltarAIrPraFrente/2 and Debounce then
		Debounce = false
		SpawnCaverna()
		PlatClone = PlatCavernaClone
		ClonePlat(PlatClone, PlatPosition, SidePicked)
	else		
		if SidePicked ~= "Nil" then
			VezesSemSubir += 1
			ClonePlat(PlatClone, PlatPosition, SidePicked)
			Plat:SetPrimaryPartCFrame(PlatCframe + offset)
		end
	end

	if L + R + F + B == 4 then
		evitarLoopInfinitoNosBloqueadores += 1
		VezessSubidasParaGerarIlhas += 1
		VezesSubidasGerarCaverna += 1
		task.wait(1)
		if VezesSemSubir ~= 0 and evitarLoopInfinitoNosBloqueadores < 5 then				
			Plat:SetPrimaryPartCFrame(Plat:GetPrimaryPartCFrame() + Vector3.new(0, platSize, 0))
			destruirArvoreQuandoSubir()
			local conseguiuVerificar = gerarBloqueadoresDeLadoQuandoSubir(Plat:GetPrimaryPartCFrame())
			while conseguiuVerificar ~= "podeContinuar" do
				task.wait(0.5)
				conseguiuVerificar = gerarBloqueadoresDeLadoQuandoSubir(Plat:GetPrimaryPartCFrame())
			end
		end
		local PlatClonadoParaEvitarProblema = PlatCloneData:Clone()
		PlatClonadoParaEvitarProblema:SetPrimaryPartCFrame(Plat:GetPrimaryPartCFrame() + Vector3.new(0, -platSize, 0))
		PlatClonadoParaEvitarProblema.Parent = game.Workspace.PastaParaArmazenarPastas.PlatCloneFolder
		VezesSemSubir = 0
	end

	local vaiSpawnarCaverna = math.random(1, 200) == 42
	if vaiSpawnarCaverna 
		and VezesSubidasGerarCaverna >= 7 
		and evitarIrParaTrasQuandoForSpawnarCaverna == 0 
		and DebouncePraSpawnarUmaVez 
	then
		VezesSubidasGerarCaverna = 3
		SpawnCaverna()
	end

	if math.random(1, 5) == 1 
		and VezessSubidasParaGerarIlhas >= 4 
		and ilhaCooldown > 250 
		and evitarSpawnarIlhaRecentePraNaoLagar >= 7 
		and evitarIrParaTrasQuandoForSpawnarCaverna == 0 
	then
		evitarSpawnarIlhaRecentePraNaoLagar = 0
		SpawnIlha()
	end

	-- 🔧 Correção adicionada aqui:
	if not Debounce and evitarIrParaTrasQuandoForSpawnarCaverna >= BlocosAtePoderVoltarAIrPraFrente then
		SpawnCaverna()
	end
end

local BlocosGerados = 0
while BlocosGerados < 8000 do
	PlatClone = PlatCloneData
	task.wait(0.03)

	if podecontinuar and Plat and Plat.PrimaryPart then
		PlaceWork()
		BlocosGerados += 1
		ilhaCooldown += 1
		evitarSpawnarIlhaRecentePraNaoLagar += 1
	else
		task.wait(0.1)
	end
end
