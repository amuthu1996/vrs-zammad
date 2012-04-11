class CreateHistory < ActiveRecord::Migration
  def up
    
    create_table :histories do |t|
      t.references :history_type,               :null => false
      t.references :history_object,             :null => false
      t.references :history_attribute,          :null => true
      t.column :o_id,           :integer,       :null => false
      t.column :id_to,          :integer,       :null => true
      t.column :id_from,        :integer,       :null => true
      t.column :value_from,     :string,        :limit => 250,  :null => true
      t.column :value_to,       :string,        :limit => 250,  :null => true
      t.column :created_by_id,  :integer,       :null => false
      t.timestamps
    end
    add_index :histories, [:o_id]
    add_index :histories, [:created_by_id]
    
    create_table :history_types do |t|
      t.column :name,         :string, :limit => 250,   :null => false
      t.timestamps
    end
    add_index :history_types, [:name],     :unique => true

    create_table :history_objects do |t|
      t.column :name,         :string, :limit => 250,   :null => false
      t.column :note,         :string, :limit => 250,   :null => true
      t.timestamps
    end
    add_index :history_objects, [:name],   :unique => true

    create_table :history_attributes do |t|
      t.column :name,         :string, :limit => 250,   :null => false
      t.timestamps
    end
    add_index :history_attributes, [:name],   :unique => true
  end

  def down
    drop_table :histories
    drop_table :history_attributes
    drop_table :history_objects
    drop_table :history_types
  end
end