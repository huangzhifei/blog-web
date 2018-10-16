Pod::Spec.new do |s|
  s.name              = "Foundation"
  s.version           = "1.1.2"
  s.summary           = "xxxxxx"
  s.homepage          = "https://www.baidu.com"
  s.author            = { "xxx" => "xxxxx", "xxxx" => "xxxx" }
  s.license = {
    :type => 'Copyright',
    :text => <<-LICENSE
           Copyright (c) 2018, xxxxxxxxxxx. All rights reserved. 
    LICENSE
  }
  # 常量配置
  # sf_source_root: 项目仓库路径地址
  # sf_source_branch: 分支信息
  # sf_source_version: 版本信息
  # sf_source_class_prefix: class文件相对路径
  sf_source_root = "http://github.com.git"
  sf_source_branch = "release/V0.1"
  sf_source_version = "#{s.version}"
  sf_source_class_prefix = "#{s.name}/Pod/Classes"

  s.source            = { :git => "#{sf_source_root}", :branch => "#{sf_source_branch}"}
  
  s.ios.frameworks = 'Foundation', 'UIKit', 'AVFoundation', 'CoreLocation', 'AssetsLibrary'
  s.platform     = :ios, '8.0'
  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  
  s.public_header_files = "#{sf_source_class_prefix}/Foundation.h"
  s.source_files = "#{sf_source_class_prefix}/Foundation.h"

  #通用的库(比如Category/Macro/Util)
  s.subspec 'Library' do |ss|
    ss.public_header_files = "#{sf_source_class_prefix}/Library/*.h"
    ss.source_files = "#{sf_source_class_prefix}/Library/*.{h,m,mm,c}"
    # 常用的宏定义
    ss.subspec 'Macro' do |macro|
      macro.source_files = "#{sf_source_class_prefix}/Library/Macro/**/*.{h,m,mm,c}"
      macro.public_header_files = "#{sf_source_class_prefix}/Library/Macro/**/*.h"
    end
    # 常用的Category
    ss.subspec 'Category' do |category|
      category.source_files = "#{sf_source_class_prefix}/Library/Category/**/*.{h,m,mm}"
      category.public_header_files = "#{sf_source_class_prefix}/Library/Category/**/*.h"
    end
    # 常用的工具集
    ss.subspec 'Utility' do |util|
      util.source_files = "#{sf_source_class_prefix}/Library/Utility/**/*.{h,m,mm,c}"
      util.public_header_files = "#{sf_source_class_prefix}/Library/Utility/**/*.h"
    end
  end

  #数据库相关
  s.subspec 'DB' do |ss|
    ss.public_header_files = "#{sf_source_class_prefix}/DB/**/*.h"
    ss.source_files = "#{sf_source_class_prefix}/DB/**/*.{h,m,mm,c}"
    ss.dependency "#{s.name}/Library"
    ss.dependency 'FMDB', '~> 2.7.5'
  end

  #日志相关
  s.subspec 'Logger' do |ss|
    ss.public_header_files = "#{sf_source_class_prefix}/Logger/**/*.h"
    ss.source_files = "#{sf_source_class_prefix}/Logger/**/*.{h,m,mm,c}"
    ss.dependency 'CocoaLumberjack', '~> 3.3.0'
  end

  #Model相关
  s.subspec 'Model' do |ss|
    ss.public_header_files = "#{sf_source_class_prefix}/Model/**/*.h"
    ss.source_files = "#{sf_source_class_prefix}/Model/**/*.{h,m,mm,c}"
    ss.dependency "#{s.name}/Library"
    ss.dependency 'JSONModel', '~> 1.8.0'
  end
  
  #缓存
  s.subspec 'Cache' do |ss|
    ss.public_header_files = "#{sf_source_class_prefix}/Cache/**/*.h"
    ss.source_files = "#{sf_source_class_prefix}/Cache/**/*.{h,m,mm,c}"
    ss.dependency "#{s.name}/Library"
    ss.dependency 'PINCache', '~> 3.0.1-beta.6'
  end

  #网络层
  s.subspec 'Network' do |ss|
    ss.public_header_files = "#{sf_source_class_prefix}/Network/**/*.h"
    ss.source_files = "#{sf_source_class_prefix}/Network/**/*.{h,m,mm,c}"
    ss.dependency "#{s.name}/Library"
    ss.dependency "#{s.name}/Model"
    ss.dependency 'AFNetworking', '~> 3.2.1'
    ss.dependency 'ReactiveObjC', '~> 3.1.0'
  end

end
