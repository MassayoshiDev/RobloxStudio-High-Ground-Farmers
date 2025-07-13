local grama = script.Parent:WaitForChild("PlatDesign"):WaitForChild("grama")
local primary = script.Parent.PrimaryPart
local PlatOriginal = game.Workspace.Plat.PrimaryPart
local auxAboveChecker = script.Parent.aclopadores.checkBlockAbove
local pasta = script.Parent.decoracoesGeradas
local gerarDebounce = false
local changeArvoreParaFlorDebounce = false
local vaiTerDecoracao = math.random(1, 5) == 1
local modelGerado = nil
local offsetX = math.random(-3, 2) + 0.5
local offsetZ = math.random(-3, 2) + 0.5
local centro = primary.Position

local function HaAlgoDentro(bloco)
	local cframe = bloco.CFrame
	local originalSize = bloco.Size

	local reductionFactor = 0.95
	local innerSize = originalSize * reductionFactor
	local parts = workspace:GetPartBoundsInBox(cframe, innerSize)
	local partesDentro = {}

	for _, part in ipairs(parts) do
		if part ~= bloco and not bloco:IsDescendantOf(part) and part:IsA("BasePart") then
			table.insert(partesDentro, part.Name)
		end
	end

	return #partesDentro > 0, partesDentro
end

local function gerarDecoracoes()
	local decor = game.ReplicatedStorage.buildings:GetChildren()
	local modelo
	if #decor == 0 then return end
	repeat
		modelo = decor[math.random(1, #decor)]:Clone()
	until modelo.Name ~= "teste"
	local posFinal

	if modelo.Name == "Flor" then
		posFinal = centro + Vector3.new(offsetX, 4.5, offsetZ)
	elseif modelo.Name == "Árvore" then
		posFinal = centro + Vector3.new(offsetX, 10, offsetZ)
	else
		return -- Evita gerar decorações desconhecidas
	end

	if not modelo.PrimaryPart then
		modelo.PrimaryPart = modelo:FindFirstChildWhichIsA("BasePart")
		if not modelo.PrimaryPart then
			warn("Modelo sem PrimaryPart:", modelo.Name)
			return
		end
	end

	modelo:SetPrimaryPartCFrame(CFrame.new(posFinal))
	modelo.Parent = pasta
	modelGerado = modelo
	gerarDebounce = true
end

-- Loop principal
local parar = 0
local impedirDestruicaoArvore = false

while true do
	local temalgo, nomes = HaAlgoDentro(auxAboveChecker)

	if temalgo then
		local partesValidas = true
		for _, nome in pairs(nomes) do
			if nome == "PlatClonado" or nome == "terra" or nome == "grama" then
				partesValidas = false
				break
			end
		end

		if not partesValidas then
			grama.BrickColor = BrickColor.new("Dark orange")
			for _, decoracao in pairs(pasta:GetChildren()) do
				decoracao:Destroy()
			end
			auxAboveChecker:Destroy()
			break
		end

		wait(1)
		parar += 1

		if modelGerado and modelGerado.Name == "Árvore" then
			local sides = script.Parent:WaitForChild("aclopadores"):WaitForChild("quatroCantos")

			local ladosValidos = 0

			for _, side in pairs(sides:GetChildren()) do
				local _, nomesLado = HaAlgoDentro(side)

				local encontrouTerraOuGrama = false

				for _, nome in pairs(nomesLado) do
					if nome == "terra" or nome == "grama" then
						encontrouTerraOuGrama = true
						break -- esse lado já é válido
					end
				end

				if encontrouTerraOuGrama then
					ladosValidos += 1
				end
			end

			if ladosValidos < 5 and not changeArvoreParaFlorDebounce then
				changeArvoreParaFlorDebounce = true

				modelGerado:Destroy()

				local vaiSpawnarFlor = math.random(1, 2) == 1
				if vaiSpawnarFlor then					
					local flor = game.ReplicatedStorage.buildings:FindFirstChild("Flor"):Clone()
					flor:SetPrimaryPartCFrame(CFrame.new(centro + Vector3.new(offsetX, 4.5, offsetZ)))
					flor.Parent = pasta
				end
			end
		end






		if parar > 8 then break end
	else
		if not gerarDebounce and vaiTerDecoracao then
			gerarDecoracoes()
		end
	end

	wait(1)
end
