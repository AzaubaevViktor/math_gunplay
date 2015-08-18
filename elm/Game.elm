import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Events exposing (onClick)
import Html.Lazy exposing (lazy2)
import StartApp
import Signal exposing (Address)
import Json.Decode as Json
import String

import Player

main =
  StartApp.start { model = model, view = view, update = update }

type alias Model =
    { nextID : Player.ID
    , players : List(Player.ID, Player.Model)
    , newName : String
    }

model : Model
model = 
    { nextID = 0
    , players = []
    , newName = ""
    }

type Action
    = UpdateField String
    | Add
    | Modify Player.ID Player.Action

update : Action -> Model -> Model
update action model =
    case action of
        UpdateField str ->
            { model | newName <- str }

        Add ->
            { model | 
                nextID <- model.nextID + 1,
                newName <- "",
                players <-
                    if String.isEmpty model.newName
                        then model.players
                        else model.players ++ [Player.init model.nextID model.newName]                        
            }

        Modify id playerAction ->
            let playerCounter (playerID, playerModel) =
                if playerID == id
                    then (playerID, Player.update playerAction playerModel)
                    else (playerID, playerModel)
            in
              { model | players <- List.map playerCounter model.players }

onEnter : Address a -> a -> Attribute
onEnter address value =
    on "keydown"
      (Json.customDecoder keyCode is13)
      (\_ -> Signal.message address value)


is13 : Int -> Result String ()
is13 code =
  if code == 13 then Ok () else Err "not the right key code"

newPlayerField : Address Action -> String -> Html
newPlayerField address newName =
    header
      [ id "header" ]
      [ input
          [ id "new-player"
          , placeholder "Имя нового игрока"
          , autofocus True
          , value newName
          , name "newPlayer"
          , on "input" targetValue (Signal.message address << UpdateField)
          , onEnter address Add
          ]
          []
      ]

playerList : Address Player.Action -> List (Player.Model) -> Html
playerList address players =
    div
    []
    (List.map (Player.view address) players) 
    

view : Address Action -> Model -> Html
view address model =
    div 
    []
    [ lazy2 newPlayerField address model.newName
    , lazy2 playerList address model.players
    ]