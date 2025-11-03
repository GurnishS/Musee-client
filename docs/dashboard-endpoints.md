# Dashboard endpoints (User)

This document describes the user-facing Dashboard endpoints. They are intentionally simple for now — both endpoints return published albums with pagination. In future we will replace the placeholder logic with personalized recommendations and trending signals.

Base path: `/api/user/dashboard` (requires authentication — include `Authorization: Bearer <JWT>`)

## Endpoints

### GET /api/user/dashboard/made-for-you

- Description: Placeholder "Made for you" feed. For now it returns published albums (same output as the public albums list) with pagination.
- Query parameters:
  - `limit` (integer, default 20, max 100)
  - `page` (integer, zero-based, default 0)
- Response: 200

```json
{
  "items": [
    {
      "album_id": "uuid",
      "title": "string",
      "cover_url": "https://...",
      "duration": 1234,
      "created_at": "ISO",
      "artists": [ { "artist_id": "uuid", "name": "string", "avatar_url": "https://..." } ]
    }
  ],
  "total": 123,
  "page": 0,
  "limit": 20
}
```

Notes:
- Currently implemented by calling `listAlbumsUser({ limit, offset })` and returning published albums ordered by creation date.
- Future: replace with personalized recommendations (followed artists, listening history, genre affinity).

### GET /api/user/dashboard/trending

- Description: Placeholder "Trending" feed. Returns published albums (same shape and paging as above).
- Query parameters: same as Made For You
- Response: same shape as Made For You

Notes:
- Current implementation uses the same underlying list; later this will be replaced by logic that sorts by play_count / likes / recent growth signals.

## Auth and access

- These endpoints are available under the authenticated user router (`/api/user`) and require a valid Supabase JWT in the `Authorization` header.
- Example header:

```
Authorization: Bearer <access_token>
```

## Implementation notes for backend developers

- Controller: `src/controllers/user/dashboardController.js` implements both endpoints and currently delegates to `listAlbumsUser` in `src/models/albumModel.js`.
- Routes: `src/routes/user/dashboardRoutes.js` mounts `/made-for-you` and `/trending` and is imported in `src/routes/userRoutes.js` as `/dashboard`.

## Frontend UX notes

- Present both feeds as horizontally-scrollable carousels or vertical lists using the returned `items`.
- Page navigation is zero-based (`page=0` for first page). Use `limit` to adjust page size.
- When real recommendations are enabled, expect the results to change shape slightly (optional metadata like recommendation_reason or trending_score could be added).
