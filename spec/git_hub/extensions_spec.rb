require File.expand_path(
        File.join(File.dirname(__FILE__), '..', 'spec_helper'))

module GitHubTest
  module A
    class B
      class C
      end
    end
  end

  describe String do
    context '#to_class' do
      it 'converts string into appropriate Class constant' do
        "Fixnum".to_class.should == Fixnum
        "GitHubTest::A::B::C".to_class.should == GitHubTest::A::B::C
      end

      it 'returns nil if string is not convertible into class' do
        "Math".to_class.should == nil
        "Math::PI".to_class.should == nil
        "Something".to_class.should == nil
      end

      it 'deals with leading colons' do
        "::GitHubTest::A::B::C".to_class.should == GitHubTest::A::B::C
      end
    end
  end

  describe Array do
    context '#args_and_opts' do
      it 'splits array into two components: enum with args and options hash' do
        args, opts = [1, 2, {3=>4}].args_and_opts
        args.should be_an Enumerator
        args.to_a.should == [1, 2]
        opts.should == {3=>4}
      end

      it 'correctly splits options if 2 Hashes are last' do
        args, opts = [1, 2, {3=>4}, {5=>6}].args_and_opts
        args.should be_an Enumerator
        args.to_a.should == [1, 2, {3=>4}]
        opts.should == {5=>6}
      end

      it 'returns empty options if last component is not a Hash' do
        args, opts = [1, 2, {3=>4}, 5].args_and_opts
        args.should be_an Enumerator
        args.to_a.should == [1, 2, {3=>4}, 5]
        opts.should == {}
      end
    end
  end
end