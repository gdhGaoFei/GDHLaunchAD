Pod::Spec.new do |s|

s.name = 'GDHLaunchAD'
s.version = '1.0.0'
s.license = 'MIT'
s.summary = 'An Launch AD view on iOS.'
s.homepage = 'https://github.com/gdhGaoFei/GDHLaunchAD'
s.authors = { '_GaoFei' => 'gdhgaofei@163.com' }
s.source = { :git => 'https://github.com/gdhGaoFei/GDHLaunchAD.git', :tag => s.version.to_s }
s.requires_arc = true
s.ios.deployment_target = '6.0'
s.source_files = 'GDHLaunchAD/*.{h,m}'

end
