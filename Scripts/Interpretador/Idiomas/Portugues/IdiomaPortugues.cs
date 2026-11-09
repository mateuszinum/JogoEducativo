#nullable enable
using System;
using System.Collections.Generic;
using Antlr4.Runtime;
using Jogo.Core;

namespace Grimorio.Interpretador.Idiomas
{
	/// <summary>
	/// Idioma português: usa o interpretador do repositório backend-extensao
	/// (Linguagem.g4 + MeuVisitor, namespace Jogo.Core).
	///
	/// O vocabulário do interpretador PT já é o canônico do jogo, então o
	/// adaptador só repassa as chamadas.
	/// </summary>
	public sealed class IdiomaPortugues : IIdiomaInterpretador
	{
		public string Codigo => "pt";

		public MensagensPonte Mensagens { get; } = new()
		{
			RetornoForaDeFuncao = "'retorna' só pode ser usado dentro de uma função.",
			ErroInesperadoNaLinha = "Algo deu errado ao executar esta linha. Confira os valores usados (algum deles pode estar Nulo).",
		};

		private readonly TradutorErrosPortugues _tradutor = new();

		public IReadOnlyList<ErroCodigo> Analisar(string codigo, out IProgramaCompilado? programa)
		{
			var lexer = new LinguagemLexer(new AntlrInputStream(codigo));
			var parser = new LinguagemParser(new CommonTokenStream(lexer));
			var coletor = new ColetorErrosSintaxe(_tradutor);
			coletor.Anexar(lexer, parser);

			var arvore = parser.programa();

			if (coletor.Erros.Count > 0)
			{
				programa = null;
				return coletor.Erros;
			}

			programa = new Programa(arvore, Mensagens);
			return Array.Empty<ErroCodigo>();
		}

		private sealed class Programa : IProgramaCompilado
		{
			private readonly LinguagemParser.ProgramaContext _arvore;
			private readonly MensagensPonte _mensagens;

			public Programa(LinguagemParser.ProgramaContext arvore, MensagensPonte mensagens)
			{
				_arvore = arvore;
				_mensagens = mensagens;
			}

			public void Executar(IPonteJogo ponte)
			{
				try
				{
					new MeuVisitor(new AdaptadorAcoesPortugues(ponte)).Visit(_arvore);
				}
				catch (ExecucaoAbortadaException) { throw; }
				catch (ErroCodigoException) { throw; }
				catch (ExcecaoRetorno ex)
				{
					// 'retorna' no corpo principal (fora de função) sobe até aqui.
					throw new ErroCodigoException(null, _mensagens.RetornoForaDeFuncao, ex);
				}
				catch (Exception ex) when (ex.GetType() == typeof(Exception))
				{
					// Erros do jogador lançados pelo MeuVisitor ("L:<linha>|<mensagem>" ou só a mensagem).
					throw ErroCodigoException.DeMensagemDoInterpretador(ex);
				}
				// Demais tipos (NullReference, InvalidCast...) sobem como erro interno.
			}
		}
	}

	/// <summary>Implementa a interface do interpretador PT repassando para a ponte.</summary>
	internal sealed class AdaptadorAcoesPortugues : IAcoesDoJogo
	{
		private readonly IPonteJogo _ponte;
		public AdaptadorAcoesPortugues(IPonteJogo ponte) { _ponte = ponte; }

		public void Mover(string direcao) => _ponte.Mover(direcao);
		public void Atacar(string alvo, string tipo) => _ponte.Atacar(alvo, tipo);
		public void Escapar() => _ponte.Escapar();
		public void EntrarArena(string arena) => _ponte.EntrarArena(arena);

		public void NotificarErro(string mensagem) => _ponte.NotificarErro(mensagem);
		public void Escreva(string texto) => _ponte.Escreva(texto);
		public void DestacarLinhaAtual(int linha, string categoria = "") => _ponte.DestacarLinhaAtual(linha, categoria);

		public string InimigoMaisProximo() => _ponte.InimigoMaisProximo();
		public bool InimigoExiste(string inimigoId) => _ponte.InimigoExiste(inimigoId);
		public bool PodeMover(string direcao) => _ponte.PodeMover(direcao);
		public int GetTempo() => _ponte.GetTempo();
		public int GetVidaAtual() => _ponte.GetVidaAtual();
		public List<string> EscanearArea() => _ponte.EscanearArea();

		public int GetPosicaoPlayerX() => _ponte.GetPosicaoPlayerX();
		public int GetPosicaoPlayerY() => _ponte.GetPosicaoPlayerY();
		public int GetPosicaoTesouroX() => _ponte.GetPosicaoTesouroX();
		public int GetPosicaoTesouroY() => _ponte.GetPosicaoTesouroY();

		public void UsarItemCinto(int indice) => _ponte.UsarItemCinto(indice);
		public void UsarItemMochila() => _ponte.UsarItemMochila();
		public void Comprar(string item) => _ponte.Comprar(item);
		public void VenderTudo() => _ponte.VenderTudo();
		public void ColocarItemMochila(string item) => _ponte.ColocarItemMochila(item);
		public void ColocarItemCinto(string item, int idx) => _ponte.ColocarItemCinto(item, idx);

		public string ObterNomeInimigo(string inimigoId) => _ponte.ObterNomeInimigo(inimigoId);
		public int ObterPosicaoXInimigo(string inimigoId) => _ponte.ObterPosicaoXInimigo(inimigoId);
		public int ObterPosicaoYInimigo(string inimigoId) => _ponte.ObterPosicaoYInimigo(inimigoId);
		public float ObterVidaInimigo(string inimigoId) => _ponte.ObterVidaInimigo(inimigoId);
	}

	/// <summary>Mensagens de erro de sintaxe em português (sintaxe com chaves { }).</summary>
	internal sealed class TradutorErrosPortugues : TradutorErrosSintaxe
	{
		protected override ErroCodigo? DicaEspecifica(DetalheErroSintaxe d)
		{
			// Código escrito na sintaxe antiga ("fim se", "fim enquanto", "fim funcao").
			// O ANTLR lê "fim" como identificador e costuma acusar a palavra seguinte ("se"/"enquanto").
			if (d.Simbolo == "fim" || d.SimboloAnterior == "fim")
				return new ErroCodigo(d.Simbolo == "fim" ? d.Linha : d.LinhaAnterior,
					"A palavra 'fim' não é mais usada. Feche o bloco com '}' (ex.: se(x) { ... }).");
			if (d.Simbolo == "funcao")
				return new ErroCodigo(d.Linha, "A palavra 'funcao' não é usada para declarar funções. Escreva o tipo de retorno e o nome, ex.: vazio andar() { ... }");
			return null;
		}

		protected override string Texto(TipoErroSintaxe tipo, string s) => tipo switch
		{
			TipoErroSintaxe.CaractereInvalido => string.IsNullOrEmpty(s)
				? "Existe um caractere que a linguagem não reconhece nesta linha."
				: $"O caractere '{s}' não é reconhecido pela linguagem. Evite acentos e símbolos especiais em nomes.",
			TipoErroSintaxe.FaltaFecharBloco => "Faltou fechar um bloco com '}'. Todo '{' precisa de um '}' correspondente.",
			TipoErroSintaxe.FaltaAbrirBloco => "Faltou abrir o bloco com '{' no final desta estrutura.",
			TipoErroSintaxe.DoisPontosEmVezDeChave => "Os blocos agora usam chaves: troque ':' por '{' e feche o bloco com '}'.",
			TipoErroSintaxe.FaltaFecharParenteses => "Faltou fechar o parêntese ')'.",
			TipoErroSintaxe.FaltaAbrirParenteses => "Faltou abrir o parêntese '('.",
			TipoErroSintaxe.FaltaFecharColchete => "Faltou fechar o colchete ']' da lista.",
			TipoErroSintaxe.ChaveSobrando => "Esta '}' está sobrando: não existe nenhum bloco aberto para ela fechar.",
			TipoErroSintaxe.BlocoVazio => "Este bloco está vazio. Coloque pelo menos um comando entre '{' e '}' (comentários não contam).",
			TipoErroSintaxe.CodigoVazio => "Não há nenhum comando para executar (comentários são ignorados).",
			TipoErroSintaxe.CodigoTerminouCedo => "O código terminou antes da hora. Algum comando ficou incompleto?",
			TipoErroSintaxe.TermoInesperado => string.IsNullOrEmpty(s)
				? "Um comando está incompleto ou terminou de repente."
				: $"O termo '{s}' está escrito errado ou foi colocado no lugar incorreto.",
			TipoErroSintaxe.TermoSobrando => string.IsNullOrEmpty(s)
				? "Existem palavras ou símbolos sobrando nesta linha."
				: $"O item '{s}' não deveria estar aqui. Você digitou algo a mais?",
			TipoErroSintaxe.ComandoDesconhecido => string.IsNullOrEmpty(s)
				? "Comando desconhecido. O grimório não conseguiu entender esta linha."
				: $"O grimório não reconhece o comando '{s}'. Ele existe e foi escrito certo?",
			_ => string.IsNullOrEmpty(s)
				? "Erro de sintaxe. Verifique a estrutura deste comando."
				: $"Erro de sintaxe perto de '{s}'. Algo está faltando ou sobrando.",
		};
	}
}
