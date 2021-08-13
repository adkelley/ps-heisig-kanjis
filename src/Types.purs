module Types ( CmdArgs, Command(..), RTKData, UpdateData) where

import Google.Auth (Client)
  
-- | P2F : Primitives to Frames
-- | I2F : Indices to Frames
-- | K2K : Kanji to Keywords
-- | K2I : Kanji to Indices
-- | UC  : Update Components
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
  

-- | Data returned from batchGet
type RTKData =
  { kanji :: Array String
  , indices :: Array String
  , keywords :: Array String
  , components :: Array String
  }
