BUILD_DIR=File.absolute_path('build')
SDK_BUILD_VERSION=ENV["SDK_BUILD_VERSION"] || ""

def system_or_exit(cmd)
  puts "Running: #{cmd}"
  unless system(cmd)
    exit 1
  end
end

def xcbuild(cmd)
  xcp = ENV['XCPRETTY'] || `which xcpretty`.strip! || ""
  if File.exists? xcp
    system_or_exit("xcodebuild #{cmd} | #{xcp} -tc")
  else
    system_or_exit("xcodebuild #{cmd}")
  end
end

def kill_simulator
  system('killall -9 "iPhone Simulator"')
  sleep 1
end

task :clean do
  system_or_exit("rm -rf #{BUILD_DIR.inspect} || true")
end

task :osx_specs do
  xcbuild("build -project Externals/cedar/Cedar.xcodeproj -configuration Debug -target Cedart c SYMROOT=#{BUILD_DIR.inspect}")
  xcbuild("build -scheme OSXSpecs -configuration Debug SYMROOT=#{BUILD_DIR.inspect}")
  system_or_exit("env DYLD_FRAMEWORK_PATH=build/Debug/ build/Debug/OSXSpecs")
end

task :specs71 do
  kill_simulator
  xcbuild("test -scheme Specs -sdk iphonesimulator#{SDK_BUILD_VERSION} -destination 'name=iPhone Retina (4-inch),OS=7.1' SYMROOT=#{BUILD_DIR.inspect}")
  puts
end

task :specs70 do
  kill_simulator
  xcbuild("test -scheme Specs -sdk iphonesimulator#{SDK_BUILD_VERSION} -destination 'name=iPhone Retina (4-inch),OS=7.0' SYMROOT=#{BUILD_DIR.inspect}")
  puts
end

task :specs61 do
  kill_simulator
  xcbuild("test -scheme Specs -sdk iphonesimulator#{SDK_BUILD_VERSION} -destination 'name=iPhone Retina (4-inch),OS=6.1' SYMROOT=#{BUILD_DIR.inspect}")
  puts
end

task :lint do
  system_or_exit('pod spec lint')
end

task :default => [:clean, :osx_specs, :specs71, :specs61]
task :ci => [:clean, :osx_specs, :specs70, :specs61, :lint]
