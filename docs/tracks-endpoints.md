# Tracks API

This document describes the Tracks endpoints for both Admin and User APIs, aligned with the normalized schema that uses `track_artists` and `track_audios` tables.

Key points:
- Pagination is zero-based: page 0 is the first page. `limit` is capped at 100.
- Audio uploads generate variants and are stored in `track_audios` with fields: `ext`, `bitrate` (kbps), and `path` (URL).
- Artists linked to a track are exposed via `artists` array on responses (sourced from `track_artists`).
- Tracks do not have a cover image; use the album's `cover_url`.
- HLS: responses include a `hls` object with a public `master` m3u8 URL and per-quality variant m3u8 URLs when the HLS container is public.

## Common object shape

Track object (admin responses include more fields; user list is a smaller projection):

```
{
  "track_id": "uuid",
  "title": "string",
  "album_id": "uuid",
  "lyrics_url": "string|null",
  "duration": 215,              // seconds, integer >= 0
  "play_count": 0,
  "is_explicit": false,
  "likes_count": 0,
  "popularity_score": 0,
  "created_at": "ISO",
  "updated_at": "ISO",
  "video_url": "string|null",
  "is_published": true|false,
  "hls": {                     // public HLS URLs (container must be public)
    "master": "https://<account>.blob.core.windows.net/<container>/hls/track_<id>/master.m3u8",
    "variants": [
      { "bitrate": 96,  "url": "https://.../hls/track_<id>/v96/index.m3u8" },
      { "bitrate": 160, "url": "https://.../hls/track_<id>/v160/index.m3u8" },
      { "bitrate": 320, "url": "https://.../hls/track_<id>/v320/index.m3u8" }
    ]
  },
  "artists": [                  // joined via track_artists → artists → users
    {
      "artist_id": "uuid",
    }
  ],
  "audios": [                   // joined via track_audios (admin + user getById)
    { "id": number, "ext": "mp3|ogg", "bitrate": 96|160|320, "path": "https://...", "created_at": "ISO" }
  ]
}
```

Files supported on create/update (multipart/form-data):
- `audio` (binary) — triggers audio processing and sets `is_published=true` upon success
- `video` (video)

---

  ### POST /api/admin/tracks/:id/artists
  Link an artist to a track with a role.

  Body:
  ```
  { "artist_id": "<uuid>", "role": "owner|editor|viewer" }
  ```

  Response: `201 Created` with `{ track_id, artist_id, role, ... }`.

  ### PATCH /api/admin/tracks/:id/artists/:artistId
  Update a linked artist's role on a track.

  Body: `{ "role": "owner|editor|viewer" }`

  Response: `200 OK` with updated record.

  ### DELETE /api/admin/tracks/:id/artists/:artistId
  Unlink an artist from a track.

  Response: `204 No Content`.

## Admin API

Base path: `/api/admin/tracks`

### GET /api/admin/tracks
List tracks with pagination and optional search.

Query params:
- `page` number (default 0)
Response:
```
{
  "items": [Track],
  "total": number,
  "page": number,
  "limit": number
}
```

### GET /api/admin/tracks/:id
Fetch a single track by id.

Response: `Track`

### POST /api/admin/tracks
Create a new track.

- Content-Type: `multipart/form-data`
  ### POST /api/user/tracks/:id/artists
  Add an artist to your track. Only album owners may call this.

  Body:
  ```
  { "artist_id": "<uuid>", "role": "owner|editor|viewer" }
  ```

  Rules:
  - Only album owners can manage track artists.
  - Album owners are always role `owner` on tracks; attempts to add them with a different role are coerced to `owner`.

  Response: `201 Created`.

  ### PATCH /api/user/tracks/:id/artists/:artistId
  Change a linked artist's role on your track. Only album owners may call this.

  Rules:
  - You cannot change an album owner's role to anything other than `owner`.

  Body: `{ "role": "owner|editor|viewer" }`

  Response: `200 OK`.

  ### DELETE /api/user/tracks/:id/artists/:artistId
  Remove a linked artist from your track. Only album owners may call this.

  Rules:
  - You cannot remove album owners from a track.

  Response: `204 No Content`.

- Body (fields):
  - `title` string (required)
   - Roles semantics:
     - `owner`: Full control on the track including adding/removing artists and updating roles.
     - `editor`: Can edit track fields (title, lyrics_url, duration, is_explicit, is_published) but cannot manage artists.
     - `viewer`: No edit permissions.
     - All roles are still bounded by user-level permissions; system/admin-only fields remain restricted.
  - `is_published` boolean (optional; if `audio` is uploaded and processed successfully, it will be set to true regardless)
- Files: `audio` (required), `video` (optional)

Additional artist linking:
- Owners of the album (from `album_artists` with role `owner`) are automatically linked to the new track with role `owner`.
- Optionally include `artists` in the body as JSON or form-data array: `artists=[{ "artist_id": "<uuid>", "role": "viewer|editor|owner" }]`. Invalid or duplicate links are ignored.

Behavior:
- Creates the track with `is_published=false` initially.
- `album_id` is required for all tracks (including singles). `audio` is required.
- On success, audio variants are generated (mp3 at source bitrate and ogg at 96/160/320kbps up to source bitrate), inserted into `track_audios`, and `is_published=true` is set.
- If `video` provided, uploads and updates `video_url`.

Response: `201 Created` with `Track`.

### PATCH /api/admin/tracks/:id
Update an existing track.

- Content-Type: `multipart/form-data`
- Body (any of): `title`, `album_id`, `duration`, `lyrics_url`, `is_explicit`, `is_published`
- Files (optional): `audio`, `video`

Behavior:
- Updates provided fields.
- If `audio` is provided, replaces all prior `track_audios` rows with newly generated variants and sets `is_published=true`.
- If `video` is provided, uploads and updates `video_url`.

Response: `200 OK` with updated `Track`.

### DELETE /api/admin/tracks/:id
Delete a track and its associated audio rows.

Behavior:
- Removes any `track_audios` entries for the track.
- Removes the track row.
- Video objects are deleted via storage helpers when present.

Response: `204 No Content`.

---

## User API

Base path: `/api/user/tracks`

### GET /api/user/tracks
List published tracks with pagination and optional search.

Query params:
- `page` number (default 0)
- `limit` number (default 20, max 100)
- `q` string (optional)

Response:
```
{
  "items": [
    {
      "track_id": "uuid",
      "title": "string",
      "duration": number,
      "created_at": "ISO",
      "hls": {
        "master": "https://.../hls/track_<id>/master.m3u8",
        "variants": [ { "bitrate": 96, "url": "https://.../v96/index.m3u8" }, { "bitrate": 160, "url": "https://.../v160/index.m3u8" }, { "bitrate": 320, "url": "https://.../v320/index.m3u8" } ]
      },
      "artists": [ { "artist_id": "uuid", "name": "string", "avatar_url": "string|null" } ]
    }
  ],
  "total": number,
  "page": number,
  "limit": number
}
```

### GET /api/user/tracks/:id
Fetch a single published track, including available audio variants.

Response:
```
{
  "track_id": "uuid",
  "title": "string",
  "album_id": "uuid",
  "duration": number,
  "play_count": number,
  "is_explicit": boolean,
  "likes_count": number,
  "created_at": "ISO",
  "hls": {
    "master": "https://.../hls/track_<id>/master.m3u8",
    "variants": [ { "bitrate": 96, "url": "https://.../v96/index.m3u8" }, { "bitrate": 160, "url": "https://.../v160/index.m3u8" }, { "bitrate": 320, "url": "https://.../v320/index.m3u8" } ]
  },
  "artists": [ { "artist_id": "uuid", "name": "string", "avatar_url": "string|null" } ],
  "audios": [ { "ext": "mp3|ogg", "bitrate": number, "path": "string" } ]
}
```

### HLS streaming for a track

There are two ways to stream HLS:

1) Public container (simplest): clients use the public blob URLs returned in `hls.master` and `hls.variants`, no auth headers required.

2) Private container (secure): use API endpoints that rewrite playlists to SAS-signed URLs and require Authorization.

Endpoints (secure mode):
- `GET /api/user/tracks/:id/hls/master.m3u8` — returns a rewritten master playlist (Content-Type: application/vnd.apple.mpegurl)
- `GET /api/user/tracks/:id/hls/v:bitrate/index.m3u8` — returns a rewritten variant playlist with signed segment URIs

Notes:
- Public mode: play `hls.master` directly; for manual quality selection, use `hls.variants[*].url`.
- Private mode: include `Authorization: Bearer <JWT>` when calling API endpoints. The playlists embed time-limited SAS URLs; refresh by re-fetching master if they expire during playback.
- See “Adaptive Streaming (HLS)” guide: `docs/streaming-hls.md`.

### POST /api/user/tracks
Create a new track (authenticated user). Caller must be album owner for the specified `album_id`.

- Content-Type: `multipart/form-data`
- Body (fields):
  - `title` string (required)
  - `album_id` uuid (required)
  - `duration` integer >= 0 (required)
  - `lyrics_url` string (optional)
  - `is_explicit` boolean (optional)
- Files: `audio` (required), `video` (optional)

Behavior:
- Creates with `is_published=false`.
- `album_id` and `audio` are required. The request fails with HTTP 400 if missing.
- On success, audio variants are generated into `track_audios` and `is_published=true` is set.
 - Owners of the album are automatically linked to the track with role `owner`.

Response: `201 Created` with `Track`.

### PATCH /api/tracks/:id
Update a track you are allowed to manage.

- Content-Type: `multipart/form-data`
- Body (any of): `title`, `album_id`, `duration`, `lyrics_url`, `is_explicit`, `is_published`
- Files (optional): `audio`, `video`

Behavior:
- Updates provided fields.
- If `audio` is provided, replaces `track_audios` entries and sets `is_published=true`.

Response: `200 OK` with updated `Track`.

### DELETE /api/tracks/:id
Delete a track you are allowed to manage.

 Behavior:
 - Removes `track_audios` rows; video is removed via storage helpers if present.
- Deletes the track row.

Response: `204 No Content`.

---

## Notes and edge cases
- If audio processing fails, the API returns `500` with `{ error: 'Audio processing failed', track: <partial> }` for creates or `{ error: 'Audio processing failed', track_id: <id> }` for updates. The track may still be created/updated without audio variants.
- Source audio bitrate determines generated variants: mp3 at source bitrate, ogg at 96/160/320kbps up to source bitrate.
- Clients can either:
  - Use HLS for adaptive playback (`hls.master`) — recommended.
  - Or pick a specific quality with `hls.variants` or `audios` (progressive).
- Ensure `album_id` is valid and the requesting user has permission to manage the album/track (enforced by middleware).
