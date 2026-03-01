Pod::Spec.new do |s|
  s.name         = 'LNetwork'
  s.version      = '1.0.0'
  s.summary      = 'Lightweight networking SDK with interceptor chain pattern'
  s.description  = <<-DESC
    LNetwork provides a protocol-driven networking layer built on Alamofire
    with interceptor chain pattern, generic response processing, and RxSwift support.
  DESC
  s.homepage     = 'https://github.com/97longphan/LNetwork'
  s.license      = { :type => 'MIT' }
  s.authors      = { 'LONGPHAN' => 'longphan@vinid.net' }
  s.platform     = :ios, '14.0'
  s.swift_version = '5.9'
  s.source       = { :git => 'https://github.com/97longphan/LNetwork.git', :tag => s.version.to_s }
  s.source_files = 'Sources/LNetwork/**/*.swift'
  s.frameworks   = 'Foundation'

  s.dependency 'Alamofire'
  s.dependency 'RxSwift'
end
