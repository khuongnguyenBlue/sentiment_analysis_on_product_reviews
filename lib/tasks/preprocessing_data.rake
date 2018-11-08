require 'pry'
require 'activerecord-import'
require 'csv'

namespace :data_preparation do
  TOKEN_REGEXP = /[\p{Alpha}\-']+/

  desc 'Preprocessing data'
  task preprocessing: :environment do
    puts 'Preprocessing data'
    text = File.open('public/preprocessing_data/Results.txt').read
    unless text.valid_encoding?
      text = text.encode('UTF-16be', invalid: :replace, replace: '?').encode('UTF-8')
    end

    split_threshold = (text.lines.count * 0.8).to_i

    puts 'Adding training data to training_data.csv'
    CSV.open('public/preprocessing_data/training_data.csv', 'wb') do |csv|
      line_num = 0
      bag_of_words = Set.new
      token_frequency_in_label = {}

      text.lines[0...split_threshold].each do |line|
        puts "#{line_num += 1} #{line}"

        label = line[0]
        token_frequency_in_label[label] ||= [0, Hash.new(0)]
        token_frequency_in_label[label][0] += 1

        content = line[2..-1].delete("\n")
        tokens = process(content)
        tokens.each_with_object(token_frequency_in_label[label]) do |token, array|
          array[1][token] += 1
        end
        bag_of_words.merge tokens
      end

      csv << Set.new(%w[label frequency]).merge(bag_of_words)
      token_frequency_in_label.each do |key, value|
        token_frequencies = bag_of_words.map {|word| value[1][word]}
        csv << [key, value[0]].concat(token_frequencies)
      end
    end
    puts 'Finished adding training data'

    puts 'Adding testing data to testing_data.txt'
    CSV.open('public/preprocessing_data/testing_data.txt', 'wb') do |csv|
      line_num = 0

      text.lines[split_threshold..-1].each do |line|
        puts "#{line_num += 1} #{line}"
        label = line[0]
        content = line[2..-1].delete("\n")
        csv << [label].concat(process(content))
      end
    end
    puts 'Finished adding testing data'
    puts 'Preprocessing progress finished, processed data were saved'
  end

  def process content
    tokens = tokenize content
    checked_tokens = []
    tokens.each do |token|
      result = Spellchecker.check(token)[0]
      if result[:correct]
        checked_tokens << result[:original]
      else
        checked_tokens.concat result[:suggestions][0].split
      end
    end
    filter = Stopwords::Snowball::Filter.new :en
    filterd_tokens = filter.filter tokens
    lemmatizer = Lemmatizer.new
    filterd_tokens.map { |token| lemmatizer.lemma token }
  end

  def tokenize content
    content.scan(TOKEN_REGEXP).map(&:downcase)
  end
end
