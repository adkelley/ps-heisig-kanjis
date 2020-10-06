module Test.Main where

import Prelude

import Effect (Effect)
import Test.Unit (suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)

import RTK (find_indices, find_keywords, find_kanji)

compound :: Array String
compound = ["漢", "字"]

kanji :: Array String
kanji = [ "字", "漢"]

keywords :: Array String
keywords = ["character", "Sino-"]

indices :: Array String
indices = ["197", "1701"]

primitives :: Array String
primitives = ["Sino-", "character"]

badArg :: Array String
badArg = ["?", "?"]

separator :: String
separator = ", "

main :: Effect Unit
main = runTest do
  suite "green" do
    test "good arguements" do
      Assert.assert "kw 漢字 should be Sino-, character" $ 
        "Sino-, character" == find_keywords compound kanji keywords separator
      Assert.assert "ix 漢字 should be 1701, 197" $ 
        "1701, 197" == find_indices compound kanji indices separator
      Assert.assert "kanji Sino-,character should be 漢字" $ 
        "漢字" == find_kanji primitives keywords kanji ""

  suite "red" do
    test "bad arguements" do
      Assert.assert "kw ?? should be Usage: kw 漢字" $ 
        "Usage: kw 漢字" == find_keywords badArg kanji keywords separator
      Assert.assert "ix ?? should be Usage: ix 漢字" $ 
        "Usage: ix 漢字" == find_indices badArg kanji indices separator
      Assert.assert "kanji ?? should be Usage: kanji Sino- character" $
        "Usage: kanji Sino- character" == find_kanji badArg keywords kanji ""
