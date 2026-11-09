#nullable enable
using System;
using System.Collections.Generic;

namespace Grimorio.Interpretador
{
	/// <summary>
	/// Lista os idiomas de interpretador disponíveis no build.
	///
	/// O inglês só entra quando o símbolo GRIMORIO_INGLES está definido no
	/// "jogo educativo.csproj" (junto com a referência ao projeto do interpretador
	/// em inglês). Enquanto isso, pedir "en" cai no português.
	/// </summary>
	public static class RegistroIdiomas
	{
		public const string Padrao = "pt";

		private static readonly Dictionary<string, Func<IIdiomaInterpretador>> _fabricas = new()
		{
			["pt"] = () => new Idiomas.IdiomaPortugues(),
#if GRIMORIO_INGLES
			["en"] = () => new Idiomas.IdiomaIngles(),
#endif
		};

		private static readonly Dictionary<string, IIdiomaInterpretador> _cache = new();

		/// <summary>Índices de Constantes.IDIOMA (pt_br = 0, en = 1) → código do idioma.</summary>
		public static string CodigoDoIndice(int indice) => indice switch
		{
			1 => "en",
			_ => "pt",
		};

		public static bool EstaDisponivel(string codigo) => _fabricas.ContainsKey(codigo);

		public static IEnumerable<string> Disponiveis => _fabricas.Keys;

		/// <summary>Retorna o idioma pedido, ou o padrão (pt) se ele não estiver compilado neste build.</summary>
		public static IIdiomaInterpretador Obter(string codigo)
		{
			if (!_fabricas.ContainsKey(codigo)) codigo = Padrao;
			lock (_cache)
			{
				if (!_cache.TryGetValue(codigo, out var idioma))
				{
					idioma = _fabricas[codigo]();
					_cache[codigo] = idioma;
				}
				return idioma;
			}
		}
	}
}
