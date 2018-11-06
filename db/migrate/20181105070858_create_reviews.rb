class CreateReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :reviews do |t|
      t.string :content
      t.integer :score
      t.integer :sentiment_class

      t.timestamps
    end
  end
end
