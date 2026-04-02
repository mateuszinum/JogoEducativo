using Godot;
using Antlr4.Runtime;
using Jogo.Core; 
using System.Collections.Generic;
using System;
using System.Threading;
using System.Threading.Tasks;

public partial class InterpretadorServico : Node, IAcoesDoJogo
{
	private AutoResetEvent _travaDeSincronizacao = new AutoResetEvent(false); 
	private Node _apiNativa; 
	private Node _gerenciador; // Variável cacheada para evitar erros de Thread
	
	private bool _execucaoAbortada = false; 

	public override void _Ready()
	{
		// Pescamos os Autoloads na Thread Principal (Seguro)
		_apiNativa = GetNodeOrNull("/root/FuncoesNativas");
		_gerenciador = GetNodeOrNull("/root/GerenciadorExecucao");
		
		GD.Print("[C#] Interpretador Serviço pronto. Conectado à API Nativa.");
	}

	public void LiberarProximoComando()
	{
		_travaDeSincronizacao.Set(); 
	}

	public void PararExecucao()
	{
		_execucaoAbortada = true;
		LiberarProximoComando(); 
	}

	public void ExecutarCodigoDoJogador(string codigo, Node personagem)
	{
		_execucaoAbortada = false; 
		
		// Registra o interpretador usando a variável cacheada
		if (_gerenciador != null) { _gerenciador.Call("registrar_interpretador", this); }

		Task.Run(() => 
		{
			try 
			{
				var inputStream = new AntlrInputStream(codigo);
				var lexer = new LinguagemLexer(inputStream);
				var tokens = new CommonTokenStream(lexer);
				var parser = new LinguagemParser(tokens);
				var arvore = parser.programa();

				var visitor = new MeuVisitor(this); 
				visitor.Visit(arvore);
			}
			catch (Exception ex) 
			{ 
				if (ex.Message == "Execução abortada pelo jogador.") {
					GD.Print("[C#] Loop infinito interrompido com sucesso.");
				} else {
					CallDeferred(nameof(NotificarErro), ex.Message); 
				}
			}
		});
	}

	public void NotificarErro(string mensagem) { GD.PrintErr($"[Erro] {mensagem}"); }

	// ==========================================
	// AÇÕES COM TICK 
	// ==========================================
	public void Mover(string direcao) { ExecutarAcaoComTick("mover", new Godot.Collections.Array { direcao }); }
	public void Atacar(string alvo, string tipo) { ExecutarAcaoComTick("atacar", new Godot.Collections.Array { alvo, tipo }); }
	public void Escapar() { ExecutarAcaoComTick("escapar", new Godot.Collections.Array()); }
	public void UsarItemCinto(int indice) { ExecutarAcaoComTick("usar_item_cinto", new Godot.Collections.Array { indice }); }
	public void UsarItemMochila() { ExecutarAcaoComTick("usar_item_mochila", new Godot.Collections.Array()); }
	public void Comprar(string item) { ExecutarAcaoComTick("comprar", new Godot.Collections.Array { item }); }
	public void EntrarArena(string arena) { ExecutarAcaoComTick("arena", new Godot.Collections.Array { arena }); }
	public void ColocarItemMochila(string item) { ExecutarAcaoComTick("colocar_item_mochila", new Godot.Collections.Array { item }); }
	public void ColocarItemCinto(string item, int idx) { ExecutarAcaoComTick("colocar_item_cinto", new Godot.Collections.Array { item, idx }); }

	private void ExecutarAcaoComTick(string metodo, Godot.Collections.Array args)
	{
		if (_execucaoAbortada) throw new Exception("Execução abortada pelo jogador.");

		if (_apiNativa != null && _apiNativa.HasMethod(metodo))
		{
			// Proteção de segurança caso o Autoload não tenha sido encontrado no _Ready
			if (_gerenciador == null) 
			{
				CallDeferred(nameof(NotificarErro), "GerenciadorExecucao não encontrado no Autoload do Godot.");
				return;
			}

			// Chama o método sem usar GetNode() dentro da Thread!
			_gerenciador.CallDeferred("executar_com_tick", _apiNativa, metodo, args);
			_travaDeSincronizacao.WaitOne(); 
			
			if (_execucaoAbortada) throw new Exception("Execução abortada pelo jogador.");
		}
		else { CallDeferred(nameof(NotificarErro), $"Função '{metodo}' não implementada em FuncoesNativas.gd."); }
	}

	// ==========================================
	// LEITURAS (Lê direto da API instantaneamente)
	// ==========================================
	public string InimigoMaisProximo() { return _apiNativa?.Call("inimigoMaisProximo").AsString() ?? ""; }
	public bool PodeMover(string direcao) { return _apiNativa?.Call("podeMover", direcao).AsBool() ?? false; }
	public int GetTempo() { return _apiNativa?.Call("getTempo").AsInt32() ?? 0; }
	public int GetVidaAtual() { return _apiNativa?.Call("getVidaAtual").AsInt32() ?? 0; }
	
	public List<string> EscanearArea()
	{
		var res = _apiNativa?.Call("escanearArea").AsStringArray();
		return res != null ? new List<string>(res) : new List<string>();
	}
	
	public string GetNomeInimigo(string alvo) => alvo;

	public int GetPosicaoPlayerX() { return _apiNativa?.Call("posicaoX").AsInt32() ?? 0; }
	public int GetPosicaoPlayerY() { return _apiNativa?.Call("posicaoY").AsInt32() ?? 0; }
	public int GetPosicaoTesouroX() { return _apiNativa?.Call("tesouroX").AsInt32() ?? 0; }
	public int GetPosicaoTesouroY() { return _apiNativa?.Call("tesouroY").AsInt32() ?? 0; }
}
