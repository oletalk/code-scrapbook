class Apartment < ActiveRecord::Base
	after_initialize :init

	def init
		self.active = true if self.active.nil?
	end
end
