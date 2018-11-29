Pod::Spec.new do |s|
  s.name              = "Vendors"
  s.version           = "1.1.2"
  s.summary           = "xxxx"
  s.homepage          = "https://www.baidu.com"
  s.author            = { "xxxx" => "xxxxx", "xxxxx" => "xxxx" }
  s.license = {
    :type => 'Copyright',
    :text => <<-LICENSE
           Copyright (c) xxxxx. All rights reserved. 
    LICENSE
  }
  
  sf_source_root = "http://github.com.git"
  sf_source_branch = "release/V0.1"
  sf_source_class_prefix = "#{s.name}/Pod"

  s.source            = { :git => "#{sf_source_root}", :branch => "#{sf_source_branch}"}
  #s.source            = { :git => "#{sf_source_root}", :tag => "#{s.version}"}
  
  s.ios.frameworks = 'UIKit', 'Foundation'
  s.ios.deployment_target = '8.0'
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  
  s.subspec 'QuanshiSDK' do |ss|
    ss.vendored_frameworks = "#{sf_source_class_prefix}/QuanshiSDK/**/*.framework"
    ss.resources           = "#{sf_source_class_prefix}/QuanshiSDK/**/*.bundle"
  end

  s.subspec 'SFGather' do |ss|
    ss.vendored_frameworks = "#{sf_source_class_prefix}/SFGather/**/*.framework"
  end

  s.subspec 'cryptopp' do |ss|
    ss.public_header_files = "#{sf_source_class_prefix}/cryptopp/**/*.h"
    ss.source_files = "#{sf_source_class_prefix}/cryptopp/**/*.{h,m,mm,c}"
    ss.vendored_libraries = "#{sf_source_class_prefix}/cryptopp/**/*.a"
  end
  

end
