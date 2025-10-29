# Countries API

This document describes Countries endpoints for Admin and User scopes.

- Admin base: `/api/admin/countries`
- User base: `/api/user/countries`

## Data model

Country fields:
- `country_id` (UUID) — primary key
- `code` (string, required, length 2, e.g., "US", "IN")
- `name` (string, required)
- `created_at`, `updated_at` (timestamps)

## Admin endpoints

### List countries
GET `/api/admin/countries?page=0&limit=20&q=us`

- Query params:
  - `page` (0-based, default 0)
  - `limit` (1..100, default 20)
  - `q` (optional, ilike search on code and name)

Response:
```json
{ "items": [ { "country_id": "...", "code": "US", "name": "United States" } ], "total": 1, "page": 0, "limit": 20 }
```

### Get a country
GET `/api/admin/countries/:id`

- 404 if not found

### Create a country
POST `/api/admin/countries`

Body (JSON):
```json
{ "code": "US", "name": "United States" }
```

- Validations: code required length 2; name required

### Update a country
PATCH `/api/admin/countries/:id`

Body (partial):
```json
{ "name": "USA" }
```

- Validations: code length 2 if present; name non-empty if present

### Delete a country
DELETE `/api/admin/countries/:id`

- 204 on success

## User endpoints (read-only)

### List countries
GET `/api/user/countries?page=0&limit=20&q=in`

- Same pagination and filtering as admin
- Response items include only: `country_id, code, name`

### Get a country
GET `/api/user/countries/:id`

- Response includes only: `country_id, code, name`
- 404 if not found
