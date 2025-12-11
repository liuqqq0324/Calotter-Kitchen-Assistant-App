-- Homepage Intake Records Table
-- 存储用户的摄入记录（来自菜谱或手动输入）

-- Create schema if not exists
CREATE SCHEMA IF NOT EXISTS sous_chef_hp;

DROP TABLE IF EXISTS sous_chef_hp.hp_intake_record;
CREATE TABLE sous_chef_hp.hp_intake_record(
    id SERIAL NOT NULL,
    user_id INT8 NOT NULL,
    date DATE NOT NULL,
    source_type VARCHAR(20) NOT NULL, -- 'recipe' or 'manual'
    recipe_id INT4, -- NULL if source_type is 'manual'
    recipe_title VARCHAR(255), -- NULL if source_type is 'manual'
    manual_food_name VARCHAR(255), -- NULL if source_type is 'recipe'
    portion_description VARCHAR(255), -- For manual intake
    consumed_percentage DECIMAL(5, 2) DEFAULT 100.00, -- 0-100, percentage consumed
    base_energy DECIMAL(10, 2), -- Base energy in kcal
    base_fat DECIMAL(10, 2), -- Base fat in grams
    base_carbohydrates DECIMAL(10, 2), -- Base carbohydrates in grams
    base_protein DECIMAL(10, 2), -- Base protein in grams
    effective_energy DECIMAL(10, 2), -- Effective energy (base * consumed_percentage / 100)
    effective_fat DECIMAL(10, 2), -- Effective fat
    effective_carbohydrates DECIMAL(10, 2), -- Effective carbohydrates
    effective_protein DECIMAL(10, 2), -- Effective protein
    create_dept INT8,
    create_by INT8,
    create_time TIMESTAMP,
    update_by INT8,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN sous_chef_hp.hp_intake_record.id IS 'Intake record id;Intake record ID (PK)';
COMMENT ON COLUMN sous_chef_hp.hp_intake_record.user_id IS 'User id;User ID (FK, user_id -> users.user_id)';
COMMENT ON COLUMN sous_chef_hp.hp_intake_record.date IS 'Intake date;Date when the food was consumed';
COMMENT ON COLUMN sous_chef_hp.hp_intake_record.source_type IS 'Source type;Source type: recipe or manual';
COMMENT ON COLUMN sous_chef_hp.hp_intake_record.recipe_id IS 'Recipe id;Recipe ID (FK, recipe_id -> rms_recipe.id), NULL if manual';
COMMENT ON COLUMN sous_chef_hp.hp_intake_record.recipe_title IS 'Recipe title;Recipe title for display, NULL if manual';
COMMENT ON COLUMN sous_chef_hp.hp_intake_record.manual_food_name IS 'Manual food name;Food name for manual intake, NULL if recipe';
COMMENT ON COLUMN sous_chef_hp.hp_intake_record.portion_description IS 'Portion description;Portion description for manual intake (e.g., "1 bowl")';
COMMENT ON COLUMN sous_chef_hp.hp_intake_record.consumed_percentage IS 'Consumed percentage;Percentage of food consumed (0-100)';
COMMENT ON COLUMN sous_chef_hp.hp_intake_record.base_energy IS 'Base energy;Base energy in kcal before percentage adjustment';
COMMENT ON COLUMN sous_chef_hp.hp_intake_record.base_fat IS 'Base fat;Base fat in grams before percentage adjustment';
COMMENT ON COLUMN sous_chef_hp.hp_intake_record.base_carbohydrates IS 'Base carbohydrates;Base carbohydrates in grams before percentage adjustment';
COMMENT ON COLUMN sous_chef_hp.hp_intake_record.base_protein IS 'Base protein;Base protein in grams before percentage adjustment';
COMMENT ON COLUMN sous_chef_hp.hp_intake_record.effective_energy IS 'Effective energy;Effective energy after percentage adjustment';
COMMENT ON COLUMN sous_chef_hp.hp_intake_record.effective_fat IS 'Effective fat;Effective fat after percentage adjustment';
COMMENT ON COLUMN sous_chef_hp.hp_intake_record.effective_carbohydrates IS 'Effective carbohydrates;Effective carbohydrates after percentage adjustment';
COMMENT ON COLUMN sous_chef_hp.hp_intake_record.effective_protein IS 'Effective protein;Effective protein after percentage adjustment';
COMMENT ON COLUMN sous_chef_hp.hp_intake_record.create_dept IS 'Creation department id';
COMMENT ON COLUMN sous_chef_hp.hp_intake_record.create_by IS 'Creator id';
COMMENT ON COLUMN sous_chef_hp.hp_intake_record.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_hp.hp_intake_record.update_by IS 'Updater id';
COMMENT ON COLUMN sous_chef_hp.hp_intake_record.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_hp.hp_intake_record IS 'hp_intake_record;This table stores user food intake records from recipes or manual input.';

CREATE INDEX idx_intake_record_user_date ON sous_chef_hp.hp_intake_record (
    user_id ASC,
    date ASC
);
COMMENT ON INDEX sous_chef_hp.idx_intake_record_user_date IS 'Index on user_id and date;Index for efficient querying by user and date';

CREATE INDEX idx_intake_record_user_week ON sous_chef_hp.hp_intake_record (
    user_id ASC,
    date ASC
);
COMMENT ON INDEX sous_chef_hp.idx_intake_record_user_week IS 'Index for weekly summary queries;Index for efficient weekly summary queries';
