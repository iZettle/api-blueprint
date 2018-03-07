class Car < ApiBlueprint::Model
  config do
    host "http://my-api.com"
  end

  api_endpoint :fetch_car, get: "/current_car"

  api_endpoint :create_car, post: "/cars"

  api_endpoint :update, put: "/cars/:id" do |params|
    params.merge({ color: "red" })
  end
end

class ApplicationController < ActionController::Base
  private

  def api
    ApiBlueprint::Runner.new({
      headers: {
        Authorization: session[:oauth_header],
        Accept: "application/json"
      }
    })
  end
end

class CarController < ApplicationController
  def index
    @car = api.run(Car, :fetch_car)
  end

  def create
    @new_car = api.run(Car, :create_car, params: { name: "Ford" })
  end

  def update
    api.run(Car, :update, url: { id: 123 }, params: { name: "Opel" })
  end
end
