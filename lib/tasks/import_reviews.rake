# frozen_string_literal: true

require "activerecord-import"

namespace :data_preparation do

  desc "Import reviews from text"
  task import_reviews: :environment do
    puts "Importing reviews"
    reviews = []
    line_num=0
    text = File.open('public/preprocessing_data/Results.txt').read
    unless text.valid_encoding?
      text = text.encode("UTF-16be", invalid: :replace, replace: "?").encode('UTF-8')
    end
    text.each_line do |line|
      print "#{line_num += 1} #{line}"
      reviews << Review.new(sentiment_class: line[0].to_i, content: line[2..-1].delete("\n"))
    end
    Review.import! reviews
    puts "Import success"
  end
end
