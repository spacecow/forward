# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'cucumber', :cli => '--no-profile --color --format progress --strict', :all_on_start => false, :all_after_pass => false do
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$})          { 'features' }
  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
end
