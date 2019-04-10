module Test.Normalizer
  ( testNormalize
  ) where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Foreign.Object (empty, insert, singleton)
import Identy.Normalizer (normalize)
import Simple.JSON (write)
import Test.Unit (TestSuite, failure, suite, test)
import Test.Unit.Assert as Assert

testNormalize :: TestSuite
testNormalize =
  suite "normalize" do
    testNormalizeArray
    testNormalizeSingle

testNormalizeArray :: TestSuite
testNormalizeArray =
  test "normalize array" do
    case normalize response of
      Left _ -> failure "Failed to read foreign"
      Right res -> Assert.equal expected res
  where
    response = write
      [ { id: "2"
        , name: "oreshinya"
        , typename: "User"
        , team: Just { id: "1001", name: "freelancer", typename: "Team" }
        , comments:
            [ { id: "10"
              , body: "BODY 10"
              , typename: "Comment"
              , replies:
                  [ { id: "333", body: "Reply 333", typename: "Reply" }
                  , { id: "222", body: "Reply 222", typename: "Reply" }
                  ]
              }
            , { id: "1"
              , body: "BODY 1"
              , typename: "Comment"
              , replies: []
              }
            ]
        }
      , { id: "1"
        , name: "ichiro"
        , typename: "User"
        , team: Just { id: "1000", name: "Seattle Mariners", typename: "Team" }
        , comments: []
        }
      , { id: "3"
        , name: "shinjo"
        , typename: "User"
        , team: Nothing
        , comments: []
        }
      ]

    expected =
      { entities:
          { user: empty
              # insert "1" { id: "1", name: "ichiro" }
              >>> insert "2" { id: "2", name: "oreshinya" }
              >>> insert "3" { id: "3", name: "shinjo" }
          , team: empty
              # insert "1000" { id: "1000", name: "Seattle Mariners" }
              >>> insert "1001" { id: "1001", name: "freelancer" }
          , comment: empty
              # insert "1" { id: "1", body: "BODY 1" }
              >>> insert "10" { id: "10", body: "BODY 10" }
          , reply: empty
              # insert "222" { id: "222", body: "Reply 222" }
              >>> insert "333" { id: "333", body: "Reply 333" }
          }
      , associations:
          { userTeam: empty
              # insert "1" "1000"
              >>> insert "2" "1001"
          , userComments: empty
              # insert "1" []
              >>> insert "2" [ "10", "1" ]
              >>> insert "3" []
          , commentReplies: empty
              # insert "10" [ "333", "222" ]
              >>> insert "1" []
          }
      , result: [ "2", "1", "3" ]
      }

testNormalizeSingle :: TestSuite
testNormalizeSingle =
  test "normalize single" do
    case normalize response of
      Left _ -> failure "Failed to read foreign"
      Right res -> Assert.equal expected res
  where
    response = write
      { id: "101"
      , name: "oreshinya"
      , typename: "User"
      , activeComments:
          [ { id: "2", body: "BODY 2", typename: "Comment" }
          , { id: "1", body: "BODY 1", typename: "Comment" }
          ]
      , pinnedComment: { id: "2", body: "BODY 2", typename: "Comment" }
      }

    expected =
      { entities:
          { user: singleton "101" { id: "101", name: "oreshinya" }
          , comment: empty
              # insert "1" { id: "1", body: "BODY 1" }
              >>> insert "2" { id: "2", body: "BODY 2" }
          }
      , associations:
          { userActiveComments: singleton "101" [ "2", "1" ]
          , userPinnedComment: singleton "101" "2"
          }
      , result: "101"
      }
