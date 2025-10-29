# Plans API

This document describes the Plans endpoints for both Admin and User scopes.

- Admin base: `/api/admin/plans`
- User base: `/api/user/plans`

## Data model

Plan fields:
- `plan_id` (UUID) — primary key
- `name` (string, required)
- `price` (number, non-negative, required)
- `currency` (string, default `INR`)
- `billing_cycle` (`monthly` | `yearly` | `lifetime`, default `monthly`)
- `features` (object, default `{}`)
- `max_devices` (integer >= 1, default 1)
- `is_active` (boolean, default true)
- `created_at`, `updated_at` (timestamps)

Note: User endpoints only return active plans (`is_active !== false`).

## Admin endpoints

### List plans
GET `/api/admin/plans`

Response:
```json
{
  "items": [ { "plan_id": "...", "name": "...", "price": 0, ... } ]
}
```

### Get a plan
GET `/api/admin/plans/:id`

- 404 if not found

### Create a plan
POST `/api/admin/plans`

Body (JSON or x-www-form-urlencoded):
```json
{
  "name": "Pro",
  "price": 499,
  "currency": "INR",
  "billing_cycle": "monthly",
  "features": {"offline": true},
  "max_devices": 3,
  "is_active": true
}
```

- Validations: name required; price >= 0; billing_cycle in monthly|yearly|lifetime; features must be an object; max_devices >= 1

### Update a plan
PATCH `/api/admin/plans/:id`

Body (partial fields allowed):
```json
{ "price": 599, "is_active": false }
```

- 404 if not found

### Delete a plan
DELETE `/api/admin/plans/:id`

- 204 on success

## User endpoints

### List active plans
GET `/api/user/plans`

Response:
```json
{ "items": [ { "plan_id": "...", "name": "...", "price": 0, ... } ] }
```

### Get a single active plan
GET `/api/user/plans/:id`

- 404 if not found or `is_active === false`
