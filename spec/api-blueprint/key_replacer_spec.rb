require "spec_helper"

describe ApiBlueprint::KeyReplacer, ".replace" do
  let(:original) { { foo: "Foo", bar: "Bar" } }
  let(:replacements) { { foo: :foo_bar } }
  let(:replaced) { ApiBlueprint::KeyReplacer.replace(original, replacements) }

  it "renames keys defined in the replacements hash" do
    expect(replaced[:foo]).to be nil
    expect(replaced[:foo_bar]).to eq "Foo"
  end

  it "doesn't rename keys not in replacements" do
    expect(replaced[:bar]).to eq "Bar"
  end
end
