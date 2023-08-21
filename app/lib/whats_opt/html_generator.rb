# frozen_string_literal: true

require "zip"
require "csv"

TEMPLATE = <<HTML
<!doctype html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<style type="text/css">
<%= @xdsm_css %>

.footer {
    font-style: italic;
    font-size: small;
    position: absolute;
    right: 20px;
}
</style>
<script type="text/javascript">
<%= @xdsm_js %>
</script>
<script type="text/javascript">
    document.addEventListener('DOMContentLoaded', () => {
      const mdo = <%= @xdsm_json %>;
      const config = {
        labelizer: {
            ellipsis: 5,
            subSupScript: false,
            showLinkNbOnly: true,
        },
        layout: {
            origin: { x: 50, y: 20 },
            cellsize: { w: 150, h: 50 },
            padding: 10,
        },
        withDefaultDriver: false,
      };
      xdsmjs.XDSMjs(config).createXdsm(mdo);
    });
</script>
</head>
<body>
    <h1><%= @mda.name %></h1>
    <div class="xdsm-toolbar"></div>
    <div class="xdsm2"></div>
    <hr>
    <div class="footer"><%= @footer %></div>
</body>
</html>
HTML

module WhatsOpt
  class HtmlGenerator
    def initialize(mda, url: nil)
      @mda = mda
      @basename = "xdsm"
      @content = ""
      @at = url.nil? ? "" : "@#{url}"
    end

    def generate
      root = "#{File.dirname(__FILE__)}/../../.."
      @xdsm_css = File.open("#{root}/node_modules/xdsmjs/xdsmjs.css").read
      @xdsm_js = File.open("#{root}/node_modules/xdsmjs/dist/xdsmjs.js").read
      @xdsm_json = @mda.to_xdsm_json
      @footer = "XDSM generated from analysis ##{@mda.id}#{@at}, #{Time.now}, ONERA WhatsOpt"
      erb = ERB.new(TEMPLATE, trim_mode: "-")
      @content = erb.result(binding)
      return @content, "#{@basename}.html"
    end
  end
end
