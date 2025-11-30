DROP TABLE IF EXISTS sous_chef_ims.ims_ingredient;
CREATE TABLE sous_chef_ims.ims_ingredient(
    id SERIAL NOT NULL,
    user_id INT8 NOT NULL,
    ingredient_id INT8 NOT NULL,
    quantity DECIMAL(10,2),
    current_unit VARCHAR(20),
    expiration_date DATE,
    storage_location VARCHAR(50),
    category_type VARCHAR(20),
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ims.ims_ingredient.id IS 'Pantry id;Pantry ID (PK)';
COMMENT ON COLUMN sous_chef_ims.ims_ingredient.user_id IS 'User id;Whose pantry (FK, user_id -> user.id)';
COMMENT ON COLUMN sous_chef_ims.ims_ingredient.ingredient_id IS 'Ingredient id;The associated ingredient (FK, ingredient_id -> ingredient.id)';
COMMENT ON COLUMN sous_chef_ims.ims_ingredient.quantity IS 'Quantity;Quantity of the ingredient';
COMMENT ON COLUMN sous_chef_ims.ims_ingredient.current_unit IS 'Current unit;Current unit of the ingredient (e.g., g, ml, ea...)';
COMMENT ON COLUMN sous_chef_ims.ims_ingredient.expiration_date IS 'Date of expiration;When the ingredient expires (for expiration display and reminder function)';
COMMENT ON COLUMN sous_chef_ims.ims_ingredient.storage_location IS 'Location of storage;Where the ingredient stores (e.g., refrigerator, cabinetry)';
COMMENT ON COLUMN sous_chef_ims.ims_ingredient.category_type IS 'Type of category;Redundant field or enumeration (e.g., "INGREDIENT" or "CONDIMENT")';
COMMENT ON TABLE sous_chef_ims.ims_ingredient IS 'ims_ingredient;This table stores all users' ingredients. Each record contains the ingredient's basic information and specifies which user owns it.';

CREATE INDEX gk_user_pantry_user_id ON sous_chef_ims.ims_ingredient (
    user_id ASC
);
COMMENT ON INDEX sous_chef_ims.gk_user_pantry_user_id IS 'General index of user id;The general index of user_id FK to id in user table';
CREATE INDEX gk_user_pantry_ingredient_id ON sous_chef_ims.ims_ingredient (
    ingredient_id ASC
);
COMMENT ON INDEX sous_chef_ims.gk_user_pantry_ingredient_id IS 'General index of ingredient id;The general index of ingredient_id FK to id in ingredient table';