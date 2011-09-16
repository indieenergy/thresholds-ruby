class CreateGeopods < ActiveRecord::Migration
  def self.up
    create_table :geopods do |t|
      t.string :name
      t.string :subdomain
      t.string :access_token
      t.string :access_token_secret

      t.timestamps
    end
  end

  def self.down
    drop_table :geopods
  end
end
