require 'test_helper'

class AnalysisDiffTest < ActiveSupport::TestCase

    def setup
        @mda = analyses(:outermda)
        @mda_copy = @mda.create_copy!
        @mda_copy.update(name: @mda_copy.name+" Copy")
        @mda_copy.disciplines.last.destroy
        Variable.of_analysis(@mda_copy).where(name: 'x1').map { |v|
            v.update(name: 'new_x1')
        }
        @mda_copy.reload
    end

    test "should generate diff result between two analysis" do
        result = WhatsOpt::AnalysisDiff.compare(@mda, @mda_copy)  
        expected = "{\n-  \"name\": \"OUTER\",\n+  \"name\": \"OUTER Copy\",\n   \"disciplines\": [\n     {\n       \"name\": \"__DRIVER__\",\n       \"variables\": [\n         {\n-          \"name\": \"x1\",\n+          \"name\": \"new_x1\",\n           \"shape\": \"1\",\n           \"units\": null,\n-          \"role\": \"design_var\"\n+          \"role\": \"parameter\"\n         },\n         {\n           \"name\": \"x2\",\n           \"shape\": \"1\",\n           \"units\": null,\n-          \"role\": \"design_var\"\n+          \"role\": \"parameter\"\n         },\n         {\n           \"name\": \"z\",\n           \"shape\": \"1\",\n           \"units\": null,\n-          \"role\": \"design_var\"\n+          \"role\": \"parameter\"\n         }\n       ]\n     },\n     {\n       \"name\": \"Disc\",\n       \"variables\": [\n         {\n           \"name\": \"y1\",\n           \"shape\": \"1\",\n           \"units\": null,\n           \"role\": \"response\"\n         }\n       ]\n     },\n     {\n       \"name\": \"InnerMdaDiscipline\",\n       \"sub_analysis\": {\n         \"name\": \"INNER\",\n         \"disciplines\": [\n           {\n             \"name\": \"__DRIVER__\",\n             \"variables\": [\n               {\n                 \"name\": \"x2\",\n                 \"shape\": \"1\",\n                 \"units\": null,\n-                \"role\": \"design_var\"\n+                \"role\": \"parameter\"\n               },\n               {\n                 \"name\": \"y1\",\n                 \"shape\": \"1\",\n                 \"units\": null,\n-                \"role\": \"design_var\"\n+                \"role\": \"parameter\"\n               },\n               {\n                 \"name\": \"z\",\n                 \"shape\": \"1\",\n                 \"units\": null,\n-                \"role\": \"design_var\"\n+                \"role\": \"parameter\"\n               }\n             ]\n           },\n           {\n             \"name\": \"PlainDiscipline\",\n             \"variables\": [\n               {\n                 \"name\": \"y\",\n                 \"shape\": \"1\",\n                 \"units\": null,\n                 \"role\": \"response\"\n               },\n               {\n                 \"name\": \"y2\",\n                 \"shape\": \"1\",\n                 \"units\": null,\n                 \"role\": \"response\"\n               }\n             ]\n           }\n         ]\n       }\n-    },\n-    {\n-      \"name\": \"VacantDiscipline\",\n-      \"variables\": [\n-\n-      ]\n     }\n   ]\n }\n"
        assert result.include? expected 
    end

end