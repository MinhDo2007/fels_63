class Answer < ActiveRecord::Base
  belongs_to :word
  has_many :results, dependent: :destroy

  scope :learned, ->(answer,word,user){where("answer_id = ?", answer.id).where("word_id = ?", word_id).where("user_id = ?", user_id)}
end
