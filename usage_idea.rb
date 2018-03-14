class Car < ApiBlueprint::Model
  attribute :name, Types::String
  attribute :color, Types::String

  configure do |config|
    config.host = "http://my-api.com"
    config.response_key_replacements = {
      colour: :color 
    }
  end

  def self.fetch_car
    blueprint :get, "/current_car"
  end

  def self.create_car(params)
    blueprint :post, "/cars", body: params
  end

  def self.update(params)
    blueprint :put, "/cars/#{params[:id]}", body: params.merge({ color: "red" })
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
    @car = api.run Car.fetch_car
  end

  def create
    @new_car = api.run Car.create_car(name: "Ford")
  end

  def update
    api.run Car.update(id: 123, name: "Opel")
  end
end
