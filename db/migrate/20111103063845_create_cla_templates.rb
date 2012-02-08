class CreateClaTemplates < ActiveRecord::Migration
  def change
    create_table :cla_templates do |t|
      t.string :name
      
      t.string :slaw_uuid

      t.timestamps
    end
  end
end
