module Test.Populater
  ( testPopulate
  ) where

import Prelude

import Data.Array (concat, cons)
import Data.Maybe (Maybe(..))
import Foreign.Object (Object, empty, insert, singleton, update)
import Identy.Populater (populate)
import Test.Unit (TestSuite, test)
import Test.Unit.Assert as Assert

type User =
  { id :: String
  , name :: String
  }

type Comment =
  { id :: String
  , body :: String
  }

type Entities =
  { user :: Object User
  , comment :: Object Comment
  }

type Associations =
  { userComments :: Object (Array String)
  }

type Scenes =
  { home :: { users :: Array String }
  }

type State =
  { entities :: Entities
  , associations :: Associations
  , scenes :: Scenes
  }

testPopulate :: TestSuite
testPopulate =
  test "populate" do
    let first = initialState # populate firstResponse
          >>> _ { scenes { home { users = firstResponse.result } } }
    Assert.equal firstExpected first
    let more = first # populate moreResponse
          >>> \s -> s { scenes { home { users = concat [ moreResponse.result, s.scenes.home.users ] } } }
    Assert.equal moreExpected more
    let moreComments = more # populate moreCommentsResponse
          >>> \s -> s { associations { userComments = update (Just <<< cons moreCommentsResponse.result) "1" s.associations.userComments } }
    Assert.equal moreCommentsExpected moreComments
  where
    firstResponse =
      { entities:
          { user: singleton "1" { id: "1", name: "oreshinya" }
          , comment: singleton "11" { id: "11", body: "BODY 11" }
          }
      , associations:
          { userComments: singleton "1" [ "11" ]
          }
      , result: [ "1" ]
      }
    firstExpected =
      { entities:
          { user: singleton "1" { id: "1", name: "oreshinya" }
          , comment: singleton "11" { id: "11", body: "BODY 11" }
          }
      , associations:
          { userComments: singleton "1" [ "11" ]
          }
      , scenes: { home: { users: [ "1" ] } }
      }
    moreResponse =
      { entities:
          { user: singleton "51" { id: "51", name: "ichiro" }
          , comment: singleton "51" { id: "51", body: "BODY 51" }
          }
      , associations:
          { userComments: singleton "51" [ "51" ]
          }
      , result: [ "51" ]
      }
    moreExpected =
      { entities:
          { user: empty
              # insert "1" { id: "1", name: "oreshinya" }
              >>> insert "51" { id: "51", name: "ichiro" }
          , comment: empty
              # insert "11" { id: "11", body: "BODY 11" }
              >>> insert "51" { id: "51", body: "BODY 51" }
          }
      , associations:
          { userComments: empty
              # insert "1" [ "11" ]
              >>> insert "51" [ "51" ]
          }
      , scenes: { home: { users: [ "51", "1" ] } }
      }
    moreCommentsResponse =
      { entities:
          { comment: singleton "111" { id: "111", body: "BODY 111" }
          }
      , associations: {}
      , result: "111"
      }
    moreCommentsExpected =
      { entities:
          { user: empty
              # insert "1" { id: "1", name: "oreshinya" }
              >>> insert "51" { id: "51", name: "ichiro" }
          , comment: empty
              # insert "11" { id: "11", body: "BODY 11" }
              >>> insert "51" { id: "51", body: "BODY 51" }
              >>> insert "111" { id: "111", body: "BODY 111" }
          }
      , associations:
          { userComments: empty
              # insert "1" [ "111", "11" ]
              >>> insert "51" [ "51" ]
          }
      , scenes: { home: { users: [ "51", "1" ] } }
      }

initialState :: State
initialState =
  { entities: { user: empty, comment: empty }
  , associations: { userComments: empty }
  , scenes: { home: { users: [] } }
  }
