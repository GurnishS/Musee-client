# Albums API (Admin and User)

This document describes the albums endpoints available for both Admin and User APIs, including input payloads, output shapes, and auth requirements.

Base paths:
- Admin: `/api/admin/albums` (requires Admin auth)
- User: `/api/user/albums` (requires User auth)

Uploads:
- Cover image uploads use `multipart/form-data` with a single file field named `cover` (2MB limit).

Pagination and search:
- Query params shared by list endpoints:
  - `page` (number, default 0) — zero-based page index
  - `limit` (number, default 20, max 100) — items per page
  - `q` (string, optional) — simple case-insensitive search by title
- List responses are wrapped as `{ items, total, page, limit }`.

---

## Admin endpoints

### GET /api/admin/albums
List albums (admin, all visibility).

Query params:
- `page`, `limit`, `q` — see pagination above

Response body:
```
{
  "items": [
    {
      "album_id": "uuid",
      "title": "string",
      "description": "string|null",
      "cover_url": "string",
      "genres": ["string"],
      "total_tracks": number|null,
      "likes_count": number|null,
      "created_at": "ISO timestamp",
      "updated_at": "ISO timestamp",
      "is_published": boolean,
      "duration": number|null,
      "artists": [
        {
          "artist_id": "uuid|null",
          "role": "owner|editor|viewer",
          "name": "string|null",
          "avatar_url": "string|null"
        }
      ]
    }
  ],
  "total": number,
  "page": number,
  "limit": number
}
```

---

### GET /api/admin/albums/:id
Get one album (admin) with artists and tracks.

Response body:
```
{
  "album_id": "uuid",
  "title": "string",
  "description": "string|null",
  "cover_url": "string",
  "genres": ["string"],
  "total_tracks": number|null,
  "likes_count": number|null,
  "created_at": "ISO timestamp",
  "updated_at": "ISO timestamp",
  "is_published": boolean,
  "duration": number|null,
  "artists": [
    { "artist_id": "uuid", "role": "owner|editor|viewer", "name": "string|null", "avatar_url": "string|null" }
  ],
  "tracks": [
    {
      "track_id": "uuid",
      "title": "string",
      "cover_url": "string",
      "duration": number,
      "is_explicit": boolean,
      "is_published": boolean,
      "created_at": "ISO timestamp",
      "artists": [
        { "artist_id": "uuid", "role": "owner|editor|viewer", "name": "string|null", "avatar_url": "string|null" }
      ]
    }
  ]
}
```

Errors:
- 404 if not found

---

### POST /api/admin/albums
Create an album (admin). Admin must provide an owner `artist_id`.

Headers:
- `Content-Type: application/json` or `multipart/form-data` (if uploading cover)

Body (JSON):
```
{
  "title": "string",            // required
  "description": "string?",
  "genres": ["string"]?,
  "is_published": boolean?,
  "artist_id": "uuid"           // required: owner artist to link
}
```

Optional file upload:
- `cover` (file) — if provided, the album's `cover_url` will be updated after creation

Response:
- 201 with album object (after cover upload if present)
- 400 if `artist_id` is missing/invalid

---

### PATCH /api/admin/albums/:id
Update an album (admin).

Headers:
- `Content-Type: application/json` or `multipart/form-data` (if uploading cover)

Body (JSON, any subset):
```
{
  "title": "string",
  "description": "string|null",
  "genres": ["string"],
  "is_published": boolean
}
```

Optional file upload:
- `cover` (file) — updates `cover_url`

Response:
- 200 with updated album (enriched where available)
- 404 if not found

---

### DELETE /api/admin/albums/:id
Delete an album (admin).

Response:
- 204 No Content
- 404 if not found

---

### POST /api/admin/albums/:id/artists
Add an artist to an album (admin).

Body (JSON):
```
{
  "artist_id": "uuid",          // required
  "role": "owner|editor|viewer" // optional, defaults to 'viewer'
}
```

Response:
```
{
  "id": "uuid",
  "album_id": "uuid",
  "artist_id": "uuid",
  "role": "owner|editor|viewer"
}
```

Errors:
- 400 for invalid payload

---

### PATCH /api/admin/albums/:id/artists/:artistId
Update an artist role for an album (admin).

Body (JSON):
```
{ "role": "owner|editor|viewer" }
```

Response:
```
{
  "id": "uuid",
  "album_id": "uuid",
  "artist_id": "uuid",
  "role": "owner|editor|viewer"
}
```

Errors:
- 400 invalid role/ids
- 404 link not found

---

### DELETE /api/admin/albums/:id/artists/:artistId
Remove an artist from an album (admin).

Response:
- 204 No Content
- 404 if link not found

---

## User endpoints

### GET /api/user/albums
List published albums.

Query params:
- `page`, `limit`, `q` — see pagination above

Response body:
```
{
  "items": [
    {
      "album_id": "uuid",
      "title": "string",
      "cover_url": "string",
      "duration": number|null,
      "created_at": "ISO timestamp",
      "artists": [
        { "artist_id": "uuid|null", "name": "string|null", "avatar_url": "string|null", "role": "owner|editor|viewer|null" }
      ]
    }
  ],
  "total": number,
  "page": number,
  "limit": number
}
```

---

### GET /api/user/albums/:id
Get one published album with artists and published tracks.

Response body:
```
{
  "album_id": "uuid",
  "title": "string",
  "cover_url": "string",
  "release_date": "YYYY-MM-DD|null",
  "duration": number|null,
  "created_at": "ISO timestamp",
  "artists": [
    { "artist_id": "uuid", "name": "string|null", "avatar_url": "string|null", "role": "owner|editor|viewer" }
  ],
  "tracks": [
    {
      "track_id": "uuid",
      "title": "string",
      "cover_url": "string",
      "duration": number,
      "is_explicit": boolean,
      "created_at": "ISO timestamp",
      "artists": [
        { "artist_id": "uuid", "name": "string|null", "avatar_url": "string|null", "role": "owner|editor|viewer" }
      ]
    }
  ]
}
```

Errors:
- 404 if not found or not published

---

### POST /api/user/albums
Create an album (user). The authenticated user must be an artist; they will be linked as the owner.

Headers:
- `Content-Type: application/json` or `multipart/form-data` (if uploading cover)

Body (JSON):
```
{
  "title": "string",            // required
  "description": "string?",
  "genres": ["string"]?,
  "is_published": boolean?
}
```

Optional file upload:
- `cover` (file)

Response:
- 201 with the created album (enriched)
- 403 if caller is not an artist

---

### PATCH /api/user/albums/:id
Update an album (owner only). Users may only change selected fields.

Headers:
- `Content-Type: application/json` or `multipart/form-data` (if uploading cover)

Allowed JSON fields:
```
{
  "title": "string",
  "description": "string",
  "genres": ["string"],
  "is_published": boolean
}
```

Optional file upload:
- `cover` (file)

Response:
- 200 with updated album (enriched)
- 403 if not owner
- 404 if not found

---

### DELETE /api/user/albums/:id
Delete an album (owner only).

Response:
- 204 No Content
- 403 if not owner
- 404 if not found

---

### POST /api/user/albums/:id/artists
Add an artist to an album (owner only).

Body (JSON):
```
{
  "artist_id": "uuid",
  "role": "owner|editor|viewer" // optional, default 'viewer'
}
```

Response:
```
{
  "id": "uuid",
  "album_id": "uuid",
  "artist_id": "uuid",
  "role": "owner|editor|viewer"
}
```

Errors:
- 400 invalid payload
- 403 if not owner

---

### PATCH /api/user/albums/:id/artists/:artistId
Update an artist role for an album (owner only).

Body (JSON):
```
{ "role": "owner|editor|viewer" }
```

Response:
```
{
  "id": "uuid",
  "album_id": "uuid",
  "artist_id": "uuid",
  "role": "owner|editor|viewer"
}
```

Errors:
- 400 invalid payload
- 403 if not owner
- 404 link not found

---

### DELETE /api/user/albums/:id/artists/:artistId
Remove an artist from an album (owner only).

Response:
- 204 No Content

Errors:
- 403 if not owner
- 404 link not found

---

## Notes
- Cover uploads use field name `cover`.
- Role values validated by backend: `'owner' | 'editor' | 'viewer'`.
- Admin endpoints can operate on unpublished content; user endpoints are restricted to published visibility for reads and ownership for writes.
