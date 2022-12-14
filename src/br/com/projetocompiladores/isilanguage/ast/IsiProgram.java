package br.com.projetocompiladores.isilanguage.ast;


import br.com.projetocompiladores.isilanguage.datastructures.IsiSymbol;
import br.com.projetocompiladores.isilanguage.datastructures.IsiSymbolTable;

import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;

public class IsiProgram {
    private IsiSymbolTable varTable;
    private ArrayList<AbstractCommand> comandos;
    private String programName;

    public void generateTarget() {
        StringBuilder str = new StringBuilder();
        str.append("import java.util.Scanner;\n\n");
        str.append("public class MainClass{ \n\n");
        str.append("\tpublic static void main(String args[]){\n\n");
        str.append("\t\tScanner _key = new Scanner(System.in);\n\n");
        for (IsiSymbol symbol : varTable.getAll()) {
            str.append("\t\t" + symbol.generateJavaCode() + "\n");
        }
        str.append("\n");
        for (AbstractCommand command : comandos) {
            str.append(command.generateJavaCode() + "\n");
        }
        str.append("\n\t}");
        str.append("\n}");

        try {
            FileWriter fr = new FileWriter(new File("MainClass.java"));
            fr.write(str.toString());
            fr.close();
        } catch (Exception ex) {
            ex.printStackTrace();
        }

    }

    public IsiSymbolTable getVarTable() {
        return varTable;
    }

    public void setVarTable(IsiSymbolTable varTable) {
        this.varTable = varTable;
    }

    public ArrayList<AbstractCommand> getComandos() {
        return comandos;
    }

    public void setComandos(ArrayList<AbstractCommand> comandos) {
        this.comandos = comandos;
    }

    public String getProgramName() {
        return programName;
    }

    public void setProgramName(String programName) {
        this.programName = programName;
    }

}