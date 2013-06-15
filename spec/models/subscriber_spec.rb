require 'spec_helper'

describe Subscriber do
  it { should belong_to :conference }
  it { should validate_presence_of :email }

  it "can returns its first error message" do
    subscriber = Subscriber.new
    subscriber.valid?
    expect(subscriber.error_message).to include 'Email'
  end

  it "can select only active subscribers" do
    active   = create :subscriber
    inactive = create :subscriber, active: false

    expect(Subscriber.active).to eq [active]
  end

  it "can select only subscriber from certain conference" do
    conference = create :conference
    subscribed = create :subscriber, conference: conference
    other      = create :subscriber, conference: create(:conference)

    expect(Subscriber.for_conference(conference.id)).to eq [subscribed]
  end

  describe "#conference_name" do
    it "returns conference name (if some)" do
      subscriber = build :subscriber, conference: build(:conference, name: 'VarnaConf')
      expect(subscriber.conference_name).to eq 'VarnaConf'
    end

    it "returns empty string if use isn't subscribed to any conference" do
      subscriber = Subscriber.new
      expect(subscriber.conference_name).to eq ''
    end
  end

  describe ".filter" do
    it "doesn't require any filters" do
      expect(Subscriber.filter).to eq Subscriber.all
    end

    it "can filter by conference_id" do
      Subscriber.stub(:for_conference).with(1) { 'filter by conference' }
      expect(Subscriber.filter(conference_id: 1)).to eq 'filter by conference'
    end

    it "can filter to only active subscribers" do
      Subscriber.stub active: 'filter by active'
      expect(Subscriber.filter(active: true)).to eq 'filter by active'
    end
  end
end
