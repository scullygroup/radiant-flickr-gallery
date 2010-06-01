namespace :radiant do
  namespace :extensions do
    namespace :flickr_gallery do
      
      # desc "Runs the migration of the FlickrPages extension"
      # task :migrate => :environment do
      #   require 'radiant/extension_migrator'
      #   if ENV["VERSION"]
      #     FlickrPagesExtension.migrator.migrate(ENV["VERSION"].to_i)
      #   else
      #     FlickrPagesExtension.migrator.migrate
      #   end
      # end
      
      desc "Copies public assets of the FlickrGallery to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[FlickrGalleryExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(FlickrGalleryExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
