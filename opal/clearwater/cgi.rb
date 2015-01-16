module Clearwater
  class CGI
    def self.escape string
      # string.gsub(/([^ a-zA-Z0-9_.-]+)/) do |ch|
      string.chars.map do |ch|
        if ch =~ /([^ a-zA-Z0-9_.-]+)/
          "%#{ch.ord.to_s(16).upcase}"
        else
          ch
        end
      end.join.tr(' ', '+')
    end
  end
end
