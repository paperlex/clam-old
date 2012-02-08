class CreateSignatures < ActiveRecord::Migration
  def change
    create_table :signatures do |t|
      t.integer :contributor_license_agreement_id
      t.integer :user_id
      t.integer :contract_id
      
      t.string :contract_uuid
      t.string :signature_uuid
      
      t.string :identity_verification_method
      t.string :identity_verification_value
      
      t.string :callback_signature_created_at

      t.timestamps
    end
  end
end
