module Test.Main where

import Prelude

import Effect (Effect)
import Data.Either (Either (..))
import Test.Unit (suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)

import RTK ( indicesToFrames, primsToFrames
           , kanjiToIndices, kanjiToKeywords)

-- | Use this main for console.log debugging
--main :: Effect Unit
--main = do
--  --log $ frames ["1", "2"] ["1", "2"] ["缶", "時"]
--  log $ prims ["a", "b"] ["a;   b", "a; b; c"] ["A", "B"]

main :: Effect Unit
main = runTest do
  suite "green" do
    test "good arguments" do
      Assert.assert "kanjiToIndices returns indices" $ 
        Right "1, 2" == kanjiToIndices ["A", "B"] ["A", "B"] ["1", "2"]
      Assert.assert  "kanjiToKeywords return keywords" $
        Right "A, B" == kanjiToKeywords ["1", "2"] ["1", "2"] ["A", "B"]
      Assert.assert "frames returns string" $
        Right "A[1] B[2]" == indicesToFrames ["1", "2"] ["1", "2"] ["A", "B"]
      Assert.assert "prims returns string" $
        Right "A[1] B[2]" == primsToFrames ["A", "B"] ["A;   B", "A; B; C"] ["A", "B"] 

  suite "red" do
    test "bad arguments" do
      Assert.assert "kanjiToKeywords: invalid args should return error message" $ 
        Left "kanjiToKeywords error" == kanjiToKeywords ["?"] ["A", "B"] ["1", "2"]
      Assert.assert "indicesToFrames: frames should return error message" $
        Left "indicesToFrames error" == indicesToFrames ["xx"] ["1", "2"] ["A", "B"]
