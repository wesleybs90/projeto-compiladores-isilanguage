grammar IsiLang;

@header{
	import br.com.projetocompiladores.isilanguage.datastructures.IsiSymbol;
	import br.com.projetocompiladores.isilanguage.datastructures.IsiVariable;
	import br.com.projetocompiladores.isilanguage.datastructures.IsiSymbolTable;
	import br.com.projetocompiladores.isilanguage.exceptions.IsiSemanticException;
	import br.com.projetocompiladores.isilanguage.ast.IsiProgram;
	import br.com.projetocompiladores.isilanguage.ast.AbstractCommand;
	import br.com.projetocompiladores.isilanguage.ast.CommandLeitura;
	import br.com.projetocompiladores.isilanguage.ast.CommandEscrita;
	import br.com.projetocompiladores.isilanguage.ast.CommandAtribuicao;
	import br.com.projetocompiladores.isilanguage.ast.CommandDecisao;
	import br.com.projetocompiladores.isilanguage.ast.CommandEnquanto;
	import java.util.ArrayList;
	import java.util.Stack;
}

@members{
	private int _tipo;
	private String _varName;
	private String _varValue;
	private IsiSymbolTable symbolTable = new IsiSymbolTable();
	private IsiSymbol symbol;
	private IsiProgram program = new IsiProgram();
	private ArrayList<AbstractCommand> curThread;
	private Stack<ArrayList<AbstractCommand>> stack = new Stack<ArrayList<AbstractCommand>>();
	private String _readID;
	private String _writeID;
	private String _exprID;
	private String _exprContent;
	private String _exprDecision;
	private ArrayList<AbstractCommand> listaTrue;
	private ArrayList<AbstractCommand> listaFalse;
	private ArrayList<AbstractCommand> listaEnquanto;
	private ArrayList<String> listaVarSemUso = new ArrayList<String>();;
	
	public void verificaID(String id){
		if (!symbolTable.exists(id)){
			throw new IsiSemanticException("Variável "+id+" não declarada");
		}
	}

    public void verificaTipo(String id, int tipo){
        if (((IsiVariable) symbolTable.get(id)).getType() != tipo){
           throw new IsiSemanticException("Variável "+id+" possui tipo errado");
        }
    }
	
	public void exibeComandos(){
		for (AbstractCommand c: program.getComandos()){
			System.out.println(c);
		}
	}
	
	public void generateCode(){
		program.generateTarget();
	}
}

prog	: 'programa' decl bloco  'fimprog;'
           {
              program.setVarTable(symbolTable);
           	  program.setComandos(stack.pop());
           	  if(listaVarSemUso.size() > 0){
                    System.err.println("WARN: Variáveis sem uso: " + listaVarSemUso);
              }
           } 
		;
		
decl    :  (declaravar)+
        ;
        
        
declaravar : tipo ID  {
	                  _varName = _input.LT(-1).getText();
	                  _varValue = null;
	                  symbol = new IsiVariable(_varName, _tipo, _varValue);
	                  if (!symbolTable.exists(_varName)){
	                     symbolTable.add(symbol);
	                     listaVarSemUso.add(_varName);
	                  }
	                  else{
	                  	 throw new IsiSemanticException("Variável "+_varName+" já declarada");
	                  }
                    } 
              (  VIR 
              	 ID {
	                  _varName = _input.LT(-1).getText();
	                  _varValue = null;
	                  symbol = new IsiVariable(_varName, _tipo, _varValue);
	                  if (!symbolTable.exists(_varName)){
	                     symbolTable.add(symbol);
	                     listaVarSemUso.add(_varName);
	                  }
	                  else{
	                  	 throw new IsiSemanticException("Variável "+_varName+" já declarada");
	                  }
                    }
              )* 
               SC
           ;
           
tipo       : 'numero' { _tipo = IsiVariable.NUMBER;  }
           | 'texto'  { _tipo = IsiVariable.TEXT;  }
           | 'booleano' { _tipo = IsiVariable.BOOLEAN; }
           ;
        
bloco	: {
            curThread = new ArrayList<AbstractCommand>();
	        stack.push(curThread);  
          }
          (cmd)+
		;
		

cmd		:  cmdleitura  
 		|  cmdescrita 
 		|  cmdattrib
 		|  cmdselecao
 		|  cmdEnquanto
		;
		
cmdleitura	: 'leia' AP
                     ID {
                          verificaID(_input.LT(-1).getText());
                     	  _readID = _input.LT(-1).getText();
                     	  listaVarSemUso.remove(_readID);
                        } 
                     FP 
                     SC
              {
              	IsiVariable var = (IsiVariable)symbolTable.get(_readID);
              	CommandLeitura cmd = new CommandLeitura(_readID, var);
              	stack.peek().add(cmd);
              }   
			;
			
cmdescrita	: 'escreva' 
                 AP 
                 ID {
                        verificaID(_input.LT(-1).getText());
	                    _writeID = _input.LT(-1).getText();
                     } 
                 FP 
                 SC
               {
               	  CommandEscrita cmd = new CommandEscrita(_writeID);
               	  stack.peek().add(cmd);
               }
			;
			
cmdattrib	:  ID {
                    verificaID(_input.LT(-1).getText());
                    _exprID = _input.LT(-1).getText();
                    listaVarSemUso.remove(_exprID);
                   } 
               ATTR { _exprContent = ""; } 
               expr 
               SC
               {
                 verificaTipo(_exprID, _tipo);
               	 CommandAtribuicao cmd = new CommandAtribuicao(_exprID, _exprContent);
               	 stack.peek().add(cmd);
               }
			;
			
			
cmdselecao  :  'se' AP
                    ID    { _exprDecision = _input.LT(-1).getText(); }
                    OPREL { _exprDecision += _input.LT(-1).getText(); }
                    (ID | NUMBER) {_exprDecision += _input.LT(-1).getText(); }
                    FP 
                    ACH 
                    { curThread = new ArrayList<AbstractCommand>(); 
                      stack.push(curThread);
                    }
                    (cmd)+ 
                    
                    FCH 
                    {
                       listaTrue = stack.pop();	
                    } 
                   ('senao' 
                   	 ACH
                   	 {
                   	 	curThread = new ArrayList<AbstractCommand>();
                   	 	stack.push(curThread);
                   	 } 
                   	(cmd+) 
                   	FCH
                   	{
                   		listaFalse = stack.pop();
                   		CommandDecisao cmd = new CommandDecisao(_exprDecision, listaTrue, listaFalse);
                   		stack.peek().add(cmd);
                   	}
                   )?
            ;

cmdEnquanto  :  'enquanto'   AP
                             ID             { _exprDecision = _input.LT(-1).getText(); }
                             OPREL          { _exprDecision += _input.LT(-1).getText(); }
                             (ID | NUMBER)  {_exprDecision += _input.LT(-1).getText(); }
                             FP
                             ACH
                             {
                                 curThread = new ArrayList<AbstractCommand>();
                                 stack.push(curThread);
                             }
                             (cmd)+
                             FCH
                             {
                                   listaEnquanto = stack.pop();
                                   CommandEnquanto cmd = new CommandEnquanto(_exprDecision, listaEnquanto);
                                   stack.peek().add(cmd);
                             }
            ;

expr		:  termo ( 
	             OP  { _exprContent += _input.LT(-1).getText();}
	            termo
	            )*
			;
			
termo		: ID {
                    verificaID(_input.LT(-1).getText());
                    _tipo = ((IsiVariable) symbolTable.get(_input.LT(-1).getText())).getType();
	                _exprContent += _input.LT(-1).getText();
                 } 
            | 
              NUMBER
              {
                _tipo = IsiVariable.NUMBER;
              	_exprContent += _input.LT(-1).getText();
              }
            |
              TEXT
              {
                _tipo = IsiVariable.TEXT;
                _exprContent += _input.LT(-1).getText();
              }
            |
              BOOLEAN
              {
                _tipo = IsiVariable.BOOLEAN;
                _exprContent += _input.LT(-1).getText();
              }
			;
			
	
AP	: '('
	;
	
FP	: ')'
	;
	
SC	: ';'
	;
	
OP	: '+' | '-' | '*' | '/'
	;
	
ATTR : '='
	 ;
	 
VIR  : ','
     ;
     
ACH  : '{'
     ;
     
FCH  : '}'
     ;
	 
	 
OPREL : '>' | '<' | '>=' | '<=' | '==' | '!='
      ;
      
ID	: [a-z] ([a-z] | [A-Z] | [0-9])*
	;
	
NUMBER	: [0-9]+ ('.' [0-9]+)?
		;
		
WS	: (' ' | '\t' | '\n' | '\r') -> skip;

TEXT: AD ([a-z] | [A-Z] | [0-9] | ' ') + AD
    ;

AD  : '"'
    ;

BOOLEAN : 'true' | 'false'
        ;