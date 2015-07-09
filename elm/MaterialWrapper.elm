module MaterialWrapper (btn_ripple, title_bar, TitleLink) where
import Html exposing (..)
import List exposing (head, tail, map)
import Html.Attributes exposing (..) 
import Html.Lazy exposing (lazy)

header = node "header"
main_tag = node "main"
spacer = div [class "mdl-layout-spacer"] []

type alias TagNoAtrr =
    List Html -> Html 

type alias Tag =
    List Attribute -> List Html -> Html

root_ : TagNoAtrr
root_ html = div [class "mdl-layout mdl-js-layout mdl-layout--fixed-header"] html

header_ : TagNoAtrr
header_ html = div [class "mdl-layout__header"] html

header_row_ : TagNoAtrr
header_row_ html = div [class "mdl-layout__header-row"] html

title_ : TagNoAtrr
title_ html = span [class "mdl-layout-title"] html

navigation_ : TagNoAtrr
navigation_ html = div [class "mdl-navigation"] html

navigation_link_ : Tag
navigation_link_ attr html = a ([class "mdl-navigation__link"] ++ attr) html

drawer_ : TagNoAtrr
drawer_ html = div [class "mdl-layout__drawer"] html

content_ : TagNoAtrr
content_ html = div [class "mdl-layout__content"] html

{-| NAVIGATION BAR |-}

type alias TitleLink =
    (List Attribute, List Html)

nav_links : List TitleLink -> List Html
nav_links titlelinks = map nav_link titlelinks

nav_link : TitleLink -> Html
nav_link titlelink = navigation_link_ (fst titlelink) (snd titlelink) 

{-| Title -> List (Action, LinkName) -> Content  |-}
title_bar : String -> List TitleLink -> List Html -> Html
title_bar title navigation content = 
    root_
    [ header_
        [ header_row_
            [ title_ [text title]
            , navigation_
                (nav_links navigation)
            ]
        ]
    , content_ content
    ]


{-| BUTTONS |-}
btn_ripple_class = [class "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect"]

btn_ripple : Tag
btn_ripple attr html = button (attr ++ btn_ripple_class) html