import cmm.PrettyPrinter;
import cmm.Absyn.*;

import java.util.*;

import javax.management.RuntimeErrorException;

public class TypeChecker {

    public class FunType {
        final Type returnType;
        final ListArg args;

        public FunType(Type t, ListArg l) {
            returnType = t;
            args = l;
        }
    }

    private HashMap<String, FunType> signature;
    private ArrayList<HashMap<String, Type>> contexts;
    private Type returnType;

    public final Type BOOL = new Type_bool();
    public final Type INT = new Type_int();
    public final Type DOUBLE = new Type_double();
    public final Type VOID = new Type_void();

    public void typecheck(Program p) {
        p.accept(new ProgramVisitor(), null);
    }

    // Program //////////////////////////////////////////////////////////

    public class ProgramVisitor implements Program.Visitor<Void, Void> {
        public Void visit(cmm.Absyn.PDefs p, Void arg) {
            signature = new HashMap<String, FunType>();
            signature.put("readInt", new FunType(INT, new ListArg()));
            signature.put("readDOUBLE", new FunType(DOUBLE, new ListArg()));
            signature.put("printInt", new FunType(VOID, singleArg(INT)));
            signature.put("printDouble", new FunType(VOID, singleArg(DOUBLE)));

            for (Def d : p.listdef_) {
                d.accept(new DefIntoSigVisitor(), null);
            }

            for (Def d : p.listdef_) {
                d.accept(new DefVisitor(), arg);
            }

            // TODO: Check for main
      

            return null;
        }
    }

    public ListArg singleArg(Type t) {
        ListArg l = new ListArg();
        l.add(new ADecl(t, "x"));
        return l;
    }

    // Function //////////////////////////////////////////////////////////

    public class DefIntoSigVisitor implements Def.Visitor<Void, Void> {

        public Void visit(cmm.Absyn.DFun p, Void arg) {
            if (signature.get(p.id_) != null)
                throw new TypeException("Function " + p.id_ + " already defined");

            FunType ft = new FunType(p.type_, p.listarg_);
            signature.put(p.id_, ft);

            return null;
        }
    }

    public class DefVisitor implements Def.Visitor<Void, Void> {
        public Void visit(cmm.Absyn.DFun p, Void arg) {
            returnType = p.type_;
            contexts = new ArrayList<HashMap<String, Type>>();
            contexts.add(new HashMap<String, Type>());

            pushBlock();

            for (Arg a : p.listarg_) {
                a.accept(new ArgVisitor(), arg);
            }

            addVar("return", returnType);

            for (Stm s : p.liststm_) {
                s.accept(new StmVisitor(), arg);
            }

            popBlock();

            return null;
        }
    }

    // Function argument //////////////////////////////////////////////////////////

    public class ArgVisitor implements Arg.Visitor<Void, Void> {
        public Void visit(cmm.Absyn.ADecl p, Void arg) {
            addVar(p.id_, p.type_);
            return null;
        }
    }

    // Statement //////////////////////////////////////////////////////////

    public class StmVisitor implements Stm.Visitor<Void, Void> {

        @Override
        public Void visit(SExp p, Void arg) {
            p.exp_.accept(new ExpVisitor(), arg);
            return null;
        }

        @Override
        public Void visit(SDecls p, Void arg) {
            if(true) throw new RuntimeException("Not yet implemented " + p.getClass().toString() + " -> " + PrettyPrinter.print(p));
            return null;
        }

        @Override
        public Void visit(SInit p, Void arg) {
            var type = p.exp_.accept(new ExpVisitor(), arg);
            typeEquals(p.type_, type);
            addVar(p.id_, p.type_);
            return null;
        }

        @Override
        public Void visit(SReturn p, Void arg) {
            var type = p.exp_.accept(new ExpVisitor(), arg);
            typeEquals(returnType, type);
            return null;
        }

        @Override
        public Void visit(SWhile p, Void arg) {
            var condition = p.exp_.accept(new ExpVisitor(), arg);
            typeEquals(BOOL, condition);
            pushBlock();
            p.stm_.accept(new StmVisitor(), arg);
            popBlock();
            return null;
        }

        @Override
        public Void visit(SBlock p, Void arg) {
            pushBlock();
            p.liststm_.forEach(s -> s.accept(new StmVisitor(), arg));
            popBlock();
            return null;
        }

        @Override
        public Void visit(SIfElse p, Void arg) {
            if(true) throw new RuntimeException("Not yet implemented " + p.getClass().toString() + " -> " + PrettyPrinter.print(p));
            return null;
        }
    }

    // Expression //////////////////////////////////////////////////////////

    public class ExpVisitor implements Exp.Visitor<Type, Void> {

        @Override
        public Type visit(EBool p, Void arg) {
            if(true) throw new RuntimeException("Not yet implemented " + p.getClass().toString() + " -> " + PrettyPrinter.print(p));
            return null;
        }

        @Override
        public Type visit(EInt p, Void arg) {
            return INT;
        }

        @Override
        public Type visit(EDouble p, Void arg) {
            if(true) throw new RuntimeException("Not yet implemented " + p.getClass().toString() + " -> " + PrettyPrinter.print(p));
            return null;
        }

        @Override
        public Type visit(EId p, Void arg) {
            return lookupVar(p.id_);
        }

        @Override
        public Type visit(EApp p, Void arg) {
            var arity = signature.get(p.id_);

            if(arity == null){
                throw new TypeException("Undefined function: " + p.id_);
            }

            if(arity.args.size() != p.listexp_.size()){
                throw new TypeException("Expected number of arguments: " + arity.args.size() + " provided: " + p.listexp_.size());
            }

            for(int i = 0; i < p.listexp_.size(); i++){
                ADecl exceptedParam = (ADecl)arity.args.get(i);
                var param = p.listexp_.get(i);
                typeEquals(exceptedParam.type_, param.accept(new ExpVisitor(), arg));
            }
            return arity.returnType;
        }

        @Override
        public Type visit(EPost p, Void arg) {
            if(true) throw new RuntimeException("Not yet implemented " + p.getClass().toString() + " -> " + PrettyPrinter.print(p));
            return null;
        }

        @Override
        public Type visit(EPre p, Void arg) {
            var type = lookupVar(p.id_);
            return getNumbericType(type);
        }

        @Override
        public Type visit(EMul p, Void arg) {
            var t1 = p.exp_1.accept(new ExpVisitor(), arg);
            var t2 = p.exp_2.accept(new ExpVisitor(), arg);
            notVoid(t1);
            getNumbericType(t1);
            getNumbericType(t2);
            typeEquals(t1, t2);
            return t1;
        }

        @Override
        public Type visit(EAdd p, Void arg) {
            var t1 = p.exp_1.accept(new ExpVisitor(), arg);
            var t2 = p.exp_2.accept(new ExpVisitor(), arg);
            notVoid(t1);
            getNumbericType(t1);
            getNumbericType(t2);
            typeEquals(t1, t2);
            return t1;
        }

        @Override
        public Type visit(ECmp p, Void arg) {
            var t1 = p.exp_1.accept(new ExpVisitor(), arg);
            var t2 = p.exp_2.accept(new ExpVisitor(), arg);
            notVoid(t1);
            typeEquals(t1, t2);
            return BOOL;
        }

        @Override
        public Type visit(EAnd p, Void arg) {
            if(true) throw new RuntimeException("Not yet implemented " + p.getClass().toString() + " -> " + PrettyPrinter.print(p));
            return null;
        }

        @Override
        public Type visit(EOr p, Void arg) {
            if(true) throw new RuntimeException("Not yet implemented " + p.getClass().toString() + " -> " + PrettyPrinter.print(p));
            return null;
        }

        @Override
        public Type visit(EAss p, Void arg) {
            var idType = lookupVar(p.id_);
            var type = p.exp_.accept(new ExpVisitor(), arg);
            typeEquals(idType, type);
            return idType;
        }

    }

    // Context handling //////////////////////////////////////////////////////////

    public void addVar(String id, Type typeCode) {

        if (contexts.get(0).containsKey(id)) {
            throw new TypeException("Variable " + id + " already defined");
        } else {
            contexts.get(0).put(id, typeCode);
        }
    }

    public void pushBlock() {
        contexts.add(0, new HashMap<String, Type>());
    }

    public void popBlock() {
        contexts.remove(0);
    }

    public Type lookupVar(String x) {
        for (HashMap<String, Type> m : contexts) {
            Type t = m.get(x);
            if (t != null){
                return t;
            }
        }
        throw new TypeException("unbound variable " + x);
    }

    // Operators //////////////////////////////////////////////////////////

    public class OperatorVisito implements CmpOp.Visitor<Type, Void>{

        @Override
        public Type visit(OLt p, Void arg) {
            // TODO Auto-generated method stub
            return null;
        }

        @Override
        public Type visit(OGt p, Void arg) {
            // TODO Auto-generated method stub
            return null;
        }

        @Override
        public Type visit(OLtEq p, Void arg) {
            // TODO Auto-generated method stub
            return null;
        }

        @Override
        public Type visit(OGtEq p, Void arg) {
            // TODO Auto-generated method stub
            return null;
        }

        @Override
        public Type visit(OEq p, Void arg) {
            // TODO Auto-generated method stub
            return null;
        }

        @Override
        public Type visit(ONEq p, Void arg) {
            // TODO Auto-generated method stub
            return null;
        }

    }

    // Exp & Type shape //////////////////////////////////////////////////////////

    public String isVar(Exp e) {
        if (e instanceof EId) {
            return ((EId) e).id_;
        } else
            throw new TypeException("Expected variable but found: " + e);
    }

    public void typeEquals(Type t1, Type t2) {
        if (!t1.equals(t2))
            throw new TypeException("Expected type " + t2 + " but found type " + t1);
    }
    
    public Type getNumbericType(Type t) {
        if (!t.equals(INT) && !t.equals(DOUBLE))
        throw new TypeException("Expected expression of numeric type");
        return t;
    }

    public void notVoid(Type t) {
        if (t.equals(VOID)){
            throw new TypeException(t + " is Void ");
        }
       }

}
