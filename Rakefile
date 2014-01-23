Dir.glob('./Externals/thrust/lib/tasks/*.rake').each { |r| import r }

task :default => [:clean, :specs7, :osxspecs108]
task :ci => [:clean, :specs7, :specs6, :osxspecs108, :osxspecs107]
