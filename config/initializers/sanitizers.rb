# Rails.application.config.to_prepare do
#   class CustomPermitScrubber < Rails::Html::PermitScrubber
#     def initialize
#       super
#       # Remove 'noscript' from the tags set to avoid the warning
#       self.tags = Set.new(%w[strong em a])
#     end
#   end

#   sanitizer = Rails::Html::SafeListSanitizer.new
#   sanitizer.instance_variable_set(:@permit_scrubber, CustomPermitScrubber.new)
#   Rails::Html::Sanitizer.instance_variable_set(:@sanitizer, sanitizer)
# end