module Player (ID, Damage, Health, Level, Action, Model, init, update, view) where

import Html exposing (..)
import Signal exposing (Address)

inside_cut : comparable -> ( comparable, comparable ) -> comparable
inside_cut val (a, b) 
    = if val < a 
        then a 
        else if val > b
            then b
            else val

inside01 : comparable -> comparable
inside01 val = inside_cut val (0, 1)

type alias ID =
    Int

type alias Damage =
    Int

type alias Health = 
    Int

type Level 
    = Square
    | Hospital
    | Resuscitation
    | Morgue

type Action 
    = NewPlayer ID String
    | Solve
    | Unsolve
    | Treat Int Health
    | Damage Damage
    | Penalty

type alias Model = 
    { id : ID
    , isAlive : Bool
    , health : Health
    , level : Level
    , solved : Int
    , unsolved : Int
    , treatment : Int
    , penalties : Int
    , name : String
    }


init : ID -> String -> Model
init id player_name = 
    { id = id
    , isAlive = True
    , health = 1
    , level = Square
    , solved = 0
    , unsolved = 0
    , treatment = 0
    , penalties = 0
    , name = player_name
    }

update : Action -> Model -> Model
update action model =
    case action of
        NewPlayer id name -> init id name

        Solve -> { model | solved <- model.solved + 1 }

        Unsolve -> { model | unsolved <- model.unsolved + 1 }

        Treat tasks healthInc -> 
            { model |
                solved <- model.solved + tasks,
                unsolved <- model.unsolved + 3 - tasks,
                health <- inside01 model.health + healthInc,
                isAlive <- model.health + healthInc > 0
            }

        Damage damage ->
            { model |
                health <- inside01 model.health - damage,
                isAlive <- model.health - damage> 0
            }

        Penalty ->
            { model | penalties <- model.penalties + 1}

view : Address Action -> Model -> Html
view address model =
    div
    []
    [ text (toString model.id ++ toString model.name) 
    ]