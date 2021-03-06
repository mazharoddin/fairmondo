#   Copyright (c) 2012-2016, Fairmondo eG.  This file is
#   licensed under the GNU Affero General Public License version 3 or later.
#   See the COPYRIGHT file for details.

require_relative '../test_helper'

describe FairTrustQuestionnaire do
  subject { FairTrustQuestionnaire.new }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :article_id }
    it { subject.must_respond_to :support }
    it { subject.must_respond_to :support_checkboxes }
    it { subject.must_respond_to :support_explanation }
    it { subject.must_respond_to :support_other }
    it { subject.must_respond_to :labor_conditions }
    it { subject.must_respond_to :labor_conditions_checkboxes }
    it { subject.must_respond_to :labor_conditions_explanation }
    it { subject.must_respond_to :labor_conditions_other }
    it { subject.must_respond_to :environment_protection }
    it { subject.must_respond_to :environment_protection_checkboxes }
    it { subject.must_respond_to :environment_protection_explanation }
    it { subject.must_respond_to :environment_protection_other }
    it { subject.must_respond_to :controlling }
    it { subject.must_respond_to :controlling_checkboxes }
    it { subject.must_respond_to :controlling_explanation }
    it { subject.must_respond_to :controlling_other }
    it { subject.must_respond_to :awareness_raising }
    it { subject.must_respond_to :awareness_raising_checkboxes }
    it { subject.must_respond_to :awareness_raising_explanation }
    it { subject.must_respond_to :awareness_raising_other }
  end

  describe 'associations' do
    it { subject.must belong_to :article }
  end

  describe 'validations' do
    # Add later: shoulda-style checboxes size validations
    it { subject.must validate_presence_of :support }
    describe 'when support is checked' do
      subject { FairTrustQuestionnaire.new support: true }
      it { subject.must validate_presence_of :support_checkboxes }
      it { subject.must validate_presence_of :support_explanation }
      it { subject.must ensure_length_of(:support_explanation).is_at_least 150 }

      it { subject.wont validate_presence_of :support_other }
      describe "and 'other' was checked" do
        before { subject.support_checkboxes = [:other] }
        it { subject.must validate_presence_of :support_other }
        it { subject.must ensure_length_of(:support_other).is_at_least 5 }
        it { subject.must ensure_length_of(:support_other).is_at_most 100 }
      end
    end

    it { subject.must validate_presence_of :labor_conditions }
    describe 'when labor_conditions is checked' do
      subject { FairTrustQuestionnaire.new labor_conditions: true }
      it { subject.must validate_presence_of :labor_conditions_checkboxes }
      it { subject.must validate_presence_of :labor_conditions_explanation }
      it { subject.must ensure_length_of(:labor_conditions_explanation).is_at_least 150 }

      it { subject.wont validate_presence_of :labor_conditions_other }
      describe "and 'other' was checked" do
        before { subject.labor_conditions_checkboxes = [:other] }
        it { subject.must validate_presence_of :labor_conditions_other }
        it { subject.must ensure_length_of(:labor_conditions_other).is_at_least 5 }
        it { subject.must ensure_length_of(:labor_conditions_other).is_at_most 100 }
      end
    end

    it { subject.wont validate_presence_of :environment_protection }
    describe 'when environment_protection is checked' do
      subject { FairTrustQuestionnaire.new environment_protection: true }
      it { subject.must validate_presence_of :environment_protection_checkboxes }
      it { subject.must ensure_length_of(:environment_protection_explanation).is_at_least 150 }

      it { subject.wont validate_presence_of :environment_protection_other }
      describe "and 'other' was checked" do
        before { subject.environment_protection_checkboxes = [:other] }
        it { subject.must validate_presence_of :environment_protection_other }
        it { subject.must ensure_length_of(:environment_protection_other).is_at_least 5 }
        it { subject.must ensure_length_of(:environment_protection_other).is_at_most 100 }
      end
    end

    it { subject.must validate_presence_of :controlling }
    describe 'when controlling is checked' do
      subject { FairTrustQuestionnaire.new controlling: true }
      it { subject.must validate_presence_of :controlling_checkboxes }
      it { subject.must validate_presence_of :controlling_explanation }
      it { subject.must ensure_length_of(:controlling_explanation).is_at_least 150 }

      it { subject.wont validate_presence_of :controlling_other }
      describe "and 'other' was checked" do
        before { subject.controlling_checkboxes = [:other] }
        it { subject.must validate_presence_of :controlling_other }
        it { subject.must ensure_length_of(:controlling_other).is_at_least 5 }
        it { subject.must ensure_length_of(:controlling_other).is_at_most 100 }
      end
    end

    it { subject.wont validate_presence_of :awareness_raising }
    describe 'when awareness_raising is checked' do
      subject { FairTrustQuestionnaire.new awareness_raising: true }
      it { subject.must validate_presence_of :awareness_raising_checkboxes }
      it { subject.must ensure_length_of(:awareness_raising_explanation).is_at_least 150 }

      it { subject.wont validate_presence_of :awareness_raising_other }
      describe "and 'other' was checked" do
        before { subject.awareness_raising_checkboxes = [:other] }
        it { subject.must validate_presence_of :awareness_raising_other }
        it { subject.must ensure_length_of(:awareness_raising_other).is_at_least 5 }
        it { subject.must ensure_length_of(:awareness_raising_other).is_at_most 100 }
      end
    end
  end

  # describe "methods" do
  #   describe "#other_selected?(field)" do
  #   end
  # end
end
