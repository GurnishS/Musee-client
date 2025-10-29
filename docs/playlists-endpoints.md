# Playlists API

Normalized to use `playlist_tracks` for many-to-many track membership.

- Pagination is zero-based.
- Cover uploads use `multipart/form-data` with field `cover`.
- Track membership is managed via dedicated endpoints; there is no `track_ids` field on playlists.

## Common object shape

```
{
  "playlist_id": "uuid",
  "name": "string",
  "creator_id": "uuid|null",
  "is_public": true|false,
  "description": "string|null",
  "cover_url": "string",
  "genres": ["pop", "rock"],
  "likes_count": number,
  "total_tracks": number,
  "duration": number|null,
  "created_at": "ISO",
  "updated_at": "ISO",
  "tracks": [
    { "track_id": "uuid", "title": "string", "cover_url": "string", "duration": number, "created_at": "ISO" }
  ] // included in get-by-id endpoints
}
```

---

## Admin API

Base: `/api/admin/playlists`

### GET /api/admin/playlists
List playlists with pagination and optional search.

Query:
- `page` (default 0)
- `limit` (default 20, max 100)
- `q` (search by name)

Response:
```
{ items: [Playlist], total, page, limit }
```

### GET /api/admin/playlists/:id
Fetch a playlist with its tracks.

Response: `Playlist` with `tracks` array.

### POST /api/admin/playlists
Create a playlist.

- Content-Type: `multipart/form-data`
- Body: `{ name (required), description?, genres?, is_public?, creator_id? }`
- Files: `cover` (optional)

Behavior: Creates the playlist; if `cover` provided, uploads and updates `cover_url`.

Response: `201 Created` with playlist.

### PATCH /api/admin/playlists/:id
Update a playlist.

- Content-Type: `multipart/form-data`
- Body: any of `{ name, description, genres, is_public, creator_id }`
- Files: `cover` (optional)

Response: updated playlist.

### DELETE /api/admin/playlists/:id
Delete a playlist. Associated `playlist_tracks` rows are removed by FK cascade.

Response: `204 No Content`.

### POST /api/admin/playlists/:id/tracks
Add a track to a playlist.

Body:
```
{ "track_id": "uuid" }
```

Response: `200 OK` with updated playlist.

### DELETE /api/admin/playlists/:id/tracks/:trackId
Remove a track from a playlist.

Response: `204 No Content`.

---

## User API

Base: `/api/playlists`

All user endpoints require authentication (mounted under the authenticated user router).

### GET /api/playlists
List public playlists with pagination.

Query: `page`, `limit`, `q`

Response:
```
{ items: [ { playlist_id, name, creator_id, cover_url, genres, duration, total_tracks } ], total, page, limit }
```

### GET /api/playlists/:id
Fetch a public playlist with tracks.

Response:
```
{
  playlist_id, name, creator_id, cover_url, genres, duration, total_tracks,
  tracks: [ { track_id, title, cover_url, duration, created_at } ]
}
```

### POST /api/playlists
Create a playlist (creator is set from the authenticated user).

- Content-Type: `multipart/form-data`
- Body: `{ name (required), description?, genres?, is_public? }`
- Files: `cover` (optional)

Response: `201 Created` with playlist.

### PATCH /api/playlists/:id
Update your own playlist.

- Content-Type: `multipart/form-data`
- Body: any of `{ name, description, genres, is_public }`
- Files: `cover` (optional)

Ownership: Only the `creator_id` can update.

Response: updated playlist.

### DELETE /api/playlists/:id
Delete your own playlist.

Ownership: Only the `creator_id` can delete.

Response: `204 No Content`.

### POST /api/playlists/:id/tracks
Add a track to your playlist.

Body: `{ track_id: "uuid" }`

Ownership: Only the `creator_id` can add.

Response: `200 OK` with updated playlist.

### DELETE /api/playlists/:id/tracks/:trackId
Remove a track from your playlist.

Ownership: Only the `creator_id` can remove.

Response: `204 No Content`.

---

## Notes
- There is no `track_ids` column on `playlists`; membership is in `playlist_tracks`.
- Duplicate membership is prevented at the application level by checking before insert.
- `total_tracks` can be managed separately; it is not automatically updated by these endpoints unless you add a trigger or code to recompute.
