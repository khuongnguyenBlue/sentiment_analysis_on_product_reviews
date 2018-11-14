class AddReviewType < ActiveRecord::Migration[5.2]
  def change
    add_column :reviews, :review_type, :integer
  end
end
