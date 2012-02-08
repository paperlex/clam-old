class CreateContracts < ActiveRecord::Migration
  def change
    create_table :contracts do |t|
      t.string :uuid
      t.integer :user_id
      t.integer :contributor_license_agreement_id

      t.text :responses

      t.timestamps
    end
  end
end
