class ApartmentsController < ApplicationController
	def new
	end

	def create
		@apartment = Apartment.new(apartment_params)

		@apartment.save
		redirect_to @apartment
	end

	def show
		@apartment = Apartment.find(params[:id])
	end

	def index
#		@apartments = Apartment.all
#       @apartments = Apartment.find_by active: true # nope! only finds the first record matching this
		@apartments = Apartment.where("active = ?", true);
	end

	private
	def apartment_params
		params.require(:apartment).permit(:number_of_bedrooms, :rent_pcm, :postcode, :description)
	end
end
