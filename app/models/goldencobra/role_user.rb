# encoding: utf-8

# == Schema Information
#
# Table name: goldencobra_roles_users
#
#  operator_id   :integer
#  role_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  operator_type :string(255)      default("User")
#

module Goldencobra
  class RoleUser < ActiveRecord::Base
    self.table_name = 'goldencobra_roles_users'
    attr_accessible :operator_id, :role_id, :operator_type

    belongs_to :operator, polymorphic: true
    belongs_to :role, class_name: Goldencobra::Role
  end
end
