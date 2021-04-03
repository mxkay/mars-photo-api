class Api::V1::PhotosController < ApplicationController

  def show
    photo = Photo.find params[:id]

    error = helpers.resize_photo photo, params

    if error.nil?
      render json: photo, serializer: PhotoSerializer, root: :photo
    else
      render json: { errors: error }, status: :bad_request
    end
  end

  def index
    rover = Rover.find_by name: params[:rover_id].titleize

    if rover
      photos = helpers.search_photos rover, photo_params
      error = helpers.resize_photos photos, params

      if error.nil?
        render json: photos, each_serializer: PhotoSerializer, root: :photos
      else
        render json: { errors: error }, status: :bad_request
      end
    else
      render json: { errors: "Invalid Rover Name" }, status: :bad_request
    end
  end

  private

  def photo_params
    params.permit :sol, :camera, :earth_date, :size
  end
end
