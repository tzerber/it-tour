module ImageUploader
  def self.included(base)
    base.send :include, CarrierWave::RMagick
    base.send :include, CarrierWave::MimeTypes
    base.send :process, :set_content_type
    base.send :storage, Features.s3_uploads? ? :fog : :file
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def filename
    "image.jpg" if original_filename
  end

  def extension_white_list
    %w(jpg jpeg png gif)
  end
end