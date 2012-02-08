class AddOrgs < ActiveRecord::Migration
  def up
    add_column :contributor_license_agreements, :org_name, :string
  end

  def down
  end
end
