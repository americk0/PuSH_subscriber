# == Schema Information
#
# Table name: feeds
#
#  id         :integer          not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  feed_url   :string
#

require 'test_helper'

class FeedTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
