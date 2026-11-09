#nullable enable
using System;
using System.Collections.Generic;

namespace Grimorio.Interpretador
{
	/// <summary>
	/// Um idioma da linguagem do Grimório (português, inglês...).
	/// Cada idioma embrulha um interpretador (gramática ANTLR + visitor) e
	/// sabe traduzir o vocabulário dele para o formato canônico de <see cref="IPonteJogo"/>.
	///
	/// Para adicionar um idioma: implemente esta interface, registre em
	/// <see cref="RegistroIdiomas"/> e crie o perfil do editor em LinguagemDB.gd.
	/// </summary>
	public interface IIdiomaInterpretador
	{
		/// <summary>Código curto do idioma ("pt", "en"). Mesmo código usado no LinguagemDB.gd.</summary>
		string Codigo { get; }

		/// <summary>Mensagens da própria ponte (erros que não vêm do interpretador).</summary>
		MensagensPonte Mensagens { get; }

		/// <summary>
		/// Faz a análise léxica/sintática. Se houver erros, retorna a lista (com mensagens
		/// já amigáveis e no idioma) e <paramref name="programa"/> fica nulo.
		/// </summary>
		IReadOnlyList<ErroCodigo> Analisar(string codigo, out IProgramaCompilado? programa);
	}

	/// <summary>Programa já analisado, pronto para rodar.</summary>
	public interface IProgramaCompilado
	{
		/// <summary>
		/// Executa o programa (bloqueante; chamado na thread de execução).
		/// Erros do código do jogador saem como <see cref="ErroCodigoException"/>;
		/// <see cref="ExecucaoAbortadaException"/> é propagada sem alteração.
		/// </summary>
		void Executar(IPonteJogo ponte);
	}

	/// <summary>Erro apontado no código do jogador. <see cref="Linha"/> começa em 1.</summary>
	public readonly record struct ErroCodigo(int Linha, string Mensagem);

	/// <summary>Textos que a ponte mostra ao jogador, por idioma.</summary>
	public sealed class MensagensPonte
	{
		public string RetornoForaDeFuncao { get; init; } = "";
		public string ErroInesperadoNaLinha { get; init; } = "";
	}

	/// <summary>Erro de execução causado pelo código do jogador.</summary>
	public sealed class ErroCodigoException : Exception
	{
		/// <summary>Linha (base 1) do erro, quando o interpretador informou.</summary>
		public int? Linha { get; }

		public ErroCodigoException(int? linha, string mensagem, Exception? interna = null)
			: base(mensagem, interna)
		{
			Linha = linha;
		}

		/// <summary>
		/// Os interpretadores lançam <c>Exception("L:&lt;linha&gt;|&lt;mensagem&gt;")</c>.
		/// Converte esse formato; exceções sem o prefixo ficam sem linha.
		/// </summary>
		public static ErroCodigoException DeMensagemDoInterpretador(Exception ex)
		{
			string msg = ex.Message ?? "";
			if (msg.StartsWith("L:", StringComparison.Ordinal))
			{
				var partes = msg.Split('|', 2);
				if (partes.Length == 2 && int.TryParse(partes[0].AsSpan(2), out int linha))
					return new ErroCodigoException(linha, partes[1].Trim(), ex);
			}
			return new ErroCodigoException(null, msg.Trim(), ex);
		}
	}

	/// <summary>Lançada dentro da thread de execução quando o jogador para o código.</summary>
	public sealed class ExecucaoAbortadaException : Exception
	{
		public ExecucaoAbortadaException() : base("Execução abortada pelo jogador.") { }
	}
}
