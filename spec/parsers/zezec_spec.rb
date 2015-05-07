#coding: utf-8
require 'spec_helper'

describe CrowdFundingParser::Parser::Zeczec do
  let(:doc) { get_project_doc("https://www.zeczec.com/projects/4thdimensionwatch", "zeczec") }

  it "gets project id" do
    expect(subject.get_id("https://www.zeczec.com/projects/4thdimensionwatch")).to eq("4thdimensionwatch")
  end
  it 'gets project title' do
    expect(subject.get_title(doc)).to eq("第四度空間腕錶 4th Dimension Watch")
  end
  it "gets money category" do
    expect(subject.get_category(doc)).to eq('設計')
  end
  it "gets creator name" do
    expect(subject.get_creator_name(doc)).to eq('游聲堯')
  end
  it "gets creator link" do
    expect(subject.get_creator_link(doc)).to eq('https://www.zeczec.com/users/yushenyao')
  end
  it "gets creator id" do
    expect(subject.get_creator_id(doc)).to eq('yushenyao')
  end
  it "gets summary" do
    expect(subject.get_summary(doc)).to include('水泥錶面')
  end
  it "gets start date" do
    expect(subject.get_start_date(doc)).to eq('2015/01/05')
  end
  it "gets end date" do
    expect(subject.get_end_date(doc)).to eq('2015/02/18')
  end
  it "gets region" do
    expect(subject.get_region(doc)).to eq('Taiwan')
  end
  it "gets currency string" do
    expect(subject.get_currency_string(doc)).to eq("twd")
  end
  it "gets money goal" do
    expect(subject.get_money_goal(doc)).to eq('250006')
  end
  it "gets money pledged" do
    expect(subject.get_money_pledged(doc)).to eq('6532659')
  end
  it "gets backer count" do
    expect(subject.get_backer_count(doc)).to eq('586')
  end
  it "gets left_time" do
    expect(subject.get_left_time(doc)).to eq('2 個月前')
  end
  it "gets status" do
    left_time = subject.get_left_time(doc)
    expect(subject.get_status(left_time)).to eq('finished')
  end
  it "gets fb count" do
    expect(subject.get_fb_count(doc)).to eq("")
  end
  it "gets following count" do
    expect(subject.get_following_count(doc)).to eq("")
  end
end
