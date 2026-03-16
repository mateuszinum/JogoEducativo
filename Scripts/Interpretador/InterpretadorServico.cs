using Godot;
using Antlr4.Runtime;
using Jogo.Core; // Acessa o seu Backend

public partial class InterpretadorServico : Node, IAcoesDoJogo
{
	// Esta variável vai guardar quem é o personagem atual sendo controlado
	private Node _personagemAtual;

	// A função que o GDScript vai chamar passando o texto e o boneco
	public void ExecutarCodigoDoJogador(string codigo, Node personagem)
	{
		_personagemAtual = personagem;

		try 
		{
			var inputStream = new AntlrInputStream(codigo);
			var lexer = new LinguagemLexer(inputStream);
			var tokens = new CommonTokenStream(lexer);
			var parser = new LinguagemParser(tokens);
			var arvore = parser.programa();

			// Passa ESTA classe (this) como o controle remoto do jogo
			var visitor = new MeuVisitor(this); 
			visitor.Visit(arvore);
		}
		catch (System.Exception ex)
		{
			NotificarErro(ex.Message);
		}
	}

	// --- IMPLEMENTAÇÃO DO CONTRATO IAcoesDoJogo ---

	public void Mover(string direcao)
	{
		if (_personagemAtual != null && _personagemAtual.HasMethod("mover"))
		{
			// O C# encontrou a função e vai tentar acioná-la!
			GD.Print($"[C# -> Godot] Acionando mover({direcao}) no GDScript...");
			_personagemAtual.Call("mover", direcao); 
		}
		else
		{
			// Se falhar, agora nós vamos saber o porquê!
			NotificarErro("O script do Personagem não possui a função 'func mover(direcao):' ou o personagem não foi encontrado.");
		}
	}

	public void Atacar(string alvo, string tipo)
	{
		if (_personagemAtual != null && _personagemAtual.HasMethod("atacar"))
		{
			_personagemAtual.Call("atacar", alvo, tipo); 
		}
	}

	public void NotificarErro(string mensagem)
	{
		// Por enquanto imprime no console, mas futuramente você pode mandar isso pra UI do Terminal
		GD.PrintErr($"[Interpretador]: {mensagem}");
	}
}
