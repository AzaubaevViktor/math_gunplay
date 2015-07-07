import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Events exposing (onClick)
import StartApp

main =
  StartApp.start { model = model, view = view, update = update }

model = 0

btn_ripple_class = "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect"

view address model =
  div []
    [ button [ onClick address Decrement, class btn_ripple_class] [ text "-" ]
    , h1 [] [ text (toString model) ]
    , button [ onClick address Increment, class btn_ripple_class ] [ text "+" ]
    ]


type Action = Increment | Decrement

update action model =
  case action of
    Increment -> model + 1
    Decrement -> model - 1