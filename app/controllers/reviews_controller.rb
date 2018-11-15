require 'csv'

class ReviewsController < ApplicationController
  attr_reader :features_data_by_class

  def analyze
    p_class = {}
    features_data_by_class.each_with_object(p_class) do |klass, hash|

    end

  end

  def read_trained_data
    @features_data_by_class = {}
    CSV.foreach('public/preprocessing_data/training_data.csv', headers: true) do |row|
      label = row['label']
      label_frequency = row['frequency'].to_i
      features_data_by_class[label] = [label_frequency, {}]
      row.headers[2..-1].each_with_object(features_data_by_class[label][1]) do |header, hash|
        hash[header] = row[header].to_i
      end
    end
  end
end
