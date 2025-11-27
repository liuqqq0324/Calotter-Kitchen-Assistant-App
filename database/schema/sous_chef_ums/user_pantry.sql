DROP TABLE IF EXISTS sous_chef_ums.user_pantry;
CREATE TABLE sous_chef_ums.user_pantry(
    id SERIAL NOT NULL,
    user_id INT8 NOT NULL,
    ingredient_id INT8 NOT NULL,
    quantity DECIMAL(10,2),
    unit VARCHAR(20),
    expiration_date DATE,
    storage_location VARCHAR(50),
    category_type VARCHAR(20),
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ums.user_pantry.id IS 'Pantry id;Pantry ID (PK)';
COMMENT ON COLUMN sous_chef_ums.user_pantry.user_id IS 'User id;Whose pantry (FK, user_id -> users.id)';
COMMENT ON COLUMN sous_chef_ums.user_pantry.ingredient_id IS 'Ingredient id;The associated ingredient (FK, ingredient_id -> ingredients.id)';
COMMENT ON COLUMN sous_chef_ums.user_pantry.quantity IS 'Quantity;Quantity of the ingredient';
COMMENT ON COLUMN sous_chef_ums.user_pantry.unit IS 'Unit;Unit of the ingredient (e.g., g, ml, ea...)';
COMMENT ON COLUMN sous_chef_ums.user_pantry.expiration_date IS 'Date of expiration;When the ingredient expires (for expiration display and reminder function)';
COMMENT ON COLUMN sous_chef_ums.user_pantry.storage_location IS 'Location of storage;Where the ingredient stores (e.g., refrigerator, cabinetry)';
COMMENT ON COLUMN sous_chef_ums.user_pantry.category_type IS 'Type of category;Redundant field or enumeration (e.g., "INGREDIENT" or "CONDIMENT")';
COMMENT ON TABLE sous_chef_ums.user_pantry IS 'user_pantry;Pantry of user. Stores different types of ingredients.';

CREATE INDEX gk_user_pantry_user_id ON sous_chef_ums.user_pantry (
    user_id ASC
);
COMMENT ON INDEX sous_chef_ums.gk_user_pantry_user_id IS 'General index of user id;The general index of user_id FK to id in users table';
CREATE INDEX gk_user_pantry_ingredient_id ON sous_chef_ums.user_pantry (
    ingredient_id ASC
);
COMMENT ON INDEX sous_chef_ums.gk_user_pantry_ingredient_id IS 'General index of ingredient id;The general index of ingredient_id FK to id in ingredients table';