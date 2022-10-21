module Css exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (style)


headerStyle : List (Attribute msg)
headerStyle =
    [ style "width" "100%"
    , style "height" "100px"
    , style "color" "black"
    , style "border-bottom" "solid 1px gray"
    ]


headerTitleStyle : List (Attribute msg)
headerTitleStyle =
    [ style "margin" "auto"
    , style "padding" "20px"
    , style "text-align" "center"
    ]


formStyle : List (Attribute msg)
formStyle =
    [ style "text-align" "right"
    ]


inputStyle : List (Attribute msg)
inputStyle =
    [ style "width" "75%"
    , style "font-size" "18px"
    ]


updateStyle : List (Attribute msg)
updateStyle =
    [ style "width" "68%"
    , style "font-size" "18px"
    ]


submitButtonStyle : List (Attribute msg)
submitButtonStyle =
    [ style "font-size" "18px" ]


todoListContainerStyle : List (Attribute msg)
todoListContainerStyle =
    [ style "width" "400px"
    , style "height" "auto"
    , style "background-color" "#db7093"
    , style "padding" "20px 40px"
    , style "margin" "auto"
    , style "margin-top" "50px"
    , style "border-radius" "10px"
    , style "box-shadow" "1px 0 5px 1px #999"
    ]


todoListStyle : List (Attribute msg)
todoListStyle =
    [ style "width" "auto"
    , style "list-style" "none"
    , style "background-color" "white"
    , style "padding" "20px 40px"
    , style "border-radius" "10px"
    ]


todoStyle : ( Attribute msg, Attribute msg ) -> List (Attribute msg)
todoStyle ( backgroundColor, textDecoration ) =
    [ style "width" "100%"
    , style "background-color" "lightblue"
    , style "margin-bottom" "10px"
    , style "padding-top" "5px"
    , style "border-radius" "5px"
    , style "box-shadow" "1px 0 1px 1px #999"
    , backgroundColor
    , textDecoration
    ]


todoButtonStyle : List (Attribute msg)
todoButtonStyle =
    [ style "width" "calc(100% / 3)" ]
