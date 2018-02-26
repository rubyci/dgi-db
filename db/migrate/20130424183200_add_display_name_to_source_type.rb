class AddDisplayNameToSourceType < ActiveRecord::Migration[4.2]
  def up
    add_column :source_types, :display_name, :string
  end

  def down
    remove_column :source_types, :display_name
  end
end
