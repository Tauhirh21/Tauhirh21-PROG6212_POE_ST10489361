# RaceDay API Endpoint Plan

## Authentication

| Method | Route | Description | Role Required | Request Body | Expected Response |
|--------|-------|-------------|---------------|--------------|-------------------|
| POST | /api/auth/register | Register a new user (Participant or Organiser) | None (public) | `{ "fullName", "email", "password", "role" }` | 201 Created – user details (no password)<br>400 Bad Request – validation errors |
| POST | /api/auth/login | Authenticate user and return JWT token | None (public) | `{ "email", "password" }` | 200 OK – `{ token, user }`<br>401 Unauthorised – invalid credentials |

## User Profile

| Method | Route | Description | Role Required | Request Body | Expected Response |
|--------|-------|-------------|---------------|--------------|-------------------|
| GET | /api/users/profile | Get current user's profile | Any (logged in) | None | 200 OK – user details (no password)<br>404 Not Found |
| PUT | /api/users/profile | Update current user's profile | Any (logged in) | `{ "fullName", "email", "password?" }` | 200 OK – updated user<br>400 Bad Request |

## Events

| Method | Route | Description | Role Required | Request Body | Expected Response |
|--------|-------|-------------|---------------|--------------|-------------------|
| GET | /api/events | Get all events (filter by status/date optional) | Any (logged in) | None (query params optional) | 200 OK – list of events with categories |
| GET | /api/events/{id} | Get a specific event by ID | Any (logged in) | None | 200 OK – event details with categories<br>404 Not Found |
| POST | /api/events | Create a new event | Organiser | `{ "title", "description", "eventDate", "startTime", "locationId", "status" }` | 201 Created – new event<br>400 Bad Request |
| PUT | /api/events/{id} | Update an existing event | Organiser | `{ "title", "description", "eventDate", "startTime", "locationId", "status" }` | 200 OK – updated event<br>404 Not Found<br>403 Forbidden (not organiser) |
| DELETE | /api/events/{id} | Delete an event (only if no enrolments) | Organiser | None | 204 No Content<br>404 Not Found<br>409 Conflict (has enrolments) |

## Categories

| Method | Route | Description | Role Required | Request Body | Expected Response |
|--------|-------|-------------|---------------|--------------|-------------------|
| GET | /api/events/{eventId}/categories | Get all categories for an event | Any (logged in) | None | 200 OK – list of categories |
| POST | /api/events/{eventId}/categories | Add a new category to an event | Organiser | `{ "name", "description", "distance", "fee", "maxParticipants" }` | 201 Created – new category<br>400 Bad Request<br>404 Not Found (event) |
| PUT | /api/categories/{id} | Update a category | Organiser | `{ "name", "description", "distance", "fee", "maxParticipants" }` | 200 OK – updated category<br>404 Not Found |
| DELETE | /api/categories/{id} | Delete a category (if no enrolments) | Organiser | None | 204 No Content<br>404 Not Found<br>409 Conflict (has enrolments) |

## Enrolments

| Method | Route | Description | Role Required | Request Body | Expected Response |
|--------|-------|-------------|---------------|--------------|-------------------|
| POST | /api/enrolments | Enrol a participant in an event category | Participant | `{ "eventId", "categoryId" }` | 201 Created – enrolment details<br>400 Bad Request (duplicate/full) |
| GET | /api/enrolments | Get all enrolments (own for Participant, all for Organiser) | Any (logged in) | None | 200 OK – list of enrolments with event & category details |
| GET | /api/enrolments/{id} | Get a specific enrolment by ID | Any (logged in) – only own if Participant | None | 200 OK – enrolment details<br>404 Not Found<br>403 Forbidden |
| DELETE | /api/enrolments/{id} | Cancel an enrolment (participant only) | Participant | None | 204 No Content<br>404 Not Found<br>403 Forbidden |

## Results

| Method | Route | Description | Role Required | Request Body | Expected Response |
|--------|-------|-------------|---------------|--------------|-------------------|
| POST | /api/results | Capture a result for an enrolment | Organiser | `{ "enrolmentId", "finishTime", "position", "status" }` | 201 Created – result details<br>400 Bad Request<br>404 Not Found (enrolment) |
| GET | /api/results/me | Get current user's personal results (Participant) | Participant | None | 200 OK – list of results with event details |
| GET | /api/events/{eventId}/results | Get all results for a specific event | Organiser | None | 200 OK – list of results with participant names |
| PUT | /api/results/{id} | Update a result | Organiser | `{ "finishTime", "position", "status" }` | 200 OK – updated result<br>404 Not Found |

## Additional Endpoints (Optional)

| Method | Route | Description | Role Required | Request Body | Expected Response |
|--------|-------|-------------|---------------|--------------|-------------------|
| GET | /api/locations | Get all locations | Any (logged in) | None | 200 OK – list of locations |
| POST | /api/locations | Add a new location | Organiser | `{ "name", "address", "city", "province", "latitude", "longitude" }` | 201 Created<br>400 Bad Request |