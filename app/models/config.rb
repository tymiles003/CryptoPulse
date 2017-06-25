class Config < ApplicationRecord
  has_many :executions
  has_many :orders, through: :executions
end
