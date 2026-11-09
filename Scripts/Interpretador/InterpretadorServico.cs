#nullable enable
using Godot;
using Grimorio.Interpretador;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

/// <summary>
/// Ponte entre o código do jogador e o jogo.
///
/// Fluxo:
///   Terminal.gd → ExecutarCodigoDoJogador()
///     → (thread de execução) idioma.Analisar() → programa.Executar(this)
///       → o visitor chama os métodos de IPonteJogo abaixo
///         → ExecutarAcaoComTick() agenda GerenciadorExecucao.executar_com_tick() na main thread
///           e bloqueia até o GDScript chamar ConcluirAcao(id, resultado).
///
/// Cada execução é uma "sessão" com id próprio: respostas atrasadas de uma
/// execução já parada são ignoradas e nunca liberam a execução seguinte.
///
/// O idioma da linguagem vem de Constantes.IDIOMA (0 = pt, 1 = en), ou de
/// <see cref="IdiomaForcado"/> se preenchido. Idiomas não compilados caem no português.
/// </summary>
public partial class InterpretadorServico : Node, IPonteJogo
{
	/// <summary>Se preenchido ("pt"/"en"), ignora Constantes.IDIOMA. Útil para testes.</summary>
	[Export] public string IdiomaForcado { get; set; } = "";

	private sealed class Sessao
	{
		public readonly int Id;
		public readonly IIdiomaInterpretador Idioma;
		public readonly AutoResetEvent Sinal = new(false);
		public volatile bool Cancelada;
		public Variant Resultado;

		// Destaque da ação com tick: aparece só quando a ação de fato executa no jogo.
		public int LinhaPendente = -1;
		public string CategoriaPendente = "";

		// Última linha executada: usada quando o interpretador lança erro sem número de linha.
		public int UltimaLinha = -1;

		public Sessao(int id, IIdiomaInterpretador idioma) { Id = id; Idioma = idioma; }
	}

	[ThreadStatic] private static Sessao? _sessaoDaThread;
	private volatile Sessao? _sessaoAtual;
	private int _ultimoId;

	private Node? _apiNativa;
	private Node? _gerenciador;
	private readonly HashSet<string> _metodosNativosDisponiveis = new();

	// Métodos do FuncoesNativas.gd usados pela ponte.
	private static readonly string[] MetodosNativos =
	{
		"mover", "atacar", "escapar", "arena", "escreva",
		"usar_item_cinto", "usar_item_mochila", "comprar", "venderTudo",
		"colocar_item_mochila", "colocar_item_cinto",
		"inimigoMaisProximo", "inimigoExiste", "podeMover", "getTempo", "getVidaAtual", "escanearArea",
		"posicaoX", "posicaoY", "tesouroX", "tesouroY",
		"nomeInimigo", "obterVidaInimigo", "obterPosicaoXInimigo", "obterPosicaoYInimigo",
	};

	public override void _Ready()
	{
		_apiNativa = GetNodeOrNull("/root/FuncoesNativas");
		_gerenciador = GetNodeOrNull("/root/GerenciadorExecucao");

		if (_apiNativa == null) GD.PushError("[InterpretadorServico] Autoload FuncoesNativas não encontrado.");
		if (_gerenciador == null) GD.PushError("[InterpretadorServico] Autoload GerenciadorExecucao não encontrado.");

		// HasMethod é resolvido aqui, na main thread; a thread de execução só consulta o HashSet.
		if (_apiNativa != null)
			foreach (var metodo in MetodosNativos)
				if (_apiNativa.HasMethod(metodo)) _metodosNativosDisponiveis.Add(metodo);
	}

	public override void _ExitTree() => PararExecucao();

	// =====================================================================
	// API PARA O GDSCRIPT
	// =====================================================================

	/// <summary>Código do idioma que será usado na próxima execução ("pt", "en"...), já considerando o que está compilado.</summary>
	public string IdiomaEfetivo()
	{
		string pedido = IdiomaPedido();
		return RegistroIdiomas.EstaDisponivel(pedido) ? pedido : RegistroIdiomas.Padrao;
	}

	public void ExecutarCodigoDoJogador(string codigo, Node personagem)
	{
		PararExecucao();

		string pedido = IdiomaPedido();
		if (!RegistroIdiomas.EstaDisponivel(pedido))
			GD.PushWarning($"[InterpretadorServico] Idioma '{pedido}' não está disponível neste build; usando '{RegistroIdiomas.Padrao}'.");

		var sessao = new Sessao(++_ultimoId, RegistroIdiomas.Obter(pedido));
		_sessaoAtual = sessao;
		_gerenciador?.Call("registrar_interpretador", this);

		Task.Run(() => RodarSessao(sessao, codigo));
	}

	public void PararExecucao()
	{
		var sessao = _sessaoAtual;
		_sessaoAtual = null;
		if (sessao != null)
		{
			sessao.Cancelada = true;
			sessao.Sinal.Set(); // acorda a thread se estiver esperando um tick
		}
		CallDeferred(nameof(DelegarLimpezaDestaque));
	}

	/// <summary>Chamado pelo GerenciadorExecucao.gd ao terminar uma ação. Ignora ids de execuções antigas.</summary>
	public void ConcluirAcao(int idExecucao, Variant resultado)
	{
		var sessao = _sessaoAtual;
		if (sessao == null || sessao.Id != idExecucao || sessao.Cancelada) return;
		sessao.Resultado = resultado;
		sessao.Sinal.Set();
	}

	/// <summary>Usado pelo GerenciadorExecucao.gd para não executar ações de uma execução já parada.</summary>
	public bool ExecucaoAtiva(int idExecucao)
	{
		var sessao = _sessaoAtual;
		return sessao != null && sessao.Id == idExecucao && !sessao.Cancelada;
	}

	// =====================================================================
	// THREAD DE EXECUÇÃO
	// =====================================================================

	private void RodarSessao(Sessao sessao, string codigo)
	{
		_sessaoDaThread = sessao;
		try
		{
			var erros = sessao.Idioma.Analisar(codigo, out var programa);
			if (sessao.Cancelada) return;

			if (erros.Count > 0 || programa == null)
			{
				CallDeferred(nameof(DelegarLimpezaDestaque));
				CallDeferred(nameof(EnviarErrosDeSintaxe), ConverterErros(erros));
				return;
			}

			CallDeferred(nameof(LimparErrosVisuais));
			programa.Executar(this);
			if (!sessao.Cancelada) CallDeferred(nameof(DelegarLimpezaDestaque));
		}
		catch (ExecucaoAbortadaException)
		{
			// Parada pelo jogador: nada a mostrar.
		}
		catch (ErroCodigoException ex)
		{
			if (!sessao.Cancelada) ReportarErro(sessao, ex.Linha ?? sessao.UltimaLinha, ex.Message, ex.Message);
		}
		catch (Exception ex)
		{
			// Falha interna (bug no interpretador ou na ponte). Detalhe técnico vai para o console.
			if (!sessao.Cancelada)
			{
				GD.PushError($"[InterpretadorServico] Erro interno na linha {sessao.UltimaLinha}: {ex}");
				ReportarErro(sessao, sessao.UltimaLinha, sessao.Idioma.Mensagens.ErroInesperadoNaLinha, ex.Message);
			}
		}
		finally
		{
			_sessaoDaThread = null;
		}
	}

	private void ReportarErro(Sessao sessao, int linha, string mensagemNaLinha, string mensagemSemLinha)
	{
		CallDeferred(nameof(DelegarLimpezaDestaque));
		if (linha > 0)
			CallDeferred(nameof(EnviarErrosDeSintaxe), ConverterErros(new[] { new ErroCodigo(linha, mensagemNaLinha) }));
		else
			CallDeferred(nameof(DelegarErroParaMainThread), mensagemSemLinha);
	}

	private static Godot.Collections.Array ConverterErros(IEnumerable<ErroCodigo> erros)
	{
		var lista = new Godot.Collections.Array();
		foreach (var erro in erros)
		{
			// O Terminal.gd usa linhas base 0.
			lista.Add(new Godot.Collections.Dictionary
			{
				{ "linha", Math.Max(0, erro.Linha - 1) },
				{ "mensagem", erro.Mensagem },
			});
		}
		return lista;
	}

	private static Sessao SessaoDaThread()
	{
		var sessao = _sessaoDaThread;
		if (sessao == null || sessao.Cancelada) throw new ExecucaoAbortadaException();
		return sessao;
	}

	private string IdiomaPedido()
	{
		if (!string.IsNullOrWhiteSpace(IdiomaForcado)) return IdiomaForcado.Trim().ToLowerInvariant();

		var constantes = GetNodeOrNull("/root/Constantes");
		if (constantes != null)
		{
			var valor = constantes.Get("IDIOMA");
			if (valor.VariantType == Variant.Type.Int) return RegistroIdiomas.CodigoDoIndice(valor.AsInt32());
		}
		return RegistroIdiomas.Padrao;
	}

	// =====================================================================
	// CHAMADAS PARA A MAIN THREAD (Terminal)
	// =====================================================================

	private void EnviarErrosDeSintaxe(Godot.Collections.Array erros) => GetTree().CallGroup("Terminal", "mostrar_erros_de_sintaxe", erros);
	private void LimparErrosVisuais() => GetTree().CallGroup("Terminal", "limpar_erros_de_sintaxe");
	private void DelegarErroParaMainThread(string mensagem) => GetTree().CallGroup("Terminal", "mostrar_erro_runtime", mensagem);
	private void DelegarDestaqueLinha(int linha, string categoria) => GetTree().CallGroup("Terminal", "destacar_linha_execucao", linha, categoria);
	private void DelegarLimpezaDestaque() => GetTree().CallGroup("Terminal", "limpar_destaque_execucao");

	// =====================================================================
	// DESTAQUE DE LINHAS
	// =====================================================================

	private void ProcessarDestaquePendente(Sessao sessao)
	{
		if (sessao.LinhaPendente == -1) return;
		CallDeferred(nameof(DelegarDestaqueLinha), sessao.LinhaPendente, sessao.CategoriaPendente);
		sessao.LinhaPendente = -1;
		sessao.CategoriaPendente = "";
	}

	public void DestacarLinhaAtual(int linha, string categoria)
	{
		// Também é o ponto de parada de laços que não chamam ações (ex.: enquanto(Verdadeiro) { x = x + 1 }).
		var sessao = SessaoDaThread();

		if (categoria != CategoriasDestaque.OrigemVar) sessao.UltimaLinha = linha;

		if (categoria == CategoriasDestaque.ChamadaFuncaoPendente)
		{
			if (sessao.LinhaPendente != linha) ProcessarDestaquePendente(sessao);
			sessao.LinhaPendente = linha;
			sessao.CategoriaPendente = CategoriasDestaque.ChamadaFuncao;
			return;
		}

		if (sessao.LinhaPendente == linha) return; // a linha já será destacada quando a ação executar

		if (categoria != CategoriasDestaque.OrigemVar && categoria != CategoriasDestaque.LeituraVar)
			ProcessarDestaquePendente(sessao);

		CallDeferred(nameof(DelegarDestaqueLinha), linha, categoria);
	}

	// =====================================================================
	// AÇÕES COM TICK
	// =====================================================================

	private Variant ExecutarAcaoComTick(string metodo, Godot.Collections.Array args)
	{
		var sessao = SessaoDaThread();

		if (_gerenciador == null || _apiNativa == null || !_metodosNativosDisponiveis.Contains(metodo))
			return default;

		_gerenciador.CallDeferred("executar_com_tick", _apiNativa, metodo, args,
			sessao.LinhaPendente, sessao.CategoriaPendente, sessao.Id);

		sessao.LinhaPendente = -1;
		sessao.CategoriaPendente = "";

		sessao.Sinal.WaitOne();
		SessaoDaThread(); // lança se foi parada enquanto esperava
		return sessao.Resultado;
	}

	// AÇÕES PRINCIPAIS
	public void Mover(string direcao) => ExecutarAcaoComTick("mover", new() { direcao });
	public void Atacar(string alvo, string ataque) => ExecutarAcaoComTick("atacar", new() { alvo, ataque });
	public void Escapar() => ExecutarAcaoComTick("escapar", new());
	public void EntrarArena(string arena) => ExecutarAcaoComTick("arena", new() { arena });

	// SISTEMA
	public void Escreva(string texto) => ExecutarAcaoComTick("escreva", new() { texto });
	public void NotificarErro(string mensagem) => CallDeferred(nameof(DelegarErroParaMainThread), mensagem);

	// INVENTÁRIO E ECONOMIA
	public void UsarItemCinto(int indice) => ExecutarAcaoComTick("usar_item_cinto", new() { indice });
	public void UsarItemMochila() => ExecutarAcaoComTick("usar_item_mochila", new());
	public void Comprar(string item) => ExecutarAcaoComTick("comprar", new() { item });
	public void VenderTudo() => ExecutarAcaoComTick("venderTudo", new());
	public void ColocarItemMochila(string item) => ExecutarAcaoComTick("colocar_item_mochila", new() { item });
	public void ColocarItemCinto(string item, int indice) => ExecutarAcaoComTick("colocar_item_cinto", new() { item, indice });

	// SENSORES (também passam pelo tick, com cooldown mínimo, para manter a ordem com as ações)
	public string InimigoMaisProximo() => ExecutarAcaoComTick("inimigoMaisProximo", new()).AsString();
	public bool InimigoExiste(string inimigoId) => ExecutarAcaoComTick("inimigoExiste", new() { inimigoId ?? "" }).AsBool();
	public bool PodeMover(string direcao) => ExecutarAcaoComTick("podeMover", new() { direcao }).AsBool();
	public int GetTempo() => ExecutarAcaoComTick("getTempo", new()).AsInt32();
	public int GetVidaAtual() => ExecutarAcaoComTick("getVidaAtual", new()).AsInt32();

	public List<string> EscanearArea()
	{
		var resultado = ExecutarAcaoComTick("escanearArea", new());
		var lista = new List<string>();
		if (resultado.VariantType == Variant.Type.Array)
		{
			foreach (var item in resultado.AsGodotArray()) lista.Add(item.AsString());
		}
		else if (resultado.VariantType == Variant.Type.PackedStringArray)
		{
			lista.AddRange(resultado.AsStringArray());
		}
		return lista;
	}

	// COORDENADAS
	public int GetPosicaoPlayerX() => ExecutarAcaoComTick("posicaoX", new()).AsInt32();
	public int GetPosicaoPlayerY() => ExecutarAcaoComTick("posicaoY", new()).AsInt32();
	public int GetPosicaoTesouroX() => ExecutarAcaoComTick("tesouroX", new()).AsInt32();
	public int GetPosicaoTesouroY() => ExecutarAcaoComTick("tesouroY", new()).AsInt32();

	// ATRIBUTOS DE INIMIGO
	public string ObterNomeInimigo(string inimigoId) => ExecutarAcaoComTick("nomeInimigo", new() { inimigoId ?? "" }).AsString();
	public float ObterVidaInimigo(string inimigoId) => ExecutarAcaoComTick("obterVidaInimigo", new() { inimigoId ?? "" }).AsSingle();
	public int ObterPosicaoXInimigo(string inimigoId) => ExecutarAcaoComTick("obterPosicaoXInimigo", new() { inimigoId ?? "" }).AsInt32();
	public int ObterPosicaoYInimigo(string inimigoId) => ExecutarAcaoComTick("obterPosicaoYInimigo", new() { inimigoId ?? "" }).AsInt32();
}
