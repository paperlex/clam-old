class UpgradeClas < ActiveRecord::Migration
  def up
    add_column :contributor_license_agreements, :owner_responses, :text
  end

  def down
  end
end
