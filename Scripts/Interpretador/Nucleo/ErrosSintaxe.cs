#nullable enable
using System;
using System.Collections.Generic;
using System.IO;
using Antlr4.Runtime;

namespace Grimorio.Interpretador
{
	/// <summary>Dados brutos de um erro reportado pelo ANTLR.</summary>
	public readonly record struct DetalheErroSintaxe(
		int Linha,          // linha (base 1) do token problemático
		int LinhaAnterior,  // linha do último token válido antes dele (útil para "faltou X")
		string Simbolo,     // texto do token problemático ("" quando é o fim do arquivo)
		string SimboloAnterior, // texto do último token válido antes dele ("" se não houver)
		bool FimDoArquivo,
		string MensagemAntlr,
		bool Lexico);

	/// <summary>Tipos de erro de sintaxe reconhecidos (independentes de idioma).</summary>
	public enum TipoErroSintaxe
	{
		CaractereInvalido,
		FaltaFecharBloco,      // faltou '}'
		FaltaAbrirBloco,       // faltou '{'
		DoisPontosEmVezDeChave,// sintaxe antiga: se(x):
		FaltaFecharParenteses,
		FaltaAbrirParenteses,
		FaltaFecharColchete,
		ChaveSobrando,         // '}' sem bloco aberto
		BlocoVazio,            // '{ }' sem nenhum comando (comentário não conta)
		CodigoVazio,           // só comentários / nada para executar
		CodigoTerminouCedo,
		TermoInesperado,       // mismatched input
		TermoSobrando,         // extraneous input
		ComandoDesconhecido,   // no viable alternative
		Generico,
	}

	/// <summary>
	/// Classifica erros do ANTLR e gera mensagens amigáveis.
	/// Cada idioma fornece os textos em <see cref="Texto"/> e pode
	/// interceptar casos próprios em <see cref="DicaEspecifica"/>.
	/// </summary>
	public abstract class TradutorErrosSintaxe
	{
		/// <summary>Texto da mensagem; {0} = símbolo problemático (pode ser vazio).</summary>
		protected abstract string Texto(TipoErroSintaxe tipo, string simbolo);

		/// <summary>Chance de o idioma tratar um caso específico (ex.: palavra antiga "fim"). Retorne null para seguir o fluxo padrão.</summary>
		protected virtual ErroCodigo? DicaEspecifica(DetalheErroSintaxe d) => null;

		public ErroCodigo Traduzir(DetalheErroSintaxe d)
		{
			var especifico = DicaEspecifica(d);
			if (especifico.HasValue) return especifico.Value;

			var (tipo, linha) = Classificar(d);
			return new ErroCodigo(linha, Texto(tipo, d.Simbolo));
		}

		public static (TipoErroSintaxe tipo, int linha) Classificar(DetalheErroSintaxe d)
		{
			string msg = d.MensagemAntlr ?? "";

			// ':' não existe mais na linguagem: é erro léxico, mas quase sempre é a sintaxe antiga "se(x):".
			if (d.Simbolo == ":") return (TipoErroSintaxe.DoisPontosEmVezDeChave, d.Linha);
			if (d.Lexico) return (TipoErroSintaxe.CaractereInvalido, d.Linha);

			bool esperando = msg.Contains("expecting");
			bool esperaFechaChave = msg.Contains("missing '}'") || (esperando && msg.Contains("'}'"));
			bool esperaAbreChave = msg.Contains("missing '{'") || (esperando && msg.Contains("'{'"));
			// O erro só apareceu na linha seguinte: o jogador quebrou a linha sem fechar algo.
			bool quebrouLinha = d.Linha > d.LinhaAnterior;

			// A gramática exige ao menos um comando em cada bloco e no programa.
			if (d.Simbolo == "}" && d.SimboloAnterior == "{") return (TipoErroSintaxe.BlocoVazio, d.LinhaAnterior);
			if (d.FimDoArquivo && d.SimboloAnterior == "") return (TipoErroSintaxe.CodigoVazio, Math.Max(1, d.Linha));
			if (d.FimDoArquivo && esperaFechaChave) return (TipoErroSintaxe.FaltaFecharBloco, d.LinhaAnterior);
			if (d.FimDoArquivo) return (TipoErroSintaxe.CodigoTerminouCedo, d.LinhaAnterior);
			if (msg.StartsWith("extraneous input '}'")) return (TipoErroSintaxe.ChaveSobrando, d.Linha);
			if (msg.Contains("missing '}'")) return (TipoErroSintaxe.FaltaFecharBloco, d.LinhaAnterior);
			if (esperaAbreChave && !esperaFechaChave) return (TipoErroSintaxe.FaltaAbrirBloco, d.LinhaAnterior);
			if (msg.Contains("missing ')'")) return (TipoErroSintaxe.FaltaFecharParenteses, d.LinhaAnterior);
			if (msg.Contains("missing '('")) return (TipoErroSintaxe.FaltaAbrirParenteses, d.Linha);
			if (msg.Contains("missing ']'")) return (TipoErroSintaxe.FaltaFecharColchete, d.LinhaAnterior);
			if (quebrouLinha && esperando && msg.Contains("')'")) return (TipoErroSintaxe.FaltaFecharParenteses, d.LinhaAnterior);
			if (quebrouLinha && esperando && msg.Contains("']'")) return (TipoErroSintaxe.FaltaFecharColchete, d.LinhaAnterior);
			if (msg.StartsWith("mismatched input")) return (TipoErroSintaxe.TermoInesperado, d.Linha);
			if (msg.StartsWith("extraneous input")) return (TipoErroSintaxe.TermoSobrando, d.Linha);
			if (msg.StartsWith("no viable alternative")) return (TipoErroSintaxe.ComandoDesconhecido, d.Linha);
			return (TipoErroSintaxe.Generico, d.Linha);
		}
	}

	/// <summary>
	/// Listener que coleta TODOS os erros de lexer e parser (sem lançar exceção),
	/// para o editor marcar todas as linhas problemáticas de uma vez.
	/// Funciona com qualquer gramática ANTLR.
	/// </summary>
	public sealed class ColetorErrosSintaxe : BaseErrorListener, IAntlrErrorListener<int>
	{
		private readonly TradutorErrosSintaxe _tradutor;
		private readonly List<ErroCodigo> _erros = new();
		private readonly HashSet<int> _linhasComErro = new();

		public IReadOnlyList<ErroCodigo> Erros => _erros;

		public ColetorErrosSintaxe(TradutorErrosSintaxe tradutor) { _tradutor = tradutor; }

		/// <summary>Anexa o coletor a um lexer e parser recém-criados (remove os listeners padrão do console).</summary>
		public void Anexar(Lexer lexer, Parser parser)
		{
			lexer.RemoveErrorListeners();
			lexer.AddErrorListener(this);
			parser.RemoveErrorListeners();
			parser.AddErrorListener(this);
		}

		// Erros do parser
		public override void SyntaxError(TextWriter output, IRecognizer recognizer, IToken offendingSymbol,
			int line, int charPositionInLine, string msg, RecognitionException e)
		{
			bool fim = offendingSymbol == null || offendingSymbol.Type == TokenConstants.EOF;
			string simbolo = fim ? "" : offendingSymbol!.Text ?? "";

			int linhaAnterior = line;
			string simboloAnterior = "";
			if (recognizer is Parser parser)
			{
				var anterior = parser.TokenStream.LT(-1);
				if (anterior != null && anterior.Type != TokenConstants.EOF)
				{
					linhaAnterior = anterior.Line;
					simboloAnterior = anterior.Text ?? "";
				}
			}
			// Em "no viable alternative" os tokens anteriores ainda estão no lookahead (não consumidos):
			// o início da tentativa é o token que de fato precede o problemático (ex.: "fim" em "fim se").
			if (e is NoViableAltException semAlternativa && semAlternativa.StartToken != null
				&& semAlternativa.StartToken != offendingSymbol && semAlternativa.StartToken.Type != TokenConstants.EOF)
			{
				linhaAnterior = semAlternativa.StartToken.Line;
				simboloAnterior = semAlternativa.StartToken.Text ?? "";
			}

			Adicionar(new DetalheErroSintaxe(line, linhaAnterior, simbolo, simboloAnterior, fim, msg, Lexico: false));
		}

		// Erros do lexer (caractere que não pertence à linguagem)
		public void SyntaxError(TextWriter output, IRecognizer recognizer, int offendingSymbol,
			int line, int charPositionInLine, string msg, RecognitionException e)
		{
			string simbolo = "";
			int ini = msg.IndexOf("at: '", StringComparison.Ordinal);
			if (ini >= 0)
			{
				ini += 5;
				int fimAspas = msg.LastIndexOf('\'');
				if (fimAspas > ini) simbolo = msg.Substring(ini, fimAspas - ini);
			}
			Adicionar(new DetalheErroSintaxe(line, line, simbolo, "", false, msg, Lexico: true));
		}

		private void Adicionar(DetalheErroSintaxe detalhe)
		{
			var erro = _tradutor.Traduzir(detalhe);
			// Uma mensagem por linha: o primeiro erro costuma ser o mais útil; os seguintes são efeito cascata.
			if (_linhasComErro.Add(erro.Linha)) _erros.Add(erro);
		}
	}
}
