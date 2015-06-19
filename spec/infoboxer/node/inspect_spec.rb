# encoding: utf-8
module Infoboxer
  describe Node do
    describe '#inspect' do
      subject{node.inspect}

      describe Node do
        context 'by default' do
          let(:node){Node.new(level: 3, class: 'red')}

          it{should == '#<Node(level: 3, class: "red")>'}
        end

        context 'when nested' do
          let(:node){Node.new(level: 3, class: 'red')}
          subject{node.inspect(2)}

          it{should == '#<Node>'}
        end
      end
      
      describe Text do
        context 'by default' do
          let(:node){Text.new('some text')}
          
          it{should == '#<Text: "some text">'}
        end

        context 'really long text' do
          let(:str){'some text'*100}
          let(:node){Text.new(str)}
          
          it{should == "#<Text: #{str[0..30].inspect}...>"}
        end

        context 'nested' do
          let(:str){'some text'*100}
          let(:node){Text.new(str)}
          subject{node.inspect(2)}
          
          it{should == "#<Text>"}
        end
      end

      describe Compound do
        context 'children' do
          let(:node){Compound.new([Text.new('one'), Text.new('two')])}

          it{should == '#<Compound: #<Text: "one">, #<Text: "two">>'}
        end

        context 'long children list' do
          let(:node){Compound.new([
            Text.new('one'),
            Text.new('two'),
            Text.new('three'),
            Text.new('four'),
            Text.new('five')])}

          it{should == '#<Compound: #<Text: "one">, #<Text: "two">, #<Text: "three"> ...2 more nodes>'}
        end

        context 'complex children' do
          let(:node){Compound.new([Italic.new(Text.new('one')), Italic.new(Bold.new(Text.new('two')))])}

          it{should ==
            '#<Compound: #<Italic: #<Text>>, #<Italic: #<Bold: 1 nodes>>>'
          }
        end

        context 'nested' do
          let(:node){Compound.new([Italic.new(Text.new('one')), Italic.new(Bold.new(Text.new('two')))])}
          subject{node.inspect(2)}

          it{should ==
            '#<Compound: 2 nodes>'
          }
        end
      end

      describe Template do
        context 'default' do
          let(:node){Template.new('test', Nodes[TemplateVariable.new(1, Text.new('var'))])}

          it{should == '#<Template(test): #<TemplateVariable(1): #<Text>>>'}
        end

        context 'many variables' do
          let(:source){ File.read('spec/fixtures/large_infobox.txt') }
          let(:node){Parser.inline(source).first}

          it{should ==
            "#<Template(Infobox country): "\
              "#<TemplateVariable(conventional_long_name): #<Text>, #<Template(efn-ua)>>, "\
              "#<TemplateVariable(native_name): #<Template(native name)>>, "\
              "#<TemplateVariable(common_name): #<Text>> ...84 more nodes>"
          }
        end

        context 'long variables' do
        end

        context 'nested' do
          let(:node){Template.new('test', Nodes[TemplateVariable.new(1, Text.new('var'))])}
          subject{node.inspect(2)}
          it{should == '#<Template(test)>'}
        end
      end

      describe Page, :vcr do
        let(:node){Infoboxer.wikipedia.get('Argentina')}
        it{should match \
          %r{^\#<Page\(title: "Argentina", url: "https://en.wikipedia.org/wiki/Argentina"\): \d+ nodes>$}
        }
      end
    end
  end
end
