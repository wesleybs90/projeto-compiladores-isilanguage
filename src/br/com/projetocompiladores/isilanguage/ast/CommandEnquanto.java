package br.com.projetocompiladores.isilanguage.ast;

import java.util.ArrayList;

public class CommandEnquanto extends AbstractCommand {

    private String condition;
    private ArrayList<AbstractCommand> listaEnquanto;

    public CommandEnquanto(String condition, ArrayList<AbstractCommand> le) {
        this.condition = condition;
        this.listaEnquanto = le;
    }

    @Override
    public String generateJavaCode() {
        // TODO Auto-generated method stub
        StringBuilder str = new StringBuilder();
        str.append("\n\t\twhile (" + condition + ") {\n\t");
        for(AbstractCommand cmd: this.listaEnquanto){
            str.append("\t");
            str.append(cmd.generateJavaCode());
            str.append("\n");
        }
        str.append("\t\t}");
        return str.toString();
    }

    @Override
    public String toString() {
        return "Comando Enquanto: [condition=" + condition + ", listaEnquanto=" + listaEnquanto
                + "]";
    }

}
