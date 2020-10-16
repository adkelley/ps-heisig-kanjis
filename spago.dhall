{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "my-project"
, dependencies =
  [ "arrays"
  , "console"
  , "effect"
  , "exceptions"
  , "foldable-traversable"
  , "foreign"
  , "lists"
  , "node-process"
  , "parseint"
  , "psci-support"
  , "strings"
  , "test-unit"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
