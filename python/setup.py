from setuptools import setup

setup(name='whatsopt',
      version='0.1.0',
      description='remote client command line tool',
      url='http://gitlab.com/relf/WhatsOpt',
      author='Remi Lafage',
      author_email='remi.lafage@onera.fr',
      license='Apache 2.0',
      packages=['whatsopt'],
      install_requires=[
          'Click', 'beautifultable'
      ],
      entry_points="""
          [console_scripts]
          wop=whatsopt.wop:cli
      """
      )