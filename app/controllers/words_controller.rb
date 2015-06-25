class WordsController < ApplicationController
  def index
    @categories = Category.all
    if params[:filter].present?
      if params[:filter][:category_id].nil?
        @category = Category.first
      else
        @category = Category.find params[:filter][:category_id]
      end
    else
      @category = Category.first
    end
    if %w[learned, not_learned].include? params[:filter_state]
      @words = @category.words.send params[:filter_state], current_user
    else
      @words = Word.filter_category @category
    end
  end
end