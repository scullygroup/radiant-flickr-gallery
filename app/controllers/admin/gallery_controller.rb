class Admin::GalleryController < ApplicationController

  require 'open-uri'
  require 'nokogiri'
  
  def index
    config = YAML.load_file("config/flickr.yml")
    @api_key = config['key']
    @user = config['user']
    
    @doc = Nokogiri::XML(open("http://api.flickr.com/services/rest/?method=flickr.photosets.getList&api_key=#{@api_key}&user_id=#{@user}"))
    
    first = true
    @flickr_photosets = []
    
    @doc.xpath("/rsp/photosets/photoset").each do |node|
      title = node.search("title").inner_html
      
      # get the first photo in the set for the primary photo
      @photoset_photos = Nokogiri::XML(open("http://api.flickr.com/services/rest/?method=flickr.photosets.getPhotos&api_key=#{@api_key}&photoset_id=#{node['id']}&per_page=1"))
      first_photo = @photoset_photos.xpath("/rsp/photoset/photo").first
      
      # now take that id and find me the actual photo
      @set_photo = Nokogiri::XML(open("http://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=#{@api_key}&photo_id=#{first_photo['id']}"))
      
      set_photo = ""
      
      @set_photo.xpath("/rsp/sizes/size").each do |size|
        if size['label'] == "Square"
          set_photo = size['source']
        end
      end
      
      @flickr_photosets.push("<td><span class=\"title\">#{title}</span></td><td><img src=\"#{set_photo}\" /></td><td><span class=\"setid\">#{node['id']}</span></td><td><a class=\"get-code\" href=\"#{node['id']}\">Get Code</a></td>")

      # its not the first run through
      first = false
    end
    
  end
  
end
