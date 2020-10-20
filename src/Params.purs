module Params (cmdLineParser) where

import Prelude

import Options.Applicative ( Parser, execParser, fullDesc, header
                           , help, helper, info, long, metavar, progDesc
                           , short, strOption, (<**>))
import Control.Alternative ((<|>))
import Data.Foldable (fold)
import Effect (Effect)
import Data.String.Common (split)
import Data.String.Pattern (Pattern (..)) 
import Data.Either (Either (..))
import Data.Maybe (fromMaybe)
import Data.Int.Parse (parseInt, toRadix)
import Data.String.Regex (regex, test, parseFlags)

import Types (RTKArgs, Error)

data Query
  = Keywords String
  | Indices String
  | Primitives String

keywords :: Parser Query
keywords = ado
  kanji <- strOption $ fold
    [ long "keywords"
    , short 'k'
    , metavar "COMMAND"
    , help "keywords command"
    ]
  in Keywords kanji

indices :: Parser Query
indices = ado
  kanji <- strOption $ fold
    [ long "indices"
    , short 'i'
    , metavar "COMMAND"
    , help "indices command"
    ]
  in Indices kanji

primitives :: Parser Query
primitives = ado
  prims <- strOption $ fold
    [ long "primatives"
    , short 'p'
    , metavar "COMMAND"
    , help "primatives command"
    ]
  in Primitives prims

-- | A RTK index should be an integer > 0 and < 3001
isIndex :: String -> Either Error String
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
isKanji :: String -> Either Error String
isKanji kanji = do 
  expression <- regex "[\\u4E00-\\u9FAF]" $ parseFlags "g" 
  if (test expression kanji)
    then Right kanji
    else Left "A jukugo must be a kanji or kanji compound"


-- | A primitive must be lower case english string
isPrim :: String -> Either Error String
isPrim prim = do
  expression <- regex "[a-z]" $ parseFlags "g" 
  if (test expression prim)
    then Right prim
    else Left "Primitives must be lower case english strings"


validate :: Query -> Effect (Either Error RTKArgs)
validate query = pure $
   case query of
     Keywords k -> (isKanji k) >>= 
                       (\xs -> Right {cmd: "-k", args: split (Pattern "") xs})
     Indices k -> (isKanji k) >>= 
                       (\xs -> Right {cmd: "-i", args: split (Pattern "") xs})
     Primitives p -> (isPrim p) >>= 
                       (\xs -> Right {cmd: "-p", args: split (Pattern " ") xs})


cmdLineParser :: Effect (Either Error RTKArgs)
cmdLineParser = validate =<< execParser opts
  where
     opts = info (keywords <|> indices <|> primitives <**> helper)
      ( fullDesc
     <> progDesc "Print a greeting for TARGET"
     <> header "hello - a test for purescript-optparse" )


--cmdLineParser :: Effect (Either Error RTKArgs)
--cmdLineParser = do
--  args <- getArgs
--  pure $ case args of
--    "-p" : rest -> (traverse isPrim rest) >>=
--                     (\xs -> mkArgs "-p" $ A.fromFoldable xs)
--    "-k" : rest -> (traverse isKanji rest) >>=
--                       (\xs -> mkArgs "-k" $ splitNode xs)
--    "-i" : rest -> (traverse isKanji rest) >>= 
--                     (\xs -> mkArgs "-i" $ splitNode xs) 
--    "-f" : rest -> (traverse isIndex rest) >>= 
--                      (\xs -> mkArgs "-f" $ A.fromFoldable xs) 
--    Nil -> Left $ "Usage: node index.js <cmd> <arguments>"
--    _ -> Left $ "Usage: node index.js <cmd> <arguments>"

