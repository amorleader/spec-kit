CREATE TABLE IF NOT EXISTS skills (
  id BIGINT PRIMARY KEY,
  code VARCHAR(64) NOT NULL UNIQUE,
  name VARCHAR(128) NOT NULL,
  max_level INT NOT NULL
);

CREATE TABLE IF NOT EXISTS equipments (
  id BIGINT PRIMARY KEY,
  name VARCHAR(128) NOT NULL,
  part VARCHAR(32) NOT NULL,
  rarity INT NOT NULL,
  weapon_type VARCHAR(32) NOT NULL
);

CREATE TABLE IF NOT EXISTS equipment_skill_points (
  equipment_id BIGINT NOT NULL,
  skill_code VARCHAR(64) NOT NULL,
  points INT NOT NULL,
  PRIMARY KEY (equipment_id, skill_code),
  CONSTRAINT fk_esp_equipment FOREIGN KEY (equipment_id) REFERENCES equipments (id)
);

CREATE TABLE IF NOT EXISTS expense_categories (
  code VARCHAR(32) PRIMARY KEY,
  label VARCHAR(64) NOT NULL
);

CREATE TABLE IF NOT EXISTS expense_transactions (
  id BIGINT PRIMARY KEY,
  amount NUMERIC(12,2) NOT NULL,
  category_code VARCHAR(32) NOT NULL,
  occurred_at DATE NOT NULL,
  note VARCHAR(255),
  CONSTRAINT fk_expense_category FOREIGN KEY (category_code) REFERENCES expense_categories (code)
);
