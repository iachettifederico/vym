require "spec_helper"
require "./lib/vym/mind_map"

# integration test
module Vym
  RSpec.describe MindMap do
    Given(:expected) {
      <<~XML
        <?xml version="1.0" encoding="utf-8"?>
        <!DOCTYPE vymmap>
        <vymmap version="2.5.0">
          <mapcenter>
            <heading>MAIN CONCEPT</heading>
            <branch>
              <heading>Branch 1</heading>
              <branch>
                <heading>Branch 1.1</heading>
                <branch>
                  <heading>Branch 1.1.1</heading>
                </branch>
                <branch>
                  <heading>Branch 1.1.2</heading>
                </branch>
              </branch>
              <branch>
                <heading>Branch 1.2</heading>
              </branch>
            </branch>
            <branch>
              <heading>Branch 2</heading>
              <branch>
                <heading>Branch 2.1</heading>
              </branch>
              <branch>
                <heading>Branch 2.2</heading>
              </branch>
            </branch>
          </mapcenter>
        </vymmap>
      XML
    }
    Given(:org_text) {
      <<~ORG
        #+TITLE: MAIN CONCEPT


        * Branch 1
        This text shouldn't show up
        ** Branch 1.1

        *** Branch 1.1.1

        This thext won't show up

        *** Branch 1.1.2
        ** Branch 1.2



        * Branch 2
        ** Branch 2.1
        ** Branch 2.2
      ORG
    }
    Given(:map) { MindMap.from(org_text: org_text) }

    Then { map.xml == expected }
  end
end
