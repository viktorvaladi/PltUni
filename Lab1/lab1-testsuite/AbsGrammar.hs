-- Haskell data types for the abstract syntax.
-- Generated by the BNF converter.

{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module AbsGrammar where

import Prelude (Char, Double, Integer, String)
import qualified Prelude as C (Eq, Ord, Show, Read)
import qualified Data.String

newtype Id = Id String
  deriving (C.Eq, C.Ord, C.Show, C.Read, Data.String.IsString)

data Program = PDefs [Def]
  deriving (C.Eq, C.Ord, C.Show, C.Read)

data Def
    = DFun Type Id [Arg] [Stm]
    | DFunCall Type Id [Arg]
    | DNameSpace Exp
    | DDecl Type Decl
    | DDecls Type [Decl]
    | DTypeDefId Type Id
  deriving (C.Eq, C.Ord, C.Show, C.Read)

data Stm
    = STypeDefId Type Id
    | SDecl Type Decl
    | SDecls Type [Decl]
    | SInit Type Id Exp
    | SEexp Exp
    | SReturn Exp
    | SWhile Exp Stm
    | SEWhile Exp
    | SBlock [Stm]
    | SIfElse Exp Stm Else
    | SConstRefInit Type Id Exp
    | SFor Type Id Exp Exp Exp Stm
    | SConstInitId Type Id Exp
    | SDo Stm Exp
  deriving (C.Eq, C.Ord, C.Show, C.Read)

data Arg
    = ADecl Type
    | ADeclId Type Id
    | AConstRefTypeId Type Id
    | ARefId Type Id
    | AConstRefType Type
    | ARefType Type
  deriving (C.Eq, C.Ord, C.Show, C.Read)

data Decl = SDeclId Id
  deriving (C.Eq, C.Ord, C.Show, C.Read)

data Else = SEElse | SElse Stm
  deriving (C.Eq, C.Ord, C.Show, C.Read)

data Exp
    = EChar Char
    | EInt Integer
    | EDouble Double
    | EString StringList
    | ETrue
    | EFalse
    | EId Id
    | EIndex Exp Exp
    | ECall Exp [Exp]
    | EFun Exp Exp
    | EPIncr Exp
    | EPDcecr Exp
    | EDeref Exp
    | ENot Exp
    | EIncr Exp
    | EDecr Exp
    | ENeg Exp
    | EArrow Exp Exp
    | EMul Exp Exp
    | EDiv Exp Exp
    | EMod Exp Exp
    | EAdd Exp Exp
    | ESub Exp Exp
    | ELt Exp Exp
    | EGt Exp Exp
    | ELEq Exp Exp
    | EGEq Exp Exp
    | EEq Exp Exp
    | ENEq Exp Exp
    | EAnd Exp Exp
    | EOr Exp Exp
    | EAss Exp Exp
    | EThrowE Exp
    | EQstnmrk Exp Exp Exp
    | ELl Exp Exp
    | EGg Exp Id
    | ELibs Id Exp
    | ELib Id Id
    | ELibType Id Type
    | ETerm
  deriving (C.Eq, C.Ord, C.Show, C.Read)

data Type
    = Tbool | Tdouble | Tint | Tstring | Tvoid | Tnew Id | TLit Id Type
  deriving (C.Eq, C.Ord, C.Show, C.Read)

data StringList = StringList [String]
  deriving (C.Eq, C.Ord, C.Show, C.Read)

