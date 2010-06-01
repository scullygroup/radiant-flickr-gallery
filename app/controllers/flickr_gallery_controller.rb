class FlickrGalleryController < ApplicationController
  
  require 'open-uri'
  require 'nokogiri'
  require 'haml'
  
  no_login_required
  radiant_layout 'photo_gallery_layout'

  before_filter :protect_from_forgery, :except => [:index, :photoset]
  
  def photoset
    config = YAML.load_file("config/flickr.yml")
    @api_key = config['key']
    @user = config['user']

    setid = params[:setid]

    @photoset_photos = Nokogiri::XML(open("http://api.flickr.com/services/rest/?method=flickr.photosets.getPhotos&api_key=#{@api_key}&photoset_id=#{setid}"))
    @photos = []
    
    @photoset_photos.xpath("/rsp/photoset/photo").each do |photo|
      @photos.push(photo)
    end
    
  end
  
end
