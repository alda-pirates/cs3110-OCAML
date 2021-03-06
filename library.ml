open Yojson.Basic.Util

type library_name = string
type track_title = string
type album_title = string
type artist_name = string

type album = {
  title : album_title;
  tracks : track_title list
}

type artist = {
  name : artist_name;
  albums : album list
}

type t = {
  lib_name : library_name;
  artists : artist list;
}

exception UnknownTrack of track_title 
exception UnknownAlbum of album_title 
exception UnknownArtist of artist_name

(** [load_album json] create [album] objects based on the contents of
    [json]. *)
let load_album json = {
  title = json |> member "title" |> to_string;
  tracks = json |> member "tracks" |> to_list |> List.map to_string;
}

(** [load_artist json] create [artist] objects based on the contents of
    [json]. *)
let load_artist json = {
  name = json |> member "name" |> to_string; 
  albums = json |> member "albums" |> to_list |> List.map load_album;
}

(** [load_library json] create [Library.t] objects based on the contents of
    [json]. *)
let load_library json = {
  lib_name = json |> member "lib_name" |> to_string;
  artists = json |> member "artists" |> to_list |> List.map load_artist;
}

let list_artists t = t.artists

let list_albums t = list_artists t |> List.map (fun x -> x.albums)
                    |> List.flatten

let list_tracks t = list_albums t |> List.map (fun x -> x.tracks)
                    |> List.flatten

let get_artist artist t =
  try (List.hd (List.filter (fun x -> x.name = artist) t.artists))
  with Failure s -> raise (UnknownArtist artist)

let get_album artist album t =
  try (List.hd (List.filter (fun x -> x.title = album) (get_artist artist t)
                                                       .albums))
  with Failure s -> raise (UnknownAlbum album)

let get_artist_path artist t = 
  t.lib_name ^ "/" ^ artist

let get_album_path artist album t =
  get_artist_path artist t ^ "/" ^ album

let get_track_path artist album track t =
  get_album_path artist album t ^ "/" ^ track
