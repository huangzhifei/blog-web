Pod::Spec.new do |s|
  s.name              = "UIKit"
  s.version           = "1.1.2"
  s.summary           = "xxxxxxxxx"
  s.homepage          = "https://www.baidu.com"
  s.author            = { "xxxxx" => "xxxxx", "xxxxx" => "xxxxx" }
  s.license = {
    :type => 'Copyright',
    :text => <<-LICENSE
           Copyright (c) xxxxx. All rights reserved. 
    LICENSE
  }
  
  sf_source_root = "http://github.com.git"
  sf_source_branch = "release/V0.1"
  sf_source_class_prefix = "#{s.name}/Pod/Classes"

  #s.source            = { :git => "#{sf_source_root}", :branch => "#{sf_source_branch}"}
  s.source            = { :git => "#{sf_source_root}", :tag => "#{s.version}"}
  
  s.ios.frameworks = 'UIKit', 'Foundation'
  s.ios.deployment_target = '8.0'
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  
  s.public_header_files = "#{sf_source_class_prefix}/UIKit.h"
  s.source_files = "#{sf_source_class_prefix}/UIKit.h"
  
  s.dependency 'Foundation', '~> 0.1.2'
  s.dependency 'Masonry', '~> 1.1.0'
  
  #通用的库(比如Category/Macro/Util)
  s.subspec 'Library' do |ss|
      ss.public_header_files = "#{sf_source_class_prefix}/Library/*.h"
      ss.source_files = "#{sf_source_class_prefix}/Library/*.{h,m,mm,c}"
      # 常用的基类
      ss.subspec 'Base' do |base|
          base.public_header_files = "#{sf_source_class_prefix}/Library/Base/**/*.h"
          base.source_files = "#{sf_source_class_prefix}/Library/Base/**/*.{h,m,mm,c}"
          base.dependency "#{s.name}/Library/Category"
      end
      # 常用的宏定义
      ss.subspec 'Macro' do |macro|
          macro.source_files = "#{sf_source_class_prefix}/Library/Macro/**/*.{h,m,mm,c}"
          macro.public_header_files = "#{sf_source_class_prefix}/Library/Macro/**/*.h"
      end
      # 常用的Category
      ss.subspec 'Category' do |category|
          category.source_files = "#{sf_source_class_prefix}/Library/Category/**/*.{h,m,mm}"
          category.public_header_files = "#{sf_source_class_prefix}/Library/Category/**/*.h"
          #category.exclude_files = "#{sf_source_class_prefix}/Library/Category/UIViewController/UIViewController+ZYSliderViewController.{h,m}"
          category.dependency 'DZNEmptyDataSet', '~> 1.8.1'
          category.dependency 'MJRefresh', '~> 3.1.15.7'
      end
      # 常用的工具集
      ss.subspec 'Utility' do |util|
          util.source_files = "#{sf_source_class_prefix}/Library/Utility/**/*.{h,m,mm,c}"
          util.public_header_files = "#{sf_source_class_prefix}/Library/Utility/**/*.h"
      end
  end
  
  # HUD相关
  s.subspec 'HUD' do |hud|
      hud.public_header_files = "#{sf_source_class_prefix}/HUD/**/*.h"
      hud.source_files = "#{sf_source_class_prefix}/HUD/**/*.{h,m,mm,c}"
      #hud.exclude_files = "#{sf_source_class_prefix}/HUD/**/UIViewController+SFIMAlertExtension.{h,m}"
      hud.dependency "#{s.name}/Library"
      hud.dependency 'MBProgressHUD', '~> 1.1.0'
      hud.dependency 'WSProgressHUD', '~> 1.1.3'
  end
  
  # Tab相关
  s.subspec 'Tab' do |tab|
      tab.public_header_files = "#{sf_source_class_prefix}/Tab/**/*.h"
      tab.source_files = "#{sf_source_class_prefix}/Tab/**/*.{h,m,mm,c}"
      tab.dependency "#{s.name}/Library"
  end
  
end
