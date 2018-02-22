require 'natto'
require "pry"


def keitaiso(text)
  natto = Natto::MeCab.new
  arr = []
  natto.parse(text) do |n|
    if n.feature.split(',')[1] == "固有名詞"
      arr << n.surface
    end
  end
  return arr
end
help = keitaiso('鷺沼駅からたまプラーザ駅まで行きたい！')
#ここから駅名の固有名詞を抽出した
p help.to_s
