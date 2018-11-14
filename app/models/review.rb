class Review < ApplicationRecord
  enum review_type: %i(training testing).freeze
end
