module Params (cmdLineParser) where

import Prelude

import Control.Alternative ((<|>))
import Data.Either (Either(..))
import Data.Foldable (fold)
import Data.Int.Parse (parseInt, toRadix)
import Data.Maybe (fromMaybe)
import Data.String.Common (split)
import Data.String.Pattern (Pattern(..))
import Data.String.Regex (regex, test, parseFlags)
import Data.Traversable (traverse)
import Effect (Effect)
import Options.Applicative (Parser, execParser, fullDesc, header, help, helper, info, long, metavar, progDesc, short, strOption, (<**>))
import Types (RTKArgs, Error)

data Query
  = Keywords String
  | Indices String
  | Primitives String
  | Frames String

keywords :: Parser Query
keywords = ado
  kanji <- strOption $ fold
    [ long "keywords"
    , short 'k'
    , metavar "QUERY"
    , help "Query for keywords command"
    ]
  in Keywords kanji

indices :: Parser Query
indices = ado
  kanji <- strOption $ fold
    [ long "indices"
    , short 'i'
    , metavar "QUERY"
    , help "Query for indices command"
    ]
  in Indices kanji


primitives :: Parser Query
primitives = ado
  prims <- strOption $ fold
    [ long "primitives"
    , short 'p'
    , metavar "QUERY"
    , help "Query for primitives command"
    ]
  in Primitives prims


frames :: Parser Query
frames = ado
  indices <- strOption $ fold
    [ long "frames"
    , short 'f'
    , metavar "QUERY"
    , help "Query for frames command"
    ]
  in Frames indices


-- | A RTK index should be an integer > 0 and < 3001
isIndices :: String -> Either Error (Array String)
isIndices ixs = 
  traverse (\i -> isIndex i) $ split (Pattern " ") ixs
  where
    isIndex index = do
      let i = fromMaybe 0 $ parseInt index $ toRadix 10 
      if (i > 0 && i < 3001)
        then Right index
        else Left "RTK indices must be integers > 0 and < 3001"


-- UNICODE RANGE : DESCRIPTION
-- 
-- 3000-303F : punctuation
-- 3040-309F : hiragana
-- 30A0-30FF : katakana
-- FF00-FFEF : Full-width roman + half-width katakana
-- 4E00-9FAF : Common and uncommon kanji
-- 
-- Non-Japanese punctuation/formatting characters commonly used in Japanese text
-- 2605-2606 : Stars
-- 2190-2195 : Arrows
-- u203B     : Weird asterisk thing
isJukugo :: String -> Either Error (Array String)
isJukugo jukugo = 
  traverse (\k -> isKanji k) $ split (Pattern "") jukugo
  where
    isKanji kanji = do
      expression <- regex "[\\u4E00-\\u9FAF]" $ parseFlags "g" 
      if (test expression kanji)
        then Right kanji
        else Left "A jukugo must be a kanji character or kanji compound"


-- | A primitive must be lower case english string
arePrimitives :: String -> Either Error (Array String)
arePrimitives prims = 
  traverse (\p -> isPrimitive p) $ split (Pattern " ") prims
  where 
    isPrimitive p = do
      expression <- regex "[a-z]" $ parseFlags "g" 
      if (test expression p)
        then Right p
        else Left "Primitives must be lower case english strings"


validate :: Query -> Effect (Either Error RTKArgs)
validate query = pure $
   case query of
     Keywords k -> (isJukugo k) >>= 
                       (\xs -> Right {cmd: "-k", args: xs})
     Indices i -> (isJukugo i) >>= 
                       (\xs -> Right {cmd: "-i", args: xs})
     Primitives p -> (arePrimitives p) >>= 
                       (\xs -> Right {cmd: "-p", args: xs})
     Frames f -> (isIndices f) >>= 
                       (\xs -> Right {cmd: "-f", args: xs})

cmdLineParser :: Effect (Either Error RTKArgs)
cmdLineParser = validate =<< execParser opts
  where
     opts = info (keywords <|> indices <|> primitives <|> 
                  frames <**> helper)
      ( fullDesc
     <> progDesc "return the result of an RTK QUERY"
     <> header "rtk - query utilities for the rtk google spreadsheet" )