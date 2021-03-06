require 'spec_helper'

module Squeel
  module Nodes
    describe Operation do
      before do
        @o = dsl{name + 1}
      end

      Squeel::Constants::PREDICATES.each do |method_name|
        it "creates #{method_name} predicates with no value" do
          predicate = @o.send(method_name)
          predicate.expr.should eq @o
          predicate.method_name.should eq method_name
          predicate.value?.should be_false
        end

        it "creates #{method_name} predicates with a value" do
          predicate = @o.send(method_name, 'value')
          predicate.expr.should eq @o
          predicate.method_name.should eq method_name
          predicate.value.should eq 'value'
        end
      end

      Squeel::Constants::PREDICATE_ALIASES.each do |method_name, aliases|
        aliases.each do |aliaz|
          ['', '_any', '_all'].each do |suffix|
            it "creates #{method_name.to_s + suffix} predicates with no value using the alias #{aliaz.to_s + suffix}" do
              predicate = @o.send(aliaz.to_s + suffix)
              predicate.expr.should eq @o
              predicate.method_name.should eq "#{method_name}#{suffix}".to_sym
              predicate.value?.should be_false
            end

            it "creates #{method_name.to_s + suffix} predicates with a value using the alias #{aliaz.to_s + suffix}" do
              predicate = @o.send((aliaz.to_s + suffix), 'value')
              predicate.expr.should eq @o
              predicate.method_name.should eq "#{method_name}#{suffix}".to_sym
              predicate.value.should eq 'value'
            end
          end
        end
      end

      it 'creates ascending Order nodes with #asc' do
        order = @o.asc
        order.expr.should eq @o
        order.should be_ascending
      end

      it 'creates descending Order nodes with #desc' do
        order = @o.desc
        order.expr.should eq @o
        order.should be_descending
      end

      it 'creates eq predicates with ==' do
        predicate = @o == 1
        predicate.expr.should eq @o
        predicate.method_name.should eq :eq
        predicate.value.should eq 1
      end

      it 'creates not_eq predicates with ^' do
        predicate = @o ^ 1
        predicate.expr.should eq @o
        predicate.method_name.should eq :not_eq
        predicate.value.should eq 1
      end

      it 'creates not_eq predicates with !=' do
        predicate = @o != 1
        predicate.expr.should eq @o
        predicate.method_name.should eq :not_eq
        predicate.value.should eq 1
      end if respond_to?('!=')

      it 'creates in predicates with >>' do
        predicate = @o >> [1,2,3]
        predicate.expr.should eq @o
        predicate.method_name.should eq :in
        predicate.value.should eq [1,2,3]
      end

      it 'creates not_in predicates with <<' do
        predicate = @o << [1,2,3]
        predicate.expr.should eq @o
        predicate.method_name.should eq :not_in
        predicate.value.should eq [1,2,3]
      end

      it 'creates matches predicates with =~' do
        predicate = @o =~ '%bob%'
        predicate.expr.should eq @o
        predicate.method_name.should eq :matches
        predicate.value.should eq '%bob%'
      end

      it 'creates does_not_match predicates with !~' do
        predicate = @o !~ '%bob%'
        predicate.expr.should eq @o
        predicate.method_name.should eq :does_not_match
        predicate.value.should eq '%bob%'
      end if respond_to?('!~')

      it 'creates gt predicates with >' do
        predicate = @o > 1
        predicate.expr.should eq @o
        predicate.method_name.should eq :gt
        predicate.value.should eq 1
      end

      it 'creates gteq predicates with >=' do
        predicate = @o >= 1
        predicate.expr.should eq @o
        predicate.method_name.should eq :gteq
        predicate.value.should eq 1
      end

      it 'creates lt predicates with <' do
        predicate = @o < 1
        predicate.expr.should eq @o
        predicate.method_name.should eq :lt
        predicate.value.should eq 1
      end

      it 'creates lteq predicates with <=' do
        predicate = @o <= 1
        predicate.expr.should eq @o
        predicate.method_name.should eq :lteq
        predicate.value.should eq 1
      end

      it 'can be ORed with another node' do
        right = Predicate.new :name, :eq, 'Bob'
        combined = @o | right
        combined.should be_a Nodes::Or
        combined.left.should eq @o
        combined.right.should eq right
      end

      it 'can be ANDed with another node' do
        right = Predicate.new :name, :eq, 'Bob'
        combined = @o & right
        combined.should be_a Nodes::And
        combined.children.should eq [@o, right]
      end

      it 'can be negated' do
        negated = -@o
        negated.should be_a Nodes::Not
        negated.expr.should eq @o
      end

      describe '#as' do

        it 'aliases the function' do
          @o.as('the_alias')
          @o.alias.should eq 'the_alias'
        end

        it 'casts the alias to a string' do
          @o.as(:the_alias)
          @o.alias.should eq 'the_alias'
        end

      end

    end
  end
end
