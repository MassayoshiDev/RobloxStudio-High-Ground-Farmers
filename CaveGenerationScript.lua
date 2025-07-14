local blocosGerados = 0
local Plat = script.Parent
local CheckerFolder = game.ReplicatedStorage.PlatFolder.CavernaFolder.CavernaSideCheckers
local PlatSize = (Plat.Size.X + Plat.Size.Z) / 2
local L, R, F, B, U = 0, 0, 0, 0, 0
local LastSidePicked

local PrimeroPlatAserClonadoParaEvitarErros = game.ReplicatedStorage.PlatFolder.CavernaFolder.PlatCaverna:Clone()
PrimeroPlatAserClonadoParaEvitarErros:SetPrimaryPartCFrame(Plat.CFrame)
PrimeroPlatAserClonadoParaEvitarErros.Parent = game.Workspace.PastaParaArmazenarPastas.PlatCavernaClonadoFolder
PrimeroPlatAserClonadoParaEvitarErros.Name = "PlatCavernaClonado"

local lados = {}

local etapaAtual = nil;

-- Clona e posiciona os lados uma única vez
for nome, side in pairs({
	back = CheckerFolder:WaitForChild("AuxBack"),
	front = CheckerFolder:WaitForChild("AuxFront"),
	left = CheckerFolder:WaitForChild("AuxLeft"),
	right = CheckerFolder:WaitForChild("AuxRight"),
	bot = CheckerFolder:WaitForChild("AuxBot")
}) do
	if side then
		local sideClone = side:Clone()

		if nome == "back" then
			sideClone.Position = Plat.Position + Vector3.new(0, 0, PlatSize)
		elseif nome == "front" then
			sideClone.Position = Plat.Position + Vector3.new(0, 0, -PlatSize)
		elseif nome == "left" then
			sideClone.Position = Plat.Position + Vector3.new(-PlatSize, 0, 0)
		elseif nome == "right" then
			sideClone.Position = Plat.Position + Vector3.new(PlatSize, 0, 0)
		elseif nome == "bot" then
			sideClone.Position = Plat.Position + Vector3.new(0, -PlatSize, 0)
		end

		sideClone.Parent = script.Parent.AuxFolder
		lados[nome] = sideClone
	else
		warn("Lado", nome, "não foi clonado porque não foi encontrado.")
	end
	task.wait(0.01)
end

task.wait(1)

-- Função que verifica se há algo dentro do bloco
local function HaAlgoDentro(bloco)
	etapaAtual = "Ha Algo Dentro"
	local cframe = bloco.CFrame
	local originalSize = bloco.Size
	local reductionFactor = 0.9
	local innerSize = originalSize * reductionFactor

	local parts = workspace:GetPartBoundsInBox(cframe, innerSize)
	local partesDentro = {}
	local nomes = {}

	for _, part in ipairs(parts) do
		if part ~= bloco and not bloco:IsAncestorOf(part) and part:IsA("Part") then
			table.insert(partesDentro, part)
			table.insert(nomes, part.Name)
			if part.Name ~= "hitboxCaverna" then
				return true, nomes
			end
		end
	end

	if #partesDentro > 0 then
		return false, nomes
	else
		return true, {}
	end
end

-- Clona novo plat em posição deslocada
local function ClonePlat(offset)
	local PlatClonado = game.ReplicatedStorage.PlatFolder.CavernaFolder.PlatCaverna:Clone()
	PlatClonado:SetPrimaryPartCFrame(Plat.CFrame + offset)
	PlatClonado.Parent = game.Workspace.PastaParaArmazenarPastas.PlatCavernaClonadoFolder
	PlatClonado.Name = "PlatCavernaClonado"
	task.wait(0.005)
end

-- Verifica quais lados estão ocupados
local function WhichSideAvaliable()
	for nome, side in pairs(lados) do
		if side then
			local temAlgo, _ = HaAlgoDentro(side)
			if temAlgo then
				if nome == "back" then B = 1 end
				if nome == "front" then F = 1 end
				if nome == "left" then L = 1 end
				if nome == "right" then R = 1 end
				if nome == "bot" then U = 1 end
			end
			task.wait(0.003)
		end
	end
end

-- Função para gerar escada com rotação correta
local function GerarEscada()
	local escada = game.ReplicatedStorage.PlatFolder.CavernaFolder.EscadaPraUsarNaCaverna:Clone()
	escada.Parent = game.Workspace.PastaParaArmazenarPastas.PlatCavernaClonadoFolder

	local baseCFrame = CFrame.new(Plat.Position)
	baseCFrame = baseCFrame * CFrame.Angles(0, math.rad(-90), 0)

	if LastSidePicked == "Left" then
		baseCFrame = baseCFrame * CFrame.Angles(0, math.rad(-270), 0)
		escada.PrimaryPart.BrickColor = BrickColor.new("Yellow flip/flop")
	elseif LastSidePicked == "Right" then
		baseCFrame = baseCFrame * CFrame.Angles(0, math.rad(-90), 0)
		escada.PrimaryPart.BrickColor = BrickColor.new("Really red")
	elseif LastSidePicked == "Back" then
		baseCFrame = baseCFrame * CFrame.Angles(0, math.rad(-180), 0)
		escada.PrimaryPart.BrickColor = BrickColor.new("Sea green")
	end

	escada:SetPrimaryPartCFrame(baseCFrame)
	task.wait(0.005)
end

-- Lógica principal de movimentação
local function PlaceWork()
	L, R, B, F, U = 0, 0, 0, 0, 0
	local platCframe = Plat.CFrame
	WhichSideAvaliable()

	local Decided = false
	local SidePicked = "Nil"
	local offset = Vector3.new(0, 0, 0)

	if L + R + F + B == 4 then
		if L+R+F+B+U ~= 5 then
			for i = 1, 2 do
				offset = Vector3.new(0, -PlatSize, 0)
				if i == 2 then
					GerarEscada()
				end
				ClonePlat(offset)
				Plat.CFrame = Plat.CFrame + offset

				for _, lado in pairs(lados) do
					if lado then
						lado.CFrame = lado.CFrame + offset
					end
				end
				task.wait(0.005)
			end
			GerarEscada()
		else
			return
		end
	else
		repeat
			local WhichSideItPicked = math.random(1, 4)
			if WhichSideItPicked == 1 and L == 0 and LastSidePicked ~= "Right" then 
				Decided = true 
				SidePicked = "Left"
			elseif WhichSideItPicked == 2 and R == 0 and LastSidePicked ~= "Left" then
				Decided = true 
				SidePicked = "Right"
			elseif WhichSideItPicked == 3 and F == 0 and LastSidePicked ~= "Back" then 
				Decided = true SidePicked = "Front"
			elseif WhichSideItPicked == 4 and B == 0 and LastSidePicked ~= "Front" then 
				Decided = true SidePicked = "Back"
			end
			task.wait()
		until Decided 

		if SidePicked == "Left" then 
			offset = Vector3.new(-PlatSize, 0, 0)
			LastSidePicked = SidePicked
		elseif SidePicked == "Right" then 
			offset = Vector3.new(PlatSize, 0, 0)
			LastSidePicked = SidePicked
		elseif SidePicked == "Front" then 
			offset = Vector3.new(0, 0, -PlatSize)
			LastSidePicked = SidePicked
		elseif SidePicked == "Back" then 
			offset = Vector3.new(0, 0, PlatSize)
			LastSidePicked = SidePicked
		end

		ClonePlat(offset)
		Plat.CFrame = platCframe + offset

		for _, lado in pairs(lados) do
			if lado then
				lado.CFrame = lado.CFrame + offset
			end
		end
	end
end

-- Loop principal
while L+R+F+B+U ~= 5 do
	blocosGerados += 1
	task.wait(0.03)
	PlaceWork()
end

for _, bloco in pairs(script.Parent.AuxFolder:GetChildren()) do
	if bloco:IsA("BasePart") then
		bloco:Destroy()
	end
	task.wait(0.002)
end

script.Parent:Destroy()
