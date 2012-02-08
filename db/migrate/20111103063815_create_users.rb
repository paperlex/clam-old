class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :github_id
      t.string :github_login
      t.string :github_email
      
      t.timestamps
    end
  end
end
