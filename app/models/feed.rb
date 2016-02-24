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

class Feed < ActiveRecord::Base
  belongs_to :feed
end
