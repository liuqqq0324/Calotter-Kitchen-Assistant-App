---
date: 2025-11-26
version: 1
tags:
  - api
  - documentation
  - INFOSYS-778
  - GroupProject
---



### `F` represents *Frontend app*, `B` represents *Backend app*, `A` represents *AI-Engine* (e.g., `F -> B` refers to frontend app is sending data to backend API).

# A. Prompt JSON

## 1. Backend -> AI Engine
```JSON

```

# B. Generated recipe JSON

## 1. AI-Engine -> Backend
```JSON

```


# C. UMS (User Management Service)
## 1. Registration Request (F -> B)

- Request method and path: `POST /api/ums/auth/register`
- Request header: Context-Type: application/json
- Request body:

## 1. Registration Request (F -> B)

```
```

# D. Inventory Management

> **Note:**
> This section requires the Backend to maintain three "Standard Libraries" (defined by developers):
> 1. **Standard Food Library**: Contains standard names, example images, and valid unit types for each food.
> 2. **Standard Cookware Library**: Contains standard cookware names and IDs.
> 3. **Standard Seasoning Library**: Contains standard seasoning names and IDs.

## 1. Get User Inventory (F -> B)
* **Description**: Fetches all ingredients in the user's current inventory.
* **Logic**: Allows multiple entries with the same `name` but different `expiry_date`. Each entry must have a unique `inventory_id`.
* **Response (JSON)**:
```JSON
[
  {
    "inventory_id": "unique_uuid_v4_1",
    "name": "Milk",
    "image_url": "[https://server.com/static/milk.png](https://server.com/static/milk.png)",
    "quantity": 2,
    "unit": "Liter",
    "expiry_date": "2025-12-01"
  },
  {
    "inventory_id": "unique_uuid_v4_2",
    "name": "Milk",
    "image_url": "[https://server.com/static/milk.png](https://server.com/static/milk.png)",
    "quantity": 1,
    "unit": "Liter",
    "expiry_date": "2025-12-05" // Same name, different expiry allowed
  },
  {
    "inventory_id": "unique_uuid_v4_3",
    "name": "Eggs",
    "image_url": "[https://server.com/static/eggs.png](https://server.com/static/eggs.png)",
    "quantity": 12,
    "unit": "Pcs",
    "expiry_date": "2025-11-30"
  }
]
```

## 2. Add Inventory Item (F -> B)
* **Description**: Adds a new item to the user's inventory.
* **Request (JSON)**:
```JSON
{
  "name": "Chicken Breast", // Must match an entry in Standard Food Library
  "quantity": 500,
  "unit": "g", // Must match valid units for this food in Standard Library
  "expiry_date": "2025-12-10"
}
```
* **Response (JSON)**:
```JSON
{
  "inventory_id": "new_generated_uuid",
  "status": "success",
  "message": "Item added"
}
```

## 3. Edit Inventory Item (F -> B)
* **Description**: Updates quantity, unit, or expiry date.
* **Note**: inventory_id is required to target the specific batch (e.g., the milk expiring on the 1st, not the 5th).
* **Request (JSON)**:
```JSON
{
  "inventory_id": "unique_uuid_v4_1",
  "quantity": 1.5, // Updated quantity
  "unit": "Liter",
  "expiry_date": "2025-12-02" // Updated expiry
}
```

## 4. Delete Inventory Item (F -> B)
* **Description**: Removes a specific item batch from inventory.
* **Request (JSON)**:
```JSON
{
  "inventory_id": "unique_uuid_v4_2" // Deletes only this specific entry, other "Milk" entries remain
}
```
## 5. Toggle Cookware Availability (F -> B)
* **Description**: Toggles whether a user owns/has access to a specific standard cookware.
* **Request (JSON)**:
```JSON
{
  "cookware_id": "cw_001",
  "name": "Non-stick Pan"
}
```
* **Response (JSON)**:
```JSON
{
{
  "cookware_id": "cw_001",
  "name": "Non-stick Pan",
  "is_available": true // Boolean flipped by backend based on previous state
}
}
```

## 6. Toggle Seasoning Availability (F -> B)
* **Description**: Toggles availability of a seasoning. (No expiry logic required).
```JSON
{
  "seasoning_id": "s_055",
  "name": "Black Pepper"
}
```
* **Response (JSON)**:
```JSON
{
  "seasoning_id": "s_055",
  "name": "Black Pepper",
  "is_available": false // Boolean flipped by backend
}
Request method and path: POST /api/ums/auth/register

Request header: Context-Type: application/json

Request body:

```json
{
	"username": "UserName",
	"password": "UserPassword123",
	"confirmPassword": "UserPassword123",
	"email": "user.email@example.com"
}
```

## 2. Registration Response (B -> F)

```json
{
	"userId": 2345678765678,
	"message": "User registered successfully"
}
```

## 3. Login Request (F -> B)

Request method and path: POST /api/ums/auth/login

Request header: Context-Type: application/json

Request body:

```json
{
	"identifier": "UsernameOrEmail",
	"password": "UserPassword123"
}
```

## 4. Login Response (B -> F)

```json
{
	"userId": 2345678765678,
	"token": {
		"accessToken": "56ncieni-oenlnoicsjoijjfofoi",
		"expiresIn": 3000
	}
}
```

## 5. User Brief Info Request (F -> B)

Request method and path: GET /api/ums/user?id=2345678765678

Request header:

Authorization: Bearer

Context-Type: application/json

## 6. User Brief Info Response (B -> F)

```json
{
	"userId": 2345678765678,
	"userName": "UserName",
	"email": "user.email@example.com",
	"profile": {
		"age": 28,
		"height": 178,
		"weight": 72
	}
}
```

## 7. Get User Preferences Request (F -> B)

Request method and path: GET /api/ums/user/preferences?id=2345678765678

Request header:

Authorization: Bearer

Context-Type: application/json

## 8. Get User Preferences Response (B -> F)

```json
{
	"userId": 2345678765678,
	"preferences": {
		"dietaryType": "vegetarian",
		"cuisineTypes": ["Italian", "Chinese", "Japanese"],
		"spiceLevel": "medium",
		"cookingTimePreference": "30-60min"
	}
}
```

## 9. Update User Preferences Request (F -> B)

Request method and path: PUT /api/ums/user/preferences?id=2345678765678

Request header:

Authorization: Bearer

Context-Type: application/json

Request body:

```json
{
	"dietaryType": "vegetarian",
	"cuisineTypes": ["Italian", "Chinese", "Japanese"],
	"spiceLevel": "medium",
	"cookingTimePreference": "30-60min"
}
```

## 10. Update User Preferences Response (B -> F)

```json
{
	"userId": 2345678765678,
	"message": "User preferences updated successfully"
}
```

## 11. Get User Taboos Request (F -> B)

Request method and path: GET /api/ums/user/taboos?id=2345678765678

Request header:

Authorization: Bearer

Context-Type: application/json

## 12. Get User Taboos Response (B -> F)

```json
{
	"userId": 2345678765678,
	"taboos": [
		"pork",
		"beef"
	]
}
```

## 13. Update User Taboos Request (F -> B)

Request method and path: PUT /api/ums/user/taboos?id=2345678765678

Request header:

Authorization: Bearer

Context-Type: application/json

Request body:

```json
{
	"taboos": [
		"pork",
		"beef",
		"alcohol"
	]
}
```

## 14. Update User Taboos Response (B -> F)

```json
{
	"userId": 2345678765678,
	"message": "User taboos updated successfully"
}
```

## 15. Get User Allergies Request (F -> B)

Request method and path: GET /api/ums/user/allergies?id=2345678765678

Request header:

Authorization: Bearer

Context-Type: application/json

## 16. Get User Allergies Response (B -> F)

```json
{
	"userId": 2345678765678,
	"allergies": [
		"peanuts",
		"shellfish",
		"dairy"
	]
}
```

## 17. Update User Allergies Request (F -> B)

Request method and path: PUT /api/ums/user/allergies?id=2345678765678

Request header:

Authorization: Bearer

Context-Type: application/json

Request body:

```json
{
	"allergies": [
		"peanuts",
		"shellfish",
		"dairy",
		"eggs"
	]
}
```

## 18. Update User Allergies Response (B -> F)

```json
{
	"userId": 2345678765678,
	"message": "User allergies updated successfully"
}
```
