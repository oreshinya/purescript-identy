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

**NOTE: The identy-style state shape force to treat id as string.**

Like this:

```purescript
type User =
  { id :: String
  , name :: String
  }

type Comment =
  { id :: String
  , body :: String
  }

type Team =
  { id :: String
  , name :: String
  }

-- keys are id, values are entity.
type Entities =
  { user :: Object User
  , comment :: Object Comment
  , team :: Object Team
  }

type Associations =
  { userComments :: Object (Array String) -- keys are user id, values are array of comment id.
  , userTeam :: Object String -- keys are user id, values are team id.
  }

-- State per UI
type Scenes =
  { home :: { users :: Array String } -- UI state for home scene. users are array of user id. this is an example.
  }

-- The identy-style state shape
type State =
  { entities :: Entities
  , associations :: Associations
  , scenes :: Scenes
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
fetchUsers = do
  res <- lift $ API.get "/users" -- res is decoded already.
  reduce $ populate res >>> _ { scenes { home { users = res.result } } }
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

It is `normalize` function in `Identy.Normalizer`.

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

```purescript
fetchUsers = do
  res <- lift $ API.get "/users" -- res is Foreign.
  case normalize res of -- reformat and decode.
    Left _ -> doSomething
    Right res' ->
      reduce $ populate res' >>> _ { scenes { home { users = res'.result } } }
```

## How to select data used in views

Selecter helpers are in `Identy.Selector` module.

I explain using the following state:

```purescript
type User =
  { id :: String
  , name :: String
  }

type Comment =
  { id :: String
  , body :: String
  }

type Team =
  { id :: String
  , name :: String
  }

type Entities =
  { user :: Object User
  , comment :: Object Comment
  , team :: Object Team
  }

type Associations =
  { userComments :: Object (Array String)
  , userTeam :: Object String
  }

type Scenes =
  { home :: { users :: Array String, selectedUser :: Maybe String }
  }

type State =
  { entities :: Entities
  , associations :: Associations
  , scenes :: Scenes
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
    state.scenes.home.users
```

### Select selected-user for home view

Use `resource` function.

Example:

```purescript
selectedUser :: State -> Maybe User
selectedUser state =
  resource
    state.entities.user
    state.scenes.home.selectedUser
```

### Select association: Comments of user

Use `assocs` function.

Example:

```purescript
userComments :: String -> State -> Array Comment
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
userTeam :: String -> State -> Maybe Team
userTeam userId state =
  assoc
    state.entities.team
    state.associations.userTeam
    (Just userId)
```
