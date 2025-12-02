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

```JSON
{
	"username": "UserName",
	"password": "UserPassword123",
	"confirmPassword": "UserPassword123",
	"email": "user.email@example.com"
}
```


## 2. Registration Response (B -> F)
```JSON
{
	"userId": 2345678765678,
	"message": "User registered successfully"
}
```

## 3. Login Request (F -> B)
- Request method and path: `POST /api/ums/auth/login`
- Request header: Context-Type: application/json
- Request body:
```JSON
{
	"identifier": "UsernameOrEmail",
	"password": "UserPassword123"
}
```

## 4. Login Response (B -> F)
```JSON
{
	"userId": 2345678765678,
	"token": {
		"accessToken": "56ncieni-oenlnoicsjoijjfofoi",
		"expiresIn": 3000
	}
}
```

## 5. User Brief Info Request(F -> B)
- Request method and path: `GET /api/ums/user?id=2345678765678`
- Request header: 
	- Authorization: Bearer
	- Context-Type: application/json

## 6. User Brief Info Response (B -> F)
```JSON
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

## 

# D. IMS (Inventory Management Service)
## 1. Add to Inventory Request (F -> B)

# E. CMS (Cooking Management Service)

# F. RMS (Recipe Management Service)