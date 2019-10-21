class CreateClients < ActiveRecord::Migration[5.2]
  def change
    create_table :clients do |t|
      t.string :name
      t.string :redirect_uri
      t.string :host
      t.timestamps
    end
  end
end
