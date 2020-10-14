module Types ( RTKArgs, RTKData, Kanji
             , Keywords, Indices, Query
             ) where

type RTKData =
  { kanji :: Array String
  , indices :: Array String
  , keywords :: Array String
  , components :: Array String
  }

type RTKArgs =
  { cmd :: String 
  , args :: Array String
  }

type Kanji = Array String
type Indices = Array String
type Keywords = Array String
type Query = Array String
