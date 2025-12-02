DROP TABLE IF EXISTS sous_chef_rms.rms_ingredient;
CREATE TABLE sous_chef_rms.rms_ingredient(
    id SERIAL NOT NULL,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    standard_unit VARCHAR(20),
    nutrition_info JSONB,
    storage_advice TEXT,
    image_url VARCHAR(255),
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_rms.rms_ingredient.id IS 'Ingredient id;Ingredient ID (PK)';
COMMENT ON COLUMN sous_chef_rms.rms_ingredient.name IS 'Ingredient name;Ingredient name (e.g., "tomato")';
COMMENT ON COLUMN sous_chef_rms.rms_ingredient.category IS 'Category;Ingredient category (e.g., "vegetable")';
COMMENT ON COLUMN sous_chef_rms.rms_ingredient.standard_unit IS 'Standard unit;Standard unit (e.g., "gram/g")';
COMMENT ON COLUMN sous_chef_rms.rms_ingredient.nutrition_info IS 'Nutrition information;Nutrition value (e.g., { "protein": "xxx g/kg", "carbohydrates": "xxx g/kg" }';
COMMENT ON COLUMN sous_chef_rms.rms_ingredient.storage_advice IS 'Advice for the ingredient storage;Storage advice (for AI assistant prompt, e.g., "Store in the refrigerator or in a cool, dark place.")';
COMMENT ON COLUMN sous_chef_rms.rms_ingredient.image_url IS 'Standard image;Standard image URL for ingredient image';
COMMENT ON TABLE sous_chef_rms.rms_ingredient IS 'rms_ingredient;Stores all ingredients could be used in a recipe.';