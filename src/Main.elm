module Main exposing (..)

import Html exposing (..)
import Http
import Json.Decode exposing (..)


--import Html.Attributes exposing (..)
--import Html.Events exposing (onClick)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { authData : AuthResponse
    , error : String
    }


initialModel : Model
initialModel =
    { authData = AuthResponse "" ""
    , error = ""
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, auth "https://niu.moe" )



-- UPDATE


type Msg
    = Authorized (Result Http.Error AuthResponse)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Authorized (Ok authData) ->
            ( { model | authData = authData }, Cmd.none )

        Authorized (Err err) ->
            ( { model | error = (toString err) }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ code [] [ text (toString model) ]
        , div []
            []
        ]



-- MASTODON


type alias AuthResponse =
    { client_id : String
    , client_secret : String
    }


authResponseDecoder : Decoder AuthResponse
authResponseDecoder =
    map2 AuthResponse (field "client_id" string) (field "client_secret" string)


client_name : String
client_name =
    "Helm for Mastodon (v0.1)s"


redirect_uris : String
redirect_uris =
    "urn:ietf:wg:oauth:2.0:oob"


scopes : String
scopes =
    "read"


auth : String -> Cmd Msg
auth baseUrl =
    let
        registerUrl =
            baseUrl ++ "/api/v1/apps"

        body =
            Http.multipartBody
                [ Http.stringPart "client_name" client_name
                , Http.stringPart "redirect_uris" redirect_uris
                , Http.stringPart "scopes" scopes
                ]

        post =
            Http.post registerUrl body authResponseDecoder
    in
        Http.send Authorized post
