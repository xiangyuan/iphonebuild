iphonebuild
===========


### NOTE

  if you want install the builded app to you Iphone simulator
    you must install the ios-sim command line tool
           brew install ios-sim
     if you want install debug app to you Iphone device
     you must install the ios-deploy tool
           git clone https://github.com/phonegap/ios-deploy.git
           cd ios-deploy
           make install


### build scripts

Example usage:
    ruby iphone.rb build [options]

        options:
            -p --project the project you want to build [must]
            -w --workspace the workspace you want to build [must -p, -w two choose one ]
            -s --scheme the scheme to provide [Default: target name]
            -d --device the sdk you want to use [device | simulator] the build use sdk
                        choose [iphoneos | iphonesimulator]
            -c --configuration  build xcode project's configuration
                eg: Release| Debug OBJROOT=$(project)/buid [Default: Debug]

    ruby iphone.rb install [options]

        options:
            -d --device the device you want to install [iphone | simulator]
            -b --bundle the app you want to install
            -t --tall   3.5 inc or 4.0 inc
            -r --retina retina simulator the simulator use
            -s --sdk the sdk version [6.0 | 7.1]


