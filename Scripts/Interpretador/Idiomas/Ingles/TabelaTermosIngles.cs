#nullable enable
using System.Collections.Generic;

namespace Grimorio.Interpretador.Idiomas
{
	/// <summary>
	/// Dicionário inglês ↔ canônico (o vocabulário interno do jogo, em português).
	///
	/// Sempre compilado (não depende do interpretador em inglês), para poder ser
	/// testado e revisado antes de ligar o idioma. Quando o interpretador em inglês
	/// for atualizado, confira se os nomes abaixo continuam batendo com os
	/// HashSets do MyVisitor (_directions, _attacks, _arenas, _enemies...).
	/// </summary>
	public static class TabelaTermosIngles
	{
		public static readonly IReadOnlyDictionary<string, string> Direcoes = new Dictionary<string, string>
		{
			["Up"] = "Cima",
			["Down"] = "Baixo",
			["Right"] = "Direita",
			["Left"] = "Esquerda",
		};

		public static readonly IReadOnlyDictionary<string, string> Ataques = new Dictionary<string, string>
		{
			["BlueSphere"] = "EsferaAzul",
			["RedSphere"] = "EsferaVermelha",
			["Lightning"] = "Raio",
			["Ice"] = "Gelo",
			["Fire"] = "Fogo",
			["FireExplosion"] = "ExplosaoFogo",
			["IceExplosion"] = "ExplosaoGelo",
			["Garlic"] = "Alho",
		};

		public static readonly IReadOnlyDictionary<string, string> Arenas = new Dictionary<string, string>
		{
			["Fields"] = "Campos",
			["Forest"] = "Floresta",
			["Maze"] = "Labirinto",
		};

		public static readonly IReadOnlyDictionary<string, string> Inimigos = new Dictionary<string, string>
		{
			["Goblin"] = "Goblin",
			["Skeleton"] = "Esqueleto",
			["FireSlime"] = "SlimeDeFogo",
			["IceSlime"] = "SlimeDeGelo",
			["Werewolf"] = "Lobisomem",
			["Orc"] = "Orc",
			["Ghost"] = "Fantasma",
			["Vampire"] = "Vampiro",
		};

		public static readonly IReadOnlyDictionary<string, string> Itens = new Dictionary<string, string>
		{
			["HealthPotion"] = "PocaoDeVida",
		};

		public static readonly IReadOnlyDictionary<string, string> Recursos = new Dictionary<string, string>
		{
			["Coin"] = "Moeda",
			["Bone"] = "Osso",
			["Leather"] = "Couro",
			["Magma"] = "Magma",
			["Crystal"] = "Cristal",
			["Plasma"] = "Plasma",
			["Blood"] = "Sangue",
			["Sapphire"] = "Safira",
			["Emerald"] = "Esmeralda",
			["Diamond"] = "Diamante",
		};

		/// <summary>Categorias de destaque do MyVisitor (inglês) → categorias do Terminal.gd.</summary>
		public static readonly IReadOnlyDictionary<string, string> CategoriasDestaque = new Dictionary<string, string>
		{
			["var_declaration"] = Interpretador.CategoriasDestaque.DeclaracaoVar,
			["var_read"] = Interpretador.CategoriasDestaque.LeituraVar,
			["var_origin"] = Interpretador.CategoriasDestaque.OrigemVar,
			["assignment"] = Interpretador.CategoriasDestaque.Atribuicao,
			["if_else"] = Interpretador.CategoriasDestaque.SeSenao,
			["end_if"] = Interpretador.CategoriasDestaque.FimSe,
			["while"] = Interpretador.CategoriasDestaque.Enquanto,
			["end_while"] = Interpretador.CategoriasDestaque.FimEnquanto,
			["function_call"] = Interpretador.CategoriasDestaque.ChamadaFuncao,
			["pending_function_call"] = Interpretador.CategoriasDestaque.ChamadaFuncaoPendente,
			["function_body"] = Interpretador.CategoriasDestaque.CorpoFuncao,
			["end_function"] = Interpretador.CategoriasDestaque.FimFuncao,
			["return"] = Interpretador.CategoriasDestaque.Retorna,
		};

		/// <summary>Textos que o jogo devolve em português e que o jogador inglês vê (ex.: alvo.name).</summary>
		public static readonly IReadOnlyDictionary<string, string> TextosDoJogo = new Dictionary<string, string>
		{
			["Inimigo Desconhecido"] = "Unknown Enemy",
			["Nulo"] = "Null",
		};

		// Tabelas invertidas (canônico → inglês), montadas uma vez.
		private static readonly Dictionary<string, string> _canonicoParaIngles = MontarInverso();

		private static Dictionary<string, string> MontarInverso()
		{
			var inverso = new Dictionary<string, string>();
			foreach (var tabela in new[] { Direcoes, Ataques, Arenas, Inimigos, Itens, Recursos, TextosDoJogo })
				foreach (var par in tabela)
					inverso.TryAdd(par.Value, par.Key);
			return inverso;
		}

		/// <summary>Inglês → canônico. Valores fora da tabela passam sem alteração.</summary>
		public static string ParaCanonico(IReadOnlyDictionary<string, string> tabela, string valor)
			=> valor != null && tabela.TryGetValue(valor, out var canonico) ? canonico : valor!;

		/// <summary>Canônico → inglês (para textos que voltam do jogo, ex.: nome do inimigo).</summary>
		public static string ParaIngles(string valor)
			=> valor != null && _canonicoParaIngles.TryGetValue(valor, out var ingles) ? ingles : valor!;

		public static string Categoria(string categoriaIngles)
			=> categoriaIngles != null && CategoriasDestaque.TryGetValue(categoriaIngles, out var c) ? c : categoriaIngles ?? "";
	}

	/// <summary>Mensagens de erro de sintaxe em inglês (sintaxe com chaves { }).</summary>
	public sealed class TradutorErrosIngles : TradutorErrosSintaxe
	{
		protected override ErroCodigo? DicaEspecifica(DetalheErroSintaxe d)
		{
			if (d.Simbolo == "end" || d.SimboloAnterior == "end")
				return new ErroCodigo(d.Simbolo == "end" ? d.Linha : d.LinhaAnterior,
					"The word 'end' is not used. Close the block with '}' (e.g. if(x) { ... }).");
			return null;
		}

		protected override string Texto(TipoErroSintaxe tipo, string s) => tipo switch
		{
			TipoErroSintaxe.CaractereInvalido => string.IsNullOrEmpty(s)
				? "This line has a character the language doesn't recognize."
				: $"The character '{s}' is not recognized by the language. Avoid accents and special symbols in names.",
			TipoErroSintaxe.FaltaFecharBloco => "A block was not closed with '}'. Every '{' needs a matching '}'.",
			TipoErroSintaxe.FaltaAbrirBloco => "Missing '{' to open the block at the end of this structure.",
			TipoErroSintaxe.DoisPontosEmVezDeChave => "Blocks use braces: replace ':' with '{' and close the block with '}'.",
			TipoErroSintaxe.FaltaFecharParenteses => "Missing closing parenthesis ')'.",
			TipoErroSintaxe.FaltaAbrirParenteses => "Missing opening parenthesis '('.",
			TipoErroSintaxe.FaltaFecharColchete => "Missing ']' to close the list.",
			TipoErroSintaxe.ChaveSobrando => "This '}' is extra: there is no open block for it to close.",
			TipoErroSintaxe.BlocoVazio => "This block is empty. Put at least one command between '{' and '}' (comments don't count).",
			TipoErroSintaxe.CodigoVazio => "There are no commands to run (comments are ignored).",
			TipoErroSintaxe.CodigoTerminouCedo => "The code ended too early. Is some command incomplete?",
			TipoErroSintaxe.TermoInesperado => string.IsNullOrEmpty(s)
				? "A command is incomplete or ended suddenly."
				: $"'{s}' is misspelled or in the wrong place.",
			TipoErroSintaxe.TermoSobrando => string.IsNullOrEmpty(s)
				? "There are extra words or symbols on this line."
				: $"'{s}' shouldn't be here. Did you type something extra?",
			TipoErroSintaxe.ComandoDesconhecido => string.IsNullOrEmpty(s)
				? "Unknown command. The grimoire couldn't understand this line."
				: $"The grimoire doesn't recognize the command '{s}'. Does it exist and is it spelled right?",
			_ => string.IsNullOrEmpty(s)
				? "Syntax error. Check the structure of this command."
				: $"Syntax error near '{s}'. Something is missing or extra.",
		};
	}
}
