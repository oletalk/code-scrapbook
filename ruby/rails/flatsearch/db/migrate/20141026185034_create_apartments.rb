class CreateApartments < ActiveRecord::Migration
  def change
    create_table :apartments do |t|
      t.integer :number_of_bedrooms
      t.decimal :rent_pcm
      t.string :postcode
      t.string :description
      t.boolean :active

      t.timestamps
    end
  end
end
