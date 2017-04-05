require 'spec_helper'
require "./lib/vym/hash_to_xml_map"

module Vym
  RSpec.describe HashToXmlMap do
    context "with an empty hash" do
      Given(:hash) { }
      Given(:expected) {
       <<~XML
        <?xml version="1.0" encoding="utf-8"?>
        <!DOCTYPE vymmap>
        <vymmap version="2.5.0">
          <mapcenter>
          </mapcenter>
        </vymmap>
       XML
      }
      When(:h2x) { HashToXmlMap.new(hash) }
      Then { h2x.render == expected }
    end
    context "with main concept" do
      Given(:hash) { { "MAIN CONCEPT" => []} }
      Given(:expected) {
      <<~XML
        <?xml version="1.0" encoding="utf-8"?>
        <!DOCTYPE vymmap>
        <vymmap version="2.5.0">
          <mapcenter>
            <heading>MAIN CONCEPT</heading>
          </mapcenter>
        </vymmap>
      XML
      }
      When(:h2x) { HashToXmlMap.new(hash) }
      Then { h2x.render == expected }
    end
    
    context "complex map" do
      Given(:hash) { {"NUMBERS"=>[{"1"=>[{"1.1"=>[{"1.1.1"=>[{"1.1.1.1"=>[]}]}]}]},{"2"=>[{"2.1"=>[]}]},{"3"=>[{"3.1"=>[]},{"3.2"=>[]},{"3.3"=>[]},{"3.4"=>[]},{"3.5"=>[]}]}]} }
      Given(:expected) {
      <<~XML
        <?xml version=\"1.0\" encoding=\"utf-8\"?>
        <!DOCTYPE vymmap>
        <vymmap version=\"2.5.0\">
          <mapcenter>
            <heading>NUMBERS</heading>
            <branch>
              <heading>1</heading>
              <branch>
                <heading>1.1</heading>
                <branch>
                  <heading>1.1.1</heading>
                  <branch>
                    <heading>1.1.1.1</heading>
                  </branch>
                </branch>
              </branch>
            </branch>
            <branch>
              <heading>2</heading>
              <branch>
                <heading>2.1</heading>
              </branch>
            </branch>
            <branch>
              <heading>3</heading>
              <branch>
                <heading>3.1</heading>
              </branch>
              <branch>
                <heading>3.2</heading>
              </branch>
              <branch>
                <heading>3.3</heading>
              </branch>
              <branch>
                <heading>3.4</heading>
              </branch>
              <branch>
                <heading>3.5</heading>
              </branch>
            </branch>
          </mapcenter>
        </vymmap>
      XML
      }
      When(:h2x) { HashToXmlMap.new(hash) }
      Then { h2x.render == expected }
    end

    context "with one branch" do
      Given(:hash) { { "MAIN CONCEPT" => [ {"Branch 1" => []} ]} }
      Given(:expected) {
      <<~XML
        <?xml version="1.0" encoding="utf-8"?>
        <!DOCTYPE vymmap>
        <vymmap version="2.5.0">
          <mapcenter>
            <heading>MAIN CONCEPT</heading>
            <branch>
              <heading>Branch 1</heading>
            </branch>
          </mapcenter>
        </vymmap>
      XML
      }
      When(:h2x) { HashToXmlMap.new(hash) }
      Then { h2x.render == expected }
    end
  end
end
