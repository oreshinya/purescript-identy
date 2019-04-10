# Philosophy

This document explains basic idea of `purescript-identy`.

It is very important for building a complex application in the real world.

## State management in `purescript-freedom`

In `purescript-freedom`, whole of app state is managed in one data type.

Like this:

```purescript
{ users:
    [ { id: "1", name: "Foo" }
    , { id: "2", name: "Bar" }
    ]
, comments:
    [ { id: "1", body: "Hello :)" }
    , { id: "2", body: "Hi !" }
    ]
}
```

In a complex application, what shape should we have state?

From now, this document will explain them.

## Situation

Please imagine the following application.

- Display all tasks as main contents
- Display my tasks as sub contents
- Users can make status "done" a task, and its task is drawn horizontal line.

And the type of `Task` is the following:

```purescript
type Task =
  { id :: String
  , name :: String
  , done :: Boolean
  }
```

### Try state shape 1

If you don't think about anything, the state shape probably looks like this.

```purescript
type State =
  { allTasks :: Array Task
  , myTasks :: Array Task
  }
```

At first glance it looks simple and good approach, but there is a problem.

> Users can make status "done" a task, and its task is drawn horizontal line.

There may be same tasks in `allTasks` and `myTasks`, so you may need to update both.

This seems to have to be solved.

### Try state shape 2

Next, let's consider state shape without duplicates.

Stop having `myTasks` in an array, you will guess we should get it like this:

```purescript
filter (_ == myId) state.allTasks
```

So the state shape is the following:

```purescript
type State =
  { tasks :: Array Task
  }
```

Or you may do like this:

```purescript
type State =
  { tasks :: Object Task -- Keys of object are task id.
  }
```

In this way, it seems that we can guarantee the consistency of data changes.

Looks like a great idea.

But wait, it has problems.

We should consider with a wider perspective.

In this case, it seems that this is good because the example is simple.

But actually, when changing the condition for the same data source and displaying it, data is filtered in server side in the first place, right?

It seems useless that data is filtered in both server and clients, doesn't it?

Such as the above twice implementation will increase.

Also if there are many tasks in state, the cost of filtering will be large.

So this approach has advantage for consistency of data, but it requires a lot of implementation, also it is prone to performance degradation.

Umm...

What should we do?

Please read next section ;)

### State shape final

This is one of the answer.

```purescript
type State =
  { tasks :: Object Task
  , allTasks :: Array String
  , myTasks :: Array String
  }
```

The first point is that tasks are stored in object with ids as keys.

You can imagine that this way of holding data is very strong against updates.
You just update it by id.

But tasks are not directly linked with UI.

Therefore we use `allTasks` and `myTasks` as links with UI.

These mean linking with what UI, which tasks and what order.

A lot of implemantion are not needed, because you can store filtered and ordered data (from server) to `allTasks` and `myTasks`.

In other words, **this approach is a method in which entity itself is not directly linked, but it represents binding to UI or another entity through id**.

This approach is not new, it is mentioned in `redux` doc and also it is adopted for inner state of `apollo-client`, and so on.

## With `purescript-identy`

`purescript-identy` is based on the above idea.

It expects the following state shape.

You will get tolerance to complex UI by this state shape.

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
  { home :: { users :: Array String } -- UI state for home scene. users are array of user id.
  }

-- The identy-style state shape
type State =
  { entities :: Entities
  , associations :: Associations
  , scenes :: Scenes
  }
```
