module Identy.Normalizer
  ( normalize
  ) where

import Prelude

import Data.Either (Either(..))
import Data.Function.Uncurried (Fn3, runFn3)
import Data.List.NonEmpty (singleton)
import Foreign (Foreign, ForeignError(..))
import Simple.JSON (class ReadForeign, E, read)

-- | Normalize nested entity to identy-style, then decode normalized foreign.
-- |
-- | **When should you use this ?**
-- |
-- | API in the world often respond nested-style object like this:
-- |
-- | ```
-- | {
-- |   "id": "1",
-- |   "name": "User Name",
-- |   "comments": [
-- |     { "id": "2", "body": "Comment Body 2" },
-- |     { "id": "1", "body": "Comment Body 1" }
-- |   ]
-- | }
-- | ```
-- |
-- | `normalize` formats object from nested-style to identy-style.
-- |
-- | ```
-- | {
-- |   "entities": {
-- |     "user": { "1": { "id": "1", "name": "User Name" } },
-- |     "comment": { "1": { "id": "1", "body": "Comment Body 1" }, "2": { "id": "2", "body": "Comment Body 2" } }
-- |   },
-- |   "associations": {
-- |     "userComments": { "1": [ "2", "1" ] } // from parent user id to comment ids.
-- |   },
-- |   "result": "1" // This is root entity id. In this case, user id.
-- | }
-- | ```
-- |
-- | `result` has root entity id. Therefore, if a response is single entity, `result` is an id of its entity, if a response is array of entity, `result` is ids of entities.
-- |
-- | **Prerequisite:**
-- |
-- | Each entity need a property `typename` that is set type name with upper camel case.
-- |
-- | For example:
-- |
-- | ```
-- | {
-- |   "id": "1",
-- |   "name": "User Name",
-- |   "typename": "User"
-- |   "comments": [
-- |     { "id": "2", "body": "Comment Body 2", "typename": "Comment" },
-- |     { "id": "1", "body": "Comment Body 1", "typename": "Comment" }
-- |   ]
-- | }
-- | ```
-- |
-- | **Note:**
-- |
-- | Essentially, such formatting for clients is the work of API server.
-- |
-- | If it's possible, receive identy-style JSON directly from API server.
normalize :: forall a. ReadForeign a => Foreign -> E a
normalize x =
  case runFn3 normalize_ Left Right x of
    Left msg -> Left $ singleton $ ForeignError msg
    Right x' -> read x'

foreign import normalize_
  :: Fn3 (String -> Either String Foreign) (Foreign -> Either String Foreign) Foreign (Either String Foreign)
