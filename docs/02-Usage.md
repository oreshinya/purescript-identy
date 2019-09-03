# Usage

Welcome to `purescript-identy`.

It is a state management utilities for [purescript-freedom](https://github.com/purescript-freedom/purescript-freedom).

Have a fun to build complex application with `purescript-identy` ;)

## Installation

### Bower

```
$ bower install --save purescript-identy
```

### Spago

```
$ spago install identy
```

## Define the state shape by identy-style

You should define the state shape by identy-style.

**NOTE: The identy-style state shape force to treat id as newtype of string.**

Like this:

```purescript
import Data.Newtype (class Newtype)
import Identy.ObjectMap (ObjectMap)
import Simple.JSON (class ReadForeign)

newtype UserId = UserId String
newtype TeamId = TeamId String
newtype CommentId = CommentId String

derive newtype instance readForeignUserId :: ReadForeign UserId
derive newtype instance readForeignTeamId :: ReadForeign TeamId
derive newtype instance readForeignCommentId :: ReadForeign CommentId

derive instance newtypeUserId :: Newtype UserId _
derive instance newtypeTeamId :: Newtype TeamId _
derive instance newtypeCommentId :: Newtype CommentId _

type User =
  { id :: UserId
  , name :: String
  }

type Comment =
  { id :: CommentId
  , body :: String
  }

type Team =
  { id :: TeamId
  , name :: String
  }

-- keys are id, values are entity.
type Entities =
  { user :: ObjectMap UserId User
  , comment :: ObjectMap CommentId Comment
  , team :: ObjectMap TeamId Team
  }

type Associations =
  { userComments :: ObjectMap UserId (Array CommentId)
  , userTeam :: ObjectMap UserId TeamId
  }

-- The identy-style state shape
type State =
  { entities :: Entities
  , associations :: Associations
  , home :: { users :: Array UserId }
  }
```

## How to populate data received from API

### Case 1 - identy-style JSON response

#### What is identy-style JSON ?

Identy-style JSON is the format optimized for `purescript-identy`.

If API respond a user with comments of its user, like this:

```json
{
  "entities": {
    "user": { "1": { "id": "1", "name": "User Name" } },
    "comment": { "1": { "id": "1", "body": "Body 1" }, "2": { "id": "2", "body": "Body 2" } }
  },
  "associations": {
    "userComments": { "1": [ "2", "1" ] }
  },
  "result": "1"
}
```

In this case, `result` is a user id.

And `associations.userComments` is an object that has user id as key and array of comment id as value. This is representation of association between user and comment.

`entities` have objects that have id of entity as key and entity itself as value.

Also if API respond array of user with comments, like this:

```json
{
  "entities": {
    "user": { "1": { "id": "1", "name": "User Name" } },
    "comment": { "1": { "id": "1", "body": "Body 1" }, "2": { "id": "2", "body": "Body 2" } }
  },
  "associations": {
    "userComments": { "1": [ "2", "1" ] }
  },
  "result": [ "1" ]
}
```

#### How to populate

You can use `populate` function in `Identy.Populater` module.

`populate` merges `entities` and `associations` in response.

And you set `result` to any state.

In `Action` of `purescript-freedom`:

```purescript
type Response =
  { entities :: { user :: ObjectMap UserId User, comment :: ObjectMap CommentId Comment }
  , associations :: { userComments :: ObjectMap UserId (Array CommentId) }
  , result :: Array UserId
  }

fetchUsers = do
  (res :: Response) <- lift $ API.get "/users" -- Fetch and decode.
  reduce $ populate res >>> _ { home { users = res.result } }
```

### Case 2 - General format JSON response

#### JSON example

Many API responds nested JSON like this:

```json
[
  {
    "id": "1",
    "name": "User Name",
    "comments": [
      { "id": "1", "body": "Body 1" },
      { "id": "2", "body": "Body 2" } 
    ]
  }
]
```

#### How to populate

`purescript-identy` has a formatter to identy-style from the above JSON.

As prerequisite, each entity need a property `typename` that is set type name with upper camel case.

Like this:

```json
[
  {
    "id": "1",
    "name": "User Name",
    "typename": "User",
    "comments": [
      { "id": "1", "body": "Body 1", "typename": "Comment" },
      { "id": "2", "body": "Body 2", "typename": "Comment" }
    ]
  }
]
```

By `typename`, you can format JSON with `normalize` function in `Identy.Normalizer`.

It formats from the above JSON to the following:

```json
{
  "entities": {
    "user": { "1": { "id": "1", "name": "User Name" } },
    "comment": { "1": { "id": "1", "body": "Body 1" }, "2": { "id": "2", "body": "Body 2" } }
  },
  "associations": {
    "userComments": { "1": [ "2", "1" ] }
  },
  "result": [ "1" ]
}
```

You can populate response with `normalize` and `populate` function.

**Note: `normalize` dynamically formats a json, so each props in `entities` and `associations` should be `Maybe`.**

```purescript
type Response =
  { entities :: { user :: Maybe (ObjectMap UserId User), comment :: Maybe (ObjectMap CommentId Comment) }
  , associations :: { userComments :: Maybe (ObjectMap UserId (Array CommentId)) }
  , result :: Array UserId
  }

fetchUsers = do
  res <- lift $ API.get "/users" -- res is Foreign.
  case normalize res of -- reformat and decode.
    Left _ -> doSomething
    Right (res' :: Response) ->
      reduce $ populate res' >>> _ { home { users = res'.result } }
```

## How to select data used in views

Selecter helpers are in `Identy.Selector` module.

I explain using the following state:

```purescript
import Data.Newtype (class Newtype)
import Identy.ObjectMap (ObjectMap)
import Simple.JSON (class ReadForeign)

newtype UserId = UserId String
newtype TeamId = TeamId String
newtype CommentId = CommentId String

derive newtype instance readForeignUserId :: ReadForeign UserId
derive newtype instance readForeignTeamId :: ReadForeign TeamId
derive newtype instance readForeignCommentId :: ReadForeign CommentId

derive instance newtypeUserId :: Newtype UserId _
derive instance newtypeTeamId :: Newtype TeamId _
derive instance newtypeCommentId :: Newtype CommentId _

type User =
  { id :: UserId
  , name :: String
  }

type Comment =
  { id :: CommentId
  , body :: String
  }

type Team =
  { id :: TeamId
  , name :: String
  }

-- keys are id, values are entity.
type Entities =
  { user :: ObjectMap UserId User
  , comment :: ObjectMap CommentId Comment
  , team :: ObjectMap TeamId Team
  }

type Associations =
  { userComments :: ObjectMap UserId (Array CommentId)
  , userTeam :: ObjectMap UserId TeamId
  }

-- The identy-style state shape
type State =
  { entities :: Entities
  , associations :: Associations
  , home :: { users :: Array UserId, selectedUser :: Maybe UserId }
  }
```

### Select users for home view

Use `resources` function.

Example:

```purescript
users :: State -> Array User
users state =
  resources
    state.entities.user
    state.home.users
```

### Select selected-user for home view

Use `resource` function.

Example:

```purescript
selectedUser :: State -> Maybe User
selectedUser state =
  resource
    state.entities.user
    state.home.selectedUser
```

### Select association: Comments of user

Use `assocs` function.

Example:

```purescript
userComments :: UserId -> State -> Array Comment
userComments userId state =
  assocs
    state.entities.comment
    state.associations.userComments
    (Just userId)
```

### Select association: A team of user

Use `assoc` function.

Example:

```purescript
userTeam :: UserId -> State -> Maybe Team
userTeam userId state =
  assoc
    state.entities.team
    state.associations.userTeam
    (Just userId)
```
