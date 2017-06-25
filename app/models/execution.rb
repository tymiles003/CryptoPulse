class Execution < ApplicationRecord
  belongs_to :config
  has_many :orders
end
