class UpgradeClaTemplates < ActiveRecord::Migration
  def up
    add_column :cla_templates, :user_form, :text
    add_column :cla_templates, :owner_form, :text
  end

  def down
  end
end
