class Word < ActiveRecord::Base
  has_many :results, dependent: :destroy
  has_many :answers, dependent: :destroy
  belongs_to :category

  scope :learned, ->(user){where("id IN (SELECT word_id from results where lesson_id 
  									IN (SELECT id from lessons where user_id = ?))", user.id)}
  scope :not_learned, ->user {where("id NOT IN (SELECT word_id FROM results WHERE lesson_id 
  									IN (SELECT id FROM lessons WHERE user_id = ?))", user.id)}
  scope :filter_category, ->(category){where(category: category.id)}
end
