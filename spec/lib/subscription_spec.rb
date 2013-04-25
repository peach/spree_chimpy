require 'spec_helper'

describe Spree::Hominid::Subscription do

  context "mail chimp enabled" do
    let(:interface)    { mock(:interface) }

    before do
      Spree::Hominid::Config.preferred_list_name  = 'Members'
      Spree::Hominid::Config.preferred_merge_vars = {'EMAIL' => :email}
      Spree::Hominid::Config.stub(interface: interface)
    end

    context "subscribing" do
      let(:user)         { FactoryGirl.build(:user, subscribed: true) }
      let(:subscription) { Spree::Hominid::Subscription.new(user) }

      before do
        Spree::Hominid::Config.preferred_merge_vars = {'EMAIL' => :email, 'SIZE' => :size, 'HEIGHT' => :height}

        def user.size
          '10'
        end

        def user.height
          '20'
        end
      end

      it "subscribes" do
        interface.should_receive(:subscribe).with('Members', user.email, {'SIZE' => '10', 'HEIGHT' => '20'})

        subscription.subscribe
      end
    end

    context "sync" do
      let(:user)         { FactoryGirl.create(:user, subscribed: true) }
      let(:subscription) { mock(:subscription) }

      before do
        interface.should_receive(:subscribe).with('Members', user.email)
        user.stub(subscription: subscription)
      end

      context "when update needed" do
        it "calls sync" do
          subscription.stub(needs_update?: true)
          subscription.should_receive(:sync)
          user.save
        end
      end

      context "when update not needed" do
        it "doesnt call sync" do
          subscription.stub(needs_update?: false)
          subscription.should_not_receive(:sync)
          user.save
        end
      end
    end

    context "subscribing" do
      let(:user)         { FactoryGirl.build(:user, subscribed: true) }
      let(:subscription) { Spree::Hominid::Subscription.new(user) }

      it "unsubscribes" do
        interface.should_receive(:unsubscribe).with('Members', user.email)
        subscription.unsubscribe
      end
    end

    context "needs update?" do
      let(:subscribed)     { FactoryGirl.build(:user, subscribed: true) }
      let(:not_subscribed) { FactoryGirl.build(:user, subscribed: false) }
      let(:subscription)   { Spree::Hominid::Subscription.new(user) }

      before do
        subscribed.email += '.com'
      end

      specify { Spree::Hominid::Subscription.new(subscribed).should         be_needs_update}
      specify { Spree::Hominid::Subscription.new(not_subscribed).should_not be_needs_update}
    end
  end

  context "mail chimp disabled" do
    before do
      Spree::Hominid::Config.stub(interface: nil)

      user = FactoryGirl.build(:user, subscribed: true)
      @subscription = Spree::Hominid::Subscription.new(user)
    end

    specify { @subscription.subscribe }
    specify { @subscription.unsubscribe }
    specify { @subscription.sync }
  end

end