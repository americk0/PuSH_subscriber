# == Schema Information
#
# Table name: feeds
#
#  id         :integer          not null, primary key
#  title      :string
#  text       :text
#  author     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class FeedTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
