require 'test_helper'

class ApiBlueprint::Test < ActiveSupport::TestCase
  test "truth" do
    binding.pry
    assert_kind_of Module, ApiBlueprint
  end
end
