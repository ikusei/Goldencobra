# encoding: utf-8

# == Schema Information
#
# Table name: goldencobra_vita
#
#  id            :integer          not null, primary key
#  loggable_id   :integer
#  loggable_type :string(255)
#  user_id       :integer
#  title         :string(255)
#  description   :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  status_cd     :integer          default 0
#

module Goldencobra
  class Vita < ActiveRecord::Base
    belongs_to :loggable, polymorphic: true
    attr_accessible :description, :title, :user_id, :status_cd
    acts_as_taggable_on :tags

    as_enum :status,  success: 0, warning: 1, error: 2

  end
end
