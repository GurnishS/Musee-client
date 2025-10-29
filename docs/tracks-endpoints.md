# Tracks API

This document describes the Tracks endpoints for both Admin and User APIs, aligned with the normalized schema that uses `track_artists` and `track_audios` tables.

Key points:
- Pagination is zero-based: page 0 is the first page. `limit` is capped at 100.
- Audio uploads generate variants and are stored in `track_audios` with fields: `ext`, `bitrate` (kbps), and `path` (URL).
- Artists linked to a track are exposed via `artists` array on responses (sourced from `track_artists`).

## Common object shape

Track object (admin responses include more fields; user list is a smaller projection):

```
{
  "track_id": "uuid",
  "title": "string",
  "album_id": "uuid",
  "cover_url": "string|null",
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
  "artists": [                  // joined via track_artists → artists → users
    {
      "artist_id": "uuid",
      "role": "owner|editor|viewer" (admin) or omitted in user list,
      "name": "Artist Name",
      "avatar_url": "string|null"
    }
  ],
  "audios": [                   // joined via track_audios (admin + user getById)
    { "id": number, "ext": "mp3|ogg", "bitrate": 96|160|320, "path": "https://...", "created_at": "ISO" }
  ]
}
```

Files supported on create/update (multipart/form-data):
- `audio` (binary) — triggers audio processing and sets `is_published=true` upon success
- `cover` (image)
- `video` (video)

---

## Admin API

Base path: `/api/admin/tracks`

### GET /api/admin/tracks
List tracks with pagination and optional search.

Query params:
- `page` number (default 0)
- `limit` number (default 20, max 100)
- `q` string (optional, ilike search on title)

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
- Body (fields):
  - `title` string (required)
  - `album_id` uuid (required)
  - `duration` integer >= 0 (required, seconds)
  - `lyrics_url` string (optional)
  - `is_explicit` boolean (optional)
  - `is_published` boolean (optional; if `audio` is uploaded and processed successfully, it will be set to true regardless)
- Files (optional): `audio`, `cover`, `video`

Behavior:
- Creates the track with `is_published=false` initially.
- If `audio` is provided, generates variants (mp3 at source bitrate and ogg at 96/160/320kbps up to source bitrate), inserts them into `track_audios`, and sets `is_published=true`.
- If `cover` provided, uploads and updates `cover_url`.
- If `video` provided, uploads and updates `video_url`.

Response: `201 Created` with `Track`.

### PATCH /api/admin/tracks/:id
Update an existing track.

- Content-Type: `multipart/form-data`
- Body (any of): `title`, `album_id`, `duration`, `lyrics_url`, `is_explicit`, `is_published`
- Files (optional): `audio`, `cover`, `video`

Behavior:
- Updates provided fields.
- If `audio` is provided, replaces all prior `track_audios` rows with newly generated variants and sets `is_published=true`.
- If `cover` is provided, uploads and updates `cover_url`.
- If `video` is provided, uploads and updates `video_url`.

Response: `200 OK` with updated `Track`.

### DELETE /api/admin/tracks/:id
Delete a track and its associated audio rows.

Behavior:
- Removes any `track_audios` entries for the track.
- Removes the track row.
- Cover/video objects are deleted via storage helpers when present.

Response: `204 No Content`.

---

## User API

Base path: `/api/tracks`

### GET /api/tracks
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
      "cover_url": "string|null",
      "duration": number,
      "created_at": "ISO",
      "artists": [ { "artist_id": "uuid", "name": "string", "avatar_url": "string|null" } ]
    }
  ],
  "total": number,
  "page": number,
  "limit": number
}
```

### GET /api/tracks/:id
Fetch a single published track, including available audio variants.

Response:
```
{
  "track_id": "uuid",
  "title": "string",
  "cover_url": "string|null",
  "album_id": "uuid",
  "duration": number,
  "play_count": number,
  "is_explicit": boolean,
  "likes_count": number,
  "created_at": "ISO",
  "artists": [ { "artist_id": "uuid", "name": "string", "avatar_url": "string|null" } ],
  "audios": [ { "ext": "mp3|ogg", "bitrate": number, "path": "string" } ]
}
```

### POST /api/tracks
Create a new track (authenticated user). Typically the caller must be authorized to manage this track (ownership rules enforced by middleware/policies).

- Content-Type: `multipart/form-data`
- Body (fields):
  - `title` string (required)
  - `album_id` uuid (required)
  - `duration` integer >= 0 (required)
  - `lyrics_url` string (optional)
  - `is_explicit` boolean (optional)
- Files (optional): `audio`, `cover`, `video`

Behavior:
- Creates with `is_published=false`.
- If `audio` provided, generates variants into `track_audios` and sets `is_published=true`.

Response: `201 Created` with `Track`.

### PATCH /api/tracks/:id
Update a track you are allowed to manage.

- Content-Type: `multipart/form-data`
- Body (any of): `title`, `album_id`, `duration`, `lyrics_url`, `is_explicit`, `is_published`
- Files (optional): `audio`, `cover`, `video`

Behavior:
- Updates provided fields.
- If `audio` is provided, replaces `track_audios` entries and sets `is_published=true`.

Response: `200 OK` with updated `Track`.

### DELETE /api/tracks/:id
Delete a track you are allowed to manage.

Behavior:
- Removes `track_audios` rows; cover/video are removed via storage helpers if present.
- Deletes the track row.

Response: `204 No Content`.

---

## Notes and edge cases
- If audio processing fails, the API returns `500` with `{ error: 'Audio processing failed', track: <partial> }` for creates or `{ error: 'Audio processing failed', track_id: <id> }` for updates. The track may still be created/updated without audio variants.
- Source audio bitrate determines generated variants: mp3 at source bitrate, ogg at 96/160/320kbps up to source bitrate.
- Clients should prefer the highest supported bitrate and fall back gracefully.
- Ensure `album_id` is valid and the requesting user has permission to manage the album/track (enforced by middleware).
