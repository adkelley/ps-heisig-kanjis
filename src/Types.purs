module Types ( RTKArgs, RTKData, Error) where


type RTKArgs =
  { cmd :: String 
  , args :: Array String
  }

type RTKData =
  { kanji :: Array String
  , indices :: Array String
  , keywords :: Array String
  , components :: Array String
  , indexPrim  :: Array String
  }

type Error = String
