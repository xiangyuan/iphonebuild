#!/usr/bin/env ruby
# encoding: utf-8


HELP = <<-eos
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
eos
#
#NOTE if you want install the builded app to you Iphone simulator
#     you must install the ios-sim command line tool
#           brew install ios-sim
#     if you want install debug app to you Iphone device
#     you must install the ios-deploy tool
#           git clone https://github.com/phonegap/ios-deploy.git
#           cd ios-deploy
#           make install
#
module Iphone
    require "optparse"
    require 'open3'
    # store the parser require
    @options = {}
    @build_options = {}

    class << self
        attr_accessor :options
        attr_accessor :build_options

        def help?
            if ARGV.length < 1
                show_help
            elsif ARGV.first.eql? 'build'
                proj_build
            elsif ARGV.first.eql? 'install'
                app_install
            else
                puts HELP
            end
        end

        def show_help
            puts HELP
        end

        # build project function
        def proj_build()
            @build_options[:device] = 'simulator'
            @build_options[:configuration] = 'Debug'
            build_parser = OptionParser.new do |opts|
                opts.banner = "Example usage: ruby #{File.basename(__FILE__)} build [options]"
                opts.separator  ''
                opts.separator  'build your ios project or workspace'
                opts.separator  ''
                opts.separator  'Options:'

                opts.on('-p','--project [project path]',String,'the project you want to build [must]') do |p|
                    @build_options[:project] = p
                end
                opts.on('-w','--workspace [workspace path]', String, 'the workspace you want to build [must -p, -w two choose one ]') do |w|
                   @build_options[:workspace] = w
                end
                opts.on('-s', '--scheme [target scheme]', String, 'the scheme to provide [Default: target name]') do |s|
                    @build_options[:scheme] = s
                end
                opts.on('-d','--device [device or simulator]', String, 'the sdk you want to use [device | simulator] the build use sdk
                                                choose [iphoneos | iphonesimulator]') do |d|
                                                    @build_options[:device] = d || 'simulator'
                                                end
                opts.on('-c','--configuration [configuration]', String,"build xcode project's configuration
                                        eg: Release| Debug OBJROOT=$(project)/buid [Default: Debug]") do |c|
                                            @build_options[:configuration] = c || 'Debug'
                                        end
                opts.on_tail('-h','--help','help message') do |h|
                    puts opts
                    exit
                end
            end

            build_parser.parse!
            if @build_options.empty?
                puts build_parser.help()
                exit
            else
                handle_build build_parser, @build_options
            end
        end

        #
        # \ handle the build project
        # |
        #/
        def handle_build(build_parser,coptions)
            if coptions[:project] and coptions[:workspace]
                puts build_parser.help
                exit
            end
            path = coptions[:project] || coptions[:workspace]
            proj=nil;target= nil;cmd=nil
            if coptions[:project]
                proj = Dir.glob("#{path}/*.xcodeproj").shift()
                if proj.nil?
                    puts build_parser.help()
                    exit
                end
                target = File.basename(proj,'.xcodeproj')
                coptions[:scheme] = coptions[:scheme] || target
                device = coptions[:device] == 'simulator'? 'iphonesimulator' : 'iphoneos'
                Dir.chdir(File.dirname(proj))
                cmd = "xctool -project #{File.basename(proj)} -scheme #{coptions[:scheme]} -sdk #{device} -configuration #{coptions[:configuration]} OBJROOT=./build SYMROOT=./build"
            elsif coptions[:workspace]
                proj = Dir.glob("#{paht}/*.xcworkspace").shift()
                if proj.nil?
                    puts build_parser.help()
                    exit
                end
                target = File.basename(proj,'.xcworksapce')
                coptions[:scheme] = coptions[:scheme] || target
                device = coptions[:device] == 'simulator'? 'iphonesimulator' : 'iphoneos'
                Dir.chdir(File.dirname(proj))
                cmd = "xctool -workspace #{File.basename(proj)} -scheme #{coptions[:scheme]} -sdk #{device} -configuration #{coptions[:configuration]} OBJROOT=#{Dir.pwd()}/build SYMROOT=#{Dir.pwd()}/build"
            end
            #
            #now build it
            puts cmd
            exit
            system(cmd)
        end
        # install app to the ios or simulator
        def app_install()
            @options[:tall] = 'tall'
            @options[:retina] = 'retina'
            @options[:sdk] = '7.1'
            @options[:device] = 'simulator'
            build_parser = OptionParser.new do |opts|
                opts.banner = "Example usage: ruby #{File.basename(__FILE__)} install [options]"
                opts.separator  ''
                opts.separator  'install your ios app to you simulator or device'
                opts.separator  ''
                opts.separator  'Options:'

                opts.on('-b','--bundle <bundle.app>',String,'the app you want to install') do |p|
                    @options[:bundle] = p
                end
                # opts.on('-debug','debug or not ') do |w|
                #    @options[:debug] = w
                # end
                opts.on('-t', '--tall', '3.5 inc or 4.0 inc device') do |s|
                    @options[:tall] = s
                end

                opts.on('-r','--retina', '3.5 inc or 4.0 inc device') do |s|
                    @options[:retina] = s
                end
                opts.on('-s','--sdk [sdk]', String, 'retina simulator the simulator use') do |s|
                    @options[:sdk] = s || '7.1'
                end
                opts.on('-d','--device [to install]',String, 'the device to install [device | simulator]') do |d|
                                                    @options[:device] = d || 'simulator'
                                                end
                opts.on_tail('-h','--help','help message') do |h|
                    puts opts
                    exit
                end
            end

            build_parser.parse!
            if @options.empty?
                puts build_parser.help()
                exit
            else
                handle_install build_parser, @options
            end
        end

        #
        # handle device install
        #
        def handle_install(build_parser,coptions)
            if coptions[:bundle].nil? or !coptions[:bundle].end_with? '.app'
                puts build_parser.help
                exit
            end
            if coptions[:device] == 'simulator'
                puts coptions
                if File.exist? coptions[:bundle]
                    cmd = "ios-sim launch #{coptions[:bundle]} --sdk #{coptions[:sdk]} --#{coptions[:retina]} --#{coptions[:tall]}"
                    puts cmd
                    system(cmd)
                else
                    puts 'the app you provided not exsits'
                    exit
                end
            elsif coptions[:device] == 'iphone'
                udid = ''
                Open3.popen3('ios-deploy -c') do |stdin,stdout,waitthr|
                    udid << stdout.read
                end
                if udid.empty? or !udid.index('(') or !udid.index(')')
                    puts 'you have not iphone device connect to your computer'
                    exit
                end
                ## get device id
                start = udid.index('(') + 1
                eid = udid.index(')')
                udid = udid[start...eid]
                #install command line
                cmd = "ios-deploy -i #{udid} -b #{coptions[:bundle]} -v"
                system(cmd)
            end
            #
        end

        #HELP
        def show()
            puts HELP
        end
    end
end

Iphone.help?
