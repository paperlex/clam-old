class CreateContributorLicenseAgreements < ActiveRecord::Migration
  def change
    create_table :contributor_license_agreements do |t|
      t.integer :user_id
      t.integer :cla_template_id
      
      t.string :repo_name
      
      t.string :company_name
      t.text :address
      t.string :legal_email

      t.timestamps
    end
  end
end
