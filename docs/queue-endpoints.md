# User Queue API

Base path: `/api/user/queue` (requires user auth)

Redis-backed per-user playback queue, stored as a Redis list at key `user:queue:<userId>`.

## Endpoints

### GET /api/user/queue
Fetch current queue for the authenticated user.

Query:
- `expand=1` optional — when set, returns track details instead of just IDs.

Response:
```
{ items: [string | Track], total: number }
```

### POST /api/user/queue/add
Append one or more tracks to the end of the queue.

Body:
```
{ "track_id": "uuid" }
# or
{ "track_ids": ["uuid", "uuid", ...] }
```

Response:
```
{ ok: true, total: number }
```

### DELETE /api/user/queue/:track_id
Remove the first occurrence of a track from the queue.

Response:
```
{ ok: true, removed: number }
```

### POST /api/user/queue/reorder
Move a track from one index to another within the queue.

Body:
```
{ "fromIndex": number, "toIndex": number }
```

Response:
```
{ ok: true, items: [string] }
```

### POST /api/user/queue/clear
Clear the queue.

Response:
```
{ ok: true }
```

### POST /api/user/queue/play
Reset the queue to the selected track followed by 10 auto-generated tracks.

Body:
```
{ "track_id": "uuid" }
```

Query:
- `expand=1` optional — when set, returns track details for the new queue.

Response:
```
{ items: [string | Track], total: number }
```

Notes:
- Auto-generation uses a simple random-offset selection of published tracks as placeholders.
- Track details include: `track_id, title, duration, created_at, hls { master, variants[] }, artists[]`.

## Redis configuration

Set either `REDIS_URL` (recommended) or these vars:
- `REDIS_HOST` (default: 127.0.0.1)
- `REDIS_PORT` (default: 6379)
- `REDIS_PASSWORD` (optional)

Docker example (compose):
```
services:
  redis:
    image: redis:7
    ports:
      - "6379:6379"
```

In `.env`:
```
REDIS_URL=redis://localhost:6379
```
