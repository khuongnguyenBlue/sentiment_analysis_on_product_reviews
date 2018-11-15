require 'pry'
require 'activerecord-import'
require 'csv'

namespace :analyzer do
  desc 'Process analyzer data'
  task process: :environment do
    features_data_by_class = {}
    total_features_count_of_class = {}
    stats_of_class = {}
    reviews_number = 0

    CSV.foreach('public/preprocessing_data/training_data.csv', headers: true) do |row|
      label = row['label']
      label_frequency = row['frequency'].to_i
      features_data_by_class[label] = [label_frequency, {}]
      total_features_count_of_class[label] = 0
      row.headers[2..-1].each_with_object(features_data_by_class[label][1]) do |header, hash|
        hash[header] = row[header].to_i
        total_features_count_of_class[label] += hash[header]
      end
    end

    features_data_by_class.each do |key, value|
      stats_of_class[key] = {frequency: value[0], probability: 0}
      reviews_number += value[0]
    end

    stats_of_class.each do |key, value|
      value[:probability] = (value[:frequency].to_f / reviews_number).round(2)
    end
    binding.pry
  end

  def analyze(additive_smoothing = 1)
    # for each review
    # calculate relative_value_of_probability of each klass
    # choose klass with higest rvp
  end

  def relative_value_of_probability(klass, features, additive_smoothing = 1)
    p_ck = stats_of_class[klass][:probability]
    reviews_number

    theta_k = -> (nki, nk) { (nki + additive_smoothing) / (nk + additive_smoothing*reviews_number) }
  end
end
