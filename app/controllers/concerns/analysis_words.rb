require 'natto'
require "pry"
module AnalysisWords
  extend ActiveSupport::Concern
  def classify_word(text)
    natto = Natto::MeCab.new
    arr = []
    natto.parse(text) do |n|
      if n.feature.split(',')[1] == "固有名詞"
        arr << n.surface
      end
    end
    return arr
  end
end
