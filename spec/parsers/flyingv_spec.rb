#coding: utf-8
require 'spec_helper'

describe CrowdFundingParser::Parser::Flyingv do
  let(:doc) { get_project_doc("https://www.flyingv.cc/project/41") }

  it 'gets project title' do
    expect(subject.get_title(doc)).to eq('ch+u：超電能飛行腕錶')
  end
  it "gets money category" do
    expect(subject.get_category(doc)).to eq('設計商品')
  end
  it "gets creator name" do
    expect(subject.get_creator_name(doc)).to eq('Eric Chiu')
  end
  it "gets creator link" do
    expect(subject.get_creator_link(doc)).to eq('https://www.flyingv.cc/profile/304')
  end
  it "gets creator id" do
    expect(subject.get_creator_id(doc)).to eq('304')
  end
  it "gets summary" do
    expect(subject.get_summary(doc)).to include('了將近半年，中間收到了不下上百次讀者的熱情詢問')
  end
  it "gets start date" do
    expect(subject.get_start_date(doc)).to eq('2012/08/22')
  end
  it "gets end date" do
    expect(subject.get_end_date(doc)).to eq('2012/11/11')
  end
  it "gets region" do
    expect(subject.get_region(doc)).to eq('Taiwan')
  end
  it "gets money goal" do
    expect(subject.get_money_goal(doc)).to eq('360000')
  end
  it "gets money pledged" do
    expect(subject.get_money_pledged(doc)).to eq('3546200')
  end
  it "gets money_goal" do
    expect(subject.get_money_goal(doc)).to eq('360000')
  end
  it "gets money_goal" do
    expect(subject.get_money_goal(doc)).to eq('360000')
  end
  it "gets money_goal" do
    expect(subject.get_money_goal(doc)).to eq('360000')
  end
  it "gets money_goal" do
    expect(subject.get_money_goal(doc)).to eq('360000')
  end

end
