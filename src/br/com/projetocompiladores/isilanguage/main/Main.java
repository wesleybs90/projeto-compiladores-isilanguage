package br.com.projetocompiladores.isilanguage.main;

import br.com.projetocompiladores.isilanguage.exceptions.IsiSemanticException;
import br.com.projetocompiladores.isilanguage.parser.IsiLangLexer;
import br.com.projetocompiladores.isilanguage.parser.IsiLangParser;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;

public class Main {

    public static void main(String[] args) {

        try {
            IsiLangLexer lexer;
            IsiLangParser parser;

            // leio o arquivo "input.isi" e isso é entrada para o Analisador Lexico
            lexer = new IsiLangLexer(CharStreams.fromFileName("input.isi"));

            // crio um "fluxo de tokens" para passar para o PARSER
            CommonTokenStream tokenStream = new CommonTokenStream(lexer);

            // crio meu parser a partir desse tokenStream
            parser = new IsiLangParser(tokenStream);

            parser.prog();

            System.out.println("Compilation Successful");

            parser.exibeComandos();

            parser.generateCode();

        } catch (IsiSemanticException ex) {
            System.err.println("Semantic error - " + ex.getMessage());
        } catch (Exception ex) {
            ex.printStackTrace();
            System.err.println("ERROR " + ex.getMessage());
        }

    }
}
