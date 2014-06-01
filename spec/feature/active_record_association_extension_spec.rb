# encoding: UTF-8
require 'active_record'
require 'unit_record'
require 'spec_helper'

ActiveRecord::Base.disconnect! :strategy => :noop
ActiveRecord::Schema.define do
  create_table 'active_record_models', :force => true do |t|
  end
  create_table 'examples', :force => true do |t|
    t.integer 'active_record_model_id'
  end
  create_table 'active_record_models_examples', :force => true do |t|
    t.integer 'active_record_model_id'
    t.integer 'example_id'
  end
end

describe ActiveRecord::Associations::ClassMethods do
  describe 'has_many' do
    before do
      class ActiveRecordModel < ActiveRecord::Base
      end
      class Example < ActiveRecord::Base
      end
    end
    it 'should call has_many_without_toggle without the toggle option' do
      expect(ActiveRecordModel).to receive(:has_many).once.and_call_original
      allow(ActiveRecordModel).to receive(:has_many_without_toggle).with(:examples, {})

      class ActiveRecordModel < ActiveRecord::Base
        has_many :examples
      end

      expect(ActiveRecordModel).to have_received(:has_many_without_toggle).with(:examples, {})
    end

    it 'should call has_many twice to create with and without associations' do
      expect(ActiveRecordModel).to receive(:has_many).exactly(3).times.and_call_original
      allow(ActiveRecordModel).to receive(:has_many_without_toggle)

      class ActiveRecordModel < ActiveRecord::Base
        has_many :examples, toggle: {
          name: 'feature', on: {on: true}, off: {off: true}
        }
      end

      expect(ActiveRecordModel).to have_received(:has_many_without_toggle).
        with('examples_with_feature', {class_name: 'Example', on: true})
      expect(ActiveRecordModel).to have_received(:has_many_without_toggle).
        with('examples_without_feature', {class_name: 'Example', off: true})
    end

    context 'method delegation' do
      before(:each) do
        class ActiveRecordModel < ActiveRecord::Base
          has_many :examples, toggle: {
            name: 'feature',
            on: {conditions: ['name like "%on%"']},
            off: {}
          }
        end
      end

      it 'should delegate to the with association when feature is active' do
        allow(Feature).to receive(:active?).with(:feature).and_return(true)

        model = ActiveRecordModel.new
        expect(model).to receive(:examples_with_feature).and_return([])

        examples = model.examples

        expect(examples).to eq([])
      end

      it 'should delegate to the with association when feature is not active' do
        allow(Feature).to receive(:active?).with(:feature).and_return(false)

        model = ActiveRecordModel.new
        expect(model).to receive(:examples_without_feature).and_return(['off'])

        examples = model.examples

        expect(examples).to eq(['off'])
      end
    end
  end

  describe 'has_one' do
    before do
      class ActiveRecordModel < ActiveRecord::Base
      end
      class Example < ActiveRecord::Base
      end
    end
    it 'should call has_one_without_toggle without the toggle option' do
      expect(ActiveRecordModel).to receive(:has_one).once.and_call_original
      allow(ActiveRecordModel).to receive(:has_one_without_toggle).with(:example, {})

      class ActiveRecordModel < ActiveRecord::Base
        has_one :example
      end

      expect(ActiveRecordModel).to have_received(:has_one_without_toggle).with(:example, {})
    end

    it 'should call has_one twice to create with and without associations' do
      expect(ActiveRecordModel).to receive(:has_one).exactly(3).times.and_call_original
      allow(ActiveRecordModel).to receive(:has_one_without_toggle)

      class ActiveRecordModel < ActiveRecord::Base
        has_one :example, toggle: {
          name: 'feature', on: {on: true}, off: {off: true}
        }
      end

      expect(ActiveRecordModel).to have_received(:has_one_without_toggle).
        with('example_with_feature', {class_name: 'Example', on: true})
      expect(ActiveRecordModel).to have_received(:has_one_without_toggle).
        with('example_without_feature', {class_name: 'Example', off: true})
    end

    context 'method delegation' do
      before(:each) do
        class ActiveRecordModel < ActiveRecord::Base
          has_one :example, toggle: {
            name: 'feature',
            on: {conditions: ['name like "%on%"']},
            off: {}
          }
        end
      end

      it 'should delegate to the with association when feature is active' do
        allow(Feature).to receive(:active?).with(:feature).and_return(true)

        expected = Example.new
        model = ActiveRecordModel.new
        expect(model).to receive(:example_with_feature).and_return(expected)

        example = model.example

        expect(example).to eq(expected)
      end

      it 'should delegate to the with association when feature is not active' do
        allow(Feature).to receive(:active?).with(:feature).and_return(false)

        model = ActiveRecordModel.new
        expect(model).to receive(:example_without_feature).and_return(nil)

        example = model.example

        expect(example).to be_nil
      end
    end
  end

  describe 'belongs_to' do
    before do
      class ActiveRecordModel < ActiveRecord::Base
      end
      class Example < ActiveRecord::Base
      end
    end
    it 'should call belongs_to_without_toggle without the toggle option' do
      expect(Example).to receive(:belongs_to).once.and_call_original
      allow(Example).to receive(:belongs_to_without_toggle).with(:active_record_model, {})

      class Example < ActiveRecord::Base
        belongs_to :active_record_model
      end

      expect(Example).to have_received(:belongs_to_without_toggle).with(:active_record_model, {})
    end

    it 'should call belongs_to twice to create with and without associations' do
      expect(Example).to receive(:belongs_to).exactly(3).times.and_call_original
      allow(Example).to receive(:belongs_to_without_toggle)

      class Example < ActiveRecord::Base
        belongs_to :active_record_model, toggle: {
          name: 'feature', on: {on: true}, off: {off: true}
        }
      end

      expect(Example).to have_received(:belongs_to_without_toggle).
        with('active_record_model_with_feature', {class_name: 'ActiveRecordModel', on: true})
      expect(Example).to have_received(:belongs_to_without_toggle).
        with('active_record_model_without_feature', {class_name: 'ActiveRecordModel', off: true})
    end

    context 'method delegation' do
      before(:each) do
        class Example < ActiveRecord::Base
          belongs_to :active_record_model, toggle: {
            name: 'feature',
            on: {conditions: ['name like "%on%"']},
            off: {}
          }
        end
      end

      it 'should delegate to the with association when feature is active' do
        allow(Feature).to receive(:active?).with(:feature).and_return(true)

        expected = ActiveRecordModel.new
        example = Example.new
        expect(example).to(
          receive(:active_record_model_with_feature).and_return(expected))

        model = example.active_record_model

        expect(model).to eq(expected)
      end

      it 'should delegate to the with association when feature is not active' do
        allow(Feature).to receive(:active?).with(:feature).and_return(false)

        example = Example.new
        expect(example).to(
          receive(:active_record_model_without_feature).and_return(nil))

        model = example.active_record_model

        expect(model).to be_nil
      end
    end
  end

  describe 'has_and_belongs_to_many' do
    before do
      class ActiveRecordModel < ActiveRecord::Base
      end
      class Example < ActiveRecord::Base
      end
    end
    it 'should call has_and_belongs_to_many_without_toggle without the toggle option' do
      expect(ActiveRecordModel).to receive(:has_and_belongs_to_many).once.and_call_original
      allow(ActiveRecordModel).to receive(:has_and_belongs_to_many_without_toggle).with(:examples, {})

      class ActiveRecordModel < ActiveRecord::Base
        has_and_belongs_to_many :examples
      end

      expect(ActiveRecordModel).to(
        have_received(:has_and_belongs_to_many_without_toggle).with(:examples, {}))
    end

    it 'should call has_and_belongs_to_many twice to create with and without associations' do
      expect(ActiveRecordModel).to receive(:has_and_belongs_to_many).exactly(3).times.and_call_original
      allow(ActiveRecordModel).to receive(:has_and_belongs_to_many_without_toggle)

      class ActiveRecordModel < ActiveRecord::Base
        has_and_belongs_to_many :examples, toggle: {
          name: 'feature', on: {on: true}, off: {off: true}
        }
      end

      expect(ActiveRecordModel).to(have_received(:has_and_belongs_to_many_without_toggle).
        with('examples_with_feature', {class_name: 'Example', on: true}))
      expect(ActiveRecordModel).to(have_received(:has_and_belongs_to_many_without_toggle).
        with('examples_without_feature', {class_name: 'Example', off: true}))
    end

    context 'method delegation' do
      before(:each) do
        class ActiveRecordModel < ActiveRecord::Base
          has_and_belongs_to_many :examples, toggle: {
            name: 'feature',
            on: {conditions: ['name like "%on%"']},
            off: {}
          }
        end
      end

      it 'should delegate to the with association when feature is active' do
        allow(Feature).to receive(:active?).with(:feature).and_return(true)

        model = ActiveRecordModel.new
        expect(model).to receive(:examples_with_feature).and_return([])

        example = model.examples

        expect(example).to eq([])
      end

      it 'should delegate to the with association when feature is not active' do
        allow(Feature).to receive(:active?).with(:feature).and_return(false)

        model = ActiveRecordModel.new
        expect(model).to receive(:examples_without_feature).and_return(['off'])

        examples = model.examples

        expect(examples).to eq(['off'])
      end
    end
  end
end