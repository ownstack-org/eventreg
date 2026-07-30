class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :location
      t.text :description
      t.integer :capacity, null: false, default: 100
      t.integer :free_dev_seats, null: false, default: 0
      t.integer :price_cents, null: false, default: 0
      t.string :currency, null: false, default: "USD"
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :events, :slug, unique: true
  end
end
