// ============================================================================
// IDIOMA INGLÊS — DESLIGADO NESTE BUILD
//
// Este arquivo só compila quando o símbolo GRIMORIO_INGLES está definido.
// Para ligar (depois de atualizar o interpretador em inglês):
//   1. Siga as instruções do bloco "Interpretador em inglês" no "jogo educativo.csproj"
//      (renomear o .csproj inglês para Game.Core.csproj + descomentar a referência).
//   2. Confira se os nomes do Game.Core (IGameActions, MyVisitor, LanguageLexer,
//      LanguageParser, ReturnException, regra 'program') ainda batem com o código abaixo.
//   3. Revise TabelaTermosIngles.cs e o perfil "en" do LinguagemDB.gd.
//
// Escrito contra a versão do backend-extensao-ingles de 2026-11 (commit 5aa579b).
// ============================================================================
#if GRIMORIO_INGLES
#nullable enable
using System;
using System.Collections.Generic;
using Antlr4.Runtime;
using Game.Core;

namespace Grimorio.Interpretador.Idiomas
{
	public sealed class IdiomaIngles : IIdiomaInterpretador
	{
		public string Codigo => "en";

		public MensagensPonte Mensagens { get; } = new()
		{
			RetornoForaDeFuncao = "'return' can only be used inside a function.",
			ErroInesperadoNaLinha = "Something went wrong while running this line. Check the values used (one of them may be Null).",
		};

		private readonly TradutorErrosIngles _tradutor = new();

		public IReadOnlyList<ErroCodigo> Analisar(string codigo, out IProgramaCompilado? programa)
		{
			var lexer = new LanguageLexer(new AntlrInputStream(codigo));
			var parser = new LanguageParser(new CommonTokenStream(lexer));
			var coletor = new ColetorErrosSintaxe(_tradutor);
			coletor.Anexar(lexer, parser);

			var arvore = parser.program();

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
			private readonly LanguageParser.ProgramContext _arvore;
			private readonly MensagensPonte _mensagens;

			public Programa(LanguageParser.ProgramContext arvore, MensagensPonte mensagens)
			{
				_arvore = arvore;
				_mensagens = mensagens;
			}

			public void Executar(IPonteJogo ponte)
			{
				try
				{
					new MyVisitor(new AdaptadorAcoesIngles(ponte)).Visit(_arvore);
				}
				catch (ExecucaoAbortadaException) { throw; }
				catch (ErroCodigoException) { throw; }
				catch (ReturnException ex)
				{
					throw new ErroCodigoException(null, _mensagens.RetornoForaDeFuncao, ex);
				}
				catch (Exception ex) when (ex.GetType() == typeof(Exception))
				{
					throw ErroCodigoException.DeMensagemDoInterpretador(ex);
				}
			}
		}
	}

	/// <summary>
	/// Implementa a interface do interpretador em inglês traduzindo os valores
	/// para o formato canônico do jogo (e de volta, quando o jogo devolve texto).
	/// </summary>
	internal sealed class AdaptadorAcoesIngles : IGameActions
	{
		private readonly IPonteJogo _ponte;
		public AdaptadorAcoesIngles(IPonteJogo ponte) { _ponte = ponte; }

		private static string Dir(string d) => TabelaTermosIngles.ParaCanonico(TabelaTermosIngles.Direcoes, d);
		private static string Atk(string a) => TabelaTermosIngles.ParaCanonico(TabelaTermosIngles.Ataques, a);
		private static string Arena(string a) => TabelaTermosIngles.ParaCanonico(TabelaTermosIngles.Arenas, a);
		private static string Item(string i) => TabelaTermosIngles.ParaCanonico(TabelaTermosIngles.Itens, i);

		// MAIN PLAYER ACTIONS
		public void Move(string direction) => _ponte.Mover(Dir(direction));
		public void Attack(string target, string type) => _ponte.Atacar(target, Atk(type));
		public void Escape() => _ponte.Escapar();
		public void EnterArena(string arena) => _ponte.EntrarArena(Arena(arena));

		// SYSTEM AND FRONTEND
		public void NotifyError(string message) => _ponte.NotificarErro(message);
		public void Write(string text) => _ponte.Escreva(text);
		public void HighlightCurrentLine(int line, string category = "")
			=> _ponte.DestacarLinhaAtual(line, TabelaTermosIngles.Categoria(category));

		// SENSORS
		public string NearestEnemy() => _ponte.InimigoMaisProximo();
		public bool EnemyExists(string enemyId) => _ponte.InimigoExiste(enemyId);
		public bool CanMove(string direction) => _ponte.PodeMover(Dir(direction));
		public int GetTime() => _ponte.GetTempo();
		public int GetCurrentHealth() => _ponte.GetVidaAtual();
		public List<string> ScanArea() => _ponte.EscanearArea();

		// COORDINATES
		public int GetPlayerPositionX() => _ponte.GetPosicaoPlayerX();
		public int GetPlayerPositionY() => _ponte.GetPosicaoPlayerY();
		public int GetTreasurePositionX() => _ponte.GetPosicaoTesouroX();
		public int GetTreasurePositionY() => _ponte.GetPosicaoTesouroY();

		// INVENTORY AND ECONOMY
		public void UseBeltItem(int index) => _ponte.UsarItemCinto(index);
		public void UseBackpackItem() => _ponte.UsarItemMochila();
		public void Buy(string item) => _ponte.Comprar(Item(item));
		public void SellAll() => _ponte.VenderTudo();
		public void PutItemInBackpack(string item) => _ponte.ColocarItemMochila(Item(item));
		public void PutItemInBelt(string item, int idx) => _ponte.ColocarItemCinto(Item(item), idx);

		// OBJECT ATTRIBUTES — o nome volta do jogo em português; o jogador compara com "Skeleton", etc.
		public string GetEnemyName(string enemyId) => TabelaTermosIngles.ParaIngles(_ponte.ObterNomeInimigo(enemyId));
		public int GetEnemyPositionX(string enemyId) => _ponte.ObterPosicaoXInimigo(enemyId);
		public int GetEnemyPositionY(string enemyId) => _ponte.ObterPosicaoYInimigo(enemyId);
		public float GetEnemyHealth(string enemyId) => _ponte.ObterVidaInimigo(enemyId);
	}
}
#endif
