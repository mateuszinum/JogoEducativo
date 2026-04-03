using Godot;
using Antlr4.Runtime;
using Jogo.Core; 
using System.Collections.Generic;
using System;
using System.Threading;
using System.Threading.Tasks;
using System.IO;

public class InterpretadorErrorListener<T> : IAntlrErrorListener<T>
{
	public void SyntaxError(TextWriter output, IRecognizer recognizer, T offendingSymbol, int line, int charPositionInLine, string msg, RecognitionException e)
	{
		string erroTraduzido = msg.Replace("missing", "Faltando")
								  .Replace("at", "em")
								  .Replace("mismatched input", "Entrada incorreta")
								  .Replace("expecting", "esperava-se")
								  .Replace("extraneous input", "Palavra ou símbolo não reconhecido")
								  .Replace("no viable alternative", "Nenhuma alternativa válida encontrada");

		throw new Exception($"Erro Crítico de Sintaxe (Linha {line}): {erroTraduzido}");
	}
}

public partial class InterpretadorServico : Node, IAcoesDoJogo
{
	private AutoResetEvent _travaDeSincronizacao = new AutoResetEvent(false); 
	private Node _apiNativa; 
	private Node _gerenciador; 
	
	private bool _execucaoAbortada = false; 
	
	// NOVO: Crachá de identificação da thread ativa
	private int _threadAtivaId = -1; 

	public override void _Ready()
	{
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
		_threadAtivaId = -1; // Invalida imediatamente o crachá da thread atual
		_travaDeSincronizacao.Set(); 
	}

	public void ExecutarCodigoDoJogador(string codigo, Node personagem)
	{
		// 1. Limpa o terreno antes de começar uma nova execução
		PararExecucao(); 
		_execucaoAbortada = false; 
		_travaDeSincronizacao.Reset(); // NOVO: Esvazia qualquer "sinal verde" fantasma que tenha ficado no buffer
		
		if (_gerenciador != null) { _gerenciador.Call("registrar_interpretador", this); }

		Task.Run(() => 
		{
			// 2. A nova thread guarda o seu próprio ID de identificação
			_threadAtivaId = Thread.CurrentThread.ManagedThreadId;
			
			try 
			{
				var inputStream = new AntlrInputStream(codigo);
				var lexer = new LinguagemLexer(inputStream);
				
				lexer.RemoveErrorListeners();
				lexer.AddErrorListener(new InterpretadorErrorListener<int>());

				var tokens = new CommonTokenStream(lexer);
				var parser = new LinguagemParser(tokens);
				
				parser.RemoveErrorListeners();
				parser.AddErrorListener(new InterpretadorErrorListener<IToken>());

				var arvore = parser.programa();

				var visitor = new MeuVisitor(this); 
				visitor.Visit(arvore);
			}
			catch (Exception ex) 
			{ 
				if (ex.Message == "Execução abortada pelo jogador.") {
					GD.Print("[C#] Loop infinito ou thread fantasma interrompida com sucesso.");
				} else {
					CallDeferred(nameof(NotificarErro), ex.Message); 
				}
			}
		});
	}

	public void NotificarErro(string mensagem) { 
		GD.PrintErr($"[Erro] {mensagem}"); 
		GetTree().CallGroup("Terminal", "mostrar_erro", mensagem);
	}

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
		// NOVO: Verifica se a thread que está a tentar executar é a oficial. Se for zombie, ela é eliminada.
		if (_execucaoAbortada || Thread.CurrentThread.ManagedThreadId != _threadAtivaId) 
			throw new Exception("Execução abortada pelo jogador.");

		if (_apiNativa != null && _apiNativa.HasMethod(metodo))
		{
			if (_gerenciador == null) 
			{
				CallDeferred(nameof(NotificarErro), "GerenciadorExecucao não encontrado.");
				return;
			}

			_gerenciador.CallDeferred("executar_com_tick", _apiNativa, metodo, args);
			_travaDeSincronizacao.WaitOne(); 
			
			// Verifica novamente logo após acordar da espera
			if (_execucaoAbortada || Thread.CurrentThread.ManagedThreadId != _threadAtivaId) 
				throw new Exception("Execução abortada pelo jogador.");
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
	
	// A nossa correção antiga contínua aqui!
	public string GetNomeInimigo(string alvo) 
	{ 
		return _apiNativa?.Call("nomeInimigo", alvo).AsString() ?? ""; 
	}

	public int GetPosicaoPlayerX() { return _apiNativa?.Call("posicaoX").AsInt32() ?? 0; }
	public int GetPosicaoPlayerY() { return _apiNativa?.Call("posicaoY").AsInt32() ?? 0; }
	public int GetPosicaoTesouroX() { return _apiNativa?.Call("tesouroX").AsInt32() ?? 0; }
	public int GetPosicaoTesouroY() { return _apiNativa?.Call("tesouroY").AsInt32() ?? 0; }
}
