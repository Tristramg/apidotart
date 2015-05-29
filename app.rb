require 'json'
require 'net/http'
require 'sinatra'

API_KEY  = ENV["APIDOTART_KEY"]
HOST = "api.art.rmngp.fr"

helpers do
  def work_url(id)
    # wors than an email regex
    "/#{URI::escape("http://#{HOST}/v1/works/#{id}")}"
  end
end


def get_api(uri)
  uri = URI(uri)
  
  # y’a moins débile ?
  http = Net::HTTP.new(uri.host)
  result = http.get("#{uri.path}?#{uri.query}", "ApiKey" => API_KEY)

  JSON.parse(result.body)
end

get '/' do
  @result = get_api("http://api.art.rmngp.fr/v1/works/3305")
  erb :index
end

get /#{HOST}/ do
  # on veut se débarasser du leading /
  link = URI::decode(request.env["REQUEST_URI"][1..-1])
  @result = get_api(link)
  erb :index
end

