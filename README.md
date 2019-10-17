[![Build Status](https://travis-ci.org/OneraHub/WhatsOpt.svg?branch=master)](https://travis-ci.org/OneraHub/WhatsOpt)
[![Documentation Status](https://readthedocs.org/projects/whatsopt/badge/?version=latest)](https://whatsopt.readthedocs.io/en/latest/?badge=latest)

# WhatsOpt [![WhatsOpt](https://github.com/OneraHub/WhatsOpt/blob/master/app/assets/images/favicon-32.png)](https://github.com/OneraHub/WhatsOpt)
WhatsOpt is a Ruby on Rails web application allowing to define and share multi-disciplinary analyses in terms of disciplines and data exchange. It was developed to support overall vehicle design activities at ONERA. 

From this high-level modeling, users can generate source code skeleton required to plug the actual implementation of their disciplines and get an actual executable model of the vehicle concept under study. Users can also generate code to run numerical methods such as sensitivity analysis, design of experiments, metamodel construction and optimizations.

## User resources
* [WhatsOpt paper](https://www.researchgate.net/publication/333806928_WhatsOpt_a_web_application_for_multidisciplinary_design_analysis_and_optimization): WhatsOpt: a web application for multidisciplinary design analysis and optimization.
* [WhatsOpt doc](https://github.com/OneraHub/WhatsOpt-Doc): Notebooks and examples
* [WhatsOpt videos](https://www.youtube.com/playlist?list=PLhWP4LJdKyGcFZyvsNLU4s2_sdmTSGVeo): Tutorials

## Citation
If you happen to find WhatsOpt useful for your research, it will be appreciated if you cite us with:
>Lafage, R., Defoort, S., & Lefebvre, T. (2019). _WhatsOpt: a web application for multidisciplinary design analysis and optimization. In AIAA Aviation 2019 Forum (p. 2990)._

or if you use Bibtex, you can use the following entry:
<pre>
@inproceedings{lafage2019whatsopt,
  title={WhatsOpt: a web application for multidisciplinary design analysis and optimization},
  doi={10.2514/6.2019-2990}, 
  url={https://doi.org/10.2514/6.2019-2990}
  author={Lafage, R{\'e}mi and Defoort, Sebastien and Lefebvre, Thierry},
  booktitle={AIAA Aviation 2019 Forum},
  pages={2990},
  year={2019}
}
</pre>

# Installation

## Prerequisites
* Ruby 2.5+ ([rvm](https://rvm.io/) recommended to manage Ruby environments)
* Python 3.6+ ([Anaconda](https://www.anaconda.com/distribution/) recommended to manage Python environments)
* Node.js 8.16.0+
* Yarn 1.x+

## Setup
WhatsOpt rails application setup:
<pre>
  git clone https://github.com/OneraHub/WhatsOpt
</pre>
WhatsOpt command line interface setup, namely wop:
<pre>
  pip install wop
</pre>
The <code>wop</code> package pulls also Python dependencies used by WhatsOpt application, specially the [OpenMDAO framework](https://openmdao.org) which is currently the execution framework used by WhatsOpt. 

Though not stricly required to run WhatsOpt, some features relies also on the following Python packages :
* [SMT](https://smt.readthedocs.io/): enable design of experiments and metamodels creation
* [SALib](https://salib.readthedocs.io/): enable sensitivity analysis operations
* [Apache Thrift](https://thrift.apache.org/): enable server creation and remote operations on local network
<pre>
  pip install smt==0.3.4 salib==1.3.3 thrift==0.11.0
</pre>

To enable server code generation, you will have to install Apache Thrift compiler as well.

### Development setup
This is the typical development mode of a Rails application, it is simpler to install than a typical production server (with a full-blown web server and database engine). It will allow you to get started with WhatsOpt in your local environment.    

<pre>
  cd WhatsOpt
  bundle install
  cp config/configuration.yml.example config/configuration.yml
  cp config/database.yml.example config/database.yml
  rails db:migrate
  rails db:seed
  rails s -b 0.0.0.0
</pre>

Then you can visit the http://localhost:3000 url and log in with the default user login/passwd: whatsopt/whatsopt!

You can also run tests with:

<pre>
  rails test
</pre>

### Production setup
Ruby on Rails ecosystem allows various options for application server configuration and deployment. Refer to related Ruby on Rails documentation to know your deployment options.

The guide lines summarized below are related to the deployment of WhatsOpt on [ONERA server](https://ether.onera.fr/whatsopt). It relies on:
* Apache Server
* Passenger (aka module for rails)
* MySQL

Once those prerequisites are installed on your server, you have to fit:
* <code>config/environments/configuration.yml</code>
* <code>config/environments/database.yml</code>
* <code>config/environments/production.rb</code>
* <code>config/environments/ldap.yml</code> (if needed) 

For deployment in production capistrano utility is used, you have to fit to your needs the following files:
* <code>config/deploy.rb</code>
* <code>config/deploy/production.rb</code>

then the deployment is one command line away:
<pre>
  cap production deploy
</pre>

## Contributing
> Disclaimer: WhatsOpt is still in an early stage as an open source project. Hopefully code and documentation will improve over time to help you get over the hurdles of development environment installation and allow proper contributions to the project.  

Any feedback, questions, bug report or code contribution is welcome. 

For bug reports or questions, you may file it in the issue tab of this repository.
For code contribution, you have use the _fork and pull request_ mechanism. See [GitHub documentation on this topic]:https://help.github.com/en/articles/about-forks

## Contact

WhatsOpt was created by Rémi Lafage for and thanks to the _MDO and Integrated Concepts_ team at [ONERA, the French Aerospace Lab](https://www.onera.fr/en). 

Contact: remi [dot] lafage [at] onera [dot] fr
