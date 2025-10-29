# Regions API

This document describes Regions endpoints for Admin and User scopes.

- Admin base: `/api/admin/regions`
- User base: `/api/user/regions`

## Data model

Region fields:
- `region_id` (UUID) — primary key
- `country_id` (UUID) — references `countries.country_id`
- `code` (string, required, pattern like `CA-SF` — two-letter country then hyphen and 1..8 alphanumerics)
- `name` (string, required)
- `created_at`, `updated_at` (timestamps)

## Admin endpoints

### List regions
GET `/api/admin/regions?page=0&limit=20&q=sf&country_id=<uuid>`

- Query params:
  - `page` (0-based, default 0)
  - `limit` (1..100, default 20)
  - `q` (optional, ilike search on code and name)
  - `country_id` (optional, UUID filter)

Response:
```json
{ "items": [ { "region_id": "...", "country_id": "...", "code": "CA-SF", "name": "San Francisco" } ], "total": 1, "page": 0, "limit": 20 }
```

### Get a region
GET `/api/admin/regions/:id`

- 404 if not found

### Create a region
POST `/api/admin/regions`

Body (JSON):
```json
{ "code": "CA-SF", "name": "San Francisco", "country_id": "<uuid>" }
```

- Validations: code matches pattern; name required; `country_id` must be a UUID

### Update a region
PATCH `/api/admin/regions/:id`

Body (partial):
```json
{ "name": "SF Bay Area" }
```

- Validations: if present, code must match pattern; `country_id` must be UUID or null

### Delete a region
DELETE `/api/admin/regions/:id`

- 204 on success

## User endpoints (read-only)

### List regions
GET `/api/user/regions?page=0&limit=20&q=sf&country_id=<uuid>`

- Same pagination and filtering as admin
- Response items include only: `region_id, country_id, code, name`

### Get a region
GET `/api/user/regions/:id`

- Response includes only: `region_id, country_id, code, name`
- 404 if not found
