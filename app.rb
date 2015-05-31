require 'json'
require 'net/http'
require 'sinatra'
require 'sinatra/activerecord'
require './environments'
require 'securerandom'

class Path < ActiveRecord::Base
end

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
  path = "#{uri.path}?#{uri.query}"
  result = http.get(path, "ApiKey" => API_KEY)

  JSON.parse(result.body)
end

get '/' do
  @path_id = SecureRandom.hex

  erb :index
end

get '/path' do
  @paths = {}
  Path.all.each do |path|
    @paths[path.path_id] ||= []
    @paths[path.path_id] << path
  end

  erb :path
end

get '/works' do
  q = URI::escape(params["q"])
  @path_id = params[:path_id]
  @origin_key = params[:origin_key]
  @origin_value = @origin_key == "start" ? q : params[:origin_value]
  @result = get_api("http://api.art.rmngp.fr/v1/works?q=#{q}&per_page=20")

  erb :work
end

get '/links/:id' do
  @path_id = params[:path_id]
  @origin_key = params[:origin_key]
  @origin_value = params[:origin_value]


  @result = get_api("http://api.art.rmngp.fr/v1/works/#{params[:id]}")
  @image = @result["hits"]["hits"][0]["_source"]["images"][0]["urls"]["original"]

  p = Path.new
  p.path_id = @path_id
  p.origin_key = @origin_key
  p.origin_value = @origin_value
  p.rmn_id = params[:id]
  p.url = @image
  p.save

  erb :links
end

get "/raw/:path_id/:origin_key/:origin_value/*" do

  @path_id = params[:path_id]
  @origin_key = params[:origin_key]
  @origin_value = params[:origin_value]
  #bldaiuenldatuienldbp(ènladtenaludice
  to_del = "/raw/#{@path_id}/#{@origin_key}/#{@origin_value}/"
  link = URI::decode(request.env["REQUEST_URI"]).force_encoding("UTF-8").gsub(to_del, "")

  @result = get_api(link)
  erb :work
end

