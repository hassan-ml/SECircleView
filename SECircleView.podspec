
Pod::Spec.new do |s|

	s.name         = "SECircleView"
	s.version      = "0.0.0"
	s.summary      = "SECircleView Summary"
	s.description  = <<-DESC
	SECircleView Description
				   DESC

	s.homepage     = "https://github.com/hassan-ml/SECircleView"
	s.author       = { "Muhammad Hassan" => "muhammad.hassan@mobilelive.ca" }

	s.platform     = :ios, "8.0"
	s.source       = { :git => "https://github.com/hassan-ml/SECircleView.git", :tag => "#{s.version}" }
	s.source_files = 'SECircleView/SECircleView/*'

	s.subspec 'SECircleView' do |ss|
	ss.source_files = 'SECircleView/SECircleView/*.{h,m}'
	end

	s.framework    = 'UIKit'	
	s.requires_arc = true

end
