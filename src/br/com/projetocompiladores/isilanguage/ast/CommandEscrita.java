package br.com.projetocompiladores.isilanguage.ast;

public class CommandEscrita extends AbstractCommand {

    private String id;

    public CommandEscrita(String id) {
        this.id = id;
    }

    @Override
    public String generateJavaCode() {
        // TODO Auto-generated method stub
        return "\t" + "System.out.println(" + id + ");";
    }

    @Override
    public String toString() {
        return "Comando Escrita: [id=" + id + "]";
    }

}