# Users API (Admin and User)

This document describes the Users endpoints exposed by the Admin and User APIs. It covers inputs, outputs, authentication, and pagination.

Base paths:
- Admin: `/api/admin/users` (requires Admin auth)
- User: `/api/user/users` (requires User auth)

Pagination and search:
- List endpoints accept:
  - `page` (number, default 0) — zero-based page index
  - `limit` (number, default 20, max 100) — items per page
  - `q` (string, optional) — case-insensitive search by name
- Responses are `{ items, total, page, limit }`.

---

## Admin endpoints

### GET /api/admin/users
List users (admin).

Query params:
- `page`, `limit`, `q` — see pagination above

Response body:
```
{
  "items": [
    {
      "user_id": "uuid",
      "name": "string",
      "email": "string",
      "subscription_type": "free|premium|trial|null",
      "plan_id": "uuid|null",
      "avatar_url": "string|null",
      "playlists": ["uuid"],
      "favorites": { ... },
      "followers_count": number,
      "followings_count": number,
      "last_login_at": "ISO timestamp|null",
      "settings": { ... },
      "created_at": "ISO timestamp",
      "updated_at": "ISO timestamp",
      "user_type": "listener|artist|admin"
    }
  ],
  "total": number,
  "page": number,
  "limit": number
}
```

---

### GET /api/admin/users/:id
Get a user by id (admin).

Response body: same shape as an item in the list above.

Errors:
- 404 if not found

---

### POST /api/admin/users
Create a user (admin). This creates an auth user and the public profile row; optionally uploads avatar.

Headers:
- JSON: `Content-Type: application/json`
- Optional avatar: `multipart/form-data` with field `avatar` (if controller is wired to accept it)

Body (JSON):
```
{
  "name": "string",            // required
  "email": "string",           // required
  "password": "string",        // required for auth creation
  "subscription_type": "free|premium|trial"?,
  "plan_id": "uuid"?,
  "avatar_url": "string"?,     // optional; usually uploaded instead
  "playlists": ["uuid"]?,
  "favorites": { ... }?,
  "followers_count": number?,   // default 0
  "followings_count": number?,  // default 0
  "last_login_at": "ISO timestamp"?,
  "settings": { ... }?,
  "user_type": "listener|artist|admin"?
}
```

Response:
- 201 with created user (after optional avatar upload)
- 400 for validation errors

---

### PATCH /api/admin/users/:id
Update a user (admin). Supports avatar upload.

Headers:
- `Content-Type: application/json` or `multipart/form-data` (if uploading avatar)

Body (JSON, any subset):
```
{
  "name": "string",
  "email": "string",
  "subscription_type": "free|premium|trial",
  "plan_id": "uuid|null",
  "avatar_url": "string",
  "playlists": ["uuid"],
  "favorites": { ... },
  "followers_count": number,
  "followings_count": number,
  "last_login_at": "ISO timestamp",
  "settings": { ... },
  "user_type": "listener|artist|admin"
}
```

Response:
- 200 with updated user
- 404 if not found

---

### DELETE /api/admin/users/:id
Delete a user (admin). Also deletes avatar from storage if set.

Response:
- 204 No Content
- 404 if not found

---

## User endpoints

### GET /api/user/users
List public user profiles (basic fields only).

Query params:
- `page`, `limit`, `q` — pagination and search

Response body:
```
{
  "items": [
    {
      "user_id": "uuid",
      "name": "string",
      "avatar_url": "string|null"
    }
  ],
  "total": number,
  "page": number,
  "limit": number
}
```

---

### GET /api/user/users/:id
Get a public user profile.

Response body:
```
{
  "user_id": "uuid",
  "name": "string",
  "followers_count": number,
  "followings_count": number,
  "avatar_url": "string|null",
  "playlists": ["uuid"]
}
```

Errors:
- 404 if not found

---

### GET /api/user/users/me
Get the authenticated user’s full profile (private fields allowed).

Response body:
- Same as admin GET one user (full profile), for the authenticated user.

---

### PATCH /api/user/users/:id
Update the authenticated user’s own profile (limited fields). Supports avatar upload.

- Only allowed fields: `name`, `settings`, `playlists`
- Any other field results in 403.

Headers:
- `Content-Type: application/json` or `multipart/form-data` (if uploading avatar with field `avatar`)

Body (JSON, any subset of allowed fields):
```
{
  "name": "string",
  "settings": { ... },
  "playlists": ["uuid"]
}
```

Response:
- 200 with updated profile
- 403 if attempting to update another user
- 404 if not found

---

### DELETE /api/user/users/:id
Delete the authenticated user’s own profile.

Response:
- 204 No Content
- 403 if attempting to delete another user
- 404 if not found

---

## Notes
- Public vs private fields: user-facing GET list/get return limited fields; admin and `GET /me` provide full profile.
- `followings_count` is the canonical column (not `following_count`).
- Pagination is zero-based across endpoints: `page` starts at 0.
