class CreateRegistrations < ActiveRecord::Migration[8.1]
  def change
    create_table :registrations do |t|
      t.references :event, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :seat_type, null: false, default: "paid"
      t.string :source, null: false, default: "web"
      t.string :registered_by

      t.timestamps
    end
    add_index :registrations, [:event_id, :email], unique: true
  end
end
