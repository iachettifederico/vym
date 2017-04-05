require 'spec_helper'
require "./lib/vym/yaml_parser"

module Vym
  RSpec.describe YamlParser do
    context "degenerate cases" do
      it "returns an empty hash if it receives nil" do
        parser = YamlParser.new(nil)

        expect(parser.to_h).to eql({})
      end

      it "returns an empty hash if it receives an empty string" do
        parser = YamlParser.new("  \t \n   ")

        expect(parser.to_h).to eql({})
      end
    end

    context "data" do
      let(:yaml_text) {
        <<~YAML
          ---
          - MAIN CONCEPT:


            - Branch 1:
              - Branch 1.1:

                - Branch 1.1.1:


                - Branch 1.1.2:
              - Branch 1.2:

            - Branch 2:
              - Branch 2.1:
              - Branch 2.2:
      YAML
      }

      it "extracts the main concept" do
        parser = YamlParser.new(yaml_text)

        expect(parser.main_concept).to eql("MAIN CONCEPT")
      end

      it "extracts the branches" do
        parser = YamlParser.new(yaml_text)

        expected = [
          YamlParser::Branch["Branch 1",     1],
          YamlParser::Branch["Branch 1.1",   2],
          YamlParser::Branch["Branch 1.1.1", 3],
          YamlParser::Branch["Branch 1.1.2", 3],
          YamlParser::Branch["Branch 1.2",   2],
          YamlParser::Branch["Branch 2",     1],
          YamlParser::Branch["Branch 2.1",   2],
          YamlParser::Branch["Branch 2.2",   2],
        ]

        expect(parser.branches).to eql(expected)
      end
    end

    context "main concept" do
      it "uses the title as the main concept" do
        parser = YamlParser.new("---\n- MAIN CONCEPT:")

        expected = { "MAIN CONCEPT" => [] }

        expect(parser.to_h).to eql(expected)
      end
    end

    context "branches" do
      it "uses sections as branches" do
        yaml_text = <<~YAML
          ---
          - MAIN CONCEPT:
            - Branch 1
        YAML

        parser = YamlParser.new(yaml_text)

        expected = {
          "MAIN CONCEPT" =>  [
            { "Branch 1" => [] }
          ]
        }

        expect(parser.to_h).to eql(expected)
      end

      it "uses sections as branches when there are 2 sections" do
        yaml_text = <<~YAML
          ---
          - MAIN CONCEPT:
            - Branch 1:
            - Branch 2:
        YAML

        parser = YamlParser.new(yaml_text)

        expected = {
          "MAIN CONCEPT" => [
            { "Branch 1" => [] },
            { "Branch 2" => [] },
          ]
        }

        expect(parser.to_h).to eql(expected)
      end

      it "uses subsections as branches" do
        yaml_text = <<~YAML
          ---
          - MAIN CONCEPT:
            - Branch 1
              - Branch 1.1
        YAML

        parser = YamlParser.new(yaml_text)

        expected = {
          "MAIN CONCEPT" => [
            { "Branch 1" => [
              { "Branch 1.1" => [] },
            ] },
          ]
        }

        expect(parser.to_h).to eql(expected)
      end

      it "uses subsections as branches when there are 2 subsections" do
        yaml_text = <<~YAML
          ---
          - MAIN CONCEPT:
            - Branch 1
              - Branch 1.1
              - Branch 1.2
        YAML

        parser = YamlParser.new(yaml_text)

        expected = {
          "MAIN CONCEPT" => [
            { "Branch 1" => [
              { "Branch 1.1" => [] },
              { "Branch 1.2" => [] },
            ] },
          ]
        }

        expect(parser.to_h).to eql(expected)
      end

      it "can go deep" do
        yaml_text = <<~YAML
        ---
        - MAIN CONCEPT:
          - Branch 1
            - Branch 1.1
              - Branch 1.1.1
                - Branch 1.1.1.1
                  - Branch 1.1.1.1.1
        YAML

        parser = YamlParser.new(yaml_text)

        expected = {"MAIN CONCEPT"=>[
          {
            "Branch 1"=>[
              {
                "Branch 1.1"=>[
                  {
                    "Branch 1.1.1"=>[
                      {
                        "Branch 1.1.1.1"=>[
                          {
                            "Branch 1.1.1.1.1"=>[]
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
        }

        expect(parser.to_h).to eql(expected)
      end

      it "accepts two consecutive branches at the same level" do
        yaml_text = <<~YAML
          ---
          - MAIN CONCEPT:
            - Branch 1
            - Branch 2:
              - Branch 2.1
        YAML

        parser = YamlParser.new(yaml_text)

        expected = {"MAIN CONCEPT"=>[{"Branch 1"=>[]}, {"Branch 2"=>[{"Branch 2.1"=>[]}]}]}

        expect(parser.to_h).to eql(expected)
      end

      it "unindents one level" do
        yaml_text = <<~YAML
        ---
        - MAIN CONCEPT:
          - Branch 1
            - Branch 1.1
          - Branch 2
        YAML

        parser = YamlParser.new(yaml_text)

        expected = {
          "MAIN CONCEPT" => [
            {
              "Branch 1" => [
                { "Branch 1.1" => [] },
              ]
            },
            { "Branch 2" => [] },
          ]
        }

        expect(parser.to_h).to eql(expected)
      end

      it "unindents several levels" do
        yaml_text = <<~YAML
          ---
          - MAIN CONCEPT:
            - Branch 1
              - Branch 1.1
                - Branch 1.1.1
                  - Branch 1.1.1.1
            - Branch 2
        YAML

        parser = YamlParser.new(yaml_text)

        expected = {"MAIN CONCEPT"=>[
          {"Branch 1"=>[{"Branch 1.1"=>[{"Branch 1.1.1"=>[{"Branch 1.1.1.1"=>[]}]}]}]},
          {"Branch 2"=>[]}]}

        expect(parser.to_h).to eql(expected)
      end

    end
  end
end
