Pod::Spec.new do |s|
  s.name                  = "Hydrant"
  s.version               = "2.0.0-alpha.2"
  s.summary               = "A simple data mapper / object serializer for objective-c"

  s.description           = <<-DESC
                            A simple object data mapper for Objective-C.

                            Automated mapping of NSDictionaries/NSArrays to Value Objects with
                            the goal of being exception-free and support graceful error handling.

                            Read up the documentation at http://hydrant.readthedocs.org/.
                            DESC

  s.homepage              = "https://github.com/jeffh/Hydrant"
  s.license               = { :type => 'BSD', :file => 'LICENSE' }
  s.author                = { "Jeff Hui" => "jeff@jeffhui.net" }
  s.social_media_url      = "http://twitter.com/jeffhui"
  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'
  s.source                = { :git => "https://github.com/jeffh/Hydrant.git", :tag => "v#{s.version}" }
  s.source_files          = 'Hydrant/**/*.{h,m}'
  s.public_header_files   = 'Hydrant/Public/**/*.h'
  s.requires_arc          = true
end
