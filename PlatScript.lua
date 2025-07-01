wait(1)
local Plat = script.Parent
local PlatCloneData = game.ReplicatedStorage.PlatFolder:WaitForChild("Plat")
local PlatSideCheckersFolder = game.ReplicatedStorage.PlatFolder.PlatSideCheckers

if not Plat.PrimaryPart then
	Plat.PrimaryPart = Plat:FindFirstChild("Plat")
end

local TemAlgoDentro = false
local L, R, F, B = 0, 0, 0, 0
local VezesSubidas = 0
local platSize = nil
local podecontinuar = true
local ilhaCooldown = 0

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
		print("Lado encontrado:", nome)
		local sideClone = side:Clone()
		if nome == "back" then
			sideClone.Position = Plat.PrimaryPart.Position + Vector3.new(0, 0, 8)
		elseif nome == "front" then
			sideClone.Position = Plat.PrimaryPart.Position + Vector3.new(0, 0, -8)
		elseif nome == "left" then
			sideClone.Position = Plat.PrimaryPart.Position + Vector3.new(-8, 0, 0)
		elseif nome == "right" then
			sideClone.Position = Plat.PrimaryPart.Position + Vector3.new(8, 0, 0)
		end
		sideClone.Parent = Plat
	else
		warn("Lado", nome, "nao foi clonado porque nao foi encontrado.")
	end
end

wait(2)

local function HaAlgoDentro(bloco)
	if not bloco or not bloco:IsA("BasePart") then return true, {} end

	local cframe = bloco.CFrame
	local originalSize = bloco.Size

	local reductionFactor = 0.95
	local innerSize = Vector3.new(
		originalSize.X * reductionFactor,
		originalSize.Y * reductionFactor,
		originalSize.Z * reductionFactor
	)

	local parts = workspace:GetPartBoundsInBox(cframe, innerSize)
	local partesDentro = {}

	for _, part in ipairs(parts) do
		if
			part ~= bloco
			and not bloco:IsDescendantOf(part)
			and part:IsA("BasePart")
			and part.Name ~= "Flor"
			and part.Name ~= "Árvore"
			and part.Name ~= "checkBlockAbove"
			and part.Name ~= "checker"
		then
			table.insert(partesDentro, part.Name)
		end
	end

	local temAlgo = #partesDentro > 0
	return temAlgo, partesDentro
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

	local lados = { [1] = 360, [2] = 90, [3] = 180, [4] = 270 }
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

			-- Verifica se há colisão dentro da hitbox
			local temAlgo, partesDentro = HaAlgoDentro(clone:FindFirstChild("hitbox"))

			-- Permite o spawn se não houver colisão ou se partes são permitidas
			if not temAlgo or TodasPartesSaoValidas(workspace:GetPartBoundsInBox(clone.hitbox.CFrame, clone.hitbox.Size * 0.9), Plat) then
				table.insert(ilhasDisponiveis, { model = ilhaModel, rotacao = rotacao })
				for _, part in pairs(clone:GetChildren()) do
					if part:IsA("BasePart") then
						if part.Name ~= "hitbox" then
							part:Destroy()
						else
							part.Transparency = 1
						end
					end
				end
			else
				clone:Destroy()
			end

		end
	end

	-- Se houver ilhas disponíveis para spawnar
	if #ilhasDisponiveis > 0 then
		local sorteada = ilhasDisponiveis[math.random(1, #ilhasDisponiveis)]
		local modelClone = sorteada.model:Clone()
		modelClone.Parent = workspace
		modelClone:SetPrimaryPartCFrame(CFrame.new(Plat.PrimaryPart.Position) * CFrame.Angles(0, math.rad(sorteada.rotacao), 0))
	end

	-- Libera o sistema para continuar gerando blocos
	podecontinuar = true
end


local function ClonePlat(PlatClone, PlatPosition, LadoEscolhido)
	local newClone = PlatClone:Clone()
	newClone.Parent = game.Workspace.PastaParaArmazenarPastas.PlatCloneFolder
	newClone.Name = "PlatClonado"
	if not newClone.PrimaryPart then
		newClone.PrimaryPart = newClone:FindFirstChild("Plat")
	end
	newClone:SetPrimaryPartCFrame(CFrame.new(PlatPosition))
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
				if nome == "back" then B = 1 end
				if nome == "front" then F = 1 end
				if nome == "left" then L = 1 end
				if nome == "right" then R = 1 end
			end
		end
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
		local WhichSideItPicked = math.random(1, 4)
		if WhichSideItPicked == 1 and L == 0 then 
			Decided = true SidePicked = "Left"
		elseif WhichSideItPicked == 2 and R == 0 then 
			Decided = true SidePicked = "Right"
		elseif WhichSideItPicked == 3 and F == 0 then 
			Decided = true SidePicked = "Front"
		elseif WhichSideItPicked == 4 and B == 0 then 
			Decided = true SidePicked = "Back" 
		end
	until Decided or L + R + F + B == 4

	local PlatClone = PlatCloneData
	local offset = Vector3.new(0, 0, 0)
	if SidePicked == "Left" then offset = Vector3.new(-platSize, 0, 0)
	elseif SidePicked == "Right" then offset = Vector3.new(platSize, 0, 0)
	elseif SidePicked == "Front" then offset = Vector3.new(0, 0, -platSize)
	elseif SidePicked == "Back" then offset = Vector3.new(0, 0, platSize) end

	if SidePicked ~= "Nil" then
		ClonePlat(PlatClone, PlatPosition, SidePicked)
		Plat:SetPrimaryPartCFrame(PlatCframe + offset)
	end

	if L + R + F + B == 4 then
		VezesSubidas += 1
		Plat:SetPrimaryPartCFrame(Plat:GetPrimaryPartCFrame() + Vector3.new(0, platSize, 0))
	end

	if math.random(1, 2) == 1 and VezesSubidas >= 4 and ilhaCooldown > 180 then
		ilhaCooldown = 0
		SpawnIlha()
	end
end

local BlocosGerados = 0
while BlocosGerados < 8000 do
	task.wait(0.03)

	if podecontinuar and Plat and Plat.PrimaryPart then
		platSize = (Plat.PrimaryPart.Size.X + Plat.PrimaryPart.Size.Z) / 2
		PlaceWork()
		BlocosGerados += 1
		ilhaCooldown += 1
	else
		-- Opcional: espera um pouco antes de tentar novamente, evita loop intenso em erro
		task.wait(0.1)
	end
end
