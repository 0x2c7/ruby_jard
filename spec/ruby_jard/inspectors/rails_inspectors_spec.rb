# frozen_string_literal: true

RSpec.describe 'Rails Inspectors' do
  subject(:inspector) { RubyJard::Inspectors::Base.new }

  context 'with #singleline' do
    let(:line_limit) { 80 }

    it {
      record = ArPet.new(name: 'Hana', age: 15)
      expect(inspector.singleline(record, line_limit: line_limit)).to match_row(<<~SPANS)
        #<ArPet:?????????????????? id → nil, name → "Hana", age → 15>
      SPANS
    }

    it {
      klass = Class.new(ArPost) do
        def attributes
          raise 'ahihi'
        end
      end
      expect(inspector.singleline(klass.new, line_limit: line_limit)).to match_row(<<~SPANS)
        #<#<Class:??????????????????>:?????????????????? ??? failed to inspect attributes>
      SPANS
    }

    it {
      begin
        record = ArPost.create(
          title: "What\nis\nRuby\nJard?",
          description: <<~DESCRIPTION
            Ruby Jard provides a rich Terminal UI that visualizes everything your need, navigates your program with pleasure, stops at matter places only, reduces manual and mental efforts. You can now focus on real debugging.
          DESCRIPTION
        )
        expect(inspector.singleline(record, line_limit: line_limit)).to match_row(<<~SPANS)
          #<ArPost:?????????????????? id → #{record.id}, title → "What\\nis\\nRuby\\nJard?", …>
        SPANS
      ensure
        record.destroy!
      end
    }

    it {
      begin
        record1 = ArPost.create(
          title: "What\nis\nRuby\nJard?",
          description: 'Description 1'
        )
        record2 = ArPost.create(
          title: 'Jard is just a normal gem',
          description: 'Description 2'
        )
        records = ArPost.where(id: [record1.id, record2.id]).order(id: :desc)
        expect(inspector.singleline(records, line_limit: line_limit)).to match_row(<<~SPANS)
          #<ArPost::ActiveRecord_Relation:?????????????????? "SELECT \\"ar_posts\\".* FROM \\"ar_posts\\" WHERE \\"ar_posts\\".\\"id\\" IN (#{record1.id}, #{record2.id}) ORDER BY \\"ar_posts\\".\\"id\\" DESC"> (not loaded)
        SPANS
      ensure
        record1.destroy!
        record2.destroy!
      end
    }

    it {
      begin
        (1..10).to_a.map do |index|
          ArPost.create!(
            title: "Title #{index}",
            description: "Description #{index}"
          )
        end
        records = ArPost.all.limit(2).order(id: :desc).load
        expect(inspector.singleline(records, line_limit: 150)).to match_row(<<~SPANS)
          #<ArPost::ActiveRecord_Relation:?????????????????? #<ArPost:?????????????????? id → #{records[0].id}, …>, #<ArPost:?????????????????? id → #{records[1].id}, …>>
        SPANS
      ensure
        ArPost.destroy_all
      end
    }

    it {
      begin
        (1..10).to_a.map do |index|
          ArPost.create!(
            title: "Title #{index}",
            description: "Description #{index}"
          )
        end
        records = ArPost.where('title like "not found"').order(id: :desc).load
        expect(inspector.singleline(records, line_limit: 150)).to match_row(<<~SPANS)
          #<ArPost::ActiveRecord_Relation:??????????????????> (empty)
        SPANS
      ensure
        ArPost.destroy_all
      end
    }

    it {
      begin
        (1..10).to_a.map do |index|
          ArPost.create!(
            title: "Title #{index}",
            description: "Description #{index}"
          )
        end
        records = ArPost.where(
          <<~SQL
            title like 'not found' OR
            false = true OR
            title like 'whatever'
          SQL
        ).order(id: :desc)
        expect(inspector.singleline(records, line_limit: 150)).to match_row(<<~SPANS)
          #<ArPost::ActiveRecord_Relation:?????????????????? "SELECT \\"ar_posts\\".* FROM \\"ar_posts\\" WHERE (title like 'not found' OR\\nfalse = true OR\\ntitle like 'whatever'\\n) ORDER BY \\"ar_posts\\".\\"id\\" DESC"> (not loaded)
        SPANS
      ensure
        ArPost.destroy_all
      end
    }

    it {
      records = ArPost.where(
        <<~SQL
          title like 'not found' OR
          false = true OR
          title like 'whatever'
        SQL
      ).order(id: :desc)
      def records.to_sql
        raise 'ahihi'
      end
      expect(inspector.singleline(records, line_limit: 150)).to match_row(<<~SPANS)
        #<ArPost::ActiveRecord_Relation:?????????????????? failed to inspect active relation's SQL…> (not loaded)
      SPANS
    }
  end

  context 'with #multiline' do
    let(:line_limit) { 60 }
    let(:first_line_limit) { 80 }

    it {
      record = ArPet.new(name: 'Hana', age: 15)
      expect(
        inspector.multiline(
          record,
          line_limit: line_limit, first_line_limit: first_line_limit, lines: 7
        )
      ).to match_rows(<<~SPANS)
        #<ArPet:??????????????????>
          ▸ id → nil
          ▸ name → "Hana"
          ▸ age → 15
      SPANS
    }

    it {
      klass = Class.new(ArPost) do
        def attributes
          raise 'ahihi'
        end
      end
      expect(
        inspector.multiline(
          klass.new,
          line_limit: line_limit, first_line_limit: first_line_limit, lines: 7
        )
      ).to match_rows(<<~SPANS)
        #<#<Class:??????????????????>:??????????????????>
          ▸ ??? failed to inspect attributes
      SPANS
    }

    it {
      begin
        record1 = ArPost.create(
          title: "What\nis\nRuby\nJard?",
          description: 'Description 1'
        )
        record2 = ArPost.create(
          title: 'Jard is just a normal gem',
          description: 'Description 2'
        )
        records = ArPost.where(id: [record1.id, record2.id]).order(id: :desc)
        expect(
          inspector.multiline(
            records,
            line_limit: line_limit, first_line_limit: first_line_limit, lines: 7
          )
        ).to match_rows(<<~SPANS)
          #<ArPost::ActiveRecord_Relation:?????????????????? "SELECT \\"ar_posts\\".* FROM \\"ar_posts\\" WHERE \\"ar_posts\\".\\"id\\" IN (#{record1.id}, #{record2.id}) ORDER BY \\"ar_posts\\".\\"id\\" DESC"> (not loaded)
        SPANS
      ensure
        record1.destroy!
        record2.destroy!
      end
    }

    it {
      begin
        (1..10).to_a.map do |index|
          ArPost.create!(
            title: "Title #{index}",
            description: "Description #{index}"
          )
        end
        records = ArPost.all.order(id: :desc).load
        expect(
          inspector.multiline(
            records,
            line_limit: 80, first_line_limit: 120, lines: 7
          )
        ).to match_rows(<<~SPANS)
          #<ArPost::ActiveRecord_Relation:??????????????????>
            ▸ #<ArPost:?????????????????? id → #{records[0].id}, title → "Title 10", …>
            ▸ #<ArPost:?????????????????? id → #{records[1].id}, title → "Title 9", …>
            ▸ #<ArPost:?????????????????? id → #{records[2].id}, title → "Title 8", …>
            ▸ #<ArPost:?????????????????? id → #{records[3].id}, title → "Title 7", …>
            ▸ #<ArPost:?????????????????? id → #{records[4].id}, title → "Title 6", …>
            ▸ #<ArPost:?????????????????? id → #{records[5].id}, title → "Title 5", …>
            ▸ 4 more...
        SPANS
      ensure
        ArPost.destroy_all
      end
    }

    it {
      begin
        (1..10).to_a.map do |index|
          ArPost.create!(
            title: "Title #{index}",
            description: "Description #{index}"
          )
        end
        records = ArPost.where('title like "not found"').order(id: :desc).load
        expect(
          inspector.multiline(
            records,
            line_limit: 80, first_line_limit: 120, lines: 7
          )
        ).to match_rows(<<~SPANS)
          #<ArPost::ActiveRecord_Relation:??????????????????> (empty)
        SPANS
      ensure
        ArPost.destroy_all
      end
    }

    it {
      begin
        (1..10).to_a.map do |index|
          ArPost.create!(
            title: "Title #{index}",
            description: "Description #{index}"
          )
        end
        records = ArPost.where(
          <<~SQL
            title like "not found" OR
            title like "another not found" OR
            title like 'whatever'
          SQL
        ).order(id: :desc)
        expect(
          inspector.multiline(
            records,
            line_limit: 80, first_line_limit: 120, lines: 7
          )
        ).to match_rows(<<~SPANS)
          #<ArPost::ActiveRecord_Relation:?????????????????? "SELECT \\"ar_posts\\".* FROM \\"ar_posts\\" WHERE (title like \\"not found\\" OR\\ntitle like \\"another not found\\" OR\\ntitle like 'whatever'\\n) ORDER BY \\"ar_posts\\".\\"id\\" DESC"> (not loaded)
        SPANS
      ensure
        ArPost.destroy_all
      end
    }

    it {
      records = ArPost.where(
        <<~SQL
          title like 'not found' OR
          false = true OR
          title like 'whatever'
        SQL
      ).order(id: :desc)
      def records.to_sql
        raise 'ahihi'
      end
      expect(
        inspector.multiline(
          records,
          line_limit: 80, first_line_limit: 120, lines: 7
        )
      ).to match_rows(<<~SPANS)
        #<ArPost::ActiveRecord_Relation:?????????????????? failed to inspect active relation's SQL…> (not loaded)
      SPANS
    }
  end
end
