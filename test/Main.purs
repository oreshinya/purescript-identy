module Test.Main where

import Prelude

import Effect (Effect)
import Test.Normalizer (testNormalize)
import Test.Populater (testPopulate)
import Test.Unit.Main (runTest)

main :: Effect Unit
main = runTest do
  testNormalize
  testPopulate
