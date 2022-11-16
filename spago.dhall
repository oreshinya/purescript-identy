{-
Welcome to a Spago project!
You can edit this file as you like.

Need help? See the following resources:
- Spago documentation: https://github.com/purescript/spago
- Dhall language tour: https://docs.dhall-lang.org/tutorials/Language-Tour.html

When creating a new Spago project, you can use
`spago init --no-comments` or `spago init -C`
to generate this file without the comments in this block.
-}
{ name = "identy"
, license = "MIT"
, repository = "https://github.com/oreshinya/purescript-identy"
, dependencies =
  [ "arrays"
  , "either"
  , "foldable-traversable"
  , "foreign"
  , "foreign-object"
  , "functions"
  , "lists"
  , "maybe"
  , "newtype"
  , "prelude"
  , "record"
  , "simple-json"
  , "st"
  , "tuples"
  , "typelevel-prelude"
  , "unfoldable"
  , "unsafe-coerce"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
