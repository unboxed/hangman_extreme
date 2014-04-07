require 'spec_helper'

describe WordsHelper do

  it 'must get the definition' do
    Dictionary.should_receive(:define).with('dog').and_return("The Definition\nTest me")
    define_word('dog').should be == 'The Definition<br/>Test me'
  end

end
