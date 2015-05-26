BUILD_DIR=File.absolute_path('build')
SDK_BUILD_VERSION=ENV["SDK_BUILD_VERSION"] || ""

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

  def self.launch(app, sdk)
    quit
    system_or_exit("ios-sim launch #{app.inspect} --tall --retina --sdk #{sdk.inspect} 2>&1 | tee -a /dev/stdout /dev/stderr | grep -q ', 0 failures'")
  end
end

def xcbuild(cmd)
  Simulator.quit
  unless system_or_exit("xcodebuild #{cmd}", "build.txt")
  end
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
  xcbuild("test -scheme Hydrant-iOS -workspace Hydrant.xcworkspace -sdk iphonesimulator#{SDK_BUILD_VERSION} -destination 'name=iPhone 5s,OS=8.3' SYMROOT=#{BUILD_DIR.inspect}")
  puts
end

desc 'Runs OSX test bundles'
task :specs_osx do
  Simulator.quit
  xcbuild("test -scheme Hydrant-OSX -workspace Hydrant.xcworkspace -sdk macosx SYMROOT=#{BUILD_DIR.inspect}")
  puts
end

desc 'Runs cocoapod spec lint'
task :lint do
  system_or_exit('pod spec lint Hydrant.podspec')
end

task :default => [:clean, :specs_osx, :specs_ios]
desc 'Runs the task CI would run'
task :ci => [:default, :lint]
