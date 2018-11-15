# frozen_string_literal: true

module ReviewsHelper
  attr_reader :features_data_of_class, :total_features_count_of_class, :stats_of_class, :unique_features_count_of_class

  def load_trained_data
    @features_data_of_class = {}
    @total_features_count_of_class = {}
    @stats_of_class = {}
    @unique_features_count_of_class = {}

    reviews_number = 0
    CSV.foreach('public/preprocessing_data/training_data.csv', headers: true) do |row|
      label = row['label']
      label_frequency = row['frequency'].to_i
      stats_of_class[label] = {frequency: label_frequency, probability: 0}
      reviews_number += label_frequency
      features_data_of_class[label] = Hash.new(0)
      total_features_count_of_class[label] = 0
      unique_features_count_of_class[label] = 0

      row.headers[2..-1].each_with_object(features_data_of_class[label]) do |header, hash|
        hash[header] = row[header].to_i
        total_features_count_of_class[label] += hash[header]
        unique_features_count_of_class[label] += 1 if hash[header].positive?
      end
    end

    best_features_data_of_class

    stats_of_class.each_value do |value|
      value[:probability] = (value[:frequency].to_f / reviews_number).round(2)
    end
  end

  def analyze(additive_smoothing = 1)
    text = File.open('public/preprocessing_data/testing_data.txt').read
    correct = 0
    File.open('public/analyzed_data/classification_result.txt', 'wb') do |file|
      text.each_line do |line|
        features = line[2..-1].split(',')
        klass = stats_of_class.keys.max_by { |klass| relative_value_of_probability(klass, features, additive_smoothing) }
        file.puts "predicted: #{klass}, actual: #{line}"
        correct += 1 if klass == line[0]
      end
      file.puts "precision: #{correct.to_f/text.lines.length}"
    end
  end

  def relative_value_of_probability(klass, features, additive_smoothing)
    p_ck = stats_of_class[klass][:probability]
    theta_k = ->(nki, nk) { (nki + additive_smoothing).to_f / (nk + additive_smoothing * unique_features_count_of_class[klass]) }

    sum_ln_theta = features.sum do |feature|
      nki = features_data_of_class[klass][feature]
      nk = total_features_count_of_class[klass]
      Math.log theta_k.call(nki, nk)
    end

    Math.log(p_ck) + sum_ln_theta
  end

  def test
    load_trained_data
    analyze
  end
end
