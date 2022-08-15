# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'easy_ipa class' do
  include_examples 'the example', 'master.pp'
end
