class Category < ApplicationRecord
  has_many :expenses, dependent: :destroy

  before_validation :strip_whitespace

  validates :name, presence: true,
                   uniqueness: { case_sensitive: false },
                   length: { minimum: 2, maximum: 50 }

  private

  def strip_whitespace
    self.name = name.strip if name.present?
  end
end
