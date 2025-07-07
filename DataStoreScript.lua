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

local atributos = {
	{nome = "Tomate", tipo = "NumberValue"},
	{nome = "SementeTomate", tipo = "NumberValue"},
	{nome = "Trigo", tipo = "NumberValue"},
	{nome = "SementeTrigo", tipo = "NumberValue"},
	{nome = "Abobora", tipo = "NumberValue"},
	{nome = "SementeAbobora", tipo = "NumberValue"},
	{nome = "Morango", tipo = "NumberValue"},
	{nome = "SementeMorango", tipo = "NumberValue"},
	{nome = "Sede", tipo = "NumberValue"},
	{nome = "Fome", tipo = "NumberValue"},
	{nome = "Vida", tipo = "NumberValue"},
	{nome = "StartSobrevivencia", tipo = "NumberValue"},
	{nome = "Moeda", tipo = "NumberValue"},
	{nome = "Diamante", tipo = "NumberValue"},
	{nome = "Agua", tipo = "NumberValue"},
	{nome = "ResetStatusPoints", tipo = "NumberValue"},
	{nome = "StatusPoints", tipo = "NumberValue"},
	{nome = "StatusRegadorCapacity", tipo = "NumberValue"},
	{nome = "StatusDoubleChanceInPlantation", tipo = "NumberValue"},
	{nome = "StatusDecreaseGrowTime", tipo = "NumberValue"},
	{nome = "StatusMoreSeeds", tipo = "NumberValue"},
	{nome = "Level", tipo = "NumberValue"},
	{nome = "XP", tipo = "NumberValue"},
	{nome = "Massa", tipo = "NumberValue"},
	{nome = "Leite", tipo = "NumberValue"},
	{nome = "Garrafa", tipo = "NumberValue"},
	{nome = "Pizza", tipo = "NumberValue"},
	{nome = "Ovo", tipo = "NumberValue"},
	{nome = "Queijo", tipo = "NumberValue"},
	{nome = "Perk", tipo = "NumberValue"},
	{nome = "Pao", tipo = "NumberValue"},
	{nome = "GarrafaDeAgua", tipo = "NumberValue"}
}

-- Armazena os atributos modificados por jogador
local modificados = {}

-- Salva apenas atributos modificados
local function salvarDados(player)
	local lista = modificados[player]
	if not lista then return end

	for nomeAtributo, _ in pairs(lista) do
		local valor = player:FindFirstChild(nomeAtributo)
		if valor then
			local success, err = pcall(function()
				dataStore:SetAsync(player.UserId .. "_" .. nomeAtributo, valor.Value)
			end)

			if not success then
				warn("Erro ao salvar", nomeAtributo, "para", player.Name, err)
			end
		end
	end

	-- Limpa lista após salvar
	modificados[player] = {}
end

Players.PlayerAdded:Connect(function(player)
	modificados[player] = {}

	for _, atributo in ipairs(atributos) do
		local valor = Instance.new(atributo.tipo)
		valor.Name = atributo.nome
		valor.Parent = player

		-- Marca como alterado sempre que mudar
		valor.Changed:Connect(function()
			modificados[player][atributo.nome] = true
		end)

		local success, data = pcall(function()
			return dataStore:GetAsync(player.UserId .. "_" .. atributo.nome)
		end)

		if success then
			valor.Value = data or 0
		else
			warn("Erro ao carregar dados de", atributo.nome, "para", player.Name)
		end
	end

	-- ✅ Função para checar se todos os atributos foram criados
	task.spawn(function()
		while true do
			local todosCriados = true

			for _, atributo in ipairs(atributos) do
				if not player:FindFirstChild(atributo.nome) then
					todosCriados = false
					break
				end
			end

			if todosCriados then
				print("Todos os atributos foram criados para " .. player.Name)
				break
			end

			task.wait(10)
		end
	end)

	-- Auto-save a cada 60 segundos
	task.spawn(function()
		while player.Parent do
			task.wait(60)
			salvarDados(player)
		end
	end)
end)


Players.PlayerRemoving:Connect(function(player)
	salvarDados(player)
	modificados[player] = nil
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		salvarDados(player)
	end
end)
