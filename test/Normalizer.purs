module Test.Normalizer
  ( testNormalize
  ) where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Identy.Normalizer (normalize)
import Identy.ObjectMap (empty, insert, singleton)
import Simple.JSON (write)
import Test.Types (CommentId(..), ReplyId(..), TeamId(..), UserId(..))
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
              # insert (UserId "1") { id: UserId "1", name: "ichiro" }
              >>> insert (UserId "2") { id: UserId "2", name: "oreshinya" }
              >>> insert (UserId "3") { id: UserId "3", name: "shinjo" }
          , team: empty
              # insert (TeamId "1000") { id: TeamId "1000", name: "Seattle Mariners" }
              >>> insert (TeamId "1001") { id: TeamId "1001", name: "freelancer" }
          , comment: empty
              # insert (CommentId "1") { id: CommentId "1", body: "BODY 1" }
              >>> insert (CommentId "10") { id: CommentId "10", body: "BODY 10" }
          , reply: empty
              # insert (ReplyId "222") { id: ReplyId "222", body: "Reply 222" }
              >>> insert (ReplyId "333") { id: ReplyId "333", body: "Reply 333" }
          }
      , associations:
          { userTeam: empty
              # insert (UserId "1") (TeamId "1000")
              >>> insert (UserId "2") (TeamId "1001")
          , userComments: empty
              # insert (UserId "1") []
              >>> insert (UserId "2") [ CommentId "10", CommentId "1" ]
              >>> insert (UserId "3") []
          , commentReplies: empty
              # insert (CommentId "10") [ ReplyId "333", ReplyId "222" ]
              >>> insert (CommentId "1") []
          }
      , result: [ UserId "2", UserId "1", UserId "3" ]
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
          { user: singleton (UserId "101") { id: UserId "101", name: "oreshinya" }
          , comment: empty
              # insert (CommentId "1") { id: CommentId "1", body: "BODY 1" }
              >>> insert (CommentId "2") { id: CommentId "2", body: "BODY 2" }
          }
      , associations:
          { userActiveComments: singleton (UserId "101") [ CommentId "2", CommentId "1" ]
          , userPinnedComment: singleton (UserId "101") (CommentId "2")
          }
      , result: UserId "101"
      }
