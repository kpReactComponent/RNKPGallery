Pod::Spec.new do |s|

  s.name         = "KPGallery"
  s.version      = "0.2.4"
  s.summary      = "image browser for iOS (powerful, superior performance)"
  s.description  = <<-DESC
  					image browser for iOS (powerful, superior performance), 
  					an easy way to use.
                   DESC

  s.homepage     = "https://github.com/kpReactComponent/RNKPGallery.git"

  s.license      = "MIT"

  s.author       = { "xukj" => "xuwaer@gmail.com" }
 
  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/kpReactComponent/RNKPGallery.git", :tag => "#{s.version}" }

  s.source_files  = "KPGallery/**/*.{h,m}"
  # s.exclude_files = "KPGallery/SDWebImage/**/*", "KPGallery/YYImage/**/*"

  s.resources = "KPGallery/YBImageBrowser/YBImageBrowser.bundle"

  s.frameworks = "Foundation","UIKit"

  s.requires_arc = true

  # s.dependency 'SDWebImage', '~>5.0.0'
  # s.dependency 'YYImage'

end
