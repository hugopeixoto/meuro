module Api
  module V1
    class BetsController < ApplicationController
      respond_to :json

      def index
        respond_with Bet.all
      end

      def show
        respond_with Bet.find(params[:id])
      end

      def create
        render json: Bet.create(current_user, params.require(:bet).permit([:amount, :high, :low]))
      end
    end
  end
end

