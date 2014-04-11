require 'net/http'
require 'uri'

class BalanceController < ApplicationController
  def index
  end

  def topup

    uri = URI.parse("https://#{ENV["PRODUCTION_ENDPOINT"]}/api/v2/checkout")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    puts "[LOG DEBUG] Set up http"

    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = {
      "payment" => {
        "amount" => params[:amount].to_f,
        "currency"=> "EUR",
        "ext_customerid" => "mergitoff" #session[:access_token]
      },
      "url_confirm" => "http://#{ENV["PRODUCTION_HOSTNAME"]}/balance/confirm",
      "url_cancel"  => "http://#{ENV["PRODUCTION_HOSTNAME"]}/balance/cancel"
    }.to_json

    request["Content-Type"] = "application/json"
    request["Authorization"] = "WalletPT #{ENV["PRODUCTION_API_KEY"]}"

    puts "[LOG DEBUG] going to request"

    response = http.request(request)

    jasao = JSON.parse(response.body)

    redirect_to jasao["url_redirect"]
  end

  def confirm
    uri = URI.parse("https://#{ENV['PRODUCTION_ENDPOINT']}/api/v2/checkout/#{params["checkoutid"]}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri.request_uri)

    request["Content-Type"] = "application/json"
    request["Authorization"] = "WalletPT #{ENV["PRODUCTION_API_KEY"]}"

    response = http.request(request)

    jasao = JSON.parse(response.body)

    #amount = jasao["payment"]["amount"]
    #token  = jasao["payment"]["ext_customerid"]

    render text: jasao
  end

  def cancel
  end
end
