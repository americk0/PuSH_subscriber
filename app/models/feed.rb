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

class Feed < ActiveRecord::Base
  has_many :entries, dependent: :destroy
end
