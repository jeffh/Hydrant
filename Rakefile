BUILD_DIR=File.absolute_path('build')
LATEST_SDK_VERSION=`xcodebuild -showsdks | grep iphonesimulator | cut -d ' ' -f 4`.chomp.split("\n").last
SDK_BUILD_VERSION=ENV["SDK_BUILD_VERSION"] || LATEST_SDK_VERSION

def system_or_exit(cmd, log=nil)
  puts "\033[32m==>\033[0m #{cmd}"
  if log
    logfile = "#{BUILD_DIR}/#{log}"
    system("mkdir -p #{BUILD_DIR.inspect}")
    unless system("#{cmd} 2>&1 > #{logfile.inspect}")
      system("cat #{logfile.inspect}")
      puts ""
      puts ""
      puts "[Failed] #{cmd}"
      puts "         Output is logged to: #{logfile}"
      exit 1
    end
  else
    unless system(cmd)
      puts "[Failed] #{cmd}"
      exit 1
    end
  end
end

class Simulator
  def self.quit
    system("osascript -e 'tell app \"iPhone Simulator\" to quit' > /dev/null")
    sleep(1)
  end
end

def xcbuild(cmd)
  Simulator.quit
  system_or_exit("xcodebuild #{cmd}", "build.txt")
end

def device_id_for(name)
  # Xcode final + beta tends to produce multiple device ids for the same OS +
  # name. Since device_ids aren't always the same across OSes, we need to
  # manually parse for one.
  contents = `xcodebuild test -scheme Hydrant-iOS -workspace Hydrant.xcworkspace -sdk iphonesimulator#{SDK_BUILD_VERSION} -destination 'help=me' 2>&1 | grep 'iOS Simulator' | grep 'OS:#{SDK_BUILD_VERSION}' | grep 'name:#{name}'`
  line = contents.split("\n").first
  match = /id:([a-zA-Z0-9-]+), /.match(line)
  unless match
    puts "[Failed] Cannot determine device id"
    exit(1)
  end

  match[1]
end

desc 'Cleans build dir'
task :clean do
  system_or_exit("rm -rf #{BUILD_DIR.inspect} || true")
end

desc 'Cleans build dir OS X Specs'
task :osx_specs do
  xcbuild("build -scheme HydrantOSXSpecs -configuration Debug SYMROOT=#{BUILD_DIR.inspect}")
  system_or_exit("env DYLD_FRAMEWORK_PATH=build/Debug/ build/Debug/HydrantOSXSpecs")
end

desc 'Runs iOS 8 test bundles'
task :specs_ios do
  Simulator.quit
  device_id = device_id_for('iPhone 5s')
  xcbuild("test -scheme Hydrant-iOS -workspace Hydrant.xcworkspace -sdk iphonesimulator#{SDK_BUILD_VERSION} -destination 'id=#{device_id}' SYMROOT=#{BUILD_DIR.inspect}")
  puts 
end

desc 'Runs OSX test bundles'
task :specs_osx do
  Simulator.quit
  xcbuild("test -scheme Hydrant-OSX -workspace Hydrant.xcworkspace SYMROOT=#{BUILD_DIR.inspect}")
  puts
end

desc 'Runs cocoapod spec lint'
task :lint do
  system_or_exit('pod spec lint Hydrant.podspec --verbose')
end

task :default => [:clean, :specs_osx, :specs_ios]
desc 'Runs the task CI would run'
task :ci => [:default, :lint]
