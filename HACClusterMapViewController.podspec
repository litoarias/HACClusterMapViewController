Pod::Spec.new do |s|
  s.name         = "HACClusterMapViewController"
  s.version      = "2.2"
  s.summary      = "HACClusterMapViewController iOS 7 >."
  s.description  = <<-DESC
    HACClusterMapViewController class is written in Objective-C and facilitates the use of maps when they have many pins that show.
    DESC
  s.homepage         = "https://github.com/litoarias/HACClusterMapViewController"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.authors          = { "litoarias" => "lito.arias.cervero@gmail.com" }
  s.social_media_url = 'https://github.com/litoarias/HACClusterMapViewController'
  s.platform         = :ios, "7.0"
  s.source           = { :git => "https://github.com/litoarias/HACClusterMapViewController.git", :tag => "2.2" }
  s.source_files     = "HACClusterMapViewController"
  s.requires_arc     = true

  s.ios.frameworks = 'CoreLocation','MapKit'

end
