module Main exposing (main)

import Html
import Rdf
import Rdf.Graph
import Rdf.Graph.Decode


main =
    let
        result =
            userInfoResponse
                |> normaliseWithBase "self"
                |> Rdf.Graph.parse
    in
    case result of
        Err e ->
            Rdf.Graph.errorToString userInfoResponse e
                |> Html.text
                |> List.singleton
                |> Html.pre []

        Ok g ->
            Rdf.Graph.serializeTurtle g
                |> Html.text
                |> List.singleton
                |> Html.pre []


normaliseWithBase base turtle =
    turtle
        |> ensureBase base
        |> normalise


normalise turtle =
    turtle
        |> String.lines
        |> List.map ensureWhitespaceBeforeFullStop
        |> String.join "\n"


ensureBase base turtle =
    if String.contains "@base" turtle then
        turtle

    else
        "@base <" ++ base ++ "> .\n" ++ turtle


ensureWhitespaceBeforeFullStop line =
    if String.endsWith " ." line then
        line

    else if String.endsWith "." line then
        String.dropRight 1 line ++ " ."

    else
        line


userInfoResponse =
    """
@prefix foaf: <http://xmlns.com/foaf/0.1/>.
@prefix solid: <http://www.w3.org/ns/solid/terms#>.

<>
    a foaf:PersonalProfileDocument ;
    foaf:maker <https://pods.solidcommunity.au/your_name/profile/card#me> ;
    foaf:primaryTopic <https://pods.solidcommunity.au/your_name/profile/card#me> .
<https://pods.solidcommunity.au/your_name/profile/card#me>
    solid:oidcIssuer <https://pods.solidcommunity.au/>;
    a foaf:Person.
"""
