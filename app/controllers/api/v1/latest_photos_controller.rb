class Api::V1::LatestPhotosController < ApplicationController
  def index
    @rover = Rover.find_by name: params[:rover_id].titleize

    if @rover then
      params = params
        .permit(:rover_id, :camera, :earth_date, :size, :page, :per_page)
        .merge(sol: @rover.photos.maximum(:sol))
      photos = rover.photos.search params, @rover
      photos = helpers.resize_photos photos, params

      if photos != 'size error'
        render json: photos, each_serializer: PhotoSerializer, root: :latest_photos
      else
        render json: { errors: "Invalid size parameter '#{photo_params[:size]}' for #{@rover.name.titleize}" }, status: :bad_request
      end
    else
      render json: { errors: "Invalid Rover Name" }, status: :bad_request
    end
  end
end
