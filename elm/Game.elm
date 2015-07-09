import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Events exposing (onClick)
import StartApp

import MaterialWrapper exposing (TitleLink, title_bar)

main =
  StartApp.start { model = model, view = view, update = update }

model = 0

--titlelinks :  List TitleLink
titlelinks address = 
    [ ([onClick address Increment, class "mdl-button"], [text "+"])
    , ([style [("background-color", "#bbb")]], [text (toString model)])
    , ([onClick address Decrement], [text "-"])
    ]

view address model =
    title_bar "Test" (titlelinks address) [div [] [text "Blya"]]


type Action = Increment | Decrement

update action model =
    case action of
        Increment -> model + 1
        Decrement -> model - 1