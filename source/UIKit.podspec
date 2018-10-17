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
  
  s.subspec 'Core' do |ss|
      s.dependency 'SFIMFoundation', '~> 0.1.1'
      s.dependency 'Masonry', '~> 1.1.0'
      ss.public_header_files = "#{sf_source_class_prefix}/SFIMUIKit.h"
      ss.source_files = "#{sf_source_class_prefix}/SFIMUIKit.h"
  end
  
  #通用的库(比如Category/Macro/Util)
  s.subspec 'Library' do |ss|
      ss.public_header_files = "#{sf_source_class_prefix}/Library/*.h"
      ss.source_files = "#{sf_source_class_prefix}/Library/*.{h,m,mm,c}"
      ss.dependency "#{s.name}/Core"
      # 常用的基类
      ss.subspec 'Base' do |sss|
          sss.public_header_files = "#{sf_source_class_prefix}/Library/Base/**/*.h"
          sss.source_files = "#{sf_source_class_prefix}/Library/Base/**/*.{h,m,mm,c}"
          sss.dependency "#{s.name}/Library/Category"
      end
      # 常用的宏定义
      ss.subspec 'Macro' do |sss|
          sss.source_files = "#{sf_source_class_prefix}/Library/Macro/**/*.{h,m,mm,c}"
          sss.public_header_files = "#{sf_source_class_prefix}/Library/Macro/**/*.h"
      end
      # 常用的Category
      ss.subspec 'Category' do |sss|
          sss.source_files = "#{sf_source_class_prefix}/Library/Category/**/*.{h,m,mm}"
          sss.public_header_files = "#{sf_source_class_prefix}/Library/Category/**/*.h"
          #category.exclude_files = "#{sf_source_class_prefix}/Library/Category/UIViewController/UIViewController+ZYSliderViewController.{h,m}"
          sss.dependency 'DZNEmptyDataSet', '~> 1.8.1'
          sss.dependency 'MJRefresh', '~> 3.1.15.7'
          sss.dependency 'OpenUDID', '~> 1.0.0'
      end
      # 常用的工具集
      ss.subspec 'Utility' do |sss|
          sss.source_files = "#{sf_source_class_prefix}/Library/Utility/**/*.{h,m,mm,c}"
          sss.public_header_files = "#{sf_source_class_prefix}/Library/Utility/**/*.h"
      end
  end
  
  # Router相关
  s.subspec 'Router' do |ss|
      ss.source_files = "#{sf_source_class_prefix}/Router/**/*.{h,m,mm,c}"
      ss.public_header_files = "#{sf_source_class_prefix}/Router/**/*.h"
      ss.dependency 'MGJRouter', '~> 0.10.0'
      ss.dependency "#{s.name}/Core"
  end
  
  # HUD相关
  s.subspec 'HUD' do |hud|
      hud.public_header_files = "#{sf_source_class_prefix}/HUD/**/*.h"
      hud.source_files = "#{sf_source_class_prefix}/HUD/**/*.{h,m,mm,c}"
      hud.dependency 'MBProgressHUD', '~> 1.1.0'
      hud.dependency 'WSProgressHUD', '~> 1.1.3'
      hud.dependency "#{s.name}/Library"
      hud.resource = "#{sf_source_class_prefix}/HUD/SFIMHUD.bundle"
  end
  
  # Tab相关
  s.subspec 'Tab' do |tab|
      tab.public_header_files = "#{sf_source_class_prefix}/Tab/**/*.h"
      tab.source_files = "#{sf_source_class_prefix}/Tab/**/*.{h,m,mm,c}"
      tab.dependency "#{s.name}/Library"
  end
  
  # 录制小视频
  s.subspec 'MicroVideo' do |microvideo|
      microvideo.source_files = "#{sf_source_class_prefix}/MicroVideo/**/*.{h,m,mm,c}"
      microvideo.public_header_files = "#{sf_source_class_prefix}/MicroVideo/**/*.h"
      microvideo.resource = "#{sf_source_class_prefix}/MicroVideo/Resources/MicroVideo.bundle"
      microvideo.dependency 'SCRecorder', '~> 2.7.0'
      microvideo.dependency 'TZImagePickerController', '~> 3.0.9'
      microvideo.dependency "#{s.name}/Library"
      microvideo.dependency "#{s.name}/HUD"
  end
  
  # 地图定位预览
  s.subspec 'MapLocation' do |location|
      location.source_files = "#{sf_source_class_prefix}/MapLocation/**/*.{h,m,mm,c}"
      location.public_header_files = "#{sf_source_class_prefix}/MapLocation/**/*.h"
      location.resources = "#{sf_source_class_prefix}/MapLocation/**/*.{storyboard,xib,png,plist,xcassets,lproj}"
      location.resource  = "#{sf_source_class_prefix}/MapLocation/MapLocation.bundle"
      location.dependency "#{s.name}/Library"
      location.dependency "#{s.name}/HUD"
  end
  
end
