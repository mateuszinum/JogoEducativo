extends Node

@export var lista_de_produtos: Array[ProdutoLoja] = []

func get_produto(nome_procurado: String) -> ProdutoLoja:
	var nome_limpo = nome_procurado.to_lower().strip_edges()
	
	for produto in lista_de_produtos:
		if produto != null and produto.nome.to_lower().strip_edges() == nome_limpo:
			return produto
			
	return null
