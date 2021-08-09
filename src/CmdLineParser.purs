module CmdLineParser (cmdLineParser) where

import Prelude

import Control.Alternative ((<|>))
import Data.Foldable (fold)
import Data.String (replaceAll)
import Data.String.Common (split)
import Data.String.Pattern (Pattern(..), Replacement(..))
import Effect (Effect)
import Options.Applicative (Parser, execParser, fullDesc, header, help, helper, info, long, metavar, progDesc, short, strOption, (<**>))
import Types (CmdArgs, Command(..))

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

control :: Query -> Effect CmdArgs
control query =  pure $
   case query of
     Keywords k -> {cmd: K2K, args: format "" k}
     Indices i -> {cmd: K2I, args: format "" i}
     Primitives p -> {cmd: P2F, args: format ";" p}
     Frames f -> {cmd: I2F, args: format ";" f}
     Update w -> {cmd: UC, args: format ";" w}
   where
     format :: String -> String -> Array String
     format pattern str = 
       split (Pattern pattern) str #
       map (replaceAll (Pattern "_") (Replacement " "))

cmdLineParser :: Effect CmdArgs
cmdLineParser = control =<< execParser opts
  where
     opts = info (keywords <|> indices <|> primitives <|> 
                  frames <|> update <**> helper)
      ( fullDesc
     <> progDesc "return the result of an RTK QUERY"
     <> header "rtk - query utilities for the rtk google spreadsheet" )
