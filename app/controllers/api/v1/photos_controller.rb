class Api::V1::PhotosController < ApplicationController
  def show
    photo = Photo.find params[:id]
    render json: photo, serializer: PhotoSerializer, root: :photo
  end

  def index
    rover = Rover.find_by name: params[:rover_id].titleize
    if rover
      render json: search_photos(rover), each_serializer: PhotoSerializer, root: :photos
    else
      render json: { errors: "Invalid Rover Name" }, status: :bad_request
    end
  end

  private

  def photo_params
    params.permit :sol, :camera, :earth_date, :size
  end

  def search_photos(rover)
    photos = rover.photos.order(:camera_id, :id).search photo_params, rover
    if params[:page]
      photos = photos.page(params[:page]).per params[:per_page]
    end

    # Resize photos
    # Curiosity: thumbnail ends in "-thm.jpg" or "-thm.png"
    # Spirit + Opportunity: thumbnail ends in "-THM.jpg"
    case params[:size]
    when nil, "large"
      # do nothing
    when "small"
      case params[:rover_id]
      when "curiosity"
        resize_each photos, ".jpg", "-thm.jpg"
      when "spirit", "opportunity"
        resize_each photos, ".jpg", "-THM.jpg"
      when "perseverance"
        resize_each photos, "1200.jpg", "320.jpg"
      else
        # ERROR: invalid size parameter for rover
      end
    when "medium"
      if params[:rover_id] == "perseverance"
        resize_each photos, "1200.jpg", "800.jpg"
      else
        # ERROR: invalid size parameter for rover
      end
    when "full"
      if params[:rover_id] == "perseverance"
        resize_each photos, "_1200.jpg", ".png"
      else
        # ERROR: invalid size parameter for rover
      end
    else
      # ERROR: invalid size parameter
    end

    photos
  end

  def resize_each(photos, old_suffix, new_suffix)
    photos.map do |photo|
      photo[:img_src] = photo[:img_src].delete_suffix(old_suffix) + new_suffix
    end
  end
end
