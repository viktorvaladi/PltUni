{-# LANGUAGE CPP #-}
#if __GLASGOW_HASKELL__ <= 708
{-# LANGUAGE OverlappingInstances #-}
#endif
{-# LANGUAGE FlexibleInstances #-}
{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}

-- | Pretty-printer for Grammar.
--   Generated by the BNF converter.

module Grammar.Print where

import qualified Grammar.Abs
import Data.Char

-- | The top-level printing method.

printTree :: Print a => a -> String
printTree = render . prt 0

type Doc = [ShowS] -> [ShowS]

doc :: ShowS -> Doc
doc = (:)

render :: Doc -> String
render d = rend 0 (map ($ "") $ d []) "" where
  rend i ss = case ss of
    "["      :ts -> showChar '[' . rend i ts
    "("      :ts -> showChar '(' . rend i ts
    "{"      :ts -> showChar '{' . new (i+1) . rend (i+1) ts
    "}" : ";":ts -> new (i-1) . space "}" . showChar ';' . new (i-1) . rend (i-1) ts
    "}"      :ts -> new (i-1) . showChar '}' . new (i-1) . rend (i-1) ts
    [";"]        -> showChar ';'
    ";"      :ts -> showChar ';' . new i . rend i ts
    t  : ts@(p:_) | closingOrPunctuation p -> showString t . rend i ts
    t        :ts -> space t . rend i ts
    _            -> id
  new i     = showChar '\n' . replicateS (2*i) (showChar ' ') . dropWhile isSpace
  space t s =
    case (all isSpace t', null spc, null rest) of
      (True , _   , True ) -> []              -- remove trailing space
      (False, _   , True ) -> t'              -- remove trailing space
      (False, True, False) -> t' ++ ' ' : s   -- add space if none
      _                    -> t' ++ s
    where
      t'          = showString t []
      (spc, rest) = span isSpace s

  closingOrPunctuation :: String -> Bool
  closingOrPunctuation [c] = c `elem` closerOrPunct
  closingOrPunctuation _   = False

  closerOrPunct :: String
  closerOrPunct = ")],;"

parenth :: Doc -> Doc
parenth ss = doc (showChar '(') . ss . doc (showChar ')')

concatS :: [ShowS] -> ShowS
concatS = foldr (.) id

concatD :: [Doc] -> Doc
concatD = foldr (.) id

replicateS :: Int -> ShowS -> ShowS
replicateS n f = concatS (replicate n f)

-- | The printer class does the job.

class Print a where
  prt :: Int -> a -> Doc
  prtList :: Int -> [a] -> Doc
  prtList i = concatD . map (prt i)

instance {-# OVERLAPPABLE #-} Print a => Print [a] where
  prt = prtList

instance Print Char where
  prt _ s = doc (showChar '\'' . mkEsc '\'' s . showChar '\'')
  prtList _ s = doc (showChar '"' . concatS (map (mkEsc '"') s) . showChar '"')

mkEsc :: Char -> Char -> ShowS
mkEsc q s = case s of
  _ | s == q -> showChar '\\' . showChar s
  '\\'-> showString "\\\\"
  '\n' -> showString "\\n"
  '\t' -> showString "\\t"
  _ -> showChar s

prPrec :: Int -> Int -> Doc -> Doc
prPrec i j = if j < i then parenth else id

instance Print Integer where
  prt _ x = doc (shows x)

instance Print Double where
  prt _ x = doc (shows x)

instance Print Grammar.Abs.Id where
  prt _ (Grammar.Abs.Id i) = doc $ showString $ i

instance Print Grammar.Abs.Program where
  prt i e = case e of
    Grammar.Abs.PDefs defs -> prPrec i 0 (concatD [prt 0 defs])

instance Print [Grammar.Abs.Def] where
  prt = prtList

instance Print Grammar.Abs.Def where
  prt i e = case e of
    Grammar.Abs.DFun type_ id args stms -> prPrec i 0 (concatD [prt 0 type_, prt 0 id, doc (showString "("), prt 0 args, doc (showString ")"), doc (showString "{"), prt 0 stms, doc (showString "}")])
    Grammar.Abs.DFunCall type_ id args -> prPrec i 0 (concatD [prt 0 type_, prt 0 id, doc (showString "("), prt 0 args, doc (showString ")"), doc (showString ";")])
    Grammar.Abs.DNameSpace exp -> prPrec i 0 (concatD [doc (showString "using"), prt 0 exp, doc (showString ";")])
    Grammar.Abs.DDecl type_ decl -> prPrec i 0 (concatD [prt 0 type_, prt 0 decl, doc (showString ";")])
    Grammar.Abs.DDecls type_ decls -> prPrec i 0 (concatD [prt 0 type_, prt 0 decls, doc (showString ";")])
    Grammar.Abs.DTypeDefId type_ id -> prPrec i 0 (concatD [doc (showString "typedef"), prt 0 type_, prt 0 id, doc (showString ";")])
  prtList _ [] = concatD []
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print [Grammar.Abs.Arg] where
  prt = prtList

instance Print [Grammar.Abs.Decl] where
  prt = prtList

instance Print [Grammar.Abs.Stm] where
  prt = prtList

instance Print Grammar.Abs.Stm where
  prt i e = case e of
    Grammar.Abs.STypeDefId type_ id -> prPrec i 0 (concatD [doc (showString "typedef"), prt 0 type_, prt 0 id, doc (showString ";")])
    Grammar.Abs.SDecl type_ decl -> prPrec i 0 (concatD [prt 0 type_, prt 0 decl, doc (showString ";")])
    Grammar.Abs.SDecls type_ decls -> prPrec i 0 (concatD [prt 0 type_, prt 0 decls, doc (showString ";")])
    Grammar.Abs.SInit type_ id exp -> prPrec i 0 (concatD [prt 0 type_, prt 0 id, doc (showString "="), prt 0 exp, doc (showString ";")])
    Grammar.Abs.SEexp exp -> prPrec i 0 (concatD [prt 0 exp, doc (showString ";")])
    Grammar.Abs.SReturn exp -> prPrec i 0 (concatD [doc (showString "return"), prt 0 exp, doc (showString ";")])
    Grammar.Abs.SWhile exp stm -> prPrec i 0 (concatD [doc (showString "while"), doc (showString "("), prt 0 exp, doc (showString ")"), prt 0 stm])
    Grammar.Abs.SEWhile exp -> prPrec i 0 (concatD [doc (showString "while"), doc (showString "("), prt 0 exp, doc (showString ")"), doc (showString ";")])
    Grammar.Abs.SBlock stms -> prPrec i 0 (concatD [doc (showString "{"), prt 0 stms, doc (showString "}")])
    Grammar.Abs.SIfElse exp stm else_ -> prPrec i 0 (concatD [doc (showString "if"), doc (showString "("), prt 0 exp, doc (showString ")"), prt 0 stm, prt 0 else_])
    Grammar.Abs.SConstRefInit type_ id exp -> prPrec i 0 (concatD [doc (showString "const"), prt 0 type_, doc (showString "&"), prt 0 id, doc (showString "="), prt 0 exp, doc (showString ";")])
    Grammar.Abs.SFor type_ id exp1 exp2 exp3 stm -> prPrec i 0 (concatD [doc (showString "for"), doc (showString "("), prt 0 type_, prt 0 id, doc (showString "="), prt 0 exp1, doc (showString ";"), prt 0 exp2, doc (showString ";"), prt 0 exp3, doc (showString ")"), prt 0 stm])
    Grammar.Abs.SConstInitId type_ id exp -> prPrec i 0 (concatD [doc (showString "const"), prt 0 type_, prt 0 id, doc (showString "="), prt 0 exp, doc (showString ";")])
    Grammar.Abs.SDo stm exp -> prPrec i 0 (concatD [doc (showString "do"), prt 0 stm, doc (showString "while"), doc (showString "("), prt 0 exp, doc (showString ")"), doc (showString ";")])
  prtList _ [] = concatD []
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print Grammar.Abs.Arg where
  prt i e = case e of
    Grammar.Abs.ADecl type_ -> prPrec i 0 (concatD [prt 0 type_])
    Grammar.Abs.ADeclId type_ id -> prPrec i 0 (concatD [prt 0 type_, prt 0 id])
    Grammar.Abs.AConstRefTypeId type_ id -> prPrec i 0 (concatD [doc (showString "const"), prt 0 type_, doc (showString "&"), prt 0 id])
    Grammar.Abs.ARefId type_ id -> prPrec i 0 (concatD [prt 0 type_, doc (showString "&"), prt 0 id])
    Grammar.Abs.AConstRefType type_ -> prPrec i 0 (concatD [doc (showString "const"), prt 0 type_, doc (showString "&")])
    Grammar.Abs.ARefType type_ -> prPrec i 0 (concatD [prt 0 type_, doc (showString "&")])
  prtList _ [] = concatD []
  prtList _ [x] = concatD [prt 0 x]
  prtList _ (x:xs) = concatD [prt 0 x, doc (showString ","), prt 0 xs]

instance Print Grammar.Abs.Decl where
  prt i e = case e of
    Grammar.Abs.SDeclId id -> prPrec i 0 (concatD [prt 0 id])
  prtList _ [x] = concatD [prt 0 x]
  prtList _ (x:xs) = concatD [prt 0 x, doc (showString ","), prt 0 xs]

instance Print Grammar.Abs.Else where
  prt i e = case e of
    Grammar.Abs.SEElse -> prPrec i 0 (concatD [])
    Grammar.Abs.SElse stm -> prPrec i 0 (concatD [doc (showString "else"), prt 0 stm])

instance Print Grammar.Abs.Exp where
  prt i e = case e of
    Grammar.Abs.EChar c -> prPrec i 15 (concatD [prt 0 c])
    Grammar.Abs.EInt n -> prPrec i 15 (concatD [prt 0 n])
    Grammar.Abs.EDouble d -> prPrec i 15 (concatD [prt 0 d])
    Grammar.Abs.EString stringlist -> prPrec i 15 (concatD [prt 0 stringlist])
    Grammar.Abs.ETrue -> prPrec i 15 (concatD [doc (showString "true")])
    Grammar.Abs.EFalse -> prPrec i 15 (concatD [doc (showString "false")])
    Grammar.Abs.EId id -> prPrec i 15 (concatD [prt 0 id])
    Grammar.Abs.EIndex exp1 exp2 -> prPrec i 15 (concatD [prt 15 exp1, doc (showString "["), prt 0 exp2, doc (showString "]")])
    Grammar.Abs.ECall exp exps -> prPrec i 15 (concatD [prt 15 exp, doc (showString "("), prt 0 exps, doc (showString ")")])
    Grammar.Abs.EFun exp1 exp2 -> prPrec i 15 (concatD [prt 15 exp1, doc (showString "."), prt 14 exp2])
    Grammar.Abs.EPIncr exp -> prPrec i 14 (concatD [prt 15 exp, doc (showString "++")])
    Grammar.Abs.EPDcecr exp -> prPrec i 14 (concatD [prt 15 exp, doc (showString "--")])
    Grammar.Abs.EDeref exp -> prPrec i 15 (concatD [doc (showString "*"), prt 15 exp])
    Grammar.Abs.ENot exp -> prPrec i 13 (concatD [doc (showString "!"), prt 14 exp])
    Grammar.Abs.EIncr exp -> prPrec i 13 (concatD [doc (showString "++"), prt 14 exp])
    Grammar.Abs.EDecr exp -> prPrec i 13 (concatD [doc (showString "--"), prt 14 exp])
    Grammar.Abs.ENeg exp -> prPrec i 13 (concatD [doc (showString "-"), prt 14 exp])
    Grammar.Abs.EArrow exp1 exp2 -> prPrec i 13 (concatD [prt 13 exp1, doc (showString "->"), prt 14 exp2])
    Grammar.Abs.EMul exp1 exp2 -> prPrec i 12 (concatD [prt 12 exp1, doc (showString "*"), prt 13 exp2])
    Grammar.Abs.EDiv exp1 exp2 -> prPrec i 12 (concatD [prt 12 exp1, doc (showString "/"), prt 13 exp2])
    Grammar.Abs.EMod exp1 exp2 -> prPrec i 12 (concatD [prt 12 exp1, doc (showString "%"), prt 13 exp2])
    Grammar.Abs.EAdd exp1 exp2 -> prPrec i 11 (concatD [prt 11 exp1, doc (showString "+"), prt 12 exp2])
    Grammar.Abs.ESub exp1 exp2 -> prPrec i 11 (concatD [prt 11 exp1, doc (showString "-"), prt 12 exp2])
    Grammar.Abs.ELt exp1 exp2 -> prPrec i 9 (concatD [prt 9 exp1, doc (showString "<"), prt 10 exp2])
    Grammar.Abs.EGt exp1 exp2 -> prPrec i 9 (concatD [prt 9 exp1, doc (showString ">"), prt 10 exp2])
    Grammar.Abs.ELEq exp1 exp2 -> prPrec i 9 (concatD [prt 9 exp1, doc (showString "<="), prt 10 exp2])
    Grammar.Abs.EGEq exp1 exp2 -> prPrec i 9 (concatD [prt 9 exp1, doc (showString ">="), prt 10 exp2])
    Grammar.Abs.EEq exp1 exp2 -> prPrec i 8 (concatD [prt 8 exp1, doc (showString "=="), prt 9 exp2])
    Grammar.Abs.ENEq exp1 exp2 -> prPrec i 8 (concatD [prt 8 exp1, doc (showString "!="), prt 9 exp2])
    Grammar.Abs.EAnd exp1 exp2 -> prPrec i 4 (concatD [prt 4 exp1, doc (showString "&&"), prt 5 exp2])
    Grammar.Abs.EOr exp1 exp2 -> prPrec i 3 (concatD [prt 3 exp1, doc (showString "||"), prt 4 exp2])
    Grammar.Abs.EAss exp1 exp2 -> prPrec i 2 (concatD [prt 3 exp1, doc (showString "="), prt 2 exp2])
    Grammar.Abs.EThrowE exp -> prPrec i 2 (concatD [doc (showString "throw"), prt 2 exp])
    Grammar.Abs.EQstnmrk exp1 exp2 exp3 -> prPrec i 2 (concatD [prt 2 exp1, doc (showString "?"), prt 3 exp2, doc (showString ":"), prt 3 exp3])
    Grammar.Abs.ELl exp1 exp2 -> prPrec i 15 (concatD [prt 15 exp1, doc (showString "<<"), prt 15 exp2])
    Grammar.Abs.EGg exp id -> prPrec i 15 (concatD [prt 15 exp, doc (showString ">>"), prt 0 id])
    Grammar.Abs.ELibs id exp -> prPrec i 15 (concatD [prt 0 id, doc (showString "::"), prt 10 exp])
    Grammar.Abs.ELib id1 id2 -> prPrec i 15 (concatD [prt 0 id1, doc (showString "::"), prt 0 id2])
    Grammar.Abs.ELibType id type_ -> prPrec i 15 (concatD [prt 0 id, doc (showString "::"), prt 0 type_])
    Grammar.Abs.ETerm -> prPrec i 15 (concatD [doc (showString "\""), doc (showString "\"")])
  prtList _ [] = concatD []
  prtList _ [x] = concatD [prt 0 x]
  prtList _ (x:xs) = concatD [prt 0 x, doc (showString ","), prt 0 xs]

instance Print [Grammar.Abs.Exp] where
  prt = prtList

instance Print Grammar.Abs.Type where
  prt i e = case e of
    Grammar.Abs.Tbool -> prPrec i 0 (concatD [doc (showString "bool")])
    Grammar.Abs.Tdouble -> prPrec i 0 (concatD [doc (showString "double")])
    Grammar.Abs.Tint -> prPrec i 0 (concatD [doc (showString "int")])
    Grammar.Abs.Tstring -> prPrec i 0 (concatD [doc (showString "string")])
    Grammar.Abs.Tvoid -> prPrec i 0 (concatD [doc (showString "void")])
    Grammar.Abs.Tnew id -> prPrec i 0 (concatD [prt 0 id])
    Grammar.Abs.TLit id type_ -> prPrec i 0 (concatD [prt 0 id, doc (showString "::"), prt 0 type_])

instance Print Grammar.Abs.StringList where
  prt i e = case e of
    Grammar.Abs.StringList strs -> prPrec i 0 (concatD [prt 0 strs])

instance Print [String] where
  prt = prtList

