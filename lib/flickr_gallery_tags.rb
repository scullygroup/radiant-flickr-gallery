module FlickrGalleryTags
  include Radiant::Taggable
  
  tag "flickrgallery" do |tag|
    attr = tag.attr.symbolize_keys
    
    photosetarray = attr[:photosets].split(',')
    
    @photos = get_photos(photosetarray[0])
    @photos_json = @photos.to_json
    
    
    @hastitle = false
    
    if !attr[:title].nil?
      @hastitle = true
    end
    
    # @photosets = get_photosets(photosetarray)
    
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
 
    def get_photosets(sets)
      require 'open-uri'
      require 'nokogiri'
      
      config = YAML.load_file("config/flickr.yml")
      @api_key = config['key']
      @user = config['user']

      @doc = Nokogiri::XML(open("http://api.flickr.com/services/rest/?method=flickr.photosets.getList&api_key=#{@api_key}&user_id=#{@user}"))

      first = true
      flickr_photosets = []

      sets.each do |setid|
        @doc.xpath("/rsp/photosets/photoset").each do |node|
          
          # if the photoset result for the user
          if setid == (node['id'])
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
        
            a_class = ""
        
            if !params[:setid] && first
              a_class = "current"
            elsif params[:setid] == node['id']
              a_class = "current"
            end
        
            flickr_photosets.push("<a class=\"#{a_class}\" href=\"/flickr-gallery/#{node['id']}\"><img src=\"#{set_photo}\" /><span>#{title.text}</span></a>")
        
            # its not the first run through
            first = false
          end
        end
      end

      # @doc.xpath("/rsp/photosets/photoset").each do |node|
      #   
      #   # if the photoset result for the user
      #   if sets.include?(node['id'])
      #     title = node.children
      #   
      #     # get the first photo in the set for the primary photo
      #     @photoset_photos = Nokogiri::XML(open("http://api.flickr.com/services/rest/?method=flickr.photosets.getPhotos&api_key=#{@api_key}&photoset_id=#{node['id']}&per_page=1"))
      #     first_photo = @photoset_photos.xpath("/rsp/photoset/photo").first
      # 
      #     # now take that id and find me the actual photo
      #     @set_photo = Nokogiri::XML(open("http://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=#{@api_key}&photo_id=#{first_photo['id']}"))
      # 
      #     set_photo = ""
      # 
      #     @set_photo.xpath("/rsp/sizes/size").each do |size|
      #       if size['label'] == "Square"
      #         set_photo = size['source']
      #       end
      #     end
      # 
      #     a_class = ""
      # 
      #     if !params[:setid] && first
      #       a_class = "current"
      #     elsif params[:setid] == node['id']
      #       a_class = "current"
      #     end
      # 
      #     flickr_photosets.push("<a class=\"#{a_class}\" href=\"/flickr-gallery/#{node['id']}\"><img src=\"#{set_photo}\" /><span>#{title.text}</span></a>")
      # 
      #     # its not the first run through
      #     first = false
      #   end
      # end

      return flickr_photosets
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
        if size['label'] == "Square" || size['label'] == "Original" || size['label'] == "Large"
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

    def get_description(photo_id)
      require 'open-uri'
      require 'nokogiri'
      
      config = YAML.load_file("config/flickr.yml")
      api_key = config['key']

      photo_info = Nokogiri::XML(open("http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=#{api_key}&photo_id=#{photo_id}"))
      description = photo_info.xpath("/rsp/photo/description").first

      return description.text
    end
 
end