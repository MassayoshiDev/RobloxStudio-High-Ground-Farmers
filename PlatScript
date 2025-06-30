wait(1)
local Plat = script.Parent
local PlatCloneData = game.ReplicatedStorage.PlatFolder.Plat
local PlatSideCheckersFolder = game.ReplicatedStorage.PlatFolder.PlatSideCheckers

local TemAlgoDentro = false
local platSize = nil
local L, R, F, B = 0, 0, 0, 0
local VezesSubidas = 0
local ilhaCooldown = 0
local platSize = nil


-- Aguarda um lado específico até que seja encontrado ou atinja o timeout
local function esperarLado(folder, nome)
	local timeout = 5 -- segundos
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

-- Inicializa as variáveis principais
wait(1)

-- Espera por todos os lados
local lados = {
	back = esperarLado(PlatSideCheckersFolder, "AuxBack"),
	front = esperarLado(PlatSideCheckersFolder, "AuxFront"),
	left = esperarLado(PlatSideCheckersFolder, "AuxLeft"),
	right = esperarLado(PlatSideCheckersFolder, "AuxRight"),
}

-- Clona os lados encontrados em volta da plataforma
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
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- ///////////////////////////////////////////////
-- :::::::::::::::::::::::::::::::::::::::::::::::

local function HaAlgoDentro(bloco)
	local cframe = bloco.CFrame
	local originalSize = bloco.Size

	-- Reduz proporcionalmente 10% do tamanho em cada eixo
	local reductionFactor = 0.9
	local innerSize = Vector3.new(
		originalSize.X * reductionFactor,
		originalSize.Y * reductionFactor,
		originalSize.Z * reductionFactor
	)

	local parts = workspace:GetPartBoundsInBox(cframe, innerSize)
	local partesDentro = {}

	for _, part in ipairs(parts) do
		if part ~= bloco and not bloco:IsAncestorOf(part) and part:IsA("Part") then
			table.insert(partesDentro, part.Name)
		end
	end

	local temAlgo = #partesDentro > 0
	return temAlgo, partesDentro
end

-- ::::::::::::::::::::::::::::::::::::::::
-- ::::::::::::::::::::::::::::::::::::::::


local function ClonePlat(PlatClone, PlatPosition, LadoEscolhido)
	local newClone = PlatClone:Clone()
	newClone.Parent = game.Workspace.PastaParaArmazenarPastas.PlatCloneFolder
	newClone.Name = "PlatClonado"

	-- Garante que o modelo tenha uma PrimaryPart
	if not newClone.PrimaryPart then
		newClone.PrimaryPart = newClone:FindFirstChild("Plat") -- ou outro nome correto
	end

	-- Posiciona usando SetPrimaryPartCFrame
	newClone:SetPrimaryPartCFrame(CFrame.new(PlatPosition))
end


-- ::::::::::::::::::::::::::::::::::::::::
-- ::::::::::::::::::::::::::::::::::::::::


local function WhichSideAvaliable(PCframe)
	local lados = {
		back = Plat:FindFirstChild("AuxBack"),
		front = Plat:FindFirstChild("AuxFront"),
		left = Plat:FindFirstChild("AuxLeft"),
		right = Plat:FindFirstChild("AuxRight")
	}

	for nome, side in pairs(lados) do
		if side then
			local temAlgo, nomesPartes = HaAlgoDentro(side)

			if temAlgo then
				print("Há partes dentro de", nome)
				if nome == "back" then B = 1 end
				if nome == "front" then F = 1 end
				if nome == "left" then L = 1 end
				if nome == "right" then R = 1 end
			else
				print("O lado", nome, "está vazio.")
			end
		else
			warn("Bloco Aux" .. nome .. " não encontrado!")
		end
	end
end

-- ::::::::::::::::::::::::::::::::::::::::
-- ::::::::::::::::::::::::::::::::::::::::

local function PlaceWork()
	L, R, F, B = 0, 0, 0, 0
	local PlatCframe = Plat:GetPrimaryPartCFrame()
	local PlatPosition = Plat.PrimaryPart.Position
	WhichSideAvaliable(PlatCframe)
	local Decided = false
	local SidePicked = "Nil"

	repeat
		local WhichSideItPicked = math.random(1, 4)
		if WhichSideItPicked == 1 and L == 0 and TemAlgoDentro ~= "Left" then
			Decided = true
			SidePicked = "Left"
		elseif WhichSideItPicked == 2 and R == 0 and TemAlgoDentro ~= "Right" then
			Decided = true
			SidePicked = "Right"
		elseif WhichSideItPicked == 3 and F == 0 and TemAlgoDentro ~= "Front" then
			Decided = true
			SidePicked = "Front"
		elseif WhichSideItPicked == 4 and B == 0 and TemAlgoDentro ~= "Back" then
			Decided = true
			SidePicked = "Back"
		end
	until Decided == true or L + R + B + F == 4

	local PlatClone = PlatCloneData
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

	if SidePicked ~= "Nil" then
		ClonePlat(PlatClone, PlatPosition, SidePicked)
		Plat:SetPrimaryPartCFrame(PlatCframe + offset)
	end

	if L + R + F + B == 4 then
		VezesSubidas += 1
		Plat:SetPrimaryPartCFrame(Plat:GetPrimaryPartCFrame() + Vector3.new(0, platSize, 0))
	end
end


-- :::::::::::::::::::::::::::::::::::::::::::::::
-- ///////////////////////////////////////////////
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

local BlocosGerados = 0
while BlocosGerados ~= 800 do
	task.wait(0.03)
	platSize = (Plat.PrimaryPart.Size.X+Plat.PrimaryPart.Size.Z)/2
	PlaceWork()
	BlocosGerados += 1
end
