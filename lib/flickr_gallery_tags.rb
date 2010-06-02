module FlickrGalleryTags
  include Radiant::Taggable
  
  tag "flickrgallery" do |tag|
    attr = tag.attr.symbolize_keys
    
    photosetarray = attr[:photosets].split(',')
    
    @photos = get_photos(photosetarray[0])
    
    @hastitle = false
    
    if !attr[:title].nil?
      @hastitle = true
    end
    
    # testing parsing templates from tags
    parse_template 'flickr_gallery/_gallery'
  end
 
  private

    def parse_template(filename)
      require 'erb'
      template = ''
      File.open("#{FlickrGalleryExtension.root}/app/views/" + filename + '.html.erb', 'r') { |f|
        template = f.read
      }
      ERB.new(template).result(binding)
    end
    
    def get_photos(setid)
      require 'open-uri'
      require 'nokogiri'
      
      config = YAML.load_file("config/flickr.yml")
      api_key = config['key']

      photoset_photos = Nokogiri::XML(open("http://api.flickr.com/services/rest/?method=flickr.photosets.getPhotos&api_key=#{api_key}&photoset_id=#{setid}"))
      photos = []
      

      photoset_photos.xpath("/rsp/photoset/photo").each do |photo|
        photourl = get_photo(photo['id'])
        photoinfo = get_title_and_description(photo['id'])
        
        photourl.concat(photoinfo)
        photos.push(photourl)
      end
      
      return photos
    end
    
    def get_photo(photo_id)
      require 'open-uri'
      require 'nokogiri'
      
      config = YAML.load_file("config/flickr.yml")
      api_key = config['key']
      
      photoset_photo = Nokogiri::XML(open("http://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=#{api_key}&photo_id=#{photo_id}"))
      
      set_photo = []
      
      photoset_photo.xpath("/rsp/sizes/size").each do |size|
        if size['label'] == "Square" || size['label'] == "Medium"
          set_photo.push(size['source'])
        end
      end

      return set_photo

    end

    def get_title_and_description(photo_id)
      require 'open-uri'
      require 'nokogiri'
      
      config = YAML.load_file("config/flickr.yml")
      api_key = config['key']

      results = []
      
      photo_info = Nokogiri::XML(open("http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=#{api_key}&photo_id=#{photo_id}"))
      title = photo_info.xpath("/rsp/photo/title").first
      description = photo_info.xpath("/rsp/photo/description").first
      
      results.push(title.text)
      
      if description.text.nil?
        results.push(description.text)
      else
        results.push(" ")
      end
      
      return results

    end
 
end