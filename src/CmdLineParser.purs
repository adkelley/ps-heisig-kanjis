module CmdLineParser (cmdLineParser) where

import Prelude

import Control.Alternative ((<|>))
import Data.Either (Either(..))
import Data.Foldable (fold)
import Data.String.Common (split)
import Data.String.Pattern (Pattern(..))
import Effect (Effect)
import Options.Applicative (Parser, execParser, fullDesc, header, help, helper, info, long, metavar, progDesc, short, strOption, (<**>))
import Types (Error, CmdArgs, Command(..))

data Query
  = Keywords String
  | Indices String
  | Primitives String
  | Frames String
  | Update String

keywords :: Parser Query
keywords = ado
  kanji <- strOption $ fold
    [ long "keywords"
    , short 'k'
    , metavar "QUERY"
    , help "Query for kanji to keywords command"
    ]
  in Keywords kanji

indices :: Parser Query
indices = ado
  kanji <- strOption $ fold
    [ long "indices"
    , short 'i'
    , metavar "QUERY"
    , help "Query for kanji to indices command"
    ]
  in Indices kanji


primitives :: Parser Query
primitives = ado
  prims <- strOption $ fold
    [ long "primitives"
    , short 'p'
    , metavar "QUERY"
    , help "Query for primitives to frames command"
    ]
  in Primitives prims


frames :: Parser Query
frames = ado
  indices <- strOption $ fold
    [ long "frames"
    , short 'f'
    , metavar "QUERY"
    , help "Query for indices to frames command"
    ]
  in Frames indices


update :: Parser Query
update = ado
  indices <- strOption $ fold
    [ long "update"
    , short 'w'
    , metavar "QUERY"
    , help "Query for update command"
    ]
  in Update indices

control :: Query -> Effect (Either Error CmdArgs)
control query =  pure $
   case query of
     Keywords k -> Right {cmd: K2K, args: split (Pattern "") k}
     Indices i -> Right {cmd: K2I, args: split (Pattern "") i}
     Primitives p -> Right {cmd: P2F, args: split (Pattern ";") p}
     Frames f -> Right {cmd: I2F, args: split (Pattern ";") f}
     Update w -> Right {cmd: UC, args: split (Pattern ";") w}

cmdLineParser :: Effect (Either Error CmdArgs)
cmdLineParser = control =<< execParser opts
  where
     opts = info (keywords <|> indices <|> primitives <|> 
                  frames <|> update <**> helper)
      ( fullDesc
     <> progDesc "return the result of an RTK QUERY"
     <> header "rtk - query utilities for the rtk google spreadsheet" )
