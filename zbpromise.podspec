Pod::Spec.new do |s|
  s.name         = "zbpromise"
  s.version      = "0.0.1.1"
  s.summary      = "Promise for Objc."
  s.description  = <<-DESC
                  Use Objc Promise.
                   DESC
  s.homepage     = "https://github.com/githubzb/zbpromise"
  s.license      = "MIT"
  s.author       = { "dr.box" => "1126976340@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/githubzb/zbpromise.git", :tag => "#{s.version}" }
  s.requires_arc = true
  s.source_files = "#{s.name}/Resource/**/*.{h,m}"
  # s.dependency "JSONKit", "~> 1.4"
end
