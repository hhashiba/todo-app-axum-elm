module Todo exposing (..)

import Json.Decode as Decode exposing (Decoder, bool, int, list, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode


type alias Todo =
    { id : Int
    , text : String
    , completed : Bool
    }


initialTodo : Todo
initialTodo =
    { id = 0, text = "", completed = False }


todosDecoder : Decoder (List Todo)
todosDecoder =
    list todoDecoder


todoDecoder : Decoder Todo
todoDecoder =
    Decode.succeed Todo
        |> required "id" int
        |> required "text" string
        |> required "completed" bool


createEncoder : String -> Encode.Value
createEncoder text =
    Encode.object
        [ ( "text", Encode.string text ) ]


updateEncoder : String -> Bool -> Encode.Value
updateEncoder text completed =
    Encode.object
        [ ( "text", Encode.string text )
        , ( "completed", Encode.bool completed )
        ]


setText : Todo -> String -> Todo
setText todo text =
    { id = todo.id
    , text = text
    , completed = todo.completed
    }
