class MetaliceGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)

  def create_uploader_file
    template "uploader.rb", File.join('app/helpers', '', "metalice_helper.rb")
  end
end
