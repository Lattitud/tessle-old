# encoding: utf-8
require 'carrierwave/processing/mime_types'

class AvatarUploader < CarrierWave::Uploader::Base
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

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  # def store_dir
  #   "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  # end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    # For Rails 3.1+ asset pipeline compatibility:
    # asset_path("fallback/" + [version_name, "default_avatar.png"].compact.join('_'))
  
    # Rails 4 Alternative
    ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default_avatar.png"].compact.join('_'))

    # "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  process :resize_to_limit => [400, 400]
  # process :convert => 'png'

  version :thumb do
    process :crop
    resize_to_fill(100, 100)
    # process :convert => 'png'
  end

  version :mini, :from_version => :thumb do
    resize_to_fill(32, 32)
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   if original_filename 
  #     if model && model.read_attribute(:avatar).present?
  #       model.read_attribute(:avatar)
  #     else
  #       @name ||= Digest::MD5.hexdigest(File.dirname(current_path))
  #       "#{@name}.#{file.extension}"
  #     end
  #   end
  # end

  def filename
    if original_filename 
      @name ||= Digest::MD5.hexdigest(File.dirname(current_path))
      "#{@name}.#{file.extension}"
    end
  end

  def crop
    if model.crop_x.present?
      manipulate! do |img|
        x = model.crop_x.to_i
        y = model.crop_y.to_i
        w = model.crop_w.to_i
        h = model.crop_h.to_i
        img.crop!(x, y, w, h)
        # Minimagick commands
        # img.crop("#{w}x#{h}+#{x}+#{y}")
        # img
      end
    end
  end

  # def is_landscape? picture
  #   image = MiniMagick::Image.open(picture.path)
  #   image[:width] > image[:height]
  # end

  # protected
  #   def is_direct_upload?
  #     ! model.direct_avatar_upload_url.blank?
  #   end

end
