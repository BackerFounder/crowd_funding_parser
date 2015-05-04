require 'spec_helper'

describe CrowdFundingParser::Parser::Flyingv do
  let(:doc) { get_project_doc("https://www.flyingv.cc/project/41") }

  it 'does stuff' do
    expect(subject.get_title(doc)).to eq("ch+u：超電能飛行腕錶")
  end
end
