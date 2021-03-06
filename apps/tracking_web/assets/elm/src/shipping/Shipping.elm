module Shipping exposing (..)

{--
The Shipping module is responsible for handling all requests and response to
and from the Shipping server. Its model contains the results from these requests.

There is no UI component is this module.

It is dependent on the Cargo, HandlingEvent and Rest modules.
--}

import Cargo as C
import HandlingEvent as HE
import Rest


type alias Model =
    { cargo : Maybe C.Cargo
    , handlingEvents : List HE.HandlingEvent
    , serverMessage : Maybe String
    , restMessage : Maybe String
    }


initModel =
    { cargo = Nothing
    , handlingEvents = []
    , serverMessage = Nothing
    , restMessage = Nothing
    }


type Msg
    = FindCargo String
    | FindHandlingEvents
    | RestMsg Rest.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FindCargo trackingId ->
            ( model, Cmd.map RestMsg (Rest.findCargo trackingId) )

        FindHandlingEvents ->
            ( model, Cmd.map RestMsg (Rest.getAllHandlingEvents) )

        RestMsg (Rest.ReceivedCargo response) ->
            case response of
                C.CargoFound cargo ->
                    ( { model
                        | cargo = Just cargo
                        , handlingEvents = []
                        , serverMessage = Nothing
                        , restMessage = Nothing
                      }
                    , Cmd.none
                    )

                C.CargoNotFound serverMessage ->
                    ( { model
                        | cargo = Nothing
                        , handlingEvents = []
                        , serverMessage = Just serverMessage
                        , restMessage = Nothing
                      }
                    , Cmd.none
                    )

        RestMsg (Rest.ReceivedAllHandlingEvents handlingEventList) ->
            ( { model
                | handlingEvents = handlingEventList.handling_events
                , serverMessage =
                    Just
                        ("Found "
                            ++ toString (List.length handlingEventList.handling_events)
                            ++ " Handling Events."
                        )
              }
            , Cmd.none
            )

        RestMsg (Rest.HttpError restMessage) ->
            ( { model
                | cargo = Nothing
                , handlingEvents = []
                , serverMessage = Nothing
                , restMessage = Just restMessage
              }
            , Cmd.none
            )
