# == Schema Information
#
# Table name: entries
#
#  id         :integer          not null, primary key
#  title      :string
#  author     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  body       :text
#  entry_id   :integer
#  feed_id    :integer
#

require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
