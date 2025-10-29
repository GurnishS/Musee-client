# Artists API (Admin and User)

This document describes the Artists endpoints used by Admin and User APIs. It covers request/response shapes, authentication, validations, and examples.

Base paths:
- Admin: `/api/admin/artists` (requires Admin auth)
- User: `/api/user/artists` (requires User auth)

Uploads:
- Cover image uploads use `multipart/form-data` with a single file field named `cover` (2MB limit).
- Admin create also supports an `avatar` file for the linked user via the `uploadAvatarAndCover` middleware.

Pagination & search:
- Query params:
  - `page` (number, default 0) — zero-based page index
  - `limit` (number, default 20, max 100)
  - `q` (string, optional) — searches `bio` and user `name` for public lists
- List responses: `{ items, total, page, limit }`

---

## Admin endpoints

### GET /api/admin/artists
List artists (admin, full records).

Query params: `page`, `limit`, `q`

Response item fields:
```
{
  artist_id: "uuid",
  bio: "string",
  cover_url: "string|null",
  genres: ["string"],
  debut_year: number|null,
  is_verified: boolean,
  social_links: { ... } | null,
  monthly_listeners: number,
  created_at: "ISO timestamp",
  updated_at: "ISO timestamp",
  region_id: "uuid",
  date_of_birth: "YYYY-MM-DD" | null,
  users: {    // nested user profile from users table
      user_id: "uuid",
      name: "string",
      email: "string",
      avatar_url: "string|null",
      ... // other user fields
  }
}
```

---

### GET /api/admin/artists/:id
Get one artist (admin). Returns the same full shape as above.

Errors:
- 404 if not found

---

### POST /api/admin/artists
Create an artist. Admin may either provide `artist_id` (existing user) or provide user fields to create the underlying user.

Middleware: `uploadAvatarAndCover` (supports `avatar` and `cover` file fields)

Body options:
- Option A: Provide `artist_id` and artist fields
```
{ "artist_id": "uuid", "bio": "string", ... }
```
- Option B: Provide user fields (name, email, password) plus artist fields — controller will create a user and then the artist
```
{ "name": "string", "email": "string", "password": "string", "bio": "string", ... }
```

Important validations (backend enforced):
- `bio` is required
- `artist_id` must be a UUID when provided
- `debut_year` if provided must be between 1900 and current year
- `region_id` if provided must be a UUID

Response:
- 201 with created artist (after optional avatar/cover processing)

---

### PATCH /api/admin/artists/:id
Update an artist (admin).

Body fields (any subset):
```
{ "bio": "string", "cover_url": "string", "genres": ["string"], "debut_year": number, "is_verified": boolean, "monthly_listeners": number, "region_id": "uuid", "date_of_birth": "YYYY-MM-DD", "social_links": { ... } }
```

Response:
- 200 with updated artist
- 404 if not found

---

### DELETE /api/admin/artists/:id
Delete an artist (admin).

Response:
- 204 No Content
- 404 if not found

---

## User endpoints

### GET /api/user/artists
List public artists (minimal profile fields + linked user public fields).

Query params: `page`, `limit`, `q`

Response item fields:
```
{
  artist_id: "uuid",
  name: "string|null",          // from linked user
  avatar_url: "string|null",   // from linked user
  cover_url: "string|null",
  bio: "string",
  genres: ["string"],
  debut_year: number|null,
  is_verified: boolean,
  monthly_listeners: number
}
```

---

### GET /api/user/artists/:id
Get a single public artist profile with linked user public fields.

Response fields:
```
{ artist_id, name, avatar_url, cover_url, bio, genres, debut_year, is_verified, monthly_listeners }
```

Errors:
- 404 if not found

---

### POST /api/user/artists
Create artist profile for the authenticated user (user becomes artist).

Requirements:
- Authenticated user (`req.user`), user ID used as `artist_id`.
- If an artist profile already exists for this user, returns 409.

Allowed fields (from request body):
```
{ "bio": "string", "cover_url": "string", "genres": ["string"], "social_links": {...}, "region_id": "uuid", "date_of_birth": "YYYY-MM-DD", "debut_year": number }
```

Upload:
- `cover` file via multipart/form-data (optional)

Response:
- 201 with created artist
- 401 if not authenticated
- 409 if artist already exists

---

### PATCH /api/user/artists/:id
Update your own artist profile (authenticated user only).

- Caller must be the same user as `:id`.
- Allowed fields same as POST.
- Optional `cover` upload updates cover_url.

Response:
- 200 updated artist
- 403 if not owner
- 404 if not found

---

### DELETE /api/user/artists/:id
Delete your own artist profile.

- Caller must be the same user as `:id`.
- After deletion, controller attempts to set `user.user_type` back to 'listener'.

Response:
- 204 No Content
- 403 if not owner
- 404 if not found

---

## Notes & recommendations
- `date_of_birth` is served as a DATE (`YYYY-MM-DD`); controllers use `toDateOnly` to normalize.
- `debut_year` is optional now; previously the model required it — adjusted to accept omission.
- `region_id` is optional; DB provides a default if omitted.
- Consider adding a uniqueness constraint on `artists.artist_id` (if not already present) to enforce 1:1 user->artist mapping.
- For admin creation when providing user fields, controllers create the user first and then create the artist with `artist_id = user.user_id`.

---

If you'd like, I can also generate a small Postman/Thunder-collection JSON for these endpoints for frontend testing.
