# frozen_string_literal: true

require 'pry'

RSpec.describe Doxxer do

  before do
    Doxxer.reset!
  end

  def undefine_classes(*classes)
    classes.each do |klass_symbol|
      Object.send(:remove_const, klass_symbol) if Object.const_defined?(klass_symbol)
    end
  end

  it "has a version number" do
    expect(Doxxer::VERSION).not_to be nil
  end

  it 'reports interactions count' do
    expect(Doxxer.calls_count).to eq(0)
  end

  # tests to do:
  # OK 1. class method in B calls class method in A
  # OK 2. class method in B calls instance method in A
  # OK 3. class method in B calls A.new
  # TODO 4. instance method in B calls instance method in A
  # TODO 5. instance method in B calls class method in A
  # TODO 6. instance method in B calls A.new

  shared_examples 'a class method of B registers N calls' do |calls_count|
    it { expect { subject }.to change { Doxxer.calls_count }.by(calls_count) }
  end

  shared_examples 'a class method of B registers no calls' do
    it { expect { subject }.not_to change { Doxxer.calls_count } }
  end

  context 'when a class method of B calls' do

    subject do
      a = A.new
      Doxxer.pry { B.bar(a) }
    end

    context 'a class method of A' do

      before do
        undefine_classes(:A, :B)

        class A; def self.foo; end; end
        class B; def self.bar(_) = A.foo; end
      end

      context 'when only A is allowed' do
        before do
          Doxxer.include(A)
        end

        it_behaves_like 'a class method of B registers no calls'
      end

      context 'when only B is allowed' do
        before do
          Doxxer.include(B)
        end

        it_behaves_like 'a class method of B registers no calls'
      end

      context 'when both A and B are allowed' do
        before do
          Doxxer.include(A)
          Doxxer.include(B)
        end

        it_behaves_like 'a class method of B registers N calls', 1
      end
    end

    context 'an instance method of A' do

      before do
        undefine_classes(:A, :B)

        class A; def foo; end; end
        class B; def self.bar(a) = a.foo; end
      end

      context 'when only A is allowed' do
        before do
          Doxxer.include(A)
        end

        it_behaves_like 'a class method of B registers no calls'
      end

      context 'when only B is allowed' do
        before do
          Doxxer.include(B)
        end

        it_behaves_like 'a class method of B registers no calls'
      end

      context 'when both A and B are allowed' do
        before do
          Doxxer.include(A)
          Doxxer.include(B)
        end

        it_behaves_like 'a class method of B registers N calls', 1
      end
    end

    context 'A.new' do

      before do
        undefine_classes(:A, :B)

        class A; end
        class B; def self.bar(_) = A.new; end
      end

      context 'when only A is allowed' do
        before do
          Doxxer.include(A)
        end

        it_behaves_like 'a class method of B registers no calls'
      end

      context 'when only B is allowed' do
        before do
          Doxxer.include(B)
        end

        it_behaves_like 'a class method of B registers no calls'
      end

      context 'when both A and B are allowed' do
        before do
          Doxxer.include(A)
          Doxxer.include(B)
        end

        # :new, :initialize
        it_behaves_like 'a class method of B registers N calls', 2
      end
    end
  end
end
