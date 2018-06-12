from setuptools import setup
from whatsopt import __version__

setup(name='whatsopt',
      version=__version__,
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
