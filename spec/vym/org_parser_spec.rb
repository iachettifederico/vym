require 'spec_helper'
require "./lib/vym/org_parser"

module Vym
  RSpec.describe OrgParser do
    context "degenerate cases" do
      it "returns an empty hash if it receives nil" do
        parser = OrgParser.new(nil)

        expect(parser.to_h).to eql({})
      end

      it "returns an empty hash if it receives an empty string" do
        parser = OrgParser.new("  \t \n   ")

        expect(parser.to_h).to eql({})
      end
    end

    context "data" do
      let(:org_text) {
        <<~ORG
          #+TITLE: MAIN CONCEPT


          * Branch 1
          This text shouldn't show up
          ** Branch 1.1

          *** Branch 1.1.1

          This text won't show up

          *** Branch 1.1.2
          ** Branch 1.2

          * Branch 2
          ** Branch 2.1
          ** Branch 2.2
      ORG
      }

      it "extracts the main concept" do
        parser = OrgParser.new(org_text)

        expect(parser.main_concept).to eql("MAIN CONCEPT")
      end

      it "extracts the branches" do
        parser = OrgParser.new(org_text)

        expected = [
                    OrgParser::Branch["Branch 1",     1],
                    OrgParser::Branch["Branch 1.1",   2],
                    OrgParser::Branch["Branch 1.1.1", 3],
                    OrgParser::Branch["Branch 1.1.2", 3],
                    OrgParser::Branch["Branch 1.2",   2],
                    OrgParser::Branch["Branch 2",     1],
                    OrgParser::Branch["Branch 2.1",   2],
                    OrgParser::Branch["Branch 2.2",   2],
                   ]

        expect(parser.branches).to eql(expected)
      end
    end

    context "main concept" do
      it "uses the title as the main concept" do
        parser = OrgParser.new("#+TITLE: MAIN CONCEPT")

        expected = { "MAIN CONCEPT" => [] }

        expect(parser.to_h).to eql(expected)
      end
    end

    context "branches" do
      it "uses sections as branches" do
        org_text = <<~ORG
        #+TITLE: MAIN CONCEPT
        * Branch 1
        ORG

        parser = OrgParser.new(org_text)

        expected = {
                    "MAIN CONCEPT" =>  [
                                        { "Branch 1" => [] }
                                       ]
                   }


        expect(parser.to_h).to eql(expected)
      end

      it "uses sections as branches when there are 2 sections" do
        org_text = <<~ORG
        #+TITLE: MAIN CONCEPT
        * Branch 1
        * Branch 2
        ORG

        parser = OrgParser.new(org_text)

        expected = {
                    "MAIN CONCEPT" => [
                                       { "Branch 1" => [] },
                                       { "Branch 2" => [] },
                                      ]
                   }

        expect(parser.to_h).to eql(expected)
      end

      it "uses subsections as branches" do
        org_text = <<~ORG
        #+TITLE: MAIN CONCEPT
        * Branch 1
        ** Branch 1.1
        ORG

        parser = OrgParser.new(org_text)

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
        org_text = <<~ORG
        #+TITLE: MAIN CONCEPT
        * Branch 1
        ** Branch 1.1
        ** Branch 1.2
        ORG

        parser = OrgParser.new(org_text)

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
        org_text = <<~ORG
        #+TITLE: MAIN CONCEPT
        * Branch 1
        ** Branch 1.1
        *** Branch 1.1.1
        **** Branch 1.1.1.1
        ***** Branch 1.1.1.1.1
        ORG

        parser = OrgParser.new(org_text)

        expected = {"MAIN CONCEPT"=>[{"Branch 1"=>[{"Branch 1.1"=>[{"Branch 1.1.1"=>[{"Branch 1.1.1.1"=>[{"Branch 1.1.1.1.1"=>[]}]}]}]}]}]}

        expect(parser.to_h).to eql(expected)
      end

      it "accepts two consecutive branches at the same level" do
        org_text = <<~ORG
        #+TITLE: MAIN CONCEPT
        * Branch 1
        * Branch 2
        ** Branch 2.1
        ORG

        parser = OrgParser.new(org_text)

        expected = {"MAIN CONCEPT"=>[{"Branch 1"=>[]}, {"Branch 2"=>[{"Branch 2.1"=>[]}]}]}

        expect(parser.to_h).to eql(expected)
      end

      it "unindents one level" do
        org_text = <<~ORG
        #+TITLE: MAIN CONCEPT
        * Branch 1
        ** Branch 1.1
        * Branch 2
        ORG

        parser = OrgParser.new(org_text)

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
        org_text = <<~ORG
        #+TITLE: MAIN CONCEPT
        * Branch 1
        ** Branch 1.1
        *** Branch 1.1.1
        **** Branch 1.1.1.1
        * Branch 2
        ORG

        parser = OrgParser.new(org_text)

        expected = {"MAIN CONCEPT"=>[
                                     {"Branch 1"=>[{"Branch 1.1"=>[{"Branch 1.1.1"=>[{"Branch 1.1.1.1"=>[]}]}]}]},
                                     {"Branch 2"=>[]}]}

        expect(parser.to_h).to eql(expected)
      end

    end
  end
end
