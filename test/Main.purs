module Test.Main where

import Prelude

import Effect (Effect)
--import Effect.Console (log)
import Test.Unit (suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)

import RTK (query_rtk, frames, prims)

errorMsg :: String
errorMsg = "Usage: xxx xxxx xxx" 

-- | Use this main for console.log debugging
--main :: Effect Unit
--main = do
--  --log $ frames ["1", "2"] ["1", "2"] ["缶", "時"]
--  log $ prims ["a", "b"] ["a;   b", "a; b; c"] ["A", "B"]

main :: Effect Unit
main = runTest do
  suite "green" do
    test "good arguements" do
      Assert.assert "rtk_query returns string" $ 
        "1, 2" == query_rtk ["A", "B"] ["A", "B"] ["1", "2"] ", " errorMsg
      Assert.assert "frames returns string" $
          "A[1] B[2]" == frames ["1", "2"] ["1", "2"] ["A", "B"] " " errorMsg
      Assert.assert "prims returns string" $
         "A[1] B[2]" == prims ["A", "B"] ["A;   B", "A; B; C"] ["A", "B"] ["1",
           "2"]

  suite "red" do
    test "bad arguements" do
      Assert.assert "invalid queries should return error message" $ 
        errorMsg == query_rtk ["?"] ["A", "B"] ["1", "2"] ", " errorMsg
      Assert.assert "invalid frames should return error message" $
        errorMsg == frames ["?"] ["1", "2"] ["A", "B"] " " errorMsg
