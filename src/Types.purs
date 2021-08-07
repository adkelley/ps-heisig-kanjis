module Types ( CmdArgs, Command(..), RTKData, UpdateData) where

import Google.Auth (Client)
  
data Command =
  P2F | I2F | K2K | K2I | UC

type CmdArgs = 
  { cmd :: Command
  , args :: Array String
  }


type UpdateData =
  { client :: Client
  , range  :: String
  , value  :: String
  }
  
type RTKData =
  { kanji :: Array String
  , indices :: Array String
  , keywords :: Array String
  , components :: Array String
  }
