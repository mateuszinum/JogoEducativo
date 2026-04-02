using Godot;
using Antlr4.Runtime;
using Jogo.Core;
using System.Collections.Generic;
using System;
using System.Threading;
using System.Threading.Tasks;

public partial class InterpretadorServico : Node, IAcoesDoJogo
{
	private Node _personagemAtual;
	private AutoResetEvent _travaDeSincronizacao = new AutoResetEvent(false); 

	public override void _Ready()
	{
		GD.Print("[C#] Interpretador Serviço pronto.");
	}

	public void LiberarProximoComando()
	{
		_travaDeSincronizacao.Set(); 
	}

	public void ExecutarCodigoDoJogador(string codigo, Node personagem)
	{
		_personagemAtual = personagem;

		var gerenciador = GetNodeOrNull("/root/GerenciadorExecucao");
		if (gerenciador != null)
		{
			gerenciador.Call("registrar_interpretador", this);
		}

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
			catch (System.Exception ex)
			{
				CallDeferred(nameof(NotificarErro), ex.Message);
			}
		});
	}

	public void NotificarErro(string mensagem)
	{
		GD.PrintErr($"[Erro] {mensagem}");
	}

	// ==========================================
	// AÇÕES (Com Tick/Espera)
	// ==========================================

	public void Mover(string direcao)
	{
		ExecutarAcaoComTick("mover", new Godot.Collections.Array { direcao });
	}

	public void Atacar(string alvo, string tipo)
	{
		ExecutarAcaoComTick("atacar", new Godot.Collections.Array { alvo, tipo });
	}

	public void Escapar()
	{
		ExecutarAcaoComTick("escapar", new Godot.Collections.Array());
	}

	public void UsarItemCinto(int indice)
	{
		ExecutarAcaoComTick("usar_item_cinto", new Godot.Collections.Array { indice });
	}

	public void UsarItemMochila()
	{
		ExecutarAcaoComTick("usar_item_mochila", new Godot.Collections.Array());
	}

	public void Comprar(string item)
	{
		ExecutarAcaoComTick("comprar", new Godot.Collections.Array { item });
	}

	public void EntrarArena(string arena)
	{
		ExecutarAcaoComTick("arena", new Godot.Collections.Array { arena });
	}

	public void ColocarItemMochila(string item)
	{
		ExecutarAcaoComTick("colocar_item_mochila", new Godot.Collections.Array { item });
	}

	public void ColocarItemCinto(string item, int idx)
	{
		ExecutarAcaoComTick("colocar_item_cinto", new Godot.Collections.Array { item, idx });
	}

	private void ExecutarAcaoComTick(string metodo, Godot.Collections.Array args)
	{
		if (_personagemAtual != null && _personagemAtual.HasMethod(metodo))
		{
			var gerenciador = GetNode("/root/GerenciadorExecucao");
			gerenciador.CallDeferred("executar_com_tick", _personagemAtual, metodo, args);
			_travaDeSincronizacao.WaitOne(); 
		}
	}

	// ==========================================
	// LEITURAS (Instantâneas - Sintaxe exata do Visitor)
	// ==========================================

	public string InimigoMaisProximo()
	{
		return _personagemAtual?.Call("inimigoMaisProximo").AsString() ?? "";
	}

	public bool PodeMover(string direcao)
	{
		return _personagemAtual?.Call("podeMover", direcao).AsBool() ?? false;
	}

	public int GetTempo()
	{
		return _personagemAtual?.Call("getTempo").AsInt32() ?? 0;
	}

	public int GetVidaAtual()
	{
		return _personagemAtual?.Call("getVidaAtual").AsInt32() ?? 0;
	}

	public List<string> EscanearArea()
	{
		var res = _personagemAtual?.Call("escanearArea").AsStringArray();
		return res != null ? new List<string>(res) : new List<string>();
	}

	public string GetNomeInimigo(object alvo) => alvo.ToString();

	// --- Coordenadas Refatoradas (Sintaxe idêntica ao Visitor/Godot) ---

	public int GetPosicaoPlayerX()
	{
		return _personagemAtual?.Call("posicaoX").AsInt32() ?? 0;
	}

	public int GetPosicaoPlayerY()
	{
		return _personagemAtual?.Call("posicaoY").AsInt32() ?? 0;
	}

	public int GetPosicaoTesouroX()
	{
		return _personagemAtual?.Call("tesouroX").AsInt32() ?? 0;
	}

	public int GetPosicaoTesouroY()
	{
		return _personagemAtual?.Call("tesouroY").AsInt32() ?? 0;
	}
}
