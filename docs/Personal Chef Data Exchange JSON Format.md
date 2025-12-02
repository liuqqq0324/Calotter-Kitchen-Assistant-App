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