-- Esse script é antigo, o atual salva os atributos sem necessáriamente ter que registrar nesse código.

-- Vantagens deste código antigo:
-- [1] Já que precisa registrar para poder salvar um novo dado, é mais fácil de achar qual foi o nome usado para tal atributo.
-- [2] Ele salva somente os atributos que sofreram mudanças, ou seja, é mais eficiente e otimizado, sem ter que salvar um por um.
-- [3] Salva automáticamente quando o player sai, a cada 60s e quando servidor fecha, evitando perca de dados.
-- Desvantagens:
-- [1] O script cria uma instância chamada NumberValue, o que não é muito efetivo e não recomendado, sendo meramente pesado de carregar.

-- Vantagens do código novo:
-- [1] Ao invés de criar uma instância NumberValue, o novo código seta atributos ao jogador, o que é mais recomendado e leve.
-- [2] Faz tudo que o código antigo faz, porém ao invés de criar NumberValues no player, seta atributos.
-- [3] Não é necessáriamente preciso ter que registrar a existência de um atributo para que ele seja salvo e carregado, o que é meramente mais efetivo, sendo assim, salvando e carregando apenas os atributos que o player tiver.
-- Desvantagens:
-- [1] Apesar de ser meio controverso, criei o novo código com uma funcionalidade específica, onde eu não necessáriamente preciso registrar a existência de um atributo no script para o mesmo ser salvo e carregado, o que deixa mais rapido, porém isso deixa meio complicado para lembrar o nome de tal atributo, como por exemplo, eu teria que lembrar isso aqui: StatusDoubleChanceInPlantation. O que eu teria que lembrar as 5 palavras, em sequência, e com as letras em maiúsculo, o que seria meio tenso, sendo assim, se eu errar a sintaxe do nome, poderia dar alguns problemas.

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
