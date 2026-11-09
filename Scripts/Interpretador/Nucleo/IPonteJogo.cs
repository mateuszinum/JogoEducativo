#nullable enable
using System.Collections.Generic;

namespace Grimorio.Interpretador
{
	/// <summary>
	/// API do jogo vista pelos interpretadores, independente de idioma.
	///
	/// Todos os valores trocados aqui estão no formato CANÔNICO do jogo, que é
	/// o formato usado internamente pelo Godot (FuncoesNativas, ArenasDB, AtaquesDB...):
	///   - Direções:  "Cima", "Baixo", "Direita", "Esquerda"
	///   - Ataques:   "EsferaAzul", "Gelo", "Fogo", ...
	///   - Arenas:    "Campos", "Floresta", "Labirinto"
	///   - Categorias de destaque: ver <see cref="CategoriasDestaque"/>
	///
	/// Cada idioma tem um adaptador que traduz do vocabulário do jogador
	/// (ex.: "Up", "Fireball") para este formato antes de chamar a ponte.
	/// Quem implementa esta interface é o InterpretadorServico (Godot).
	/// </summary>
	public interface IPonteJogo
	{
		// AÇÕES PRINCIPAIS
		void Mover(string direcao);
		void Atacar(string alvo, string ataque);
		void Escapar();
		void EntrarArena(string arena);

		// SISTEMA E FRONTEND
		void Escreva(string texto);
		void NotificarErro(string mensagem);
		void DestacarLinhaAtual(int linha, string categoria);

		// SENSORES
		string InimigoMaisProximo();
		bool InimigoExiste(string inimigoId);
		bool PodeMover(string direcao);
		int GetTempo();
		int GetVidaAtual();
		List<string> EscanearArea();

		// COORDENADAS
		int GetPosicaoPlayerX();
		int GetPosicaoPlayerY();
		int GetPosicaoTesouroX();
		int GetPosicaoTesouroY();

		// INVENTÁRIO E ECONOMIA
		void UsarItemCinto(int indice);
		void UsarItemMochila();
		void Comprar(string item);
		void VenderTudo();
		void ColocarItemMochila(string item);
		void ColocarItemCinto(string item, int indice);

		// ATRIBUTOS DE INIMIGO
		string ObterNomeInimigo(string inimigoId);
		int ObterPosicaoXInimigo(string inimigoId);
		int ObterPosicaoYInimigo(string inimigoId);
		float ObterVidaInimigo(string inimigoId);
	}

	/// <summary>
	/// Categorias de destaque de linha aceitas pelo Terminal.gd (destacar_linha_execucao).
	/// São os nomes usados pelo interpretador em português; outros idiomas
	/// devem ser normalizados para estes valores no adaptador.
	/// </summary>
	public static class CategoriasDestaque
	{
		public const string DeclaracaoVar = "declaracao_var";
		public const string LeituraVar = "leitura_var";
		public const string OrigemVar = "origem_var";
		public const string Atribuicao = "atribuicao";
		public const string SeSenao = "se_senao";
		public const string FimSe = "fim_se";
		public const string Enquanto = "enquanto";
		public const string FimEnquanto = "fim_enquanto";
		public const string ChamadaFuncao = "chamada_funcao";
		/// <summary>Ação com tick (mover, atacar...): o destaque só aparece quando a ação de fato executa.</summary>
		public const string ChamadaFuncaoPendente = "chamada_funcao_pendente";
		public const string CorpoFuncao = "corpo_funcao";
		public const string FimFuncao = "fim_funcao";
		public const string Retorna = "retorna";
	}
}
