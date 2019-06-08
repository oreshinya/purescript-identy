module Test.Populater
  ( testPopulate
  ) where

import Prelude

import Data.Array (concat, cons)
import Data.Maybe (Maybe(..))
import Identy.ObjectMap (empty, insert, singleton, update)
import Identy.Populater (populate)
import Test.Types (CommentId(..), UserId(..), State)
import Test.Unit (TestSuite, test)
import Test.Unit.Assert as Assert

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
          >>> \s -> s { associations { userComments = update (Just <<< cons moreCommentsResponse.result) (UserId "1") s.associations.userComments } }
    Assert.equal moreCommentsExpected moreComments
  where
    firstResponse =
      { entities:
          { user: singleton (UserId "1") { id: UserId "1", name: "oreshinya" }
          , comment: singleton (CommentId "11") { id: CommentId "11", body: "BODY 11" }
          }
      , associations:
          { userComments: singleton (UserId "1") [ CommentId "11" ]
          }
      , result: [ UserId "1" ]
      }
    firstExpected =
      { entities:
          { user: singleton (UserId "1") { id: UserId "1", name: "oreshinya" }
          , comment: singleton (CommentId "11") { id: CommentId "11", body: "BODY 11" }
          }
      , associations:
          { userComments: singleton (UserId "1") [ CommentId "11" ]
          }
      , scenes: { home: { users: [ UserId "1" ] } }
      }
    moreResponse =
      { entities:
          { user: singleton (UserId "51") { id: UserId "51", name: "ichiro" }
          , comment: singleton (CommentId "51") { id: CommentId "51", body: "BODY 51" }
          }
      , associations:
          { userComments: singleton (UserId "51") [ CommentId "51" ]
          }
      , result: [ UserId "51" ]
      }
    moreExpected =
      { entities:
          { user: empty
              # insert (UserId "1") { id: UserId "1", name: "oreshinya" }
              >>> insert (UserId "51") { id: UserId "51", name: "ichiro" }
          , comment: empty
              # insert (CommentId "11") { id: CommentId "11", body: "BODY 11" }
              >>> insert (CommentId "51") { id: CommentId "51", body: "BODY 51" }
          }
      , associations:
          { userComments: empty
              # insert (UserId "1") [ CommentId "11" ]
              >>> insert (UserId "51") [ CommentId "51" ]
          }
      , scenes: { home: { users: [ UserId "51", UserId "1" ] } }
      }
    moreCommentsResponse =
      { entities:
          { comment: singleton (CommentId "111") { id: CommentId "111", body: "BODY 111" }
          }
      , associations: {}
      , result: CommentId "111"
      }
    moreCommentsExpected =
      { entities:
          { user: empty
              # insert (UserId "1") { id: UserId "1", name: "oreshinya" }
              >>> insert (UserId "51") { id: UserId "51", name: "ichiro" }
          , comment: empty
              # insert (CommentId "11") { id: CommentId "11", body: "BODY 11" }
              >>> insert (CommentId "51") { id: CommentId "51", body: "BODY 51" }
              >>> insert (CommentId "111") { id: CommentId "111", body: "BODY 111" }
          }
      , associations:
          { userComments: empty
              # insert (UserId "1") [ CommentId "111", CommentId "11" ]
              >>> insert (UserId "51") [ CommentId "51" ]
          }
      , scenes: { home: { users: [ UserId "51", UserId "1" ] } }
      }

initialState :: State
initialState =
  { entities: { user: empty, comment: empty }
  , associations: { userComments: empty }
  , scenes: { home: { users: [] } }
  }
