module Test.Types where

import Prelude

import Data.Newtype (class Newtype)
import Identy.ObjectMap (ObjectMap)
import Simple.JSON (class ReadForeign)

newtype UserId = UserId String
newtype TeamId = TeamId String
newtype CommentId = CommentId String
newtype ReplyId = ReplyId String

derive newtype instance showUserId :: Show UserId
derive newtype instance showTeamId :: Show TeamId
derive newtype instance showCommentId :: Show CommentId
derive newtype instance showReplyId :: Show ReplyId

derive newtype instance eqUserId :: Eq UserId
derive newtype instance eqTeamId :: Eq TeamId
derive newtype instance eqCommentId :: Eq CommentId
derive newtype instance eqReplyId :: Eq ReplyId

derive newtype instance readForeignUserId :: ReadForeign UserId
derive newtype instance readForeignTeamId :: ReadForeign TeamId
derive newtype instance readForeignCommentId :: ReadForeign CommentId
derive newtype instance readForeignReplyId :: ReadForeign ReplyId

derive instance newtypeUserId :: Newtype UserId _
derive instance newtypeTeamId :: Newtype TeamId _
derive instance newtypeCommentId :: Newtype CommentId _
derive instance newtypeReplyId :: Newtype ReplyId _

type User =
  { id :: UserId
  , name :: String
  }

type Comment =
  { id :: CommentId
  , body :: String
  }

type Entities =
  { user :: ObjectMap UserId User
  , comment :: ObjectMap CommentId Comment
  }

type Associations =
  { userComments :: ObjectMap UserId (Array CommentId)
  }

type State =
  { entities :: Entities
  , associations :: Associations
  , home :: { users :: Array UserId }
  }
