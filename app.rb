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
  erb :index
end

get '/works' do
  q = URI::escape(params["q"])
  @result = get_api("http://api.art.rmngp.fr/v1/works?q=#{q}")

  erb :work
end

get '/links/:id' do
  @result = get_api("http://api.art.rmngp.fr/v1/works/#{params[:id]}")
  @image = @result["hits"]["hits"][0]["_source"]["images"][0]["urls"]["original"]

  erb :links
end

get "/raw/*" do
  link = URI::decode(request.env["REQUEST_URI"][5..-1])
  @result = get_api(link)
  erb :work
end

