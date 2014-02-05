Pod::Spec.new do |s|
  s.name         = "Hydrant"
  s.version      = "0.1.1"
  s.summary      = "A simple data mapper / object serializer for objective-c"

  s.description  = <<-DESC
                   A simply object data mapper for Objective-C.

                   Automated mapping of NSDictionaries/NSArrays to Value Objects with
                   the goal of being exception-free and support graceful degregation.
                   DESC

  s.homepage     = "https://github.com/jeffh/Hydrant"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { "Jeff Hui" => "jeff@jeffhui.net" }
  s.social_media_url = "http://twitter.com/jeffhui"
  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'
  s.source       = { :git => "https://github.com/jeffh/Hydrant.git", :branch => "master" }
  s.source_files  = 'Hydrant/**/*.{h,m}'
  s.public_header_files = 'Hydrant/Public/**/*.h'
  s.requires_arc = true
end
