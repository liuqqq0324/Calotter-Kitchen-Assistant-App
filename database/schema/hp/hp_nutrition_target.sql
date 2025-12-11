-- Homepage Nutrition Targets Table
-- 存储用户的周营养目标

-- Create schema if not exists
CREATE SCHEMA IF NOT EXISTS sous_chef_hp;

DROP TABLE IF EXISTS sous_chef_hp.hp_nutrition_target;
CREATE TABLE sous_chef_hp.hp_nutrition_target(
    id SERIAL NOT NULL,
    user_id INT8 NOT NULL,
    week_start DATE NOT NULL,
    week_end DATE NOT NULL,
    weekly_target_energy DECIMAL(10, 2) NOT NULL,
    weekly_target_fat DECIMAL(10, 2) NOT NULL,
    weekly_target_carbohydrates DECIMAL(10, 2) NOT NULL,
    weekly_target_protein DECIMAL(10, 2) NOT NULL,
    bmi DECIMAL(5, 2),
    goal_type VARCHAR(50), -- 'fat_loss', 'muscle_gain', 'maintain', etc.
    calculation_model VARCHAR(50), -- 'mifflin_st_jeor', 'harris_benedict', etc.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

COMMENT ON COLUMN sous_chef_hp.hp_nutrition_target.id IS 'Nutrition target id;Nutrition target ID (PK)';
COMMENT ON COLUMN sous_chef_hp.hp_nutrition_target.user_id IS 'User id;User ID (FK, user_id -> users.user_id)';
COMMENT ON COLUMN sous_chef_hp.hp_nutrition_target.week_start IS 'Week start date;Start date of the week (Monday)';
COMMENT ON COLUMN sous_chef_hp.hp_nutrition_target.week_end IS 'Week end date;End date of the week (Sunday)';
COMMENT ON COLUMN sous_chef_hp.hp_nutrition_target.weekly_target_energy IS 'Weekly target energy;Weekly target energy in kcal';
COMMENT ON COLUMN sous_chef_hp.hp_nutrition_target.weekly_target_fat IS 'Weekly target fat;Weekly target fat in grams';
COMMENT ON COLUMN sous_chef_hp.hp_nutrition_target.weekly_target_carbohydrates IS 'Weekly target carbohydrates;Weekly target carbohydrates in grams';
COMMENT ON COLUMN sous_chef_hp.hp_nutrition_target.weekly_target_protein IS 'Weekly target protein;Weekly target protein in grams';
COMMENT ON COLUMN sous_chef_hp.hp_nutrition_target.bmi IS 'BMI value;Body Mass Index used for calculation';
COMMENT ON COLUMN sous_chef_hp.hp_nutrition_target.goal_type IS 'Goal type;User goal type (fat_loss, muscle_gain, maintain, etc.)';
COMMENT ON COLUMN sous_chef_hp.hp_nutrition_target.calculation_model IS 'Calculation model;Nutrition calculation model (mifflin_st_jeor, harris_benedict, etc.)';
COMMENT ON TABLE sous_chef_hp.hp_nutrition_target IS 'hp_nutrition_target;This table stores weekly nutrition targets for users.';

CREATE INDEX idx_nutrition_target_user_week ON sous_chef_hp.hp_nutrition_target (
    user_id ASC,
    week_start ASC
);
COMMENT ON INDEX sous_chef_hp.idx_nutrition_target_user_week IS 'Index on user_id and week_start;Index for efficient querying by user and week';
