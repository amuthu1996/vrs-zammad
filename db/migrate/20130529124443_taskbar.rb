class Taskbar < ActiveRecord::Migration
  def up
    create_table :taskbars do |t|
      t.column :user_id,              		:integer,   :null => false
      t.column :last_contact,				:datetime,  :null => false
      t.column :client_id,					:string,    :null => false
      t.column :key,                        :string,    :limit => 100,  :null => false
      t.column :callback,                   :string,    :limit => 100,  :null => false
      t.column :state,    				    :string,    :limit => 8000, :null => true
      t.column :params,					    :string,    :limit => 2000, :null => true
      t.column :prio,                       :integer,   :null => false
      t.column :notify,                     :boolean,   :null => false, :default => false
      t.column :active,                     :boolean,   :null => false, :default => false
      t.timestamps
    end
    add_index :taskbars, [:user_id]
    add_index :taskbars, [:client_id]
  end

  def down
    drop_table :taskbars
  end
end