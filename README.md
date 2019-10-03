# WhatsOpt
WhatsOpt is a web application allowing to define and share multi-disciplinary analyses in terms of disciplines and data exchange. It was develop at ONERA, in the context of overall aircraft design activities. From that high-level definition, users can generate source code skeleton required to plug the actual implementation of their disciplines and get an actual executable model of the concept under study. WhatsOpt allows to generate code to run numerical methods such as sensitivity analysis, design of experiments and optimizations.

* [WhatsOpt paper](https://www.researchgate.net/publication/333806928_WhatsOpt_a_web_application_for_multidisciplinary_design_analysis_and_optimization): Lafage, R., Defoort, S., & Lefebvre, T. (2019). _WhatsOpt: a web application for multidisciplinary design analysis and optimization. In AIAA Aviation 2019 Forum (p. 2990)._
* [WhatsOpt doc](https://github.com/OneraHub/WhatsOpt-Doc): Notebooks and examples
* [WhatsOpt videos](https://www.youtube.com/playlist?list=PLhWP4LJdKyGcFZyvsNLU4s2_sdmTSGVeo): Tutorials

# Installation

## Prerequisites
* Ruby 2.5+ (rvm recommended to manage Ruby environments)
* Python 3.6+ (Anaconda recommended to manage Python environments)

## Setup
WhatsOpt rails application setup:
<pre>
  git clone https://github.com/OneraHub/WhatsOpt
  cd WhatsOpt
  bundle install
  rails db:migrate
</pre>
WhatsOpt command line interface setup:
<pre>
  pip install wop
</pre>
The wop package pulls also other Python package dependencies used by WhatsOpt application, specially the [OpenMDAO framework](https://openmdao.org) which is currently the execution framework used by WhatsOpt.

### Development mode
<pre>
  cp config/database.yml.example config/database.yml
  rails s -b 0.0.0.0
</pre>
The you can visit the http://localhost:3000 url and log with the default user login: whatsopt, password: whatsopt.
Otherwise you can run the test suite with
<code>
  rake tests
</code>

### Production
WhatsOpt is deployed on [public server](https://ether.onera.fr/whatsopt)
<code>
</code>  

## Optional setup
* SMT 0.3.4: enable metamodel creation
* SALib 1.3.3: enable sensitivity analysis operations
* Thrift 0.11.0: enable server creation and remote operations on local network
