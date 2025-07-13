local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local dataStore = DataStoreService:GetDataStore("SistemaDeRecursos")

-- Guarda os nomes dos atributos que foram modificados por jogador
local modificados = {}

-- Salvar apenas os atributos modificados
local function salvarDados(player)
	local lista = modificados[player]
	if not lista then return end

	for nome, _ in pairs(lista) do
		local valor = player:GetAttribute(nome)
		if valor ~= nil then
			local success, err = pcall(function()
				dataStore:SetAsync("Player_" .. player.UserId .. "_" .. nome, valor)
			end)

			if not success then
				warn("Erro ao salvar atributo", nome, "para", player.Name, err)
			end
		end
	end

	-- Limpa modificações salvas
	modificados[player] = {}
end

-- Carrega todos os atributos do jogador
local function carregarDados(player)
	modificados[player] = {}

	local success, data = pcall(function()
		return dataStore:GetAsync("Player_" .. player.UserId .. "_AllAttributes")
	end)

	if success and data then
		for nome, valor in pairs(data) do
			player:SetAttribute(nome, valor)
		end
	else
		if not success then
			warn("Erro ao carregar dados de atributos de", player.Name)
		end
	end

	-- Detecta alterações
	player.AttributeChanged:Connect(function(attrName)
		modificados[player][attrName] = true
	end)

	-- Auto-save a cada 60 segundos
	task.spawn(function()
		while player.Parent do
			task.wait(60)
			salvarDados(player)
		end
	end)
end

-- Salvar tudo de uma vez no desligamento
local function salvarTudo(player)
	local atributos = player:GetAttributes()
	local success, err = pcall(function()
		dataStore:SetAsync("Player_" .. player.UserId .. "_AllAttributes", atributos)
	end)

	if not success then
		warn("Erro ao salvar todos os atributos de", player.Name, err)
	end
end

Players.PlayerAdded:Connect(carregarDados)

Players.PlayerRemoving:Connect(function(player)
	salvarDados(player)
	salvarTudo(player)
	modificados[player] = nil
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		salvarDados(player)
		salvarTudo(player)
	end
end)
