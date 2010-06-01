class FlickrJavascriptController < ApplicationController
  
  no_login_required
  
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
    
    render :layout => false 
  end
  
end
