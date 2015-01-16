# encoding: utf-8
require 'carrierwave/processing/mime_types'

class ImageUploader < CarrierWave::Uploader::Base
  # include CarrierWaveDirect::Uploader
  # include ::CarrierWave::Backgrounder::Delay

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper

  # Sprockets Rails 4 Style
  # include Sprockets::Rails::Helper

  # Choose what kind of storage to use for this uploader:
  # storage :file
  storage :fog

  include CarrierWave::MimeTypes
  process :set_content_type

  # after :store, :unlink_original
  # before :process, :set_image_dimensions

  # def unlink_original(file)
  #   File.delete if version_name.blank?
  # end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  # def store_dir
  #   "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  # end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    # For Rails 3.1+ asset pipeline compatibility:
    # asset_path("fallback/" + [version_name, "default_link.png"].compact.join('_'))

    # Rails 4 Alternative
    ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default_link.png"].compact.join('_'))

    # "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  end

  # def image
  #   @image ||= MiniMagick::Image.open( model.send(mounted_as).path )
  # end

  # def image_width 
  #   image[:width]
  # end

  # def image_height
  #   image[:height]
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end
  
  # Create different versions of your uploaded files:
  # version :original, :if => :is_file_upload?

  # process :get_original_dimensions
  process :resize_to_fit => [50, 50], :if => :not_file_upload?

  # def get_original_dimensions
  #   @original_width = image_width
  #   @original_height = image_height
  # end


  # process :resize_to_limit => [200, 200], :if => :is_not_file_upload?

  # Default version always saves thumbs
  version :thumb do 
    # process :convert => 'png'
    process :resize_to_fit => [50, 50]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    if original_filename 
      @name ||= Digest::MD5.hexdigest(File.dirname(current_path))
      "#{@name}.#{file.extension}"
    end
  end

  # def is_landscape? picture
  #   image = RMagick::Image.open(picture.path)
  #   image[:width] > image[:height]
  # end

  protected

    def is_file_upload? picture
      model.remote_image_url.blank?
    end

    def not_file_upload? picture
      !model.remote_image_url.blank?
    end

    # def set_image_dimensions picture
      
    #   if @original_width.nil?
    #     @original_width = image[:width]
    #     @original_height = image[:height]
    #   end
    # end
    # def is_not_file_upload? picture
    #   not model.remote_image_url.blank?
    # end
end
