class CreateNagEverybodyOptions < ActiveRecord::Migration
  def change
    create_table :nag_everybody_options do |t|
      t.integer :project_id
      t.boolean :send_to_watchers, :default => false
    end
  end
end
