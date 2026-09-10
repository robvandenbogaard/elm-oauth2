module Main exposing (main)

import Html
import Rdf
import Rdf.Decode
import Rdf.Graph


type alias UserInfo =
    { topic : Rdf.Iri
    , issuer : Rdf.Iri
    }


self =
    Rdf.iri "self"


foaf name =
    Rdf.iri ("http://xmlns.com/foaf/0.1/" ++ name)


solid name =
    Rdf.iri ("http://www.w3.org/ns/solid/terms#" ++ name)


main =
    let
        result =
            userInfoResponse
                |> Rdf.Graph.fromTurtleWith Rdf.initialSeed self
                |> Result.map Tuple.first

        data =
            result
                |> Result.withDefault Rdf.Graph.empty
                |> Rdf.Graph.decode userInfoDecoder
    in
    case data of
        Ok d ->
            d
                |> Debug.toString
                |> Html.text
                |> List.singleton
                |> Html.pre []

        Err de ->
            [ Rdf.Decode.errorToString de
            , case result of
                Err e ->
                    Rdf.Graph.errorToString userInfoResponse e

                Ok g ->
                    Rdf.Graph.toTurtle g
            ]
                |> List.map Html.text
                |> Html.pre []


userInfoDecoder =
    Rdf.Decode.map2 UserInfo
        (Rdf.Decode.from (foaf "PersonalProfileDocument")
            (Rdf.Decode.property (Rdf.inverse Rdf.a)
                Rdf.Decode.iri
            )
        )
        (Rdf.Decode.from (foaf "Person")
            (Rdf.Decode.property (Rdf.inverse Rdf.a)
                (Rdf.Decode.property (solid "oidcIssuer")
                    Rdf.Decode.iri
                )
            )
        )


userInfoResponse =
    """
@prefix foaf: <http://xmlns.com/foaf/0.1/>.
@prefix solid: <http://www.w3.org/ns/solid/terms#>.

<>
    a foaf:PersonalProfileDocument;
    foaf:maker <https://pods.solidcommunity.au/your_name/profile/card#me>;
    foaf:primaryTopic <https://pods.solidcommunity.au/your_name/profile/card#me>.
<https://pods.solidcommunity.au/your_name/profile/card#me>
    solid:oidcIssuer <https://pods.solidcommunity.au/>;
    a foaf:Person.
"""
