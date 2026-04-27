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
	public Godot.Collections.Array ErrosEncontrados { get; } = new Godot.Collections.Array();

	public void SyntaxError(TextWriter output, IRecognizer recognizer, T offendingSymbol, int line, int charPositionInLine, string msg, RecognitionException e)
	{
		string erroTraduzido = msg;

		if (erroTraduzido.Contains("missing 'fim' at '<EOF>'")) {
			erroTraduzido = "Faltou fechar o bloco com 'fim' (o arquivo terminou antes).";
		} else {
			erroTraduzido = erroTraduzido.Replace("missing", "Faltando")
										 .Replace("at", "em")
										 .Replace("mismatched input", "Entrada incorreta")
										 .Replace("expecting", "esperava-se")
										 .Replace("extraneous input", "Palavra ou símbolo não reconhecido")
										 .Replace("no viable alternative", "Comando inválido ou incompleto")
										 .Replace("<EOF>", "fim do arquivo");
		}

		var erro = new Godot.Collections.Dictionary
		{
			{ "linha", line - 1 }, 
			{ "mensagem", erroTraduzido }
		};
		ErrosEncontrados.Add(erro);
	}
}

public partial class InterpretadorServico : Node, IAcoesDoJogo
{
	private AutoResetEvent _travaDeSincronizacao = new AutoResetEvent(false); 
	private Node _apiNativa; 
	private Node _gerenciador; 
	
	private bool _execucaoAbortada = false; 
	private int _threadAtivaId = -1; 

	public override void _Ready()
	{
		_apiNativa = GetNodeOrNull("/root/FuncoesNativas");
		_gerenciador = GetNodeOrNull("/root/GerenciadorExecucao");
	}
	
	private void VerificarAbortagem()
	{
		if (_execucaoAbortada || (_threadAtivaId != -1 && Thread.CurrentThread.ManagedThreadId != _threadAtivaId))
		{
			throw new Exception("Execução abortada pelo jogador.");
		}
	}	

	public void LiberarProximoComando() { _travaDeSincronizacao.Set(); }

	public void PararExecucao()
	{
		_execucaoAbortada = true;
		_threadAtivaId = -1; 
		_travaDeSincronizacao.Set(); 
	}

	public void ExecutarCodigoDoJogador(string codigo, Node personagem)
	{
		PararExecucao(); 
		_execucaoAbortada = false; 
		_travaDeSincronizacao.Reset(); 
		
		if (_gerenciador != null) { _gerenciador.Call("registrar_interpretador", this); }

		Task.Run(() => 
		{
			_threadAtivaId = Thread.CurrentThread.ManagedThreadId;
			
			try 
			{
				var inputStream = new AntlrInputStream(codigo);
				var lexer = new LinguagemLexer(inputStream);
				
				var lexerListener = new InterpretadorErrorListener<int>();
				lexer.RemoveErrorListeners();
				lexer.AddErrorListener(lexerListener);

				var tokens = new CommonTokenStream(lexer);
				var parser = new LinguagemParser(tokens);
				
				var parserListener = new InterpretadorErrorListener<IToken>();
				parser.RemoveErrorListeners();
				parser.AddErrorListener(parserListener);

				var arvore = parser.programa();

				var todosErros = new Godot.Collections.Array();
				foreach (var e in lexerListener.ErrosEncontrados) todosErros.Add(e);
				foreach (var e in parserListener.ErrosEncontrados) todosErros.Add(e);

				if (todosErros.Count > 0)
				{
					CallDeferred(nameof(EnviarErrosDeSintaxe), todosErros);
					return; 
				}
				
				CallDeferred(nameof(LimparErrosVisuais));

				var visitor = new MeuVisitor(this); 
				visitor.Visit(arvore);
			}
			catch (Exception ex) 
			{ 
				if (ex.Message == "Execução abortada pelo jogador.") {
					// Parou limpo, ignora o log.
				} else if (ex.Message.StartsWith("L:")) {
					var parts = ex.Message.Split(new char[] { '|' }, 2);
					if (int.TryParse(parts[0].Substring(2), out int linha)) {
						var erro = new Godot.Collections.Dictionary {
							{ "linha", linha - 1 }, 
							{ "mensagem", parts[1] }
						};
						var todosErros = new Godot.Collections.Array { erro };
						CallDeferred(nameof(EnviarErrosDeSintaxe), todosErros);
					}
				} else {
					CallDeferred(nameof(DelegarErroParaMainThread), ex.Message); 
				}
			}
		});
	}

	public void EnviarErrosDeSintaxe(Godot.Collections.Array erros) 
	{ 
		GetTree().CallGroup("Terminal", "mostrar_erros_de_sintaxe", erros);
	}

	public void LimparErrosVisuais() 
	{ 
		GetTree().CallGroup("Terminal", "limpar_erros_de_sintaxe");
	}

	public void NotificarErro(string mensagem) 
	{ 
		CallDeferred(nameof(DelegarErroParaMainThread), mensagem);
	}

	private void DelegarErroParaMainThread(string mensagem)
	{
		GetTree().CallGroup("Terminal", "mostrar_erro_runtime", mensagem);
	}
	
	public void Mover(string direcao) { ExecutarAcaoComTick("mover", new Godot.Collections.Array { direcao }); }
	public void Atacar(string alvo, string tipo) { ExecutarAcaoComTick("atacar", new Godot.Collections.Array { alvo, tipo }); }
	public void Escapar() { ExecutarAcaoComTick("escapar", new Godot.Collections.Array()); }
	public void UsarItemCinto(int indice) { ExecutarAcaoComTick("usar_item_cinto", new Godot.Collections.Array { indice }); }
	public void UsarItemMochila() { ExecutarAcaoComTick("usar_item_mochila", new Godot.Collections.Array()); }
	public void Comprar(string item) { ExecutarAcaoComTick("comprar", new Godot.Collections.Array { item }); }
	public void VenderTudo() { ExecutarAcaoComTick("venderTudo", new Godot.Collections.Array()); }
	public void EntrarArena(string arena) { ExecutarAcaoComTick("arena", new Godot.Collections.Array { arena }); }
	public void ColocarItemMochila(string item) { ExecutarAcaoComTick("colocar_item_mochila", new Godot.Collections.Array { item }); }
	public void ColocarItemCinto(string item, int idx) { ExecutarAcaoComTick("colocar_item_cinto", new Godot.Collections.Array { item, idx }); }

	private void ExecutarAcaoComTick(string metodo, Godot.Collections.Array args)
	{
		VerificarAbortagem();
		
		if (_apiNativa != null && _apiNativa.HasMethod(metodo))
		{
			if (_gerenciador == null) return;
			_gerenciador.CallDeferred("executar_com_tick", _apiNativa, metodo, args);
			
			_travaDeSincronizacao.WaitOne(); 
			
			VerificarAbortagem();
		}
	}

	public string InimigoMaisProximo() { return _apiNativa?.Call("inimigoMaisProximo").AsString() ?? ""; }
	public bool PodeMover(string direcao) { return _apiNativa?.Call("podeMover", direcao).AsBool() ?? false; }
	public int GetTempo() { return _apiNativa?.Call("getTempo").AsInt32() ?? 0; }
	public int GetVidaAtual() { return _apiNativa?.Call("getVidaAtual").AsInt32() ?? 0; }
	public List<string> EscanearArea()
	{
		var res = _apiNativa?.Call("escanearArea").AsStringArray();
		return res != null ? new List<string>(res) : new List<string>();
	}
	public string GetNomeInimigo(string alvo) { return _apiNativa?.Call("nomeInimigo", alvo).AsString() ?? ""; }
	public int GetPosicaoPlayerX() { return _apiNativa?.Call("posicaoX").AsInt32() ?? 0; }
	public int GetPosicaoPlayerY() { return _apiNativa?.Call("posicaoY").AsInt32() ?? 0; }
	public int GetPosicaoTesouroX() { return _apiNativa?.Call("tesouroX").AsInt32() ?? 0; }
	public int GetPosicaoTesouroY() { return _apiNativa?.Call("tesouroY").AsInt32() ?? 0; }
}
