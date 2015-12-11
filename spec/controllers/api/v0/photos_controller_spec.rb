require 'rails_helper'

describe Api::V0::PhotosController do
  describe "GET 'index'" do

    let(:rover) { create(:rover) }
    let(:camera) { create(:camera, rover: rover) }

    context "with no query parameters" do
      let!(:photo) { create(:photo, rover: rover) }
      before(:each) do
        get :index, { rover_id: rover.name.downcase }
      end

      it "defaults to max sol" do
        expect(response.status).to eq 200
      end

      it "renders photo data matching sol" do
        expect(json["photos"].length).to eq 1
        expect(json["photos"].first["sol"]).to eq photo.sol
      end
    end

    context "with sol query" do
      let!(:photo) { create(:photo, rover: rover) }
      before(:each) do
        get :index, { rover_id: rover.name, sol: 829 }
      end

      it "returns http 200 success" do
        expect(response.status).to eq 200
      end

      it "renders photo data matching sol" do
        expect(json["photos"].length).to eq 1
        expect(json["photos"].first["sol"]).to eq photo.sol
      end
    end

    context "with sol query - page 1" do
      before(:each) do
        create_list(:photo, 25, rover: rover)
        get :index, { rover_id: rover.name, sol: 829, page: 1 }
      end

      it "returns http 200 success" do
        expect(response.status).to eq 200
      end

      it "limits responses to 25 per page" do
        expect(json["photos"].length).to eq 25
      end
    end

    context "with sol query - page 3" do
      before(:each) do
        create_list(:photo, 51, rover: rover)
        get :index, { rover_id: rover.name, sol: 829, page: 3 }
      end

      it "returns http 200 success" do
        expect(response.status).to eq 200
      end

      it "limits responses to 25 per page" do
        expect(json["photos"].length).to eq 1
      end
    end

    context "with sol and camera query" do
      let!(:photo) { create(:photo, rover: rover, camera: camera) }
      before(:each) do
        get :index, { rover_id: rover.name, sol: 829, camera: camera.name }
      end

      it "returns http 200 success" do
        expect(response.status).to eq 200
      end

      it "renders photo data matching sol and camera" do
        expect(json["photos"].length).to eq 1
        expect(json["photos"].first["camera"]["name"]).to eq camera.name
      end
    end

    context "with Earth date query" do
      let!(:photo) { create(:photo, rover: rover) }
      before(:each) do
        get :index, { rover_id: rover.name, earth_date: "2014-12-05" }
      end

      it "returns http 200 success" do
        expect(response.status).to eq 200
      end

      it "renders photo data matching Earth date" do
        expect(json["photos"].length).to eq 1
        expect(json["photos"].first["earth_date"]).to eq "2014-12-05"
      end
    end

    context "with Earth date and camera query" do
      let!(:photo) { create(:photo, rover: rover, camera: camera) }
      before(:each) do
        get :index, { rover_id: rover.name.downcase, earth_date: "2014-12-05", camera: camera.name }
      end

      it "returns http 200 success" do
        expect(response.status).to eq 200
      end

      it "renders photo data matching sol and camera" do
        expect(json["photos"].length).to eq 1
        expect(json["photos"].first["camera"]["name"]).to eq camera.name
      end
    end
  end

  describe "GET 'show'" do
    context "for an existing photo" do
      let!(:photo) { create(:photo) }
      before(:each) do
        get :show, { id: photo.id }
      end

      it "returns http 200 success" do
        expect(response.status).to eq 200
      end

      it "returns the photo's json" do
        expect(json["photo"])
      end
    end
  end
end
