module Main exposing (main)

import Browser
import Css exposing (..)
import Html exposing (Html, button, div, h1, h2, input, li, strong, text, ul)
import Html.Attributes exposing (disabled, id, style, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import RemoteData exposing (WebData)
import Todo exposing (..)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


dbUrl : String
dbUrl =
    "http://localhost:3000/todos"


type alias Model =
    { input : String
    , updateTodoInfo : Todo
    , todos : WebData (List Todo)
    , crudErr : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel
    , fetchTodos
    )


initialModel : Model
initialModel =
    { input = ""
    , updateTodoInfo = initialTodo
    , todos = RemoteData.Loading
    , crudErr = ""
    }


type Msg
    = TodosReceived (WebData (List Todo))
    | InputText String
    | UpdateText String
    | CreateTodo
    | TodoCreated (Result Http.Error Todo)
    | CompleteTodo Todo
    | EditTodo Todo
    | UpdateTodo Todo
    | TodoEdited (Result Http.Error Todo)
    | DeleteTodo Int
    | TodoDeleted (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TodosReceived response ->
            ( { model | todos = response }, Cmd.none )

        InputText text ->
            ( { model | input = text }, Cmd.none )

        UpdateText text ->
            ( { model | updateTodoInfo = setText model.updateTodoInfo text }, Cmd.none )

        CreateTodo ->
            ( { model | input = "" }, createTodo model.input )

        TodoCreated (Ok _) ->
            ( model, fetchTodos )

        TodoCreated (Err httpError) ->
            ( { model | crudErr = buildErrorMessage httpError }, Cmd.none )

        CompleteTodo todo ->
            ( model, completeTodo todo )

        EditTodo todo ->
            ( { model | updateTodoInfo = todo }, Cmd.none )

        UpdateTodo todo ->
            ( { model | input = "", updateTodoInfo = initialTodo }, updateTodo todo )

        TodoEdited (Ok _) ->
            ( model, fetchTodos )

        TodoEdited (Err httpError) ->
            ( { model | crudErr = buildErrorMessage httpError }, Cmd.none )

        DeleteTodo id ->
            ( model, deleteTodo id )

        TodoDeleted (Ok _) ->
            ( model, fetchTodos )

        TodoDeleted (Err httpError) ->
            ( { model | crudErr = buildErrorMessage httpError }, Cmd.none )


fetchTodos : Cmd Msg
fetchTodos =
    Http.get
        { url = dbUrl
        , expect =
            todosDecoder
                |> Http.expectJson (RemoteData.fromResult >> TodosReceived)
        }


createTodo : String -> Cmd Msg
createTodo text =
    Http.post
        { url = dbUrl
        , body = Http.jsonBody (createEncoder text)
        , expect = Http.expectJson TodoCreated todoDecoder
        }


completeTodo : Todo -> Cmd Msg
completeTodo todo =
    Http.request
        { method = "PATCH"
        , headers = []
        , url = dbUrl ++ "/" ++ String.fromInt todo.id
        , body = Http.jsonBody (updateEncoder todo.text (not todo.completed))
        , expect = Http.expectJson TodoEdited todoDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


updateTodo : Todo -> Cmd Msg
updateTodo todo =
    Http.request
        { method = "PATCH"
        , headers = []
        , url = dbUrl ++ "/" ++ String.fromInt todo.id
        , body = Http.jsonBody (updateEncoder todo.text todo.completed)
        , expect = Http.expectJson TodoEdited todoDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


deleteTodo : Int -> Cmd Msg
deleteTodo id =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = dbUrl ++ "/" ++ String.fromInt id
        , body = Http.emptyBody
        , expect = Http.expectString TodoDeleted
        , timeout = Nothing
        , tracker = Nothing
        }


view : Model -> Html Msg
view model =
    let
        content =
            case model.crudErr of
                "" ->
                    viewBody model

                _ ->
                    text model.crudErr
    in
    div []
        [ viewHeader
        , content
        ]


viewHeader : Html Msg
viewHeader =
    div
        headerStyle
        [ h1
            headerTitleStyle
            [ text
                "Todo App"
            ]
        ]


viewBody : Model -> Html Msg
viewBody model =
    case model.todos of
        RemoteData.Loading ->
            h2 [] [ text "Loading.." ]

        RemoteData.Success payload ->
            div
                todoListContainerStyle
                [ inputTodo model.input model.updateTodoInfo
                , ul
                    todoListStyle
                    (viewTodos payload)
                ]

        RemoteData.NotAsked ->
            text "NotAsked!!"

        RemoteData.Failure httpError ->
            text (buildErrorMessage httpError)


inputTodo : String -> Todo -> Html Msg
inputTodo currentInput todo =
    if todo == initialTodo then
        Html.form
            (onSubmit CreateTodo :: formStyle)
            [ input ([ value currentInput, onInput InputText ] ++ inputStyle) []
            , button
                (disabled (String.length currentInput < 1 || String.length currentInput > 20)
                    :: submitButtonStyle
                )
                [ text "NewTodo" ]
            ]

    else
        Html.form
            (onSubmit (UpdateTodo todo) :: formStyle)
            [ input ([ value todo.text, onInput UpdateText ] ++ updateStyle) []
            , button
                (disabled (String.length todo.text < 1 || String.length todo.text > 20)
                    :: submitButtonStyle
                )
                [ text "UpdateTodo" ]
            ]


viewTodos : List Todo -> List (Html Msg)
viewTodos todos =
    List.map viewTodo todos


viewTodo : Todo -> Html Msg
viewTodo todo =
    let
        ( bgColor, decoration ) =
            if todo.completed == False then
                ( style "background-color" "lightblue", style "text-decoration" "none" )

            else
                ( style "background-color" "gray", style "text-decoration" "line-through" )
    in
    li (todoStyle ( bgColor, decoration ))
        [ strong [ style "padding-left" "20px" ] [ text todo.text ]
        , div [ style "width" "100%" ]
            [ todoButton "Complete" (CompleteTodo todo)
            , todoButton "Edit" (EditTodo todo)
            , todoButton "Delete" (DeleteTodo todo.id)
            ]
        ]


todoButton : String -> Msg -> Html Msg
todoButton label msg =
    button
        (onClick msg :: todoButtonStyle)
        [ strong [] [ text label ] ]


buildErrorMessage : Http.Error -> String
buildErrorMessage httpError =
    case httpError of
        Http.BadUrl message ->
            message

        Http.Timeout ->
            "Sever is taking too long to respond. Please try again later."

        Http.NetworkError ->
            "Unable to reach the server"

        Http.BadStatus statusCode ->
            "Request failed with status code : " ++ String.fromInt statusCode

        Http.BadBody message ->
            message
