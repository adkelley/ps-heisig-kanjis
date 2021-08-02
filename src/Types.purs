module Types ( CmdArgs, Command(..), RTKData, Error) where

data Command =
  P2F | I2F | K2K | K2I | UC
                          
type CmdArgs = 
  { cmd :: Command
  , args :: Array String
  }
  

type RTKData =
  { kanji :: Array String
  , indices :: Array String
  , keywords :: Array String
  , components :: Array String
  }


type Error = String
