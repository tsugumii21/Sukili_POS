-- SUKLI POS CLOUD BACKEND SCHEMA
-- Strategy: Last-Write-Wins (LWW) Sync with soft deletes

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- --- TABLES ---

-- USERS TABLE
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  pin_hash TEXT,
  role TEXT NOT NULL CHECK (role IN ('cashier', 'admin')),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- CATEGORIES TABLE
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  icon_emoji TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- MENU ITEMS TABLE
CREATE TABLE menu_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id TEXT UNIQUE NOT NULL,
  category_id TEXT NOT NULL REFERENCES categories(sync_id),
  name TEXT NOT NULL,
  description TEXT,
  base_price NUMERIC(10,2) NOT NULL,
  image_url TEXT,
  is_available BOOLEAN NOT NULL DEFAULT TRUE,
  track_inventory BOOLEAN NOT NULL DEFAULT FALSE,
  stock_quantity NUMERIC(10,2),
  low_stock_threshold NUMERIC(10,2),
  sort_order INTEGER NOT NULL DEFAULT 0,
  variants_json JSONB DEFAULT '[]',
  modifiers_json JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- ORDERS TABLE
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id TEXT UNIQUE NOT NULL,
  order_number TEXT UNIQUE NOT NULL,
  cashier_id TEXT NOT NULL,
  cashier_name TEXT NOT NULL,
  order_items_json JSONB DEFAULT '[]',
  subtotal NUMERIC(10,2) NOT NULL DEFAULT 0,
  discount_amount NUMERIC(10,2) NOT NULL DEFAULT 0,
  discount_reason TEXT,
  tax_amount NUMERIC(10,2) NOT NULL DEFAULT 0,
  total_amount NUMERIC(10,2) NOT NULL DEFAULT 0,
  amount_tendered NUMERIC(10,2) NOT NULL DEFAULT 0,
  change_amount NUMERIC(10,2) NOT NULL DEFAULT 0,
  payment_method TEXT NOT NULL CHECK (payment_method IN ('cash', 'gcash', 'maya', 'card', 'other')),
  payment_reference TEXT,
  status TEXT NOT NULL DEFAULT 'completed' CHECK (status IN ('completed', 'voided', 'refunded')),
  void_reason TEXT,
  refund_reason TEXT,
  voided_by_id TEXT,
  voided_at TIMESTAMPTZ,
  ordered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- INVENTORY LOGS TABLE
CREATE TABLE inventory_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id TEXT UNIQUE NOT NULL,
  menu_item_id TEXT NOT NULL,
  menu_item_name TEXT NOT NULL,
  previous_quantity NUMERIC(10,2) NOT NULL,
  adjustment_quantity NUMERIC(10,2) NOT NULL,
  new_quantity NUMERIC(10,2) NOT NULL,
  reason TEXT NOT NULL CHECK (reason IN ('sale', 'manual_add', 'manual_deduct', 'spoilage', 'restock')),
  notes TEXT,
  performed_by_id TEXT NOT NULL,
  performed_by_name TEXT NOT NULL,
  performed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- --- UPDATED_AT TRIGGER ---

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_menu_items_updated_at BEFORE UPDATE ON menu_items FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_inventory_logs_updated_at BEFORE UPDATE ON inventory_logs FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- --- INDEXES ---

CREATE INDEX idx_users_sync_id ON users(sync_id);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_categories_sort_order ON categories(sort_order);
CREATE INDEX idx_menu_items_category ON menu_items(category_id);
CREATE INDEX idx_orders_cashier ON orders(cashier_id);
CREATE INDEX idx_orders_ordered_at ON orders(ordered_at);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_inventory_logs_item ON inventory_logs(menu_item_id);
CREATE INDEX idx_inventory_logs_performed_at ON inventory_logs(performed_at);

-- --- ROW LEVEL SECURITY (RLS) ---

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_logs ENABLE ROW LEVEL SECURITY;

-- Read Policy
CREATE POLICY "Allow authenticated read" ON users FOR SELECT TO authenticated USING (is_deleted = FALSE);
CREATE POLICY "Allow authenticated read" ON categories FOR SELECT TO authenticated USING (is_deleted = FALSE);
CREATE POLICY "Allow authenticated read" ON menu_items FOR SELECT TO authenticated USING (is_deleted = FALSE);
CREATE POLICY "Allow authenticated read" ON orders FOR SELECT TO authenticated USING (is_deleted = FALSE);
CREATE POLICY "Allow authenticated read" ON inventory_logs FOR SELECT TO authenticated USING (is_deleted = FALSE);

-- Insert Policy
CREATE POLICY "Allow authenticated insert" ON users FOR INSERT TO authenticated WITH CHECK (TRUE);
CREATE POLICY "Allow authenticated insert" ON categories FOR INSERT TO authenticated WITH CHECK (TRUE);
CREATE POLICY "Allow authenticated insert" ON menu_items FOR INSERT TO authenticated WITH CHECK (TRUE);
CREATE POLICY "Allow authenticated insert" ON orders FOR INSERT TO authenticated WITH CHECK (TRUE);
CREATE POLICY "Allow authenticated insert" ON inventory_logs FOR INSERT TO authenticated WITH CHECK (TRUE);

-- Update Policy
CREATE POLICY "Allow authenticated update" ON users FOR UPDATE TO authenticated USING (TRUE);
CREATE POLICY "Allow authenticated update" ON categories FOR UPDATE TO authenticated USING (TRUE);
CREATE POLICY "Allow authenticated update" ON menu_items FOR UPDATE TO authenticated USING (TRUE);
CREATE POLICY "Allow authenticated update" ON orders FOR UPDATE TO authenticated USING (TRUE);
CREATE POLICY "Allow authenticated update" ON inventory_logs FOR UPDATE TO authenticated USING (TRUE);
