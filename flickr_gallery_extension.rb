# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

require 'open-uri'
require 'nokogiri'

class FlickrGalleryExtension < Radiant::Extension
  version "1.0"
  description "A Radiant extension that allows you to add paginated flickr galleries"
  url "http://www.scullytown.com"
  
  define_routes do |map|
    
    #This links to an xml file listing of all the testimonials, defined in the extension tags
    #map.connect 'testimonials', :url => '/testimonials', :controller => "site", :action => "show_page"
    #map.connect '', :controller => "testimonials", :action => "index"
   
    # map.with_options(:controller => 'flickr_pages') do |flickr|
    #   flickr.flickr_page_index '/guestphotos', :action => 'index'
    # end
    # 
    
    map.with_options(:controller => 'admin/gallery') do |flickr|
      flickr.flickr_gallery_index   'admin/gallery', :action => 'index'
    end
    
    map.with_options(:controller => 'flickr_gallery') do |flickr|
      flickr.flickr_gallery_photoset '/flickr-gallery/:setid', :action => 'photoset'
    end
    
    map.with_options(:controller => 'flickr_javascript') do |flickr|
      flickr.flickr_gallery_photoset '/flickr-gallery/:setid/javascript', :action => 'photoset'
    end

  end
  
  def activate
    admin.tabs.add("Flickr Gallery", "/admin/gallery", :after => "Layouts", :visibility => [:all])
    Page.send :include, FlickrGalleryTags
    NoCachePage
  end
  
  def deactivate
    # admin.tabs.remove "Testimonial"
  end
  
end