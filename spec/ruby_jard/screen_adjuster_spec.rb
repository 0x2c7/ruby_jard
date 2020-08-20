# frozen_string_literal: true

RSpec.describe RubyJard::ScreenAdjuster do
  let(:parent_template_a) { RubyJard::Templates::LayoutTemplate.new }

  let(:template_1) { RubyJard::Templates::ScreenTemplate.new }
  let(:layout_1) do
    RubyJard::Layout.new(
      box_width: 75, box_height: 41,
      box_x: 72, box_y: 0,
      width: 73, height: 39,
      x: 73, y: 1,
      template: template_1,
      parent_template: parent_template_a
    )
  end

  let(:template_2) { RubyJard::Templates::ScreenTemplate.new }
  let(:layout_2) do
    RubyJard::Layout.new(
      box_width: 75, box_height: 12,
      box_x: 72, box_y: 40,
      width: 73, height: 10,
      x: 73, y: 41,
      template: template_2,
      parent_template: parent_template_a
    )
  end

  context 'when input nothing' do
    let(:adjuster) { described_class.new([]) }

    it 'does not raise exception' do
      expect { adjuster.adjust }.not_to raise_exception
    end
  end

  context 'when there is only 1 screen' do
    let(:screen_1) { RubyJard::Screen.new(layout_1) }
    let(:adjuster) { described_class.new([screen_1]) }

    before do
      screen_1.window = ['empty line'] * 40
    end

    it 'does not adjust screen layouts' do
      adjuster.adjust
      expect(layout_1.box_width).to eq(75)
      expect(layout_1.box_height).to eq(41)
      expect(layout_1.box_x).to eq(72)
      expect(layout_1.box_y).to eq(0)
      expect(layout_1.width).to eq(73)
      expect(layout_1.height).to eq(39)
      expect(layout_1.x).to eq(73)
      expect(layout_1.y).to eq(1)
    end
  end

  context 'when screens are not aligned' do
    let(:layout_3) do
      RubyJard::Layout.new(
        box_width: 75, box_height: 41,
        box_x: 72, box_y: 0,
        width: 73, height: 39,
        x: 73, y: 1,
        template: template_1,
        parent_template: parent_template_a
      )
    end

    let(:template_2) { RubyJard::Templates::ScreenTemplate.new }
    let(:layout_4) do
      RubyJard::Layout.new(
        box_width: 75, box_height: 12,
        box_x: 71, box_y: 40,
        width: 73, height: 10,
        x: 72, y: 41,
        template: template_2,
        parent_template: parent_template_a
      )
    end

    let(:screen_3) { RubyJard::Screen.new(layout_3) }
    let(:screen_4) { RubyJard::Screen.new(layout_4) }
    let(:adjuster) { described_class.new([screen_3, screen_4]) }

    before do
      screen_3.window = ['empty line'] * 50
      screen_4.window = ['empty line'] * 5
    end

    it 'does not adjust screen layouts' do
      adjuster.adjust
      expect(layout_3.box_width).to eq(75)
      expect(layout_3.box_height).to eq(41)
      expect(layout_3.box_x).to eq(72)
      expect(layout_3.box_y).to eq(0)
      expect(layout_3.width).to eq(73)
      expect(layout_3.height).to eq(39)
      expect(layout_3.x).to eq(73)
      expect(layout_3.y).to eq(1)

      expect(layout_4.box_width).to eq(75)
      expect(layout_4.box_height).to eq(12)
      expect(layout_4.box_x).to eq(71)
      expect(layout_4.box_y).to eq(40)
      expect(layout_4.width).to eq(73)
      expect(layout_4.height).to eq(10)
      expect(layout_4.x).to eq(72)
      expect(layout_4.y).to eq(41)
    end
  end

  context 'when screens have different width' do
    let(:layout_3) do
      RubyJard::Layout.new(
        box_width: 75, box_height: 41,
        box_x: 72, box_y: 0,
        width: 73, height: 39,
        x: 73, y: 1,
        template: template_1,
        parent_template: parent_template_a
      )
    end

    let(:template_2) { RubyJard::Templates::ScreenTemplate.new }
    let(:layout_4) do
      RubyJard::Layout.new(
        box_width: 82, box_height: 12,
        box_x: 72, box_y: 40,
        width: 80, height: 10,
        x: 73, y: 41,
        template: template_2,
        parent_template: parent_template_a
      )
    end

    let(:screen_3) { RubyJard::Screen.new(layout_3) }
    let(:screen_4) { RubyJard::Screen.new(layout_4) }
    let(:adjuster) { described_class.new([screen_3, screen_4]) }

    before do
      screen_3.window = ['empty line'] * 50
      screen_4.window = ['empty line'] * 5
    end

    it 'does not adjust screen layouts' do
      adjuster.adjust
      expect(layout_3.box_width).to eq(75)
      expect(layout_3.box_height).to eq(41)
      expect(layout_3.box_x).to eq(72)
      expect(layout_3.box_y).to eq(0)
      expect(layout_3.width).to eq(73)
      expect(layout_3.height).to eq(39)
      expect(layout_3.x).to eq(73)
      expect(layout_3.y).to eq(1)

      expect(layout_4.box_width).to eq(82)
      expect(layout_4.box_height).to eq(12)
      expect(layout_4.box_x).to eq(72)
      expect(layout_4.box_y).to eq(40)
      expect(layout_4.width).to eq(80)
      expect(layout_4.height).to eq(10)
      expect(layout_4.x).to eq(73)
      expect(layout_4.y).to eq(41)
    end
  end

  context 'when all of the screens still have spaces left' do
    let(:screen_1) { RubyJard::Screen.new(layout_1) }
    let(:screen_2) { RubyJard::Screen.new(layout_2) }
    let(:adjuster) { described_class.new([screen_1, screen_2]) }

    before do
      screen_1.window = ['empty line'] * 35
      screen_2.window = ['empty line'] * 9
    end

    it 'does not adjust screen layouts' do
      adjuster.adjust
      expect(layout_1.box_width).to eq(75)
      expect(layout_1.box_height).to eq(41)
      expect(layout_1.box_x).to eq(72)
      expect(layout_1.box_y).to eq(0)
      expect(layout_1.width).to eq(73)
      expect(layout_1.height).to eq(39)
      expect(layout_1.x).to eq(73)
      expect(layout_1.y).to eq(1)

      expect(layout_2.box_width).to eq(75)
      expect(layout_2.box_height).to eq(12)
      expect(layout_2.box_x).to eq(72)
      expect(layout_2.box_y).to eq(40)
      expect(layout_2.width).to eq(73)
      expect(layout_2.height).to eq(10)
      expect(layout_2.x).to eq(73)
      expect(layout_2.y).to eq(41)
    end
  end

  context 'when first screen needs to expand and second one is shrinkable' do
    let(:screen_1) { RubyJard::Screen.new(layout_1) }
    let(:screen_2) { RubyJard::Screen.new(layout_2) }

    let(:adjuster) { described_class.new([screen_1, screen_2]) }

    before do
      screen_1.window = ['empty line'] * 39 # Right reaching the edge
      screen_2.window = ['empty line'] * 5
    end

    it 'expands the first screen, and shrinks the second one' do
      adjuster.adjust
      expect(layout_1.box_width).to eq(75)
      expect(layout_1.box_height).to eq(46)
      expect(layout_1.box_x).to eq(72)
      expect(layout_1.box_y).to eq(0)
      expect(layout_1.width).to eq(73)
      expect(layout_1.height).to eq(44)
      expect(layout_1.x).to eq(73)
      expect(layout_1.y).to eq(1)

      expect(layout_2.box_width).to eq(75)
      expect(layout_2.box_height).to eq(7)
      expect(layout_2.box_x).to eq(72)
      expect(layout_2.box_y).to eq(45)
      expect(layout_2.width).to eq(73)
      expect(layout_2.height).to eq(5)
      expect(layout_2.x).to eq(73)
      expect(layout_2.y).to eq(46)
    end
  end

  context 'when first screen needs to expand and second one has min_height attribute' do
    let(:screen_1) { RubyJard::Screen.new(layout_1) }
    let(:template_2) { RubyJard::Templates::ScreenTemplate.new(min_height: 3) }
    let(:screen_2) { RubyJard::Screen.new(layout_2) }

    let(:adjuster) { described_class.new([screen_1, screen_2]) }

    before do
      screen_1.window = ['empty line'] * 39 # Right reaching the edge
      screen_2.window = ['empty line'] * 1
    end

    it 'expands the first screen, and shrinks the second one to min_height' do
      adjuster.adjust
      expect(layout_1.box_width).to eq(75)
      expect(layout_1.box_height).to eq(48)
      expect(layout_1.box_x).to eq(72)
      expect(layout_1.box_y).to eq(0)
      expect(layout_1.width).to eq(73)
      expect(layout_1.height).to eq(46)
      expect(layout_1.x).to eq(73)
      expect(layout_1.y).to eq(1)

      expect(layout_2.box_width).to eq(75)
      expect(layout_2.box_height).to eq(5)
      expect(layout_2.box_x).to eq(72)
      expect(layout_2.box_y).to eq(47)
      expect(layout_2.width).to eq(73)
      expect(layout_2.height).to eq(3)
      expect(layout_2.x).to eq(73)
      expect(layout_2.y).to eq(48)
    end
  end

  context 'when second screen needs to expand and first one is shrinkable' do
    let(:layout_3) do
      RubyJard::Layout.new(
        box_width: 75, box_height: 12,
        box_x: 72, box_y: 0,
        width: 73, height: 10,
        x: 73, y: 1,
        template: RubyJard::Templates::ScreenTemplate.new,
        parent_template: parent_template_a
      )
    end
    let(:screen_3) { RubyJard::Screen.new(layout_3) }

    let(:layout_4) do
      RubyJard::Layout.new(
        box_width: 75, box_height: 41,
        box_x: 72, box_y: 12,
        width: 73, height: 39,
        x: 73, y: 13,
        template: RubyJard::Templates::ScreenTemplate.new,
        parent_template: parent_template_a
      )
    end
    let(:screen_4) { RubyJard::Screen.new(layout_4) }

    let(:adjuster) { described_class.new([screen_3, screen_4]) }

    before do
      screen_3.window = ['empty line'] * 5
      screen_4.window = ['empty line'] * 40 # Overflow the edge
    end

    it 'shrinks the first one, expands the second layout' do
      adjuster.adjust
      expect(layout_3.box_width).to eq(75)
      expect(layout_3.box_height).to eq(7)
      expect(layout_3.box_x).to eq(72)
      expect(layout_3.box_y).to eq(0)
      expect(layout_3.width).to eq(73)
      expect(layout_3.height).to eq(5)
      expect(layout_3.x).to eq(73)
      expect(layout_3.y).to eq(1)

      expect(layout_4.box_width).to eq(75)
      expect(layout_4.box_height).to eq(46)
      expect(layout_4.box_x).to eq(72)
      expect(layout_4.box_y).to eq(6)
      expect(layout_4.width).to eq(73)
      expect(layout_4.height).to eq(44)
      expect(layout_4.x).to eq(73)
      expect(layout_4.y).to eq(7)
    end
  end

  context 'when all of screens are full' do
    let(:screen_1) { RubyJard::Screen.new(layout_1) }
    let(:screen_2) { RubyJard::Screen.new(layout_2) }

    let(:adjuster) { described_class.new([screen_1, screen_2]) }

    before do
      screen_1.window = ['empty line'] * 39
      screen_2.window = ['empty line'] * 10
    end

    it 'does not adjust screen layouts' do
      adjuster.adjust
      expect(layout_1.box_width).to eq(75)
      expect(layout_1.box_height).to eq(41)
      expect(layout_1.box_x).to eq(72)
      expect(layout_1.box_y).to eq(0)
      expect(layout_1.width).to eq(73)
      expect(layout_1.height).to eq(39)
      expect(layout_1.x).to eq(73)
      expect(layout_1.y).to eq(1)

      expect(layout_2.box_width).to eq(75)
      expect(layout_2.box_height).to eq(12)
      expect(layout_2.box_x).to eq(72)
      expect(layout_2.box_y).to eq(40)
      expect(layout_2.width).to eq(73)
      expect(layout_2.height).to eq(10)
      expect(layout_2.x).to eq(73)
      expect(layout_2.y).to eq(41)
    end
  end

  context 'when both screens have spaces left but the first one has expand mode' do
    let(:template_1) { RubyJard::Templates::ScreenTemplate.new(adjust_mode: :expand) }
    let(:screen_1) { RubyJard::Screen.new(layout_1) }
    let(:screen_2) { RubyJard::Screen.new(layout_2) }

    let(:adjuster) { described_class.new([screen_1, screen_2]) }

    before do
      screen_1.window = ['empty line'] * 5
      screen_2.window = ['empty line'] * 5
    end

    it 'expands the first screen, and shrinks the second one' do
      adjuster.adjust
      expect(layout_1.box_width).to eq(75)
      expect(layout_1.box_height).to eq(46)
      expect(layout_1.box_x).to eq(72)
      expect(layout_1.box_y).to eq(0)
      expect(layout_1.width).to eq(73)
      expect(layout_1.height).to eq(44)
      expect(layout_1.x).to eq(73)
      expect(layout_1.y).to eq(1)

      expect(layout_2.box_width).to eq(75)
      expect(layout_2.box_height).to eq(7)
      expect(layout_2.box_x).to eq(72)
      expect(layout_2.box_y).to eq(45)
      expect(layout_2.width).to eq(73)
      expect(layout_2.height).to eq(5)
      expect(layout_2.x).to eq(73)
      expect(layout_2.y).to eq(46)
    end
  end

  context 'when both screens have spaces left and both have expand mode' do
    let(:template_1) { RubyJard::Templates::ScreenTemplate.new(adjust_mode: :expand) }
    let(:template_2) { RubyJard::Templates::ScreenTemplate.new(adjust_mode: :expand) }
    let(:screen_1) { RubyJard::Screen.new(layout_1) }
    let(:screen_2) { RubyJard::Screen.new(layout_2) }

    let(:adjuster) { described_class.new([screen_1, screen_2]) }

    before do
      screen_1.window = ['empty line'] * 5
      screen_2.window = ['empty line'] * 5
    end

    it 'does not adjust screen layouts' do
      adjuster.adjust
      expect(layout_1.box_width).to eq(75)
      expect(layout_1.box_height).to eq(41)
      expect(layout_1.box_x).to eq(72)
      expect(layout_1.box_y).to eq(0)
      expect(layout_1.width).to eq(73)
      expect(layout_1.height).to eq(39)
      expect(layout_1.x).to eq(73)
      expect(layout_1.y).to eq(1)

      expect(layout_2.box_width).to eq(75)
      expect(layout_2.box_height).to eq(12)
      expect(layout_2.box_x).to eq(72)
      expect(layout_2.box_y).to eq(40)
      expect(layout_2.width).to eq(73)
      expect(layout_2.height).to eq(10)
      expect(layout_2.x).to eq(73)
      expect(layout_2.y).to eq(41)
    end
  end

  context 'when the layout includes 2 columns' do
    let(:parent_template_b) { RubyJard::Templates::LayoutTemplate.new }
    let(:layout_3) do
      RubyJard::Layout.new(
        box_width: 73, box_height: 36,
        box_x: 0, box_y: 0,
        width: 71, height: 34,
        x: 1, y: 1,
        template: RubyJard::Templates::ScreenTemplate.new,
        parent_template: parent_template_b
      )
    end
    let(:layout_4) do
      RubyJard::Layout.new(
        box_width: 73, box_height: 17,
        box_x: 0, box_y: 35,
        width: 71, height: 15,
        x: 1, y: 36,
        template: RubyJard::Templates::ScreenTemplate.new,
        parent_template: parent_template_b
      )
    end

    let(:screen_1) { RubyJard::Screen.new(layout_1) }
    let(:screen_2) { RubyJard::Screen.new(layout_2) }
    let(:screen_3) { RubyJard::Screen.new(layout_3) }
    let(:screen_4) { RubyJard::Screen.new(layout_4) }

    let(:adjuster) { described_class.new([screen_1, screen_2, screen_3, screen_4]) }

    before do
      screen_1.window = ['empty line'] * 39
      screen_2.window = ['empty line'] * 5
      screen_3.window = ['empty line'] * 34
      screen_4.window = ['empty line'] * 10
    end

    it 'expands the first screen and third screen, shrinks the second and fourth one, grouped by column' do
      adjuster.adjust
      expect(layout_1.box_width).to eq(75)
      expect(layout_1.box_height).to eq(46)
      expect(layout_1.box_x).to eq(72)
      expect(layout_1.box_y).to eq(0)
      expect(layout_1.width).to eq(73)
      expect(layout_1.height).to eq(44)
      expect(layout_1.x).to eq(73)
      expect(layout_1.y).to eq(1)

      expect(layout_2.box_width).to eq(75)
      expect(layout_2.box_height).to eq(7)
      expect(layout_2.box_x).to eq(72)
      expect(layout_2.box_y).to eq(45)
      expect(layout_2.width).to eq(73)
      expect(layout_2.height).to eq(5)
      expect(layout_2.x).to eq(73)
      expect(layout_2.y).to eq(46)

      expect(layout_3.box_width).to eq(73)
      expect(layout_3.box_height).to eq(41)
      expect(layout_3.box_x).to eq(0)
      expect(layout_3.box_y).to eq(0)
      expect(layout_3.width).to eq(71)
      expect(layout_3.height).to eq(39)
      expect(layout_3.x).to eq(1)
      expect(layout_3.y).to eq(1)

      expect(layout_4.box_width).to eq(73)
      expect(layout_4.box_height).to eq(12)
      expect(layout_4.box_x).to eq(0)
      expect(layout_4.box_y).to eq(40)
      expect(layout_4.width).to eq(71)
      expect(layout_4.height).to eq(10)
      expect(layout_4.x).to eq(1)
      expect(layout_4.y).to eq(41)
    end
  end
end
