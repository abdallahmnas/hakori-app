# Hakori Almadina — Haute Joaillerie & Atelier API Documentation

> **Base Production URL:** `https://hakori-service.onrender.com/api`  
> **Base Local URL:** `http://localhost:5000/api`  
> **API Version:** `1.2.0`  
> **Protocol:** HTTPS (REST, JSON)  
> *Note: This documentation covers public client, patron portal, order commission, consultation, and customer service endpoints. All internal administrative endpoints (`/admin/*`) have been excluded.*

---

## Table of Contents

1. [Architectural Overview & Standards](#architectural-overview--standards)
2. [Authentication Flow & Security](#authentication-flow--security)
3. [Error Handling & Response Standard](#error-handling--response-standard)
4. [Authentication & Patron Onboarding](#authentication-patron-onboarding) (9 endpoints)
5. [Patron Profile & Settings](#patron-profile-settings) (2 endpoints)
6. [Public Boutique & Products](#public-boutique-products) (3 endpoints)
7. [Collections & Taxonomy](#collections-taxonomy) (2 endpoints)
8. [Orders, Commissions & Payments](#orders-commissions-payments) (6 endpoints)
9. [Bespoke Consultations & VIP Concierge](#bespoke-consultations-vip-concierge) (3 endpoints)
10. [Customer Support Tickets](#customer-support-tickets) (3 endpoints)
11. [Patron Notifications](#patron-notifications) (3 endpoints)
12. [System & Health](#system-health) (1 endpoints)
13. [Core Data Models & Schemas](#core-data-models--schemas)

---

## Architectural Overview & Standards

The **Hakori Almadina Backend API** is an enterprise RESTful service supporting the luxury dental atelier and bespoke jewelry discovery experience.

- **Content Type**: All requests and responses use `application/json` unless uploading multipart files.
- **Authentication**: JWT Bearer token authentication via the HTTP `Authorization` header:
  ```http
  Authorization: Bearer <your_jwt_token>
  ```
- **Standard Envelope**: All JSON responses conform to the standard `ApiResponse` envelope:
  ```json
  {
    "success": true,
    "data": { ... },
    "message": "Operation completed successfully"
  }
  ```
- **CORS**: Enabled for cross-origin requests from the client mobile application and web portals.

---

## Authentication Flow & Security

Hakori Almadina employs a high-security 3-step Patron Onboarding lifecycle alongside standard credential authentication:

1. **Step 1 - Initiate Signup (`POST /auth/signup/init`)**: Patron submits email, phone, and desired password. A 6-digit cryptographic OTP is generated and dispatched via email / SMS.
2. **Step 2 - Verify OTP (`POST /auth/signup/verify`)**: Patron inputs the received OTP to obtain a signed verification proof.
3. **Step 3 - Complete Profile (`POST /auth/signup/complete`)**: Patron finalizes their profile (Full name, delivery location, fitting tier). Returns authenticated User model and JWT Bearer token.
4. **Login (`POST /auth/login`)**: Authenticates existing users and returns the access token.
5. **Password Reset Flow**: Standard 3-step OTP flow via `/auth/forgot-password`, `/auth/verify-reset-otp`, and `/auth/reset-password`.

---

## Error Handling & Response Standard

When an error occurs, the server responds with a corresponding HTTP status code (4xx / 5xx) and error envelope:

| Status Code | Meaning | Typical Scenario |
| :--- | :--- | :--- |
| **`200 OK`** | Success | Request succeeded with payload |
| **`201 Created`** | Created | Resource successfully created (signup complete, order placed, ticket logged) |
| **`400 Bad Request`** | Validation Error | Missing required fields, invalid email format, or invalid OTP |
| **`401 Unauthorized`** | Authentication Failure | Missing, invalid, or expired JWT Bearer token |
| **`403 Forbidden`** | Authorization Error | Insufficient permissions for the requested resource |
| **`404 Not Found`** | Resource Missing | Product, Order, or Ticket ID does not exist |
| **`500 Internal Error`** | Atelier Service Error | Unexpected server or payment gateway exception |

---

## Authentication & Patron Onboarding

### POST `/auth/signup/init`

**Summary:** Step 1: Initiate Patron Signup

Generates OTP and sends verification email. Returns transient encrypted session token without persisting to database.

- **Method:** `POST`
- **Endpoint:** `/auth/signup/init`
- **Authentication:** 🌐 **Public** (No auth token required)

#### Request Body

- **Content-Type:** `application/json`

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `email` | `string (email)` | **Yes** | Example: `patron@mayfair.co.uk` |

**Example Request Payload:**
```json
{
  "email": "patron@mayfair.co.uk"
}
```

#### Responses

**Status Code:** `200` — OTP dispatched and session token returned

---

### POST `/auth/signup/verify`

**Summary:** Step 2: Verify Signup OTP

Validates 6-character OTP with transient session token and returns verified completion token.

- **Method:** `POST`
- **Endpoint:** `/auth/signup/verify`
- **Authentication:** 🌐 **Public** (No auth token required)

#### Parameters

| Name | In | Type | Required | Description |
| :--- | :--- | :--- | :--- | :--- |
| `Authorization` | `header` | `string` | **Yes** | Bearer <session_token> |

#### Request Body

- **Content-Type:** `application/json`

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `otp` | `string` | **Yes** | Example: `123456` |

**Example Request Payload:**
```json
{
  "otp": "123456"
}
```

#### Responses

**Status Code:** `200` — OTP verified. Profile completion token granted.

---

### POST `/auth/signup/complete`

**Summary:** Step 3: Complete Profile & Register in Database

Accepts completion token and profile details. Atomically persists new user to database and sends welcome email.

- **Method:** `POST`
- **Endpoint:** `/auth/signup/complete`
- **Authentication:** 🌐 **Public** (No auth token required)

#### Parameters

| Name | In | Type | Required | Description |
| :--- | :--- | :--- | :--- | :--- |
| `Authorization` | `header` | `string` | **Yes** | Bearer <completion_token> |

#### Request Body

- **Content-Type:** `application/json`

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `firstName` | `string` | **Yes** | Example: `Julian` |
| `lastName` | `string` | **Yes** | Example: `Vance` |
| `password` | `string (password)` | **Yes** | Example: `SecurePassword123!` |
| `phone` | `string` | No | Example: `+44 20 7946 0992` |
| `city` | `string` | No | Example: `London` |
| `country` | `string` | No | Example: `United Kingdom` |
| `address` | `string` | No | Example: `14 Mayfair Square` |

**Example Request Payload:**
```json
{
  "firstName": "Julian",
  "lastName": "Vance",
  "password": "SecurePassword123!",
  "phone": "+44 20 7946 0992",
  "city": "London",
  "country": "United Kingdom",
  "address": "14 Mayfair Square"
}
```

#### Responses

**Status Code:** `201` — Patron created successfully with auth token

---

### POST `/auth/login`

**Summary:** User & Admin Login

- **Method:** `POST`
- **Endpoint:** `/auth/login`
- **Authentication:** 🌐 **Public** (No auth token required)

#### Request Body

- **Content-Type:** `application/json`

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `email` | `string (email)` | **Yes** | Example: `admin@hakori.com` |
| `password` | `string (password)` | **Yes** | Example: `Admin@Hakori2025!` |

**Example Request Payload:**
```json
{
  "email": "admin@hakori.com",
  "password": "Admin@Hakori2025!"
}
```

#### Responses

**Status Code:** `200` — Authenticated successfully. Returns user object and JWT token.

---

### POST `/auth/forgot-password`

**Summary:** Request Password Reset OTP

- **Method:** `POST`
- **Endpoint:** `/auth/forgot-password`
- **Authentication:** 🌐 **Public** (No auth token required)

#### Request Body

- **Content-Type:** `application/json`

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `email` | `string (email)` | **Yes** | Example: `staff@hakori.com` |

**Example Request Payload:**
```json
{
  "email": "staff@hakori.com"
}
```

#### Responses

**Status Code:** `200` — Reset OTP sent to registered email

---

### POST `/auth/verify-reset-otp`

**Summary:** Verify Password Reset OTP

- **Method:** `POST`
- **Endpoint:** `/auth/verify-reset-otp`
- **Authentication:** 🌐 **Public** (No auth token required)

#### Request Body

- **Content-Type:** `application/json`

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `email` | `string (email)` | **Yes** | - |
| `otp` | `string` | **Yes** | Example: `123456` |

**Example Request Payload:**
```json
{
  "email": "patron@aurumatelier.com",
  "otp": "123456"
}
```

#### Responses

**Status Code:** `200` — OTP verified. Returns reset token.

---

### POST `/auth/reset-password`

**Summary:** Set New Password

- **Method:** `POST`
- **Endpoint:** `/auth/reset-password`
- **Authentication:** 🌐 **Public** (No auth token required)

#### Request Body

- **Content-Type:** `application/json`

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `email` | `string (email)` | **Yes** | - |
| `resetToken` | `string` | **Yes** | - |
| `newPassword` | `string (password)` | **Yes** | - |

**Example Request Payload:**
```json
{
  "email": "patron@aurumatelier.com",
  "resetToken": "string",
  "newPassword": "string"
}
```

#### Responses

**Status Code:** `200` — Password successfully changed

---

### GET `/auth/me`

**Summary:** Get Active Authenticated User

- **Method:** `GET`
- **Endpoint:** `/auth/me`
- **Authentication:** 🔒 **Required** (`BearerAuth` JWT)

#### Responses

**Status Code:** `200` — Active user session

---

### POST `/auth/logout`

**Summary:** Logout Active User

- **Method:** `POST`
- **Endpoint:** `/auth/logout`
- **Authentication:** 🔒 **Required** (`BearerAuth` JWT)

#### Responses

**Status Code:** `200` — Logged out successfully

---


## Patron Profile & Settings

### GET `/users/profile`

**Summary:** Get Patron Profile & Dynamic Metrics

Returns profile with dynamically computed `ordersCount`, `lifetimeValue`, and `recentOrderDesc` calculated via Order relationships.

- **Method:** `GET`
- **Endpoint:** `/users/profile`
- **Authentication:** 🔒 **Required** (`BearerAuth` JWT)

#### Responses

**Status Code:** `200` — Patron profile with computed metrics

---

### PUT `/users/profile`

**Summary:** Update Patron Profile & FCM Token

Updates patron dossier, delivery address, Cloudinary avatar, and mobile/web FCM push token.

- **Method:** `PUT`
- **Endpoint:** `/users/profile`
- **Authentication:** 🔒 **Required** (`BearerAuth` JWT)

#### Request Body

- **Content-Type:** `application/json`

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `firstName` | `string` | No | - |
| `lastName` | `string` | No | - |
| `phone` | `string` | No | - |
| `address` | `string` | No | - |
| `city` | `string` | No | - |
| `country` | `string` | No | - |
| `fcmToken` | `string` | No | Firebase Cloud Messaging push token |
| `avatarUrl` | `string` | No | - |

**Example Request Payload:**
```json
{
  "firstName": "string",
  "lastName": "string",
  "phone": "string",
  "address": "string",
  "city": "string",
  "country": "string",
  "fcmToken": "string",
  "avatarUrl": "string"
}
```

#### Responses

**Status Code:** `200` — Profile updated

---


## Public Boutique & Products

### GET `/products`

**Summary:** Public Catalog Listing

- **Method:** `GET`
- **Endpoint:** `/products`
- **Authentication:** 🌐 **Public** (No auth token required)

#### Parameters

| Name | In | Type | Required | Description |
| :--- | :--- | :--- | :--- | :--- |
| `category` | `query` | `string` | No | - |
| `search` | `query` | `string` | No | - |
| `inStock` | `query` | `boolean` | No | - |
| `page` | `query` | `integer` | No | - |
| `pageSize` | `query` | `integer` | No | - |

#### Responses

**Status Code:** `200` — Filtered products with pagination

---

### GET `/products/categories`

**Summary:** Public Product Categories

- **Method:** `GET`
- **Endpoint:** `/products/categories`
- **Authentication:** 🌐 **Public** (No auth token required)

#### Responses

**Status Code:** `200` — List of product categories

---

### GET `/products/{id}`

**Summary:** Get Product Details

- **Method:** `GET`
- **Endpoint:** `/products/{id}`
- **Authentication:** 🌐 **Public** (No auth token required)

#### Parameters

| Name | In | Type | Required | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `path` | `string` | **Yes** | - |

#### Responses

**Status Code:** `200` — Product record

---


## Collections & Taxonomy

### GET `/categories`

**Summary:** List Public Collections & Taxonomy

- **Method:** `GET`
- **Endpoint:** `/categories`
- **Authentication:** 🌐 **Public** (No auth token required)

#### Parameters

| Name | In | Type | Required | Description |
| :--- | :--- | :--- | :--- | :--- |
| `subCategoryType` | `query` | `enum: metal | gemological | anatomical | collection` | No | - |

#### Responses

**Status Code:** `200` — Active collections

---

### GET `/categories/{id}`

**Summary:** Get Collection by ID or Slug

- **Method:** `GET`
- **Endpoint:** `/categories/{id}`
- **Authentication:** 🌐 **Public** (No auth token required)

#### Parameters

| Name | In | Type | Required | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `path` | `string` | **Yes** | - |

#### Responses

**Status Code:** `200` — Collection details

---


## Orders, Commissions & Payments

### POST `/orders`

**Summary:** Place New Commission Order (Flutterwave)

Initializes bespoke order, generates Flutterwave payment checkout session URL, creates linked transaction, and sends receipt.

- **Method:** `POST`
- **Endpoint:** `/orders`
- **Authentication:** 🌐 **Public** (No auth token required)

#### Request Body

- **Content-Type:** `application/json`

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `client` | `object` | No | - |
| `specimen` | `object` | No | - |
| `total` | `number` | No | Example: `24500` |
| `currency` | `string` | No | Example: `USD` |
| `shippingAddress` | `string` | No | - |

**Example Request Payload:**
```json
{
  "client": {
    "name": "Lord Sterling",
    "email": "sterling@mayfair.co.uk",
    "phone": "+44 20 7946 0992"
  },
  "specimen": {
    "title": "18K Gold Deep Cut (Top 8)",
    "specDetails": "18K Solid Yellow • VVS1 Pavé Inlay",
    "caratOrPurity": "18K Yellow Gold",
    "subType": "Haute Series",
    "qty": 1
  },
  "total": 24500,
  "currency": "USD",
  "shippingAddress": "string"
}
```

#### Responses

**Status Code:** `201` — Commission created. Returns `paymentUrl` and `flwRef`.

---

### GET `/orders/my-orders`

**Summary:** Get Patron Order History

- **Method:** `GET`
- **Endpoint:** `/orders/my-orders`
- **Authentication:** 🔒 **Required** (`BearerAuth` JWT)

#### Responses

**Status Code:** `200` — List of commissions for active patron

---

### GET `/orders/{id}`

**Summary:** Get Order Details

- **Method:** `GET`
- **Endpoint:** `/orders/{id}`
- **Authentication:** 🌐 **Public** (No auth token required)

#### Parameters

| Name | In | Type | Required | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `path` | `string` | **Yes** | - |

#### Responses

**Status Code:** `200` — Order details

---

### POST `/orders/{id}/cancel`

**Summary:** Cancel Pending Commission

- **Method:** `POST`
- **Endpoint:** `/orders/{id}/cancel`
- **Authentication:** 🔒 **Required** (`BearerAuth` JWT)

#### Parameters

| Name | In | Type | Required | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `path` | `string` | **Yes** | - |

#### Responses

**Status Code:** `200` — Order cancelled successfully

---

### GET `/orders/payment/verify/{reference}`

**Summary:** Verify Flutterwave Payment Session

- **Method:** `GET`
- **Endpoint:** `/orders/payment/verify/{reference}`
- **Authentication:** 🌐 **Public** (No auth token required)

#### Parameters

| Name | In | Type | Required | Description |
| :--- | :--- | :--- | :--- | :--- |
| `reference` | `path` | `string` | **Yes** | - |

#### Responses

**Status Code:** `200` — Payment verified and order settled

---

### POST `/orders/webhook/flutterwave`

**Summary:** Flutterwave Webhook Callback

- **Method:** `POST`
- **Endpoint:** `/orders/webhook/flutterwave`
- **Authentication:** 🌐 **Public** (No auth token required)

#### Parameters

| Name | In | Type | Required | Description |
| :--- | :--- | :--- | :--- | :--- |
| `verif-hash` | `header` | `string` | **Yes** | - |

#### Responses

**Status Code:** `200` — Webhook processed

---


## Bespoke Consultations & VIP Concierge

### POST `/consultations`

**Summary:** Book Bespoke Haute Consultation

Registers custom fitting & 3D scan inquiry. Sends confirmation email to patron and alerts Atelier Concierge.

- **Method:** `POST`
- **Endpoint:** `/consultations`
- **Authentication:** 🌐 **Public** (No auth token required)

#### Request Body

- **Content-Type:** `application/json`

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `fullName` | `string` | **Yes** | Example: `Lord Sterling` |
| `email` | `string (email)` | **Yes** | Example: `sterling@mayfair.co.uk` |
| `phone` | `string` | **Yes** | Example: `+44 20 7946 0992` |
| `archPlacement` | `string` | No | Example: `Top 8 Teeth` |
| `preciousMetal` | `string` | No | Example: `18K Royal Yellow Gold` |
| `diamondGrade` | `string` | No | Example: `VVS1 Colorless Diamonds` |
| `notes` | `string` | No | Example: `3D impression scan requested in London studio` |

**Example Request Payload:**
```json
{
  "fullName": "Lord Sterling",
  "email": "sterling@mayfair.co.uk",
  "phone": "+44 20 7946 0992",
  "archPlacement": "Top 8 Teeth",
  "preciousMetal": "18K Royal Yellow Gold",
  "diamondGrade": "VVS1 Colorless Diamonds",
  "notes": "3D impression scan requested in London studio"
}
```

#### Responses

**Status Code:** `201` — Consultation case registered

---

### GET `/consultations`

**Summary:** Admin: List Consultations

- **Method:** `GET`
- **Endpoint:** `/consultations`
- **Authentication:** 🔒 **Required** (`BearerAuth` JWT)

#### Responses

**Status Code:** `200` — List of consultation cases

---

### GET `/consultations/{id}`

**Summary:** Admin: Get Consultation Details

- **Method:** `GET`
- **Endpoint:** `/consultations/{id}`
- **Authentication:** 🔒 **Required** (`BearerAuth` JWT)

#### Parameters

| Name | In | Type | Required | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `path` | `string` | **Yes** | - |

#### Responses

**Status Code:** `200` — Consultation dossier

---


## Customer Support Tickets

### POST `/tickets`

**Summary:** Create Customer Support Ticket

Customer submits a new inquiry docket. Returns generated ticket number (`HAK-XXXXXX`).

- **Method:** `POST`
- **Endpoint:** `/tickets`
- **Authentication:** 🌐 **Public** (No auth token required)

#### Request Body

- **Content-Type:** `application/json`

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `customerName` | `string` | **Yes** | Example: `Lord Sterling` |
| `customerEmail` | `string (email)` | **Yes** | Example: `sterling@mayfair.co.uk` |
| `customerPhone` | `string` | No | Example: `+44 20 7946 0992` |
| `subject` | `string` | **Yes** | Example: `Impression kit delivery tracking` |
| `category` | `enum: Order Inquiry | Bespoke Commission | Fitting & Impression | Payment & Bullion | Vault Care | General` | **Yes** | - |
| `priority` | `enum: LOW | NORMAL | HIGH | URGENT` | No | - |
| `orderId` | `string` | No | Example: `AUR-98214` |
| `message` | `string` | **Yes** | Example: `When will the 3D impression kit arrive in Mayfair?` |

**Example Request Payload:**
```json
{
  "customerName": "Lord Sterling",
  "customerEmail": "sterling@mayfair.co.uk",
  "customerPhone": "+44 20 7946 0992",
  "subject": "Impression kit delivery tracking",
  "category": "Order Inquiry",
  "priority": "NORMAL",
  "orderId": "AUR-98214",
  "message": "When will the 3D impression kit arrive in Mayfair?"
}
```

#### Responses

**Status Code:** `201` — Support docket initiated

```json
{
  "success": true,
  "data": {
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "ticketNumber": "HAK-894102",
    "userId": "string",
    "customerName": "Lord Sterling",
    "customerEmail": "sterling@mayfair.co.uk",
    "customerPhone": "+44 20 7946 0992",
    "subject": "Impression Mold Sizing Guidance",
    "category": "Order Inquiry",
    "priority": "LOW",
    "status": "OPEN",
    "orderId": "AUR-98214",
    "message": "string",
    "assignedStaff": "Master Jeweler Tariq",
    "adminNotes": "string",
    "responses": [
      {
        "id": "string",
        "sender": "customer",
        "senderName": "string",
        "message": "string",
        "createdAt": "2026-10-03T12:00:00.000Z"
      }
    ],
    "createdAt": "2026-10-03T12:00:00.000Z",
    "updatedAt": "2026-10-03T12:00:00.000Z"
  }
}
```

---

### GET `/tickets/{id}`

**Summary:** Get Support Ticket & Thread History

Retrieves ticket by internal ID or public `ticketNumber` (`HAK-...`), along with all responses.

- **Method:** `GET`
- **Endpoint:** `/tickets/{id}`
- **Authentication:** 🌐 **Public** (No auth token required)

#### Parameters

| Name | In | Type | Required | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `path` | `string` | **Yes** | - |

#### Responses

**Status Code:** `200` — Ticket details and correspondence thread

```json
{
  "success": true,
  "data": {
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "ticketNumber": "HAK-894102",
    "userId": "string",
    "customerName": "Lord Sterling",
    "customerEmail": "sterling@mayfair.co.uk",
    "customerPhone": "+44 20 7946 0992",
    "subject": "Impression Mold Sizing Guidance",
    "category": "Order Inquiry",
    "priority": "LOW",
    "status": "OPEN",
    "orderId": "AUR-98214",
    "message": "string",
    "assignedStaff": "Master Jeweler Tariq",
    "adminNotes": "string",
    "responses": [
      {
        "id": "string",
        "sender": "customer",
        "senderName": "string",
        "message": "string",
        "createdAt": "2026-10-03T12:00:00.000Z"
      }
    ],
    "createdAt": "2026-10-03T12:00:00.000Z",
    "updatedAt": "2026-10-03T12:00:00.000Z"
  }
}
```

**Status Code:** `404` — Ticket not found

---

### POST `/tickets/{id}/reply`

**Summary:** Customer Reply to Ticket Thread

Appends a customer response to the ticket conversation.

- **Method:** `POST`
- **Endpoint:** `/tickets/{id}/reply`
- **Authentication:** 🌐 **Public** (No auth token required)

#### Parameters

| Name | In | Type | Required | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `path` | `string` | **Yes** | - |

#### Request Body

- **Content-Type:** `application/json`

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `message` | `string` | **Yes** | Example: `I have received the impression putty. How many minutes should I hold?` |
| `senderName` | `string` | No | Example: `Lord Sterling` |

**Example Request Payload:**
```json
{
  "message": "I have received the impression putty. How many minutes should I hold?",
  "senderName": "Lord Sterling"
}
```

#### Responses

**Status Code:** `200` — Reply appended to ticket thread

```json
{
  "success": true,
  "data": {
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "ticketNumber": "HAK-894102",
    "userId": "string",
    "customerName": "Lord Sterling",
    "customerEmail": "sterling@mayfair.co.uk",
    "customerPhone": "+44 20 7946 0992",
    "subject": "Impression Mold Sizing Guidance",
    "category": "Order Inquiry",
    "priority": "LOW",
    "status": "OPEN",
    "orderId": "AUR-98214",
    "message": "string",
    "assignedStaff": "Master Jeweler Tariq",
    "adminNotes": "string",
    "responses": [
      {
        "id": "string",
        "sender": "customer",
        "senderName": "string",
        "message": "string",
        "createdAt": "2026-10-03T12:00:00.000Z"
      }
    ],
    "createdAt": "2026-10-03T12:00:00.000Z",
    "updatedAt": "2026-10-03T12:00:00.000Z"
  }
}
```

---


## Patron Notifications

### GET `/notifications`

**Summary:** Get Patron Notifications Feed

- **Method:** `GET`
- **Endpoint:** `/notifications`
- **Authentication:** 🔒 **Required** (`BearerAuth` JWT)

#### Responses

**Status Code:** `200` — In-app notification records

---

### PUT `/notifications/{id}/read`

**Summary:** Mark Notification as Read

- **Method:** `PUT`
- **Endpoint:** `/notifications/{id}/read`
- **Authentication:** 🔒 **Required** (`BearerAuth` JWT)

#### Parameters

| Name | In | Type | Required | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `path` | `string` | **Yes** | - |

#### Responses

**Status Code:** `200` — Marked read

---

### PUT `/notifications/read-all`

**Summary:** Mark All Notifications as Read

- **Method:** `PUT`
- **Endpoint:** `/notifications/read-all`
- **Authentication:** 🔒 **Required** (`BearerAuth` JWT)

#### Responses

**Status Code:** `200` — All marked read

---


## System & Health

### GET `/health`

**Summary:** API Health Check

- **Method:** `GET`
- **Endpoint:** `/health`
- **Authentication:** 🌐 **Public** (No auth token required)

#### Responses

**Status Code:** `200` — Service is healthy

---

## Core Data Models & Schemas

### Model: `User`

| Field | Type | Description / Constraints |
| :--- | :--- | :--- |
| `id` | `string (uuid)` | - |
| `email` | `string (email)` | - |
| `fullName` | `string` | - |
| `role` | `enum: user | admin | staff | manager` |  Enum: [user, admin, staff, manager] |
| `phone` | `string` | - |
| `location` | `string` | - |
| `tier` | `string` | - |
| `standing` | `enum: ACTIVE | FITTING MOLD | SUSPENDED` |  Enum: [ACTIVE, FITTING MOLD, SUSPENDED] |
| `ordersCount` | `integer` | Dynamically computed via Order relationship |
| `lifetimeValue` | `number` | Dynamically computed via Order relationship |
| `recentOrderDesc` | `string` | Dynamically computed via Order relationship |
| `profilePic` | `string` | - |

**Model Schema Example:**
```json
{
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "email": "patron@aurumatelier.com",
  "fullName": "string",
  "role": "user",
  "phone": "string",
  "location": "string",
  "tier": "string",
  "standing": "ACTIVE",
  "ordersCount": 100,
  "lifetimeValue": 100,
  "recentOrderDesc": "string",
  "profilePic": "string"
}
```

---

### Model: `Product`

| Field | Type | Description / Constraints |
| :--- | :--- | :--- |
| `id` | `string (uuid)` | - |
| `name` | `string` | - |
| `sku` | `string` | - |
| `category` | `string` | - |
| `price` | `number` | Price in USD (0 for bespoke/quote on demand) |
| `stock` | `integer` | - |
| `description` | `string` | - |
| `imageUrl` | `string` | - |
| `rating` | `number` | - |
| `inStock` | `boolean` | - |
| `images` | Array<`string`> | - |
| `tags` | Array<`string`> | - |

**Model Schema Example:**
```json
{
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "name": "string",
  "sku": "string",
  "category": "string",
  "price": 100,
  "stock": 100,
  "description": "string",
  "imageUrl": "string",
  "rating": 100,
  "inStock": true,
  "images": [
    "string"
  ],
  "tags": [
    "string"
  ]
}
```

---

### Model: `Category`

| Field | Type | Description / Constraints |
| :--- | :--- | :--- |
| `id` | `string (uuid)` | - |
| `name` | `string` |  (e.g. `Royal Yellow Gold`) |
| `slug` | `string` |  (e.g. `royal-yellow-gold`) |
| `description` | `string` | - |
| `imageUrl` | `string` | - |
| `subCategoryType` | `enum: metal | gemological | anatomical | collection` |  Enum: [metal, gemological, anatomical, collection] |
| `isActive` | `boolean` | - |
| `productCount` | `integer` | - |

**Model Schema Example:**
```json
{
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "name": "Royal Yellow Gold",
  "slug": "royal-yellow-gold",
  "description": "string",
  "imageUrl": "string",
  "subCategoryType": "metal",
  "isActive": true,
  "productCount": 100
}
```

---

### Model: `Order`

| Field | Type | Description / Constraints |
| :--- | :--- | :--- |
| `id` | `string` |  (e.g. `AUR-98214`) |
| `date` | `string` | - |
| `userId` | `string` | - |
| `client` | `object` | - |
| `specimen` | `object` | - |
| `total` | `number` | - |
| `paymentStatus` | `enum: PAID | PENDING | REFUNDED` |  Enum: [PAID, PENDING, REFUNDED] |
| `orderStatus` | `enum: PROCESSING | IN PRODUCTION | SHIPPED | DELIVERED | CANCELLED` |  Enum: [PROCESSING, IN PRODUCTION, SHIPPED, DELIVERED, CANCELLED] |
| `pipelineStage` | `enum: 1 | 2 | 3 | 4` |  Enum: [1, 2, 3, 4] |
| `paymentUrl` | `string (uri)` | - |
| `flwRef` | `string` | - |
| `trackingNumber` | `string` | - |
| `starred` | `boolean` | - |

**Model Schema Example:**
```json
{
  "id": "AUR-98214",
  "date": "string",
  "userId": "string",
  "client": {
    "name": "string",
    "email": "string",
    "phone": "string",
    "avatarInitials": "string",
    "tier": "string",
    "address": "string"
  },
  "specimen": {
    "title": "string",
    "specDetails": "string",
    "caratOrPurity": "string",
    "subType": "string",
    "qty": 100
  },
  "total": 100,
  "paymentStatus": "PAID",
  "orderStatus": "PROCESSING",
  "pipelineStage": 1,
  "paymentUrl": "https://images.unsplash.com/photo-example",
  "flwRef": "string",
  "trackingNumber": "string",
  "starred": true
}
```

---

### Model: `Transaction`

| Field | Type | Description / Constraints |
| :--- | :--- | :--- |
| `id` | `string` |  (e.g. `#TX-98214`) |
| `date` | `string` | - |
| `customer` | `object` | - |
| `linkedOrder` | `string` |  (e.g. `#AUR-98214`) |
| `gateway` | `string` |  (e.g. `Flutterwave Card`) |
| `grossAmount` | `number` | - |
| `status` | `enum: Settled | In Escrow | Refunded | Pending` |  Enum: [Settled, In Escrow, Refunded, Pending] |
| `currency` | `string` |  (e.g. `USD`) |

**Model Schema Example:**
```json
{
  "id": "#TX-98214",
  "date": "string",
  "customer": {
    "name": "string",
    "clientType": "string",
    "avatarInitials": "string"
  },
  "linkedOrder": "#AUR-98214",
  "gateway": "Flutterwave Card",
  "grossAmount": 100,
  "status": "Settled",
  "currency": "USD"
}
```

---

### Model: `Consultation`

| Field | Type | Description / Constraints |
| :--- | :--- | :--- |
| `id` | `string` | - |
| `fullName` | `string` | - |
| `email` | `string (email)` | - |
| `phone` | `string` | - |
| `archPlacement` | `string` |  (e.g. `Top 8 Teeth`) |
| `preciousMetal` | `string` |  (e.g. `18K Royal Yellow Gold`) |
| `diamondGrade` | `string` |  (e.g. `VVS1 Colorless Diamonds`) |
| `notes` | `string` | - |
| `status` | `enum: Pending | Confirmed | Completed | Cancelled` |  Enum: [Pending, Confirmed, Completed, Cancelled] |
| `appointmentDate` | `string` | - |

**Model Schema Example:**
```json
{
  "id": "string",
  "fullName": "string",
  "email": "patron@aurumatelier.com",
  "phone": "string",
  "archPlacement": "Top 8 Teeth",
  "preciousMetal": "18K Royal Yellow Gold",
  "diamondGrade": "VVS1 Colorless Diamonds",
  "notes": "string",
  "status": "Pending",
  "appointmentDate": "string"
}
```

---

### Model: `SupportTicket`

| Field | Type | Description / Constraints |
| :--- | :--- | :--- |
| `id` | `string (uuid)` | - |
| `ticketNumber` | `string` |  (e.g. `HAK-894102`) |
| `userId` | `string` | - |
| `customerName` | `string` |  (e.g. `Lord Sterling`) |
| `customerEmail` | `string (email)` |  (e.g. `sterling@mayfair.co.uk`) |
| `customerPhone` | `string` |  (e.g. `+44 20 7946 0992`) |
| `subject` | `string` |  (e.g. `Impression Mold Sizing Guidance`) |
| `category` | `enum: Order Inquiry | Bespoke Commission | Fitting & Impression | Payment & Bullion | Vault Care | General` |  Enum: [Order Inquiry, Bespoke Commission, Fitting & Impression, Payment & Bullion, Vault Care, General] |
| `priority` | `enum: LOW | NORMAL | HIGH | URGENT` |  Enum: [LOW, NORMAL, HIGH, URGENT] |
| `status` | `enum: OPEN | IN_PROGRESS | WAITING_CLIENT | RESOLVED | CLOSED` |  Enum: [OPEN, IN_PROGRESS, WAITING_CLIENT, RESOLVED, CLOSED] |
| `orderId` | `string` |  (e.g. `AUR-98214`) |
| `message` | `string` | - |
| `assignedStaff` | `string` |  (e.g. `Master Jeweler Tariq`) |
| `adminNotes` | `string` | - |
| `responses` | Array<`TicketResponseItem`> | - |
| `createdAt` | `string (date-time)` | - |
| `updatedAt` | `string (date-time)` | - |

**Model Schema Example:**
```json
{
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "ticketNumber": "HAK-894102",
  "userId": "string",
  "customerName": "Lord Sterling",
  "customerEmail": "sterling@mayfair.co.uk",
  "customerPhone": "+44 20 7946 0992",
  "subject": "Impression Mold Sizing Guidance",
  "category": "Order Inquiry",
  "priority": "LOW",
  "status": "OPEN",
  "orderId": "AUR-98214",
  "message": "string",
  "assignedStaff": "Master Jeweler Tariq",
  "adminNotes": "string",
  "responses": [
    {
      "id": "string",
      "sender": "customer",
      "senderName": "string",
      "message": "string",
      "createdAt": "2026-10-03T12:00:00.000Z"
    }
  ],
  "createdAt": "2026-10-03T12:00:00.000Z",
  "updatedAt": "2026-10-03T12:00:00.000Z"
}
```

---

### Model: `TicketResponseItem`

| Field | Type | Description / Constraints |
| :--- | :--- | :--- |
| `id` | `string` | - |
| `sender` | `enum: customer | admin | staff` |  Enum: [customer, admin, staff] |
| `senderName` | `string` | - |
| `message` | `string` | - |
| `createdAt` | `string (date-time)` | - |

**Model Schema Example:**
```json
{
  "id": "string",
  "sender": "customer",
  "senderName": "string",
  "message": "string",
  "createdAt": "2026-10-03T12:00:00.000Z"
}
```

---

### Model: `ApiResponse`

| Field | Type | Description / Constraints |
| :--- | :--- | :--- |
| `success` | `boolean` |  (e.g. `true`) |
| `data` | `object` | - |
| `message` | `string` |  (e.g. `Operation completed successfully`) |

**Model Schema Example:**
```json
{
  "success": true,
  "data": {},
  "message": "Operation completed successfully"
}
```

---

