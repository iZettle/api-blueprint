guard :rspec, cmd: 'bin/rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/api-blueprint/(.+)\.rb$})     { |m| "spec/api-blueprint/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end
