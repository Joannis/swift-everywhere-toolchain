require_relative "../Scripts/Common/Builder.rb"
Dir[File.dirname(__FILE__) + '/../Scripts/**/*.rb'].each { |file| require file }

class ProjectBuilder < Builder

   attr_reader :binary

   def initialize(component, arch)
      super(component, arch)
      @sources = "#{Config.projects}/#{component}"
      @swift = SwiftBuilder.new()
      @ndk = NDK.new()
      @dispatch = DispatchBuilder.new(@arch)
      @foundation = FoundationBuilder.new(@arch)
      @icu = ICUBuilder.new(@arch)
      @curl = CurlBuilder.new(@arch)
      @xml = XMLBuilder.new(arch)
      @ssl = OpenSSLBuilder.new(@arch)
      @binary = "#{@builds}/#{component}"
   end

   def prepare
      removeBuilds()
      super
   end

   def libs
      return Dir["#{@builds}/lib/*"]
   end

   def copyLibs()
      targetDir = "#{@builds}/lib"
      execute "rm -rvf \"#{targetDir}\""
      execute "mkdir -p \"#{targetDir}\""
      message "Copying Shared Objects started."
      Dir["#{@swift.installs}/lib/swift/android/armv7" + "/*.so"].each { |lib|
         execute "cp -vf #{lib} #{targetDir}"
      }
      Dir["#{@dispatch.installs}/lib/swift/android" + "/*.so"].each { |lib|
         execute "cp -vf #{lib} #{targetDir}"
      }
      Dir["#{@foundation.installs}/lib/swift/android" + "/*.so"].each { |lib|
         execute "cp -vf #{lib} #{targetDir}"
      }
      Dir[@icu.lib + "/*.so"].each { |lib|
         execute "cp -vf #{lib} #{targetDir}"
      }
      Dir[@curl.lib + "/*.so"].each { |lib|
         execute "cp -vf #{lib} #{targetDir}"
      }
      Dir[@xml.lib + "/*.so"].each { |lib|
         execute "cp -vf #{lib} #{targetDir}"
      }
      Dir[@ssl.lib + "/*.so*"].each { |lib|
         execute "cp -vf #{lib} #{targetDir}"
      }
      cxxLibPath = "#{@ndk.sources}/sources/cxx-stl/llvm-libc++/libs/armeabi-v7a/libc++_shared.so"
      execute "cp -vf #{cxxLibPath} #{targetDir}"
      message "Copying Shared Objects completed."
   end

   def swiftFlags
      cmd = []
      cmd << "-target armv7-none-linux-androideabi"
      # cmd << "-v"
      cmd << "-tools-directory #{@ndk.toolchain}"
      cmd << "-sdk #{@ndk.sources}/platforms/android-21/arch-arm"
      cmd << "-Xcc -I#{@ndk.toolchain}/sysroot/usr/include -Xcc -I#{@ndk.toolchain}/sysroot/usr/include/arm-linux-androideabi"
      cmd << "-Xcc -DDEPLOYMENT_TARGET_ANDROID -Xcc -DDEPLOYMENT_TARGET_LINUX -Xcc -DDEPLOYMENT_RUNTIME_SWIFT"
      cmd << "-I #{@dispatch.installs}/lib/swift/dispatch"
      cmd << "-I #{@dispatch.installs}/lib/swift/android/armv7"
      cmd << "-I #{@dispatch.installs}/lib/swift"
      cmd << "-I #{@foundation.installs}/lib/swift/android/armv7"
      cmd << "-I #{@foundation.installs}/lib/swift/CoreFoundation"
      cmd << "-I #{@foundation.installs}/lib/swift"
      cmd << "-L #{@ndk.sources}/sources/cxx-stl/llvm-libc++/libs/armeabi-v7a"
      cmd << "-L #{@ndk.toolchain}/lib/gcc/arm-linux-androideabi/4.9.x" # Link the Android NDK's libc++ and libgcc.
      cmd << "-L #{@foundation.installs}/lib/swift/android"
      cmd << "-L #{@dispatch.installs}/lib/swift/android"
      cmd << "-L #{@swift.installs}/lib/swift/android/armv7"
      return cmd
   end

end
