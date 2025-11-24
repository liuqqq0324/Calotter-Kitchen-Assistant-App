---
date: 2025-05-23
tags:
  - INFOSYS-778
  - ProjectProposal
version: 1
---


# FR and NFR
## Functional Requirements (FR)
> [!info] FR levels
> The FR is separated into three levels, with a x.x.x representation, the 3-rd level should be detailed user stories.

- User Account & Personalization [fr1.0.0]
	- User must be able to **register** with email and password. [fr1.1.0]
		- As a user, I can register with email, username, password. [fr1.1.1]
		- As a user, I want to receive email verification code to ensure my account safety. [fr1.1.2]
		- As a user, I want to register with Google / Facebook account so that I can save time finishing registration field. [fr1.1.3]
	- User must be able to **login** with email and password or third-party authentication (e.g., Google or Apple). [fr1.2.0]
		-  
	- User must be able to **logout**. [fr1.3.0]
	- User should be able to **edit configurations and user profiles** (such as dietary preferences, taboos, allergies and ages) so that the system could suggest more personalized recipes. [fr1.4.0]
- Inventory Management [f2.0.0]
	- User must be able to **upload images / videos** or even dynamically **scanning Ingredients**. [fr2.1.0]
	- User must be able to **receive a list** of scanned ingredients. [fr2.2.0]
	- User can **modify, add and delete the list item** of scanned item (especially the item which the system is not certain about). [fr2.3.0]
	- User should be able to **manually manage the ingredient list**. [fr2.4.0]
	- User should be able to **specify the amount** (e.g., "three" / "500g") and **expired date** of the ingredients. [fr2.5.0]
- Recipe Generation, Planning and management [fr3.0.0]
	- The system should be able to call *generative AI API* to **generate recipes** according to inventory ingredients and user profile settings. [fr3.1.0]
	- User should be able to **search or filter** the recipes according to name, time of cooking, recipe category or ingredients used for the recipe. [fr3.2.0]
	- When the user is browsing a recipe, the system is expected to **show the required ingredients and the expected amount of ingredient consumption**, if the inventory is sufficient to finish the recipe, . [fr3.3.0]
	- The system should be able to generate a shopping list of *missing ingredient* to inform the user to purchase. [fr3.4.0]
	- User should be able to manually add recipes or missing ingredients to the shopping list. [fr3.5.0]
- Cooking Assistant [fr4.0.0]
	- The system should be able to create a cooking guideline (with many steps) for users to follow. [fr4.1.0]
	- The cooking guidance page should include a *hands-free mode*, such as navigating steps via voice commands (e.g., "next step", "repeat") or automatically reading steps aloud. [4.2.0]
	- The system should provide build-in timer for cooks to follow. [4.3.0]
	- **Optional** - The system should provide timely feedback during the cooking process (for example, analyze the status of the current process, to suggest the cooks how could they do better or their supposed action for next step) [4.4.0]

## Non-Functional Requirements (NFRs)
> [!INFO] NFR levels
> The NFRs should have 2 levels supposed.

