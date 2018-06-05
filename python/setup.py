from setuptools import setup

setup(name='whatsopt',
      version='0.4.1',
      description='Remote client command line tool',
      url='http://gitlab.com/relf/WhatsOpt',
      author='Remi Lafage',
      author_email='remi.lafage@onera.fr',
      license='Apache 2.0',
      packages=['whatsopt'],
      install_requires=[
          'Click', 'tabulate'
      ],
      entry_points="""
          [console_scripts]
          wop=whatsopt.wop:cli
      """
      )
